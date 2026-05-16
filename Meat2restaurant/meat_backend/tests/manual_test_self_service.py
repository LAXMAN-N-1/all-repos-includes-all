import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import traceback
from fastapi.testclient import TestClient
from app.main import app
from app.api import deps
from app import models
from app.db.session import SessionLocal

# Mock Entities
mock_admin = models.User(id=1, email="admin@test.com", is_superuser=True, is_active=True)
mock_admin.identity_type = "staff"

mock_partner = models.Customer(id=100, email="partner@test.com")
mock_partner.identity_type = "partner"
mock_partner.is_active = True

mock_other_partner = models.Customer(id=200, email="other@test.com")
mock_other_partner.identity_type = "partner"
mock_other_partner.is_active = True

def run_tests():
    try:
        print("Initializing TestClient...")
        client = TestClient(app)
        
        # Setup Data
        db = SessionLocal()
        plan = db.query(models.MembershipPlan).filter_by(name="Self Plan").first()
        if not plan:
            plan = models.MembershipPlan(name="Self Plan", price=10, duration_days=30, is_active=True)
            db.add(plan)
            db.commit()
            db.refresh(plan)
        print(f"Plan ID: {plan.id}")

        # Ensure customers exist
        if not db.query(models.Customer).filter_by(id=mock_partner.id).first():
            db.add(mock_partner)
        if not db.query(models.Customer).filter_by(id=mock_other_partner.id).first():
            db.add(mock_other_partner)
        db.commit()
        
        assign_data = {"plan_id": plan.id}

        # --- Scene 1: Partner Self-Assign ---
        print("\n--- Testing Partner Self-Assign ---")
        app.dependency_overrides[deps.get_current_active_user] = lambda: mock_partner
        app.dependency_overrides[deps.get_current_active_superuser] = lambda: mock_partner # Should NOT be used, but safety
        
        resp = client.post(f"/api/v1/customers/{mock_partner.id}/membership", json=assign_data)
        print(f"Status: {resp.status_code}")
        if resp.status_code != 200:
            print(f"Error: {resp.text}")
        else:
            print("SUCCESS: Partner assigned self.")

        # --- Scene 2: Partner Cross-Assign ---
        print("\n--- Testing Partner Cross-Assign ---")
        resp = client.post(f"/api/v1/customers/{mock_other_partner.id}/membership", json=assign_data)
        print(f"Status: {resp.status_code}")
        if resp.status_code == 403:
            print("SUCCESS: Partner blocked from assigning other.")
        else:
            print(f"FAILURE: Expected 403, got {resp.status_code}")

        # --- Scene 3: Admin Assign ---
        print("\n--- Testing Admin Assign ---")
        app.dependency_overrides[deps.get_current_active_user] = lambda: mock_admin
        app.dependency_overrides[deps.get_current_active_superuser] = lambda: mock_admin

        resp = client.post(f"/api/v1/customers/{mock_other_partner.id}/membership", json=assign_data)
        print(f"Status: {resp.status_code}")
        if resp.status_code == 200:
            print("SUCCESS: Admin assigned to any.")
        else:
            print(f"FAILURE: Admin failed. {resp.text}")

    except Exception:
        traceback.print_exc()

if __name__ == "__main__":
    run_tests()
