// ============================================================
// ConversaGraph AI - Neo4j Complete Graph Schema
// ============================================================
// Run this in Neo4j Browser or via cypher-shell
// Usage: cat neo4j_schema.cypher | cypher-shell -u neo4j -p password123

// ==================== CONSTRAINTS ====================
// Ensure unique identifiers for nodes

// Conversation constraints
CREATE CONSTRAINT conversation_id IF NOT EXISTS
FOR (c:Conversation) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT conversation_timestamp IF NOT EXISTS
FOR (c:Conversation) REQUIRE c.timestamp IS NOT NULL;

// Speaker constraints
CREATE CONSTRAINT speaker_id IF NOT EXISTS
FOR (s:Speaker) REQUIRE s.id IS UNIQUE;

// Transcript constraints
CREATE CONSTRAINT transcript_id IF NOT EXISTS
FOR (t:Transcript) REQUIRE t.id IS UNIQUE;

// Entity constraints
CREATE CONSTRAINT entity_unique IF NOT EXISTS
FOR (e:Entity) REQUIRE (e.text, e.type) IS UNIQUE;

// Topic constraints
CREATE CONSTRAINT topic_name IF NOT EXISTS
FOR (t:Topic) REQUIRE t.name IS UNIQUE;

// Sentiment constraints
CREATE CONSTRAINT sentiment_id IF NOT EXISTS
FOR (s:Sentiment) REQUIRE s.id IS UNIQUE;

// Intent constraints
CREATE CONSTRAINT intent_type IF NOT EXISTS
FOR (i:Intent) REQUIRE i.type IS UNIQUE;

// ==================== INDEXES ====================
// Optimize query performance

// Conversation indexes
CREATE INDEX conversation_date IF NOT EXISTS
FOR (c:Conversation) ON (c.timestamp);

CREATE INDEX conversation_quality IF NOT EXISTS
FOR (c:Conversation) ON (c.quality_score);

CREATE INDEX conversation_sentiment IF NOT EXISTS
FOR (c:Conversation) ON (c.sentiment_score);

// Entity indexes
CREATE INDEX entity_type IF NOT EXISTS
FOR (e:Entity) ON (e.type);

CREATE INDEX entity_confidence IF NOT EXISTS
FOR (e:Entity) ON (e.confidence);

// Topic indexes
CREATE INDEX topic_weight IF NOT EXISTS
FOR (t:Topic) ON (t.weight);

// Sentiment indexes
CREATE INDEX sentiment_score IF NOT EXISTS
FOR (s:Sentiment) ON (s.score);

CREATE INDEX sentiment_polarity IF NOT EXISTS
FOR (s:Sentiment) ON (s.polarity);

// Transcript indexes
CREATE INDEX transcript_timestamp IF NOT EXISTS
FOR (t:Transcript) ON (t.timestamp);

CREATE INDEX transcript_confidence IF NOT EXISTS
FOR (t:Transcript) ON (t.confidence);

// ==================== FULL-TEXT INDEXES ====================
// Enable advanced text search

// Transcript full-text search
CREATE FULLTEXT INDEX transcript_text_search IF NOT EXISTS
FOR (t:Transcript) ON EACH [t.text];

// Entity full-text search
CREATE FULLTEXT INDEX entity_text_search IF NOT EXISTS
FOR (e:Entity) ON EACH [e.text];

// Topic keyword search
CREATE FULLTEXT INDEX topic_keyword_search IF NOT EXISTS
FOR (t:Topic) ON EACH [t.keywords];

// ==================== COMPOSITE INDEXES ====================
// Multi-property indexes for complex queries

CREATE INDEX entity_type_confidence IF NOT EXISTS
FOR (e:Entity) ON (e.type, e.confidence);

CREATE INDEX conversation_date_quality IF NOT EXISTS
FOR (c:Conversation) ON (c.timestamp, c.quality_score);

// ==================== SAMPLE DATA CREATION ====================
// Create sample conversation for testing

// Create conversation
CREATE (c:Conversation {
  id: 'conv_sample_001',
  timestamp: datetime('2024-01-15T10:30:00Z'),
  duration: 1847,
  quality_score: 87.5,
  sentiment_score: 72.3
});

// Create speakers
CREATE (s1:Speaker {
  id: 'speaker_001',
  name: 'Sales Representative',
  role: 'agent',
  email: 'sales.rep@company.com'
});

CREATE (s2:Speaker {
  id: 'speaker_002',
  name: 'Customer',
  role: 'customer',
  company: 'Acme Corp'
});

// Create participation relationships
MATCH (s:Speaker {id: 'speaker_001'}), (c:Conversation {id: 'conv_sample_001'})
CREATE (s)-[:PARTICIPATED_IN {
  word_count: 234,
  talk_time: 892,
  sentiment: 68.5,
  turn_count: 12
}]->(c);

