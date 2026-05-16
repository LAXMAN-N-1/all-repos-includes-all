import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:customer_app/core/services/cart_service.dart';

class AIService extends ChangeNotifier {
  final CartService cart;
  AIService({required this.cart});
  
  // Use 192.168.1.11 for physical
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.11:8001/api/v1/ai',
    connectTimeout: const Duration(seconds: 10),
  ));
  
  // ... rest of fields

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool get isListening => _isListening;
  
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;
  
  int? _conversationId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _currentLanguage = 'en'; // Default
  String get currentLanguage => _currentLanguage;
  
  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    
    // Check availability
    if (_systemLocales.isNotEmpty) {
        bool hasLang = _systemLocales.any((l) => l.localeId.startsWith(langCode));
        if (!hasLang) {
            debugPrint("Language $langCode not found on device.");
            await _speak("Selected language is not installed on this device. Please enable it in settings.");
        }
    }
    
    notifyListeners();
  }

  List<LocaleName> _systemLocales = [];

  // Initialize Speech & TTS
  Future<bool> initSpeech() async {
    bool available = await _speech.initialize(
      onError: (val) => debugPrint('STT Error: $val'),
      onStatus: (val) => debugPrint('STT Status: $val'),
    );
    if (available) {
      _systemLocales = await _speech.locales();
      debugPrint('Available Locales: ${_systemLocales.map((e) => e.localeId).join(', ')}');
    }
    return available;
  }

  int _retryCount = 0;

  Future<void> startListening(Function(String) onResult) async {
    try {
        // ... (Circuit Breaker logic same as before) ...
        if (_retryCount > 3) {
             debugPrint("Microphone Circuit Broken. Manual restart required.");
             _isListening = false;
             notifyListeners();
             return;
        }

        // Ensure clean slate
        await _flutterTts.stop();
        if (_speech.isListening) {
             await _speech.stop();
        }
        
        bool available = await initSpeech();
        if (available) {
          _isListening = true;
          _retryCount = 0; 
          notifyListeners();
          
          // DYNAMIC LOCALE SELECTION
          String localeId = _getBestMatchLocale(_currentLanguage);
          debugPrint("Selected Locale for STT: $localeId");
          
          await _speech.listen(
            onResult: (result) {
              onResult(result.recognizedWords);
              if (result.finalResult) {
                   stopListeningAndSend(result.recognizedWords);
              }
            },
            localeId: localeId,
            listenFor: const Duration(seconds: 10), 
            pauseFor: const Duration(seconds: 2), 
            partialResults: true,
            cancelOnError: true,
            listenMode: ListenMode.dictation
          );
        } else {
            debugPrint("Speech recognition denied.");
            _isListening = false;
            notifyListeners();
        }
    } catch (e) {
        debugPrint("StartListening Error (Attempt $_retryCount): $e");
        _retryCount++;
        _isListening = false;
        notifyListeners();
        
        if (_retryCount <= 3) {
             await Future.delayed(const Duration(seconds: 2));
             if (!_isListening) { 
                 startListening(onResult);
             }
        }
    }
  }

  String _getBestMatchLocale(String code) {
      if (_systemLocales.isEmpty) return 'en_US';
      
      // Try exact match first (e.g. 'te' -> 'te_IN' or 'te-IN')
      try {
          var match = _systemLocales.firstWhere((l) => l.localeId.startsWith(code));
          return match.localeId;
      } catch (e) {
          debugPrint("No locale found for $code, falling back to English");
          return 'en_US';
      }
  }

  Future<void> stopListening() async {
    _isListening = false;
    notifyListeners();
    await _speech.stop();
  }

  Future<void> stopListeningAndSend(String text) async {
    // Only send if not empty
    if (text.trim().isEmpty) return;
    
    await _speech.stop(); 
    _isListening = false; 
    notifyListeners();
    
    await sendMessage(text);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add({"role": "user", "content": text});
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id') ?? "1"; 

      final response = await _dio.post('/chat', data: {
        "message": text,
        "conversation_id": _conversationId,
        "user_id": int.tryParse(userId),
        "language": _currentLanguage 
      });

      final data = response.data;
      _conversationId = data['conversation_id'];
      String reply = data['response_text'];
      String intent = data['detected_intent'] ?? '';
      
      // Handle Cart Action
      if (intent == 'ADD_TO_CART') {
          List recs = data['recommendations'] ?? [];
          for (var item in recs) {
              // Mock price 50 if missing
              cart.addItem(item['product_name'] ?? 'Medicine', 50.0);
          }
      }
      
      _messages.add({
        "role": "ai", 
        "content": reply,
        "recommendations": data['recommendations'],
        "actions": data['suggested_actions']
      });
      
      // Speak the reply
      await _speak(reply);
      
      // Auto-Resume Listening (Active Mode) with Delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (!_isListening) {
          try {
              await startListening((text) {
                  // We rely on stopListeningAndSend triggered by finalResult/silence
              });
          } catch (e) {
              debugPrint("Auto-restart failed: $e");
              // Don't crash, just let user tap mic
          }
      }

    } catch (e) {
      debugPrint("AI Logic Error: $e");
      _messages.add({"role": "ai", "content": "Error: $e"});
      // Only speak if it's not a silence timeout
      await _speak("Sorry, I faced an error."); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _speak(String text) async {
     await _flutterTts.setLanguage(_getBestMatchLocale(_currentLanguage));
     await _flutterTts.setPitch(1.0);
     await _flutterTts.awaitSpeakCompletion(true); // Wait for finish
     await _flutterTts.speak(text); 
  }

  void clearChat() {
    _messages.clear();
    _conversationId = null;
    notifyListeners();
  }
}
