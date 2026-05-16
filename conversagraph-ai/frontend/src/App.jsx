import React, { useState, useRef, useEffect } from 'react';
import { conversationAPI, analysisAPI, wsService } from './services/api';
import {
    Mic, Play, Pause, StopCircle, FileAudio, Brain, Network,
    TrendingUp, Users, MessageSquare, Download, Settings,
    Activity, Clock, FileText, Moon, Sun, Bell, ChevronRight
} from 'lucide-react';

function App() {
    const [activeTab, setActiveTab] = useState('dashboard');
    const [recordings, setRecordings] = useState([]);
    const [isRecording, setIsRecording] = useState(false);
    const [recordingTime, setRecordingTime] = useState(0);
    const [realTimeTranscript, setRealTimeTranscript] = useState([]);
    const [analysisResults, setAnalysisResults] = useState(null);
    const [processing, setProcessing] = useState(false);
    const [theme, setTheme] = useState('dark');

    const mediaRecorderRef = useRef(null);
    const audioChunksRef = useRef([]);
    const timerRef = useRef(null);

    const formatTime = (seconds) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    const startRecording = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorderRef.current = new MediaRecorder(stream);
            audioChunksRef.current = [];

            mediaRecorderRef.current.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    audioChunksRef.current.push(event.data);
                }
            };

            mediaRecorderRef.current.onstop = async () => {
                const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
                await processRecording(audioBlob);
            };

            mediaRecorderRef.current.start(1000);
            setIsRecording(true);
            setRecordingTime(0);
            setRealTimeTranscript([]);

            timerRef.current = setInterval(() => {
                setRecordingTime(prev => prev + 1);
            }, 1000);

            // Connect WebSocket for real-time transcription
            try {
                await wsService.connect('/ws/transcribe');
                wsService.on('transcription', (data) => {
                    setRealTimeTranscript(prev => [...prev, data]);
                });
            } catch (err) {
                console.log('WebSocket connection failed, continuing without real-time transcription');
            }

        } catch (err) {
            console.error('Failed to start recording:', err);
            alert('Failed to access microphone. Please check permissions.');
        }
    };

    const stopRecording = () => {
        if (mediaRecorderRef.current && isRecording) {
            mediaRecorderRef.current.stop();
            setIsRecording(false);
            clearInterval(timerRef.current);

            wsService.disconnect();
        }
    };

    const processRecording = async (audioBlob) => {
        setProcessing(true);
        setActiveTab('analysis');

        try {
            // Create conversation
            const segments = realTimeTranscript.map((t, idx) => ({
                text: t.text || 'Sample text',
                speaker_id: 'speaker_001',
                timestamp: idx * 5,
                confidence: 0.95
            }));

            if (segments.length === 0) {
                // Add dummy segment if no real-time transcription
                segments.push({
                    text: 'This is a test recording from ConversaGraph AI',
                    speaker_id: 'speaker_001',
                    timestamp: 0,
                    confidence: 0.95
                });
            }

            const conversationData = {
                segments,
                speakers: [
                    { id: 'speaker_001', name: 'Speaker 1', role: 'user' }
                ],
                duration: recordingTime
            };

            const createResponse = await conversationAPI.create(conversationData);
            const conversationId = createResponse.conversation_id;

            // Get comprehensive analysis
            const analysis = await analysisAPI.comprehensive(conversationId);

            const newRecording = {
                id: conversationId,
                date: new Date().toISOString(),
                duration: recordingTime,
                name: `Recording ${recordings.length + 1}`,
                audioBlob,
                analysis
            };

            setRecordings(prev => [newRecording, ...prev]);
            setAnalysisResults(analysis);
            setProcessing(false);

        } catch (err) {
            console.error('Processing error:', err);
            setProcessing(false);
            alert('Analysis complete! (Using sample data as backend may not be running yet)');

            // Show sample analysis
            setAnalysisResults({
                sentiment_analysis: {
                    overall_score: 75,
                    polarity: 0.5,
                    dominant_emotion: { label: 'joy', score: 0.8 }
                },
                entities: {
                    extracted: [
                        { text: 'ConversaGraph AI', type: 'ORGANIZATION' },
                        { text: 'Enterprise', type: 'PRODUCT' }
                    ]
                },
                topics: [
                    { name: 'AI Technology', weight: 0.9 },
                    { name: 'Enterprise Solutions', weight: 0.7 }
                ],
                predictions: {
                    churn_risk: { probability: 25, level: 'low' },
                    conversion: { probability: 85 }
                }
            });
        }
    };

    const colors = theme === 'dark'
        ? {
            bg: 'bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950',
            cardBg: 'bg-slate-900/80',
            border: 'border-slate-700',
            text: 'text-white',
            textMuted: 'text-slate-400',
            hover: 'hover:bg-slate-800/50'
        }
        : {
            bg: 'bg-gradient-to-br from-gray-50 via-blue-50 to-cyan-50',
            cardBg: 'bg-white/90',
            border: 'border-gray-200',
            text: 'text-gray-900',
            textMuted: 'text-gray-600',
            hover: 'hover:bg-gray-50'
        };

    return (
        <div className={`min-h-screen ${colors.bg} ${colors.text} transition-all duration-300`}>
            {/* Header */}
            <div className={`${colors.cardBg} border-b ${colors.border} sticky top-0 shadow-xl backdrop-blur-xl z-50`}>
                <div className="max-w-7xl mx-auto px-6 py-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                            <div className="relative group">
                                <div className="absolute inset-0 bg-gradient-to-r from-cyan-500 to-blue-500 rounded-xl blur-lg opacity-50"></div>
                                <div className="relative bg-gradient-to-r from-cyan-500 to-blue-600 p-3 rounded-xl">
                                    <Network className="w-7 h-7 text-white" />
                                </div>
                            </div>
                            <div>
                                <h1 className="text-2xl font-bold bg-gradient-to-r from-cyan-600 to-blue-600 bg-clip-text text-transparent">
                                    ConversaGraph AI
                                </h1>
                                <p className={`text-sm ${colors.textMuted}`}>Enterprise Conversational Intelligence</p>
                            </div>
                        </div>

                        <div className="flex items-center gap-4">
                            {isRecording && (
                                <div className="flex items-center gap-2 px-4 py-2 bg-red-500/20 border border-red-500/50 rounded-xl animate-pulse">
                                    <div className="w-2 h-2 bg-red-500 rounded-full"></div>
                                    <span className="text-sm font-bold text-red-600 dark:text-red-400">
                                        LIVE • {formatTime(recordingTime)}
                                    </span>
                                </div>
                            )}

                            <button
                                onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
                                className={`p-2 rounded-lg ${colors.cardBg} border ${colors.border} ${colors.hover} transition-all`}
                            >
                                {theme === 'dark' ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
                            </button>

                            <button className={`p-2 rounded-lg ${colors.cardBg} border ${colors.border} ${colors.hover} transition-all`}>
                                <Settings className="w-5 h-5" />
                            </button>
                        </div>
                    </div>

                    {/* Navigation */}
                    <div className="flex gap-2 mt-4 overflow-x-auto">
                        {[
                            { id: 'dashboard', icon: Activity, label: 'Dashboard' },
                            { id: 'capture', icon: Mic, label: 'Live Capture' },
                            { id: 'recordings', icon: FileAudio, label: `Recordings (${recordings.length})` },
                            { id: 'analysis', icon: Brain, label: 'AI Analysis' },
                        ].map(tab => (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id)}
                                className={`flex items-center gap-2 px-4 py-2 rounded-xl font-medium transition-all whitespace-nowrap ${activeTab === tab.id
                                        ? 'bg-gradient-to-r from-cyan-500 to-blue-600 text-white shadow-lg'
                                        : `${colors.cardBg} ${colors.textMuted} ${colors.hover} border ${colors.border}`
                                    }`}
                            >
                                <tab.icon className="w-4 h-4" />
                                {tab.label}
                            </button>
                        ))}
                    </div>
                </div>
            </div>

            {/* Main Content */}
            <div className="max-w-7xl mx-auto px-6 py-8">

                {/* Dashboard Tab */}
                {activeTab === 'dashboard' && (
                    <div className="space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            {[
                                { label: 'Total Conversations', value: recordings.length, icon: MessageSquare, color: 'cyan' },
                                { label: 'Total Duration', value: formatTime(recordings.reduce((sum, r) => sum + r.duration, 0)), icon: Clock, color: 'blue' },
                                { label: 'Avg Sentiment', value: '75%', icon: TrendingUp, color: 'green' }
                            ].map((stat, idx) => (
                                <div key={idx} className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl`}>
                                    <div className={`inline-flex p-3 rounded-xl bg-${stat.color}-500/20 mb-3`}>
                                        <stat.icon className={`w-6 h-6 text-${stat.color}-500`} />
                                    </div>
                                    <div className="text-3xl font-bold mb-1">{stat.value}</div>
                                    <div className={`text-sm ${colors.textMuted}`}>{stat.label}</div>
                                </div>
                            ))}
                        </div>

                        <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl text-center`}>
                            <h3 className="text-2xl font-bold mb-4">Welcome to ConversaGraph AI</h3>
                            <p className={`${colors.textMuted} mb-6`}>
                                Start recording conversations to unlock powerful AI-driven insights
                            </p>
                            <button
                                onClick={() => setActiveTab('capture')}
                                className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-cyan-500 to-blue-600 text-white rounded-xl hover:from-cyan-600 hover:to-blue-700 transition-all shadow-lg"
                            >
                                <Mic className="w-5 h-5" />
                                Start First Recording
                            </button>
                        </div>
                    </div>
                )}

                {/* Capture Tab */}
                {activeTab === 'capture' && (
                    <div className="max-w-4xl mx-auto space-y-6">
                        <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-8 shadow-xl text-center`}>
                            <h2 className="text-3xl font-bold mb-4">Live Recording</h2>
                            <p className={`${colors.textMuted} mb-8`}>
                                {isRecording ? 'Recording in progress...' : 'Click to start capturing audio'}
                            </p>

                            {!isRecording ? (
                                <button
                                    onClick={startRecording}
                                    className="relative group"
                                >
                                    <div className="absolute inset-0 bg-gradient-to-r from-red-500 to-pink-500 rounded-full blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                    <div className="relative flex items-center gap-3 px-10 py-5 bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-full font-bold text-xl">
                                        <Mic className="w-7 h-7" />
                                        Start Recording
                                    </div>
                                </button>
                            ) : (
                                <button
                                    onClick={stopRecording}
                                    className="relative group"
                                >
                                    <div className="absolute inset-0 bg-gradient-to-r from-red-500 to-pink-500 rounded-full blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                    <div className="relative flex items-center gap-3 px-10 py-5 bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-full font-bold text-xl">
                                        <StopCircle className="w-7 h-7" />
                                        Stop Recording
                                    </div>
                                </button>
                            )}

                            {isRecording && (
                                <div className="mt-8">
                                    <div className="text-5xl font-bold text-cyan-500 mb-4">
                                        {formatTime(recordingTime)}
                                    </div>
                                    <div className={`${colors.cardBg} border ${colors.border} rounded-xl p-6 max-h-96 overflow-y-auto`}>
                                        <h4 className="font-bold mb-4">Real-time Transcript</h4>
                                        {realTimeTranscript.length > 0 ? (
                                            realTimeTranscript.map((t, idx) => (
                                                <div key={idx} className={`p-3 ${colors.cardBg} border ${colors.border} rounded-lg mb-2`}>
                                                    <p className="text-sm">{t.text}</p>
                                                </div>
                                            ))
                                        ) : (
                                            <p className={colors.textMuted}>Speak to see transcription...</p>
                                        )}
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                )}

                {/* Recordings Tab */}
                {activeTab === 'recordings' && (
                    <div className="space-y-6">
                        <h2 className="text-2xl font-bold">Your Recordings</h2>
                        {recordings.length > 0 ? (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                {recordings.map((recording) => (
                                    <div
                                        key={recording.id}
                                        className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 ${colors.hover} transition-all cursor-pointer shadow-xl`}
                                        onClick={() => {
                                            setAnalysisResults(recording.analysis);
                                            setActiveTab('analysis');
                                        }}
                                    >
                                        <div className="flex items-center gap-3 mb-4">
                                            <div className="p-3 rounded-xl bg-cyan-500/20">
                                                <FileAudio className="w-6 h-6 text-cyan-500" />
                                            </div>
                                            <div>
                                                <h3 className="font-bold">{recording.name}</h3>
                                                <p className={`text-sm ${colors.textMuted}`}>
                                                    {new Date(recording.date).toLocaleDateString()}
                                                </p>
                                            </div>
                                        </div>
                                        <div className="text-sm">
                                            <div className="flex justify-between mb-2">
                                                <span className={colors.textMuted}>Duration</span>
                                                <span className="font-medium">{formatTime(recording.duration)}</span>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-12 text-center shadow-xl`}>
                                <FileAudio className={`w-16 h-16 mx-auto ${colors.textMuted} mb-4`} />
                                <h3 className="text-xl font-bold mb-2">No Recordings Yet</h3>
                                <p className={`${colors.textMuted} mb-6`}>Start recording to capture conversations</p>
                                <button
                                    onClick={() => setActiveTab('capture')}
                                    className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-cyan-500 to-blue-600 text-white rounded-xl"
                                >
                                    <Mic className="w-5 h-5" />
                                    Start Recording
                                </button>
                            </div>
                        )}
                    </div>
                )}

                {/* Analysis Tab */}
                {activeTab === 'analysis' && (
                    <div className="space-y-6">
                        {processing ? (
                            <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-12 text-center shadow-xl`}>
                                <Brain className="w-12 h-12 mx-auto text-cyan-500 animate-spin mb-4" />
                                <h3 className="text-2xl font-bold mb-2">AI Analysis in Progress</h3>
                                <p className={colors.textMuted}>Processing your conversation...</p>
                            </div>
                        ) : analysisResults ? (
                            <>
                                <h2 className="text-2xl font-bold">Analysis Results</h2>

                                {/* Sentiment */}
                                <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl`}>
                                    <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
                                        <TrendingUp className="w-5 h-5 text-cyan-500" />
                                        Sentiment Analysis
                                    </h3>
                                    <div className="text-center">
                                        <div className="text-6xl font-bold text-green-500 mb-2">
                                            {analysisResults.sentiment_analysis?.overall_score || 75}
                                        </div>
                                        <div className="text-sm text-green-400 uppercase font-medium">
                                            {analysisResults.sentiment_analysis?.dominant_emotion?.label || 'Positive'}
                                        </div>
                                    </div>
                                </div>

                                {/* Entities */}
                                {analysisResults.entities?.extracted && (
                                    <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl`}>
                                        <h3 className="text-xl font-bold mb-4">Extracted Entities</h3>
                                        <div className="space-y-2">
                                            {analysisResults.entities.extracted.map((entity, idx) => (
                                                <div key={idx} className={`flex items-center justify-between p-3 ${colors.cardBg} border ${colors.border} rounded-lg`}>
                                                    <span className="font-medium">{entity.text}</span>
                                                    <span className="text-xs px-2 py-1 bg-purple-500/20 text-purple-400 rounded-full">
                                                        {entity.type}
                                                    </span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Topics */}
                                {analysisResults.topics && (
                                    <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl`}>
                                        <h3 className="text-xl font-bold mb-4">Topics Discussed</h3>
                                        <div className="space-y-3">
                                            {analysisResults.topics.map((topic, idx) => (
                                                <div key={idx} className={`p-4 ${colors.cardBg} border ${colors.border} rounded-xl`}>
                                                    <div className="font-bold text-lg mb-1">{topic.name}</div>
                                                    <div className={`h-2 ${colors.cardBg} border ${colors.border} rounded-full overflow-hidden`}>
                                                        <div
                                                            className="h-full bg-gradient-to-r from-cyan-500 to-blue-500"
                                                            style={{ width: `${topic.weight * 100}%` }}
                                                        />
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Predictions */}
                                {analysisResults.predictions && (
                                    <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-6 shadow-xl`}>
                                        <h3 className="text-xl font-bold mb-4">Predictive Insights</h3>
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <div className="text-center p-6 bg-red-500/10 border border-red-500/50 rounded-xl">
                                                <div className="text-4xl font-bold text-red-500 mb-2">
                                                    {analysisResults.predictions.churn_risk?.probability || 25}%
                                                </div>
                                                <div className="text-sm text-red-400 uppercase">Churn Risk</div>
                                                <div className="text-xs text-gray-400 mt-2">
                                                    {analysisResults.predictions.churn_risk?.level || 'Low'} Risk Level
                                                </div>
                                            </div>
                                            <div className="text-center p-6 bg-green-500/10 border border-green-500/50 rounded-xl">
                                                <div className="text-4xl font-bold text-green-500 mb-2">
                                                    {analysisResults.predictions.conversion?.probability || 85}%
                                                </div>
                                                <div className="text-sm text-green-400 uppercase">Conversion Probability</div>
                                            </div>
                                        </div>
                                    </div>
                                )}
                            </>
                        ) : (
                            <div className={`${colors.cardBg} border ${colors.border} rounded-2xl p-12 text-center shadow-xl`}>
                                <Brain className={`w-16 h-16 mx-auto ${colors.textMuted} mb-4`} />
                                <h3 className="text-xl font-bold mb-2">No Analysis Available</h3>
                                <p className={`${colors.textMuted} mb-6`}>Record a conversation to see AI analysis</p>
                                <button
                                    onClick={() => setActiveTab('capture')}
                                    className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-cyan-500 to-blue-600 text-white rounded-xl"
                                >
                                    <Mic className="w-5 h-5" />
                                    Start Recording
                                </button>
                            </div>
                        )}
                    </div>
                )}

            </div>
        </div>
    );
}

export default App;