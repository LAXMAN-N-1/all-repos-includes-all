import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/core/services/cart_service.dart';

class AIService extends ChangeNotifier {
  final CartService cart;
  AIService({required this.cart});
  
  // Use 192.168.1.11 for physical
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.11:8001/api/v1/ai',
    connectTimeout: const Duration(seconds: 20), // Increased for audio upload
  ));
  
  final AudioRecorder _audioRecorder = AudioRecorder();
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
    notifyListeners();
  }

  // Initialize (Clean up mainly)
  Future<void> initSpeech() async {
    // Permission check upfront
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    try {
        if (await _audioRecorder.hasPermission()) {
          final directory = await getApplicationDocumentsDirectory();
          final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          
          await _flutterTts.stop(); // Stop speaking if any
          
          const config = RecordConfig(encoder: AudioEncoder.aacLc);
          
          await _audioRecorder.start(config, path: path);
          
          _isListening = true;
          notifyListeners();
          debugPrint("Started Recording to $path");
        } else {
             debugPrint("Microphone permission denied.");
             _isListening = false;
             notifyListeners();
        }
    } catch (e) {
        debugPrint("StartRecording Error: $e");
        _isListening = false;
        notifyListeners();
    }
  }

  // We don't really use onResult stream anymore, we wait for stop
  Future<void> stopListeningAndSend(String ignoredText) async {
     await stopListening();
  }
  
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      final path = await _audioRecorder.stop();
      _isListening = false;
      notifyListeners();
      
      if (path != null) {
          debugPrint("Recording stopped. File at: $path");
          await sendAudioMessage(path);
      }
    } catch (e) {
      debugPrint("StopRecording Error: $e");
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> sendAudioMessage(String filePath) async {
    _messages.add({"role": "user", "content": "🎤 Audio Message..."});
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id') ?? "1"; 

      // Prepare FormData
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(filePath, filename: fileName),
        "user_id": userId,
        "language": _currentLanguage,
        "conversation_id": _conversationId ?? "",
      });

      final response = await _dio.post('/chat-audio', data: formData);

      _handleResponse(response.data);

    } catch (e) {
      debugPrint("AI Audio Error: $e");
      _messages.add({"role": "ai", "content": "Error sending audio: $e"});
      await _speak("Sorry, I couldn't process your audio."); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Text Message Fallback
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

      _handleResponse(response.data);

    } catch (e) {
      debugPrint("AI Text Error: $e");
      _messages.add({"role": "ai", "content": "Error: $e"});
      await _speak("Sorry, I faced an error."); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleResponse(Map<String, dynamic> data) async {
      _conversationId = data['conversation_id'];
      String reply = data['response_text'];
      String intent = data['detected_intent'] ?? '';
      
      // Handle Cart Action
      if (intent == 'ADD_TO_CART') {
          List recs = data['recommendations'] ?? [];
          for (var item in recs) {
              cart.addItem(item['product_name'] ?? 'Medicine', 50.0);
          }
      }
      
      // Update UI (replace audio holder with actual text?) 
      // OR just add the AI reply. 
      // Ideally we'd update the user message content if the backend returned the transcribed text, 
      // but standard ChatResponse only has response_text.
      // We will just append the AI response.
      
      _messages.add({
        "role": "ai", 
        "content": reply,
        "recommendations": data['recommendations'],
        "actions": data['suggested_actions']
      });
      
      // Speak the reply
      await _speak(reply);
  }
  
  Future<void> _speak(String text) async {
     // TTS setup can remain simple or use language code
     // Note: _getBestMatchLocale logic is less critical for TTS usually, but good to keep if valid
     // For now just setting language code directly as simple fallback
     await _flutterTts.setLanguage(_currentLanguage == 'te' ? 'te-IN' : 'en-US'); 
     await _flutterTts.setPitch(1.0);
     await _flutterTts.awaitSpeakCompletion(true); 
     await _flutterTts.speak(text);
  }

  void clearChat() {
    _messages.clear();
    _conversationId = null;
    notifyListeners();
  }
}
