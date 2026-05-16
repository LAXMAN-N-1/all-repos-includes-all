import json
import os
import joblib
import pandas as pd
from sentence_transformers import SentenceTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report

# Configuration
DATASET_PATH = "backend/ml_engine/dataset/intents.json"
MODEL_DIR = "backend/ml_engine/models"
EMBEDDING_MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

def train_model():
    print("Loading data...")
    if not os.path.exists(DATASET_PATH):
        print(f"Error: Dataset not found at {DATASET_PATH}")
        return

    with open(DATASET_PATH, 'r') as f:
        data = json.load(f)
    
    df = pd.DataFrame(data)
    print(f"Loaded {len(df)} examples.")
    print(df['intent'].value_counts())

    # 1. Generate Embeddings
    print(f"Loading Embedding Model: {EMBEDDING_MODEL_NAME}...")
    embedder = SentenceTransformer(EMBEDDING_MODEL_NAME)
    X_embeddings = embedder.encode(df['text'].tolist(), show_progress_bar=True)

    # 2. Encode Labels
    print("Encoding labels...")
    label_encoder = LabelEncoder()
    y_labels = label_encoder.fit_transform(df['intent'])

    # 3. Train Classifier
    print("Training Classifier...")
    clf = LogisticRegression(random_state=42, max_iter=1000)
    clf.fit(X_embeddings, y_labels)

    # 4. Evaluate (Simple check on training data)
    y_pred = clf.predict(X_embeddings)
    print("\nTraining Metrics:")
    print(classification_report(y_labels, y_pred, target_names=label_encoder.classes_))

    # 5. Save Artifacts
    if not os.path.exists(MODEL_DIR):
        os.makedirs(MODEL_DIR)

    joblib.dump(clf, os.path.join(MODEL_DIR, "nlu_classifier.pkl"))
    joblib.dump(label_encoder, os.path.join(MODEL_DIR, "label_encoder.pkl"))
    
    # Save metadata about model used
    with open(os.path.join(MODEL_DIR, "config.json"), "w") as f:
        json.dump({"embedding_model": EMBEDDING_MODEL_NAME}, f)

    print(f"Model artifacts saved to {MODEL_DIR}")

if __name__ == "__main__":
    train_model()
