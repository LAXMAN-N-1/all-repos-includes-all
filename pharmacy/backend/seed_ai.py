import sys
import os

# Create a fake context to import app modules
sys.path.append(os.getcwd())

from app.database import SessionLocal, engine, Base
from app.models.customer_ai import MedicalCondition, SymptomProductMap
# Ensure tables exist
from app.models import customer_ai # Register models

def seed_ai_data():
    db = SessionLocal()
    try:
        print("Seeding AI Data...")
        
        # 1. Viral Fever
        fever = db.query(MedicalCondition).filter_by(name="Viral Fever").first()
        if not fever:
            fever = MedicalCondition(
                name="Viral Fever",
                description="Common viral infection characterized by high temperature.",
                symptom_keywords=["fever", "high temp", "hot", "shivering"],
                triage_questions=["How long have you had the fever?", "What is your temperature?"]
            )
            db.add(fever)
            db.commit()
            db.refresh(fever)
            print("Created Condition: Viral Fever")
            
            # Map Products (IDs are examples, ideally should match real products)
            # Dolo 650
            db.add(SymptomProductMap(condition_id=fever.id, product_id=101, relevance_score=95, is_prescription_required=False))
            # Thermometer
            db.add(SymptomProductMap(condition_id=fever.id, product_id=102, relevance_score=80))
            db.commit()
            
        # 2. Common Cold
        cold = db.query(MedicalCondition).filter_by(name="Common Cold").first()
        if not cold:
            cold = MedicalCondition(
                name="Common Cold",
                description="Viral infection of nose and throat.",
                symptom_keywords=["cold", "runny nose", "sneeze", "cough"],
                triage_questions=["Do you have a sore throat?", "Is the cough dry or wet?"]
            )
            db.add(cold)
            db.commit()
            db.refresh(cold)
            print("Created Condition: Common Cold")
            
            # Otrivin
            db.add(SymptomProductMap(condition_id=cold.id, product_id=201, relevance_score=90))
            # Vicks
            db.add(SymptomProductMap(condition_id=cold.id, product_id=202, relevance_score=85))
            db.commit()
        
        print("Seeding Complete!")
            
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    # Create tables if they don't exist (Quick fix for dev)
    # Base.metadata.create_all(bind=engine) 
    # Better to rely on migrations, but for this specific new module we might need to run this.
    # Given I didn't run alembic, I will rely on auto-create or run this:
    Base.metadata.create_all(bind=engine)
    seed_ai_data()
