"""
Pytest Configuration for Unit Tests
Provides fixtures for test database and TestClient
"""
import pytest
from typing import Generator
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
import os
os.environ["TESTING"] = "1"
# Ensure required settings exist for CI environments
os.environ.setdefault("SECRET_KEY", "test-secret-key-for-ci")
os.environ.setdefault("STRIPE_SECRET_KEY", "sk_test_placeholder")
os.environ.setdefault("STRIPE_PUBLISHABLE_KEY", "pk_test_placeholder")
os.environ.setdefault("STRIPE_WEBHOOK_SECRET", "whsec_placeholder")
os.environ.setdefault("DATABASE_URL", "sqlite:///./test.db")

from app.main import app
from app.db.base_class import Base
from app.api.deps import get_db

# Use DATABASE_URL from env if available, else fallback to SQLite
SQLALCHEMY_TEST_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

connect_args = {"check_same_thread": False} if SQLALCHEMY_TEST_DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(SQLALCHEMY_TEST_DATABASE_URL, connect_args=connect_args)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db() -> Generator[Session, None, None]:
    """
    Create a fresh database for each test function.
    """
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Create session
    session = TestingSessionLocal()
    
    try:
        yield session
    finally:
        session.close()
        # Drop all tables after test
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db: Session) -> Generator[TestClient, None, None]:
    """
    Create a TestClient with overridden database dependency.
    """
    def override_get_db():
        try:
            yield db
        finally:
            pass
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    # Clean up
    app.dependency_overrides.clear()


# --- Database Persistence for Test Results ---
results_data = []

def pytest_runtest_logreport(report):
    """
    Collect individual test results after each test 'call' phase.
    """
    if report.when == 'call':
        results_data.append({
            "nodeid": report.nodeid,
            "fspath": str(report.location[0]) if hasattr(report, 'location') and report.location else None,
            "status": report.outcome,
            "duration": report.duration,
            "error_message": str(report.longrepr) if report.failed else None
        })

def pytest_sessionfinish(session, exitstatus):
    """
    After the entire test session finishes, persist summarized results to the DB.
    """
    if not results_data:
        return

    # Use the application's actual database session, not the test one
    from app.db.session import SessionLocal, engine as main_engine
    from app.models.test_history import TestRun, TestResult
    from app.core.config import settings
    import os
    
    # Ensure tables exist in the target database
    # In production/real use, this should be done via migrations
    # But for this integration task, we ensure the history tables are there.
    Base.metadata.create_all(bind=main_engine)
    
    db = SessionLocal()
    try:
        # Calculate session stats
        passed = len([r for r in results_data if r["status"] == "passed"])
        failed = len([r for r in results_data if r["status"] == "failed"])
        skipped = len([r for r in results_data if r["status"] == "skipped"])
        total = len(results_data)
        duration = sum(r["duration"] for r in results_data)
        
        test_run = TestRun(
            total_tests=total,
            passed_count=passed,
            failed_count=failed,
            skipped_count=skipped,
            duration=duration,
            environment="unit-test",
            project_code=settings.PROJECT_NAME 
        )
        db.add(test_run)
        db.flush() # Get the generated TestRun ID
        
        # Add individual results
        for r in results_data:
            # Extract module code from fspath or nodeid
            try:
                # Prioritize fspath (absolute path usually)
                if r.get("fspath"):
                    filename = r["fspath"]
                else:
                    filename = r["nodeid"].split("::")[0]
                
                # Use pathlib to handle slash differences and extract stem
                from pathlib import Path
                path_obj = Path(filename)
                stem = path_obj.stem # e.g. test_examples
                
                if stem.startswith("test_"):
                    module_code = stem[5:] # examples
                else:
                    module_code = stem
            except Exception:
                module_code = "unknown"

            result = TestResult(
                test_run_id=test_run.id,
                nodeid=r["nodeid"],
                module_code=module_code,
                status=r["status"],
                duration=r["duration"],
                error_message=r["error_message"]
            )
            db.add(result)
        
        db.commit()
        print(f"\n[OK] Test results persisted to database (Run ID: {test_run.id})")
    except Exception as e:
        print(f"\n[ERROR] Failed to save test results to database: {e}")
        db.rollback()
    finally:
        db.close()
