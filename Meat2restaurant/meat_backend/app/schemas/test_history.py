from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

class TestResultBase(BaseModel):
    nodeid: str
    module_code: Optional[str] = None
    status: str
    duration: float
    error_message: Optional[str] = None

class TestResult(TestResultBase):
    id: int
    test_run_id: int

    class Config:
        from_attributes = True

class TestRunBase(BaseModel):
    timestamp: datetime
    total_tests: int
    passed_count: int
    failed_count: int
    skipped_count: int
    duration: float
    environment: str
    project_code: str = "MEAT-BACKED"

class TestRun(TestRunBase):
    id: int
    results: List[TestResult] = []

    class Config:
        from_attributes = True
