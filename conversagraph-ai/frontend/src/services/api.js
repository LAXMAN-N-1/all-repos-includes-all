// ConversaGraph AI - API Service Integration
// src/services/api.js

import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// ==================== CONVERSATION API ====================

export const conversationAPI = {
  // Create new conversation with segments
  create: async (data) => {
    const response = await api.post('/api/conversations/create', data);
    return response.data;
  },

  // Get conversation by ID
  get: async (conversationId) => {
    const response = await api.get(`/api/conversations/${conversationId}`);
    return response.data;
  },

  // Get knowledge graph for conversation
  getGraph: async (conversationId) => {
    const response = await api.get(`/api/conversations/${conversationId}/graph`);
    return response.data;
  },

  // Search conversations
  search: async (query, filters = {}) => {
    const response = await api.get('/api/conversations/search', {
      params: { q: query, ...filters },
    });
    return response.data;
  },

  // Delete conversation
  delete: async (conversationId) => {
    const response = await api.delete(`/api/conversations/${conversationId}`);
    return response.data;
  },
};

// ==================== ANALYSIS API ====================

export const analysisAPI = {
  // Comprehensive analysis
  comprehensive: async (conversationId) => {
    const response = await api.post('/api/analyze/comprehensive', {
      conversation_id: conversationId,
      analysis_type: 'comprehensive',
    });
    return response.data;
  },

  // Sentiment analysis only
  sentiment: async (conversationId) => {
    const response = await api.post('/api/analyze/sentiment', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Entity extraction
  entities: async (conversationId) => {
    const response = await api.post('/api/analyze/entities', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Topic modeling
  topics: async (conversationId) => {
    const response = await api.post('/api/analyze/topics', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Intent detection
  intents: async (conversationId) => {
    const response = await api.post('/api/analyze/intents', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Predictive insights
  predictions: async (conversationId) => {
    const response = await api.get(`/api/analyze/${conversationId}/predictions`);
    return response.data;
  },
};

// ==================== AUDIO API ====================

export const audioAPI = {
  // Process audio file
  process: async (audioFile) => {
    const formData = new FormData();
    formData.append('file', audioFile);

    const response = await api.post('/api/audio/process', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // Transcribe audio
  transcribe: async (audioFile) => {
    const formData = new FormData();
    formData.append('file', audioFile);

    const response = await api.post('/api/audio/transcribe', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },
};

// ==================== GRAPH API ====================

export const graphAPI = {
  // Get graph for conversation
  get: async (conversationId) => {
    const response = await api.get(`/api/graph/${conversationId}`);
    return response.data;
  },

  // Run PageRank algorithm
  pageRank: async (conversationId) => {
    const response = await api.post('/api/graph/algorithms/pagerank', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Community detection
  communities: async (conversationId) => {
    const response = await api.post('/api/graph/algorithms/communities', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Centrality measures
  centrality: async (conversationId) => {
    const response = await api.post('/api/graph/algorithms/centrality', {
      conversation_id: conversationId,
    });
    return response.data;
  },

  // Custom Cypher query
  query: async (cypherQuery, params = {}) => {
    const response = await api.post('/api/graph/query', {
      query: cypherQuery,
      parameters: params,
    });
    return response.data;
  },
};

// ==================== WEBSOCKET CONNECTION ====================

export class WebSocketService {
  constructor(url = 'ws://localhost:8000') {
    this.url = url;
    this.ws = null;
    this.listeners = new Map();
  }

  connect(endpoint) {
    return new Promise((resolve, reject) => {
      this.ws = new WebSocket(`${this.url}${endpoint}`);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
        resolve();
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        reject(error);
      };

      this.ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        this.notifyListeners(data.type, data);
      };

      this.ws.onclose = () => {
        console.log('WebSocket disconnected');
        this.reconnect(endpoint);
      };
    });
  }

  send(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }

  sendBinary(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(data);
    }
  }

  on(eventType, callback) {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType).push(callback);
  }

  off(eventType, callback) {
    if (this.listeners.has(eventType)) {
      const callbacks = this.listeners.get(eventType);
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  notifyListeners(eventType, data) {
    if (this.listeners.has(eventType)) {
      this.listeners.get(eventType).forEach((callback) => {
        callback(data);
      });
    }
  }

  reconnect(endpoint) {
    setTimeout(() => {
      console.log('Attempting to reconnect...');
      this.connect(endpoint);
    }, 3000);
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

export const wsService = new WebSocketService();

// ==================== ERROR HANDLING ====================

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      // Server responded with error
      console.error('API Error:', error.response.data);
      return Promise.reject(error.response.data);
    } else if (error.request) {
      // Request made but no response
      console.error('Network Error:', error.request);
      return Promise.reject({ message: 'Network error. Please check your connection.' });
    } else {
      // Something else happened
      console.error('Error:', error.message);
      return Promise.reject({ message: error.message });
    }
  }
);

export default api;

// ==================== USAGE EXAMPLES ====================
/*

// Creating a conversation
const conversation = await conversationAPI.create({
  segments: [
    {
      text: "Hello, how can I help you?",
      speaker_id: "speaker_001",
      timestamp: 0,
      confidence: 0.95
    }
  ],
  speakers: [
    { id: "speaker_001", name: "Agent", role: "agent" }
  ],
  duration: 1800
});

// Getting comprehensive analysis
const analysis = await analysisAPI.comprehensive(conversationId);

// Getting knowledge graph
const graph = await graphAPI.get(conversationId);

// WebSocket for real-time transcription
await wsService.connect('/ws/transcribe');

wsService.on('audio_features', (data) => {
  console.log('Audio features:', data);
});

wsService.on('transcription', (data) => {
  console.log('Transcription:', data);
});

// Send audio chunk
wsService.sendBinary(audioChunk);

// Cleanup
wsService.disconnect();

*/
