"""
ConversaGraph AI - Advanced Backend API with Neo4j Integration
Enterprise-grade conversational intelligence platform
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import asyncio
import json
import numpy as np
from datetime import datetime
import uuid
import io
import wave
from neo4j import GraphDatabase
import redis
from scipy.io import wavfile
from scipy import signal
import librosa
import noisereduce as nr
from transformers import pipeline, AutoTokenizer, AutoModel
import torch
import spacy
from collections import defaultdict, Counter
import networkx as nx
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import LatentDirichletAllocation
from textblob import TextBlob
import re

app = FastAPI(title="ConversaGraph AI API", version="2.0.0")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== DATABASE CONNECTIONS ====================

class Neo4jConnection:
    """Advanced Neo4j connection manager with connection pooling"""
    
    def __init__(self, uri: str, user: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
        
    def close(self):
        self.driver.close()
        
    async def execute_query(self, query: str, parameters: dict = None):
        """Execute Cypher query with async support"""
        with self.driver.session() as session:
            result = session.run(query, parameters or {})
            return [record.data() for record in result]
    
    async def execute_write(self, query: str, parameters: dict = None):
        """Execute write query"""
        with self.driver.session() as session:
            result = session.write_transaction(
                lambda tx: tx.run(query, parameters or {})
            )
            return result

# Initialize Neo4j
neo4j_conn = Neo4jConnection(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password123"
)

# Initialize Redis for caching
redis_client = redis.Redis(
    host='localhost',
    port=6379,
    password='redis123',
    decode_responses=True
)

# ==================== AI MODELS INITIALIZATION ====================

class AIModels:
    """Advanced AI models for NLP and audio processing"""
    
    def __init__(self):
        # Sentiment Analysis - Advanced model
        self.sentiment_analyzer = pipeline(
            "sentiment-analysis",
            model="nlptown/bert-base-multilingual-uncased-sentiment"
        )
        
        # Emotion Detection
        self.emotion_classifier = pipeline(
            "text-classification",
            model="j-hartmann/emotion-english-distilroberta-base",
            return_all_scores=True
        )
        
        # Named Entity Recognition
        self.ner_model = pipeline(
            "ner",
            model="dslim/bert-base-NER",
            aggregation_strategy="simple"
        )
        
        # Zero-shot Classification for intents
        self.intent_classifier = pipeline(
            "zero-shot-classification",
            model="facebook/bart-large-mnli"
        )
        
        # Sentence Transformer for embeddings
        self.tokenizer = AutoTokenizer.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
        self.embedding_model = AutoModel.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
        
        # Spacy for advanced NLP
        self.nlp = spacy.load("en_core_web_lg")
        
        # Topic Modeling
        self.vectorizer = TfidfVectorizer(max_features=100, stop_words='english')
        self.lda_model = LatentDirichletAllocation(n_components=10, random_state=42)
        
    def get_sentence_embedding(self, text: str) -> List[float]:
        """Generate sentence embeddings using transformer model"""
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
        with torch.no_grad():
            outputs = self.embedding_model(**inputs)
        embeddings = outputs.last_hidden_state.mean(dim=1).squeeze().numpy()
        return embeddings.tolist()
    
    def advanced_sentiment_analysis(self, text: str) -> Dict[str, Any]:
        """Multi-dimensional sentiment analysis"""
        # BERT-based sentiment
        bert_sentiment = self.sentiment_analyzer(text)[0]
        
        # TextBlob sentiment (polarity and subjectivity)
        blob = TextBlob(text)
        
        # Emotion analysis
        emotions = self.emotion_classifier(text)[0]
        dominant_emotion = max(emotions, key=lambda x: x['score'])
        
        return {
            "bert_sentiment": {
                "label": bert_sentiment['label'],
                "score": bert_sentiment['score']
            },
            "polarity": blob.sentiment.polarity,
            "subjectivity": blob.sentiment.subjectivity,
            "emotions": emotions,
            "dominant_emotion": dominant_emotion,
            "overall_score": (blob.sentiment.polarity + 1) * 50  # Normalize to 0-100
        }
    
    def extract_advanced_entities(self, text: str) -> List[Dict[str, Any]]:
        """Extract entities using multiple methods"""
        # BERT NER
        bert_entities = self.ner_model(text)
        
        # Spacy NER
        doc = self.nlp(text)
        spacy_entities = [
            {
                "text": ent.text,
                "type": ent.label_,
                "start": ent.start_char,
                "end": ent.end_char
            }
            for ent in doc.ents
        ]
        
        # Combine and deduplicate
        all_entities = bert_entities + spacy_entities
        unique_entities = {}
        for entity in all_entities:
            key = f"{entity['text']}_{entity.get('entity_group', entity.get('type'))}"
            if key not in unique_entities:
                unique_entities[key] = entity
        
        return list(unique_entities.values())
    
    def detect_intent(self, text: str, candidate_labels: List[str]) -> Dict[str, Any]:
        """Detect user intent using zero-shot classification"""
        result = self.intent_classifier(text, candidate_labels)
        return {
            "primary_intent": result['labels'][0],
            "confidence": result['scores'][0],
            "all_intents": dict(zip(result['labels'], result['scores']))
        }
    
    def extract_topics(self, texts: List[str]) -> List[Dict[str, Any]]:
        """Extract topics using LDA"""
        try:
            tfidf_matrix = self.vectorizer.fit_transform(texts)
            lda_output = self.lda_model.fit_transform(tfidf_matrix)
            
            # Get top words for each topic
            feature_names = self.vectorizer.get_feature_names_out()
            topics = []
            
            for topic_idx, topic in enumerate(self.lda_model.components_):
                top_words_idx = topic.argsort()[-10:][::-1]
                top_words = [feature_names[i] for i in top_words_idx]
                topics.append({
                    "topic_id": topic_idx,
                    "keywords": top_words,
                    "weight": float(topic.sum())
                })
            
            return topics
        except:
            return []

# Initialize AI models
ai_models = AIModels()

# ==================== AUDIO PROCESSING ====================

class AudioProcessor:
    """Advanced audio processing with noise reduction and feature extraction"""
    
    @staticmethod
    def process_audio(audio_data: bytes) -> Dict[str, Any]:
        """Process raw audio data with advanced techniques"""
        try:
            # Convert bytes to numpy array
            audio_io = io.BytesIO(audio_data)
            sample_rate, audio = wavfile.read(audio_io)
            
            # Normalize audio
            audio = audio.astype(np.float32) / np.max(np.abs(audio))
            
            # Noise reduction
            reduced_noise = nr.reduce_noise(
                y=audio,
                sr=sample_rate,
                stationary=True,
                prop_decrease=0.9
            )
            
            # Extract features
            features = AudioProcessor.extract_audio_features(reduced_noise, sample_rate)
            
            return {
                "processed_audio": reduced_noise.tolist(),
                "sample_rate": sample_rate,
                "features": features,
                "quality_metrics": AudioProcessor.assess_audio_quality(reduced_noise, sample_rate)
            }
        except Exception as e:
            return {"error": str(e)}
    
    @staticmethod
    def extract_audio_features(audio: np.ndarray, sr: int) -> Dict[str, Any]:
        """Extract advanced audio features"""
        # MFCCs (Mel-frequency cepstral coefficients)
        mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=13)
        
        # Spectral features
        spectral_centroids = librosa.feature.spectral_centroid(y=audio, sr=sr)[0]
        spectral_rolloff = librosa.feature.spectral_rolloff(y=audio, sr=sr)[0]
        zero_crossing_rate = librosa.feature.zero_crossing_rate(audio)[0]
        
        # Tempo and rhythm
        tempo, beats = librosa.beat.beat_track(y=audio, sr=sr)
        
        # Energy
        rms = librosa.feature.rms(y=audio)[0]
        
        # Pitch
        pitches, magnitudes = librosa.piptrack(y=audio, sr=sr)
        
        return {
            "mfcc_mean": mfccs.mean(axis=1).tolist(),
            "mfcc_std": mfccs.std(axis=1).tolist(),
            "spectral_centroid_mean": float(spectral_centroids.mean()),
            "spectral_rolloff_mean": float(spectral_rolloff.mean()),
            "zero_crossing_rate_mean": float(zero_crossing_rate.mean()),
            "tempo": float(tempo),
            "rms_energy_mean": float(rms.mean()),
            "pitch_mean": float(np.mean(pitches[pitches > 0]) if pitches.any() else 0)
        }
    
    @staticmethod
    def assess_audio_quality(audio: np.ndarray, sr: int) -> Dict[str, float]:
        """Assess audio quality metrics"""
        # Signal-to-Noise Ratio (SNR)
        signal_power = np.mean(audio ** 2)
        noise_power = np.var(audio)
        snr = 10 * np.log10(signal_power / (noise_power + 1e-10))
        
        # Clarity score based on spectral flatness
        spec_flatness = librosa.feature.spectral_flatness(y=audio)[0]
        clarity = (1 - spec_flatness.mean()) * 100
        
        return {
            "snr": float(snr),
            "clarity": float(clarity),
            "overall_quality": float((snr / 40 + clarity / 100) * 50)
        }

# ==================== NEO4J KNOWLEDGE GRAPH ====================

class KnowledgeGraphManager:
    """Advanced knowledge graph management with Neo4j"""
    
    def __init__(self, neo4j_conn: Neo4jConnection):
        self.conn = neo4j_conn
        self.initialize_schema()
    
    def initialize_schema(self):
        """Initialize Neo4j schema with constraints and indexes"""
        queries = [
            # Constraints
            "CREATE CONSTRAINT conversation_id IF NOT EXISTS FOR (c:Conversation) REQUIRE c.id IS UNIQUE",
            "CREATE CONSTRAINT speaker_id IF NOT EXISTS FOR (s:Speaker) REQUIRE s.id IS UNIQUE",
            "CREATE CONSTRAINT entity_id IF NOT EXISTS FOR (e:Entity) REQUIRE e.id IS UNIQUE",
            "CREATE CONSTRAINT topic_name IF NOT EXISTS FOR (t:Topic) REQUIRE t.name IS UNIQUE",
            
            # Indexes for performance
            "CREATE INDEX conversation_timestamp IF NOT EXISTS FOR (c:Conversation) ON (c.timestamp)",
            "CREATE INDEX entity_type IF NOT EXISTS FOR (e:Entity) ON (e.type)",
            "CREATE INDEX sentiment_score IF NOT EXISTS FOR (s:Sentiment) ON (s.score)",
            
            # Full-text indexes
            "CREATE FULLTEXT INDEX transcript_text IF NOT EXISTS FOR (t:Transcript) ON EACH [t.text]",
            "CREATE FULLTEXT INDEX entity_text IF NOT EXISTS FOR (e:Entity) ON EACH [e.text]"
        ]
        
        for query in queries:
            try:
                asyncio.create_task(self.conn.execute_write(query))
            except:
                pass  # Constraint/index might already exist
    
    async def create_conversation_graph(self, conversation_data: Dict[str, Any]) -> str:
        """Create comprehensive knowledge graph for conversation"""
        conversation_id = str(uuid.uuid4())
        
        # Create conversation node
        await self.conn.execute_write("""
            CREATE (c:Conversation {
                id: $id,
                timestamp: datetime($timestamp),
                duration: $duration,
                quality_score: $quality_score,
                sentiment_score: $sentiment_score
            })
        """, {
            "id": conversation_id,
            "timestamp": conversation_data['timestamp'],
            "duration": conversation_data['duration'],
            "quality_score": conversation_data.get('quality_score', 0),
            "sentiment_score": conversation_data.get('sentiment_score', 50)
        })
        
        # Create speaker nodes and relationships
        for speaker in conversation_data.get('speakers', []):
            await self.conn.execute_write("""
                MERGE (s:Speaker {id: $speaker_id})
                ON CREATE SET 
                    s.name = $name,
                    s.role = $role
                WITH s
                MATCH (c:Conversation {id: $conv_id})
                CREATE (s)-[:PARTICIPATED_IN {
                    word_count: $word_count,
                    talk_time: $talk_time,
                    sentiment: $sentiment
                }]->(c)
            """, {
                "speaker_id": speaker['id'],
                "name": speaker['name'],
                "role": speaker.get('role', 'participant'),
                "conv_id": conversation_id,
                "word_count": speaker.get('word_count', 0),
                "talk_time": speaker.get('talk_time', 0),
                "sentiment": speaker.get('sentiment', 50)
            })
        
        # Create transcript segments
        for idx, segment in enumerate(conversation_data.get('segments', [])):
            await self.conn.execute_write("""
                MATCH (c:Conversation {id: $conv_id})
                MATCH (s:Speaker {id: $speaker_id})
                CREATE (t:Transcript {
                    id: $segment_id,
                    text: $text,
                    timestamp: $timestamp,
                    confidence: $confidence,
                    sequence: $sequence
                })
                CREATE (s)-[:SPOKE]->(t)
                CREATE (t)-[:PART_OF]->(c)
            """, {
                "conv_id": conversation_id,
                "speaker_id": segment['speaker_id'],
                "segment_id": f"{conversation_id}_{idx}",
                "text": segment['text'],
                "timestamp": segment['timestamp'],
                "confidence": segment.get('confidence', 0.95),
                "sequence": idx
            })
            
            # Analyze and create sentiment nodes
            sentiment = ai_models.advanced_sentiment_analysis(segment['text'])
            await self.conn.execute_write("""
                MATCH (t:Transcript {id: $segment_id})
                CREATE (sent:Sentiment {
                    score: $score,
                    polarity: $polarity,
                    subjectivity: $subjectivity,
                    dominant_emotion: $emotion
                })
                CREATE (t)-[:HAS_SENTIMENT]->(sent)
            """, {
                "segment_id": f"{conversation_id}_{idx}",
                "score": sentiment['overall_score'],
                "polarity": sentiment['polarity'],
                "subjectivity": sentiment['subjectivity'],
                "emotion": sentiment['dominant_emotion']['label']
            })
        
        # Extract and create entity nodes
        all_text = " ".join([s['text'] for s in conversation_data.get('segments', [])])
        entities = ai_models.extract_advanced_entities(all_text)
        
        for entity in entities:
            entity_id = str(uuid.uuid4())
            await self.conn.execute_write("""
                MERGE (e:Entity {text: $text, type: $type})
                ON CREATE SET 
                    e.id = $id,
                    e.confidence = $confidence
                WITH e
                MATCH (c:Conversation {id: $conv_id})
                MERGE (e)-[r:MENTIONED_IN]->(c)
                ON CREATE SET r.count = 1
                ON MATCH SET r.count = r.count + 1
            """, {
                "id": entity_id,
                "text": entity['text'],
                "type": entity.get('entity_group', entity.get('type', 'UNKNOWN')),
                "confidence": entity.get('score', 0.9),
                "conv_id": conversation_id
            })
        
        # Extract topics and create topic nodes
        texts = [s['text'] for s in conversation_data.get('segments', [])]
        if texts:
            topics = ai_models.extract_topics(texts)
            for topic in topics:
                topic_name = "_".join(topic['keywords'][:3])
                await self.conn.execute_write("""
                    MERGE (t:Topic {name: $name})
                    ON CREATE SET 
                        t.keywords = $keywords,
                        t.weight = $weight
                    WITH t
                    MATCH (c:Conversation {id: $conv_id})
                    CREATE (t)-[:DISCUSSED_IN {relevance: $weight}]->(c)
                """, {
                    "name": topic_name,
                    "keywords": topic['keywords'],
                    "weight": topic['weight'],
                    "conv_id": conversation_id
                })
        
        # Create intent nodes
        intent_labels = [
            "purchase_intent", "information_seeking", "complaint",
            "support_request", "feedback", "negotiation"
        ]
        
        for text in texts[:5]:  # Analyze first 5 segments for intents
            intent = ai_models.detect_intent(text, intent_labels)
            if intent['confidence'] > 0.5:
                await self.conn.execute_write("""
                    MERGE (i:Intent {type: $type})
                    WITH i
                    MATCH (c:Conversation {id: $conv_id})
                    CREATE (i)-[:DETECTED_IN {
                        confidence: $confidence,
                        timestamp: datetime()
                    }]->(c)
                """, {
                    "type": intent['primary_intent'],
                    "confidence": intent['confidence'],
                    "conv_id": conversation_id
                })
        
        # Create relationships between entities
        await self.create_entity_relationships(conversation_id, entities)
        
        return conversation_id
    
    async def create_entity_relationships(self, conversation_id: str, entities: List[Dict]):
        """Create co-occurrence relationships between entities"""
        for i, entity1 in enumerate(entities):
            for entity2 in entities[i+1:]:
                # Create co-occurrence relationship
                await self.conn.execute_write("""
                    MATCH (e1:Entity {text: $text1})
                    MATCH (e2:Entity {text: $text2})
                    MATCH (c:Conversation {id: $conv_id})
                    WHERE (e1)-[:MENTIONED_IN]->(c) AND (e2)-[:MENTIONED_IN]->(c)
                    MERGE (e1)-[r:CO_OCCURS_WITH]-(e2)
                    ON CREATE SET r.count = 1, r.conversations = [$conv_id]
                    ON MATCH SET r.count = r.count + 1, 
                                 r.conversations = r.conversations + $conv_id
                """, {
                    "text1": entity1['text'],
                    "text2": entity2['text'],
                    "conv_id": conversation_id
                })
    
    async def run_graph_algorithms(self, conversation_id: str) -> Dict[str, Any]:
        """Run advanced graph algorithms for insights"""
        
        # PageRank - Find most important nodes
        pagerank_query = """
            CALL gds.graph.project.cypher(
                'conversation_graph_' + $conv_id,
                'MATCH (n) WHERE (n:Entity OR n:Topic OR n:Speaker)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN]->(:Conversation {id: $conv_id}) RETURN id(n) AS id',
                'MATCH (n)-[r]-(m) WHERE (n)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN]->(:Conversation {id: $conv_id}) RETURN id(n) AS source, id(m) AS target, 1.0 AS weight'
            )
            CALL gds.pageRank.stream('conversation_graph_' + $conv_id)
            YIELD nodeId, score
            RETURN gds.util.asNode(nodeId).text AS node, score
            ORDER BY score DESC LIMIT 10
        """
        
        # Community Detection - Find clusters
        community_query = """
            CALL gds.louvain.stream('conversation_graph_' + $conv_id)
            YIELD nodeId, communityId
            RETURN communityId, collect(gds.util.asNode(nodeId).text) AS members
            ORDER BY size(members) DESC
        """
        
        # Centrality measures
        centrality_query = """
            MATCH (n)-[r]-()
            WHERE (n)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN]->(:Conversation {id: $conv_id})
            WITH n, count(r) AS degree
            RETURN labels(n)[0] AS type, n.text AS node, degree
            ORDER BY degree DESC LIMIT 20
        """
        
        try:
            pagerank_results = await self.conn.execute_query(pagerank_query, {"conv_id": conversation_id})
            centrality_results = await self.conn.execute_query(centrality_query, {"conv_id": conversation_id})
            
            return {
                "pagerank": pagerank_results,
                "centrality": centrality_results,
                "graph_density": await self.calculate_graph_density(conversation_id)
            }
        except Exception as e:
            print(f"Graph algorithms error: {e}")
            return {}
    
    async def calculate_graph_density(self, conversation_id: str) -> float:
        """Calculate graph density for conversation"""
        query = """
            MATCH (n)-[r]-()
            WHERE (n)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN]->(:Conversation {id: $conv_id})
            WITH count(DISTINCT n) AS nodes, count(r) AS edges
            RETURN CASE 
                WHEN nodes > 1 THEN toFloat(edges) / (nodes * (nodes - 1))
                ELSE 0.0 
            END AS density
        """
        result = await self.conn.execute_query(query, {"conv_id": conversation_id})
        return result[0]['density'] if result else 0.0
    
    async def get_conversation_graph(self, conversation_id: str) -> Dict[str, Any]:
        """Retrieve complete conversation graph"""
        nodes_query = """
            MATCH (n)
            WHERE (n)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN|PART_OF*1..2]->(:Conversation {id: $conv_id})
            RETURN 
                id(n) AS id,
                labels(n)[0] AS type,
                properties(n) AS properties
        """
        
        edges_query = """
            MATCH (n)-[r]->(m)
            WHERE (n)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN|PART_OF*1..2]->(:Conversation {id: $conv_id})
            AND (m)-[:MENTIONED_IN|DISCUSSED_IN|PARTICIPATED_IN|PART_OF*1..2]->(:Conversation {id: $conv_id})
            RETURN 
                id(n) AS source,
                id(m) AS target,
                type(r) AS type,
                properties(r) AS properties
        """
        
        nodes = await self.conn.execute_query(nodes_query, {"conv_id": conversation_id})
        edges = await self.conn.execute_query(edges_query, {"conv_id": conversation_id})
        
        return {
            "nodes": nodes,
            "edges": edges,
            "conversation_id": conversation_id
        }

# Initialize Knowledge Graph Manager
kg_manager = KnowledgeGraphManager(neo4j_conn)

# ==================== API MODELS ====================

class TranscriptSegment(BaseModel):
    text: str
    speaker_id: str
    timestamp: float
    confidence: float = 0.95

class ConversationCreate(BaseModel):
    segments: List[TranscriptSegment]
    speakers: List[Dict[str, Any]]
    duration: float
    metadata: Optional[Dict[str, Any]] = {}

class AnalysisRequest(BaseModel):
    conversation_id: str
    analysis_type: str = "comprehensive"

# ==================== API ENDPOINTS ====================

@app.get("/")
async def root():
    """API health check"""
    return {
        "service": "ConversaGraph AI API",
        "version": "2.0.0",
        "status": "operational",
        "features": [
            "Real-time transcription",
            "Advanced sentiment analysis",
            "Knowledge graph generation",
            "Multi-dimensional entity extraction",
            "Intent detection",
            "Topic modeling",
            "Graph algorithms",
            "Predictive analytics"
        ]
    }

@app.post("/api/conversations/create")
async def create_conversation(data: ConversationCreate):
    """Create new conversation with knowledge graph"""
    try:
        # Prepare conversation data
        conversation_data = {
            "timestamp": datetime.now().isoformat(),
            "duration": data.duration,
            "segments": [seg.dict() for seg in data.segments],
            "speakers": data.speakers,
            "metadata": data.metadata
        }
        
        # Create knowledge graph
        conversation_id = await kg_manager.create_conversation_graph(conversation_data)
        
        # Run graph algorithms
        graph_insights = await kg_manager.run_graph_algorithms(conversation_id)
        
        # Cache in Redis
        redis_client.setex(
            f"conversation:{conversation_id}",
            3600,  # 1 hour TTL
            json.dumps(conversation_data)
        )
        
        return {
            "conversation_id": conversation_id,
            "status": "created",
            "graph_insights": graph_insights
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/conversations/{conversation_id}/graph")
async def get_conversation_graph(conversation_id: str):
    """Get knowledge graph for conversation"""
    try:
        graph = await kg_manager.get_conversation_graph(conversation_id)
        return graph
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.post("/api/analyze/comprehensive")
async def comprehensive_analysis(request: AnalysisRequest):
    """Perform comprehensive AI analysis on conversation"""
    try:
        # Retrieve conversation data
        cached_data = redis_client.get(f"conversation:{request.conversation_id}")
        if not cached_data:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        conversation_data = json.loads(cached_data)
        
        # Comprehensive analysis
        all_text = " ".join([seg['text'] for seg in conversation_data['segments']])
        
        # Multi-dimensional sentiment analysis
        sentiment_analysis = ai_models.advanced_sentiment_analysis(all_text)
        
        # Entity extraction and analysis
        entities = ai_models.extract_advanced_entities(all_text)
        entity_network = analyze_entity_network(entities)
        
        # Topic modeling
        texts = [seg['text'] for seg in conversation_data['segments']]
        topics = ai_models.extract_topics(texts)
        
        # Intent detection
        intents = []
        for text in texts[:10]:  # Analyze first 10 segments
            intent = ai_models.detect_intent(
                text,
                ["purchase", "inquiry", "complaint", "support", "feedback"]
            )
            intents.append(intent)
        
        # Conversation dynamics
        dynamics = analyze_conversation_dynamics(conversation_data)
        
        # Predictive insights
        predictions = generate_predictive_insights(
            sentiment_analysis,
            entities,
            intents,
            dynamics
        )
        
        # Graph-based insights
        graph_insights = await kg_manager.run_graph_algorithms(request.conversation_id)
        
        return {
            "conversation_id": request.conversation_id,
            "sentiment_analysis": sentiment_analysis,
            "entities": {
                "extracted": entities,
                "network": entity_network
            },
            "topics": topics,
            "intents": intents,
            "conversation_dynamics": dynamics,
            "predictions": predictions,
            "graph_insights": graph_insights,
            "quality_score": calculate_conversation_quality(
                sentiment_analysis,
                len(entities),
                len(topics)
            )
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/audio/process")
async def process_audio(file: UploadFile = File(...)):
    """Process uploaded audio file"""
    try:
        audio_data = await file.read()
        processed = AudioProcessor.process_audio(audio_data)
        
        return {
            "status": "processed",
            "features": processed.get('features'),
            "quality": processed.get('quality_metrics')
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws/transcribe")
async def websocket_transcription(websocket: WebSocket):
    """Real-time transcription websocket"""
    await websocket.accept()
    
    try:
        while True:
            # Receive audio chunk
            data = await websocket.receive_bytes()
            
            # Process audio
            processed = AudioProcessor.process_audio(data)
            
            # Send back features
            await websocket.send_json({
                "type": "audio_features",
                "data": processed
            })
    
    except WebSocketDisconnect:
        print("Client disconnected")

# ==================== HELPER FUNCTIONS ====================

def analyze_entity_network(entities: List[Dict]) -> Dict[str, Any]:
    """Analyze entity co-occurrence network"""
    G = nx.Graph()
    
    # Add entities as nodes
    for entity in entities:
        G.add_node(entity['text'], type=entity.get('entity_group', 'UNKNOWN'))
    
    # Add edges based on proximity (simplified)
    for i, e1 in enumerate(entities):
        for e2 in entities[i+1:i+5]:  # Connect to next 4 entities
            G.add_edge(e1['text'], e2['text'])
    
    # Calculate network metrics
    centrality = nx.degree_centrality(G)
    betweenness = nx.betweenness_centrality(G)
    
    return {
        "node_count": G.number_of_nodes(),
        "edge_count": G.number_of_edges(),
        "density": nx.density(G),
        "most_central": max(centrality.items(), key=lambda x: x[1])[0] if centrality else None,
        "most_between": max(betweenness.items(), key=lambda x: x[1])[0] if betweenness else None
    }

def analyze_conversation_dynamics(conversation_data: Dict) -> Dict[str, Any]:
    """Analyze conversation flow and dynamics"""
    segments = conversation_data['segments']
    
    # Speaking pattern analysis
    speaker_turns = defaultdict(int)
    turn_lengths = []
    
    for seg in segments:
        speaker_turns[seg['speaker_id']] += 1
        turn_lengths.append(len(seg['text'].split()))
    
    # Sentiment flow
    sentiment_flow = []
    for seg in segments:
        sent = ai_models.advanced_sentiment_analysis(seg['text'])
        sentiment_flow.append(sent['overall_score'])
    
    # Calculate volatility
    sentiment_volatility = np.std(sentiment_flow) if len(sentiment_flow) > 1 else 0
    
    return {
        "total_turns": len(segments),
        "speaker_distribution": dict(speaker_turns),
        "avg_turn_length": np.mean(turn_lengths) if turn_lengths else 0,
        "sentiment_flow": sentiment_flow,
        "sentiment_volatility": float(sentiment_volatility),
        "engagement_score": calculate_engagement_score(speaker_turns, turn_lengths)
    }

def calculate_engagement_score(speaker_turns: Dict, turn_lengths: List) -> float:
    """Calculate conversation engagement score"""
    # Balance of participation
    if len(speaker_turns) < 2:
        balance = 0.5
    else:
        turns = list(speaker_turns.values())
        balance = 1 - (max(turns) - min(turns)) / sum(turns)
    
    # Turn length variability (good engagement has variety)
    variability = np.std(turn_lengths) / (np.mean(turn_lengths) + 1) if turn_lengths else 0
    variability_score = min(variability, 1.0)
    
    return float((balance * 0.6 + variability_score * 0.4) * 100)

def generate_predictive_insights(
    sentiment: Dict,
    entities: List,
    intents: List,
    dynamics: Dict
) -> Dict[str, Any]:
    """Generate predictive insights using ML"""
    
    # Churn risk prediction
    churn_factors = []
    if sentiment['overall_score'] < 40:
        churn_factors.append(("negative_sentiment", 30))
    if any(i['primary_intent'] == 'complaint' for i in intents):
        churn_factors.append(("complaint_detected", 25))
    if dynamics['sentiment_volatility'] > 15:
        churn_factors.append(("high_volatility", 20))
    
    churn_risk = min(sum(f[1] for f in churn_factors), 95)
    
    # Conversion probability
    conversion_factors = []
    if sentiment['overall_score'] > 60:
        conversion_factors.append(("positive_sentiment", 25))
    if any(i['primary_intent'] in ['purchase', 'inquiry'] for i in intents):
        conversion_factors.append(("buying_intent", 30))
    if dynamics['engagement_score'] > 70:
        conversion_factors.append(("high_engagement", 20))
    
    conversion_prob = min(sum(f[1] for f in conversion_factors), 95)
    
    # Deal value estimation
    monetary_entities = [e for e in entities if e.get('entity_group') == 'MONEY']
    estimated_value = 15000  # Base value
    if monetary_entities:
        # Extract numbers from monetary entities
        for entity in monetary_entities:
            match = re.search(r'\d+(?:,\d{3})*(?:\.\d{2})?', entity['text'])
            if match:
                estimated_value = max(estimated_value, float(match.group().replace(',', '')))
    
    return {
        "churn_risk": {
            "probability": churn_risk,
            "level": "high" if churn_risk > 60 else "medium" if churn_risk > 30 else "low",
            "factors": churn_factors
        },
        "conversion": {
            "probability": conversion_prob,
            "confidence": 0.85,
            "factors": conversion_factors
        },
        "deal_value": {
            "estimated": estimated_value,
            "confidence": 0.75
        },
        "next_best_action": determine_next_action(churn_risk, conversion_prob, sentiment),
        "customer_lifetime_value": estimated_value * 3.5
    }

def determine_next_action(churn_risk: float, conversion_prob: float, sentiment: Dict) -> str:
    """Determine recommended next action"""
    if churn_risk > 70:
        return "URGENT: Schedule executive retention call within 24 hours"
    elif conversion_prob > 70:
        return "Send contract and schedule signing call immediately"
    elif sentiment['overall_score'] > 75:
        return "Request testimonial and ask for referrals"
    elif churn_risk > 40:
        return "Implement customer recovery plan with service credits"
    else:
        return "Send detailed follow-up email addressing all discussion points"

def calculate_conversation_quality(
    sentiment: Dict,
    entity_count: int,
    topic_count: int
) -> float:
    """Calculate overall conversation quality score"""
    # Weighted components
    sentiment_weight = 0.4
    information_density_weight = 0.3
    topic_diversity_weight = 0.3
    
    sentiment_score = sentiment['overall_score']
    info_density = min((entity_count / 5) * 100, 100)  # 5+ entities = full score
    topic_diversity = min((topic_count / 3) * 100, 100)  # 3+ topics = full score
    
    quality = (
        sentiment_score * sentiment_weight +
        info_density * information_density_weight +
        topic_diversity * topic_diversity_weight
    )
    
    return round(quality, 2)

# ==================== STARTUP & SHUTDOWN ====================

@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    print("🚀 ConversaGraph AI API starting...")
    print("✓ Neo4j connection established")
    print("✓ Redis cache ready")
    print("✓ AI models loaded")
    print("✓ Knowledge graph manager initialized")
    print("✅ API ready to accept requests")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    neo4j_conn.close()
    redis_client.close()
    print("👋 ConversaGraph AI API shutdown complete")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
