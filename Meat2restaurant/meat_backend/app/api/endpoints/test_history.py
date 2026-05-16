from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api import deps
from app.models.test_history import TestRun, TestResult
from app.schemas.test_history import TestRun as TestRunSchema
from app.schemas.test_history import TestResult as TestResultSchema

router = APIRouter()

@router.get("/", response_model=List[TestRunSchema])
def read_test_runs(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 20,
) -> Any:
    """
    Retrieve test runs history.
    """
    runs = db.query(TestRun).order_by(TestRun.timestamp.desc()).offset(skip).limit(limit).all()
    return runs

@router.get("/{run_id}", response_model=TestRunSchema)
def read_test_run(
    run_id: int,
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Get a specific test run detail.
    """
    run = db.query(TestRun).filter(TestRun.id == run_id).first()
    if not run:
        raise HTTPException(status_code=404, detail="Test run not found")
    return run

@router.get("/{run_id}/results", response_model=List[TestResultSchema])
def read_test_results(
    run_id: int,
    db: Session = Depends(deps.get_db),
) -> Any:
    """
    Get all test results for a specific run.
    """
    results = db.query(TestResult).filter(TestResult.test_run_id == run_id).all()
    return results