MATCH (s:Speaker {id: 'speaker_002'}), (c:Conversation {id: 'conv_sample_001'})
CREATE (s)-[:PARTICIPATED_IN {
  word_count: 189,
  talk_time: 955,
  sentiment: 75.8,
  turn_count: 11
}]->(c);

// Create transcript segments
CREATE (t1:Transcript {
  id: 'trans_001',
  text: 'Hi, thank you for calling. How can I help you today?',
  timestamp: 0,
  confidence: 0.95,
  sequence: 0
});

CREATE (t2:Transcript {
  id: 'trans_002',
  text: 'Hello, I am interested in your enterprise solution for our team of 50 people.',
  timestamp: 5,
  confidence: 0.92,
  sequence: 1
});

CREATE (t3:Transcript {
  id: 'trans_003',
  text: 'Excellent! Our enterprise plan would be perfect for your needs. It includes advanced analytics and priority support.',
  timestamp: 12,
  confidence: 0.94,
  sequence: 2
});

// Link transcripts
MATCH (s:Speaker {id: 'speaker_001'}), (t:Transcript {id: 'trans_001'})
CREATE (s)-[:SPOKE]->(t);

MATCH (s:Speaker {id: 'speaker_002'}), (t:Transcript {id: 'trans_002'})
CREATE (s)-[:SPOKE]->(t);

MATCH (s:Speaker {id: 'speaker_001'}), (t:Transcript {id: 'trans_003'})
CREATE (s)-[:SPOKE]->(t);

MATCH (t:Transcript), (c:Conversation {id: 'conv_sample_001'})
WHERE t.id IN ['trans_001', 'trans_002', 'trans_003']
CREATE (t)-[:PART_OF]->(c);

// Create sentiment nodes
CREATE (sent1:Sentiment {
  id: 'sent_001',
  score: 68.5,
  polarity: 0.45,
  subjectivity: 0.62,
  dominant_emotion: 'neutral'
});

CREATE (sent2:Sentiment {
  id: 'sent_002',
  score: 82.3,
  polarity: 0.72,
  subjectivity: 0.58,
  dominant_emotion: 'joy'
});

MATCH (t:Transcript {id: 'trans_001'}), (s:Sentiment {id: 'sent_001'})
CREATE (t)-[:HAS_SENTIMENT]->(s);

MATCH (t:Transcript {id: 'trans_002'}), (s:Sentiment {id: 'sent_002'})
CREATE (t)-[:HAS_SENTIMENT]->(s);

// Create entities
CREATE (e1:Entity {
  id: 'entity_001',
  text: 'Acme Corp',
  type: 'ORGANIZATION',
  confidence: 0.96
});

CREATE (e2:Entity {
  id: 'entity_002',
  text: '50 people',
  type: 'QUANTITY',
  confidence: 0.94
});

CREATE (e3:Entity {
  id: 'entity_003',
  text: 'enterprise solution',
  type: 'PRODUCT',
  confidence: 0.89
});

// Link entities to conversation
MATCH (e:Entity), (c:Conversation {id: 'conv_sample_001'})
WHERE e.id IN ['entity_001', 'entity_002', 'entity_003']
CREATE (e)-[:MENTIONED_IN {count: 1}]->(c);

// Create entity relationships
MATCH (e1:Entity {text: 'Acme Corp'}), (e2:Entity {text: '50 people'})
CREATE (e1)-[:CO_OCCURS_WITH {count: 1, conversations: ['conv_sample_001']}]-(e2);

MATCH (e2:Entity {text: '50 people'}), (e3:Entity {text: 'enterprise solution'})
CREATE (e2)-[:CO_OCCURS_WITH {count: 1, conversations: ['conv_sample_001']}]-(e3);

// Create topics
CREATE (topic1:Topic {
  name: 'enterprise_sales',
  keywords: ['enterprise', 'solution', 'team', 'analytics', 'support'],
  weight: 0.85
});

CREATE (topic2:Topic {
  name: 'product_inquiry',
  keywords: ['interested', 'plan', 'features', 'pricing'],
  weight: 0.72
});

// Link topics
MATCH (t:Topic), (c:Conversation {id: 'conv_sample_001'})
WHERE t.name IN ['enterprise_sales', 'product_inquiry']
CREATE (t)-[:DISCUSSED_IN {relevance: t.weight}]->(c);

// Create intents
CREATE (i1:Intent {
  type: 'purchase_intent',
  confidence: 0.78
});

CREATE (i2:Intent {
  type: 'information_seeking',
  confidence: 0.91
});

MATCH (i:Intent), (c:Conversation {id: 'conv_sample_001'})
WHERE i.type IN ['purchase_intent', 'information_seeking']
CREATE (i)-[:DETECTED_IN {confidence: i.confidence, timestamp: datetime()}]->(c);

// ==================== ADVANCED QUERIES ====================
// Sample queries for testing

// 1. Find all high-quality conversations
MATCH (c:Conversation)
WHERE c.quality_score > 80
RETURN c.id, c.timestamp, c.quality_score, c.sentiment_score
ORDER BY c.quality_score DESC
LIMIT 10;

// 2. Analyze speaker performance
MATCH (s:Speaker)-[p:PARTICIPATED_IN]->(c:Conversation)
WITH s, 
     count(c) AS total_conversations,
     avg(p.sentiment) AS avg_sentiment,
     sum(p.word_count) AS total_words,
     avg(c.quality_score) AS avg_quality
RETURN s.name, 
       s.role,
       total_conversations,
       round(avg_sentiment, 2) AS avg_sentiment,
       total_words,
       round(avg_quality, 2) AS avg_quality
ORDER BY avg_quality DESC;

// 3. Find most frequently mentioned entities
MATCH (e:Entity)-[m:MENTIONED_IN]->(c:Conversation)
WITH e, sum(m.count) AS total_mentions, count(c) AS conversation_count
WHERE total_mentions > 5
RETURN e.text, e.type, total_mentions, conversation_count
ORDER BY total_mentions DESC
LIMIT 20;

// 4. Topic analysis across conversations
MATCH (t:Topic)-[d:DISCUSSED_IN]->(c:Conversation)
WITH t, count(c) AS frequency, avg(d.relevance) AS avg_relevance
RETURN t.name, t.keywords, frequency, round(avg_relevance, 3) AS avg_relevance
ORDER BY frequency DESC;

// 5. Sentiment trends over time
MATCH (c:Conversation)-[:HAS_SENTIMENT]->(s:Sentiment)
WHERE c.timestamp >= datetime() - duration({days: 7})
WITH date(c.timestamp) AS day, avg(s.score) AS avg_sentiment
RETURN day, round(avg_sentiment, 2) AS sentiment
ORDER BY day;

// 6. Entity co-occurrence network
MATCH (e1:Entity)-[r:CO_OCCURS_WITH]-(e2:Entity)
WHERE r.count > 3
RETURN e1.text, e1.type, e2.text, e2.type, r.count
ORDER BY r.count DESC
LIMIT 50;

// 7. Conversation pathways
MATCH path = (s:Speaker)-[:SPOKE]->(t:Transcript)-[:HAS_SENTIMENT]->(sent:Sentiment)
WHERE sent.score > 70
RETURN s.name, t.text, sent.score, sent.dominant_emotion
LIMIT 10;

// 8. Intent distribution
MATCH (i:Intent)-[d:DETECTED_IN]->(c:Conversation)
WITH i.type AS intent, count(c) AS count, avg(d.confidence) AS avg_confidence
RETURN intent, count, round(avg_confidence, 3) AS confidence
ORDER BY count DESC;

// ==================== GRAPH DATA SCIENCE ====================
// Prepare for GDS algorithms

// Create entity co-occurrence projection
CALL gds.graph.project(
  'entity-cooccurrence',
  'Entity',
  {
    CO_OCCURS_WITH: {
      orientation: 'UNDIRECTED',
      properties: 'count'
    }
  }
);

// Run PageRank
CALL gds.pageRank.stream('entity-cooccurrence')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).text AS entity, 
       gds.util.asNode(nodeId).type AS type,
       score
ORDER BY score DESC
LIMIT 20;

// Community Detection with Louvain
CALL gds.louvain.stream('entity-cooccurrence')
YIELD nodeId, communityId
WITH communityId, collect(gds.util.asNode(nodeId).text) AS members
WHERE size(members) > 2
RETURN communityId, members, size(members) AS size
ORDER BY size DESC;

// Betweenness Centrality
CALL gds.betweenness.stream('entity-cooccurrence')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).text AS entity, score
ORDER BY score DESC
LIMIT 10;

// Degree Centrality
CALL gds.degree.stream('entity-cooccurrence')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).text AS entity, score
ORDER BY score DESC
LIMIT 10;

// ==================== CLEANUP ====================
// Drop projection when done
CALL gds.graph.drop('entity-cooccurrence');

// ==================== VERIFICATION ====================
// Check schema creation
CALL db.constraints();
CALL db.indexes();
CALL db.schema.visualization();

// ============================================================
// Schema creation complete!
// Next steps:
// 1. Verify all constraints: CALL db.constraints();
// 2. Verify all indexes: CALL db.indexes();
// 3. Check sample data: MATCH (n) RETURN count(n);
// 4. Run sample queries above
// ============================================================
