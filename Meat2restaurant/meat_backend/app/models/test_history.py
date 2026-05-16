from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db.base_class import Base

class TestRun(Base):
    __tablename__ = "test_runs"

    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    total_tests = Column(Integer)
    passed_count = Column(Integer)
    failed_count = Column(Integer)
    skipped_count = Column(Integer)
    duration = Column(Float)  # In seconds
    environment = Column(String(50), default="unit-test")
    project_code = Column(String(50), default="MEAT-BACKED")

    results = relationship("TestResult", back_populates="test_run", cascade="all, delete-orphan")

class TestResult(Base):
    __tablename__ = "test_results"

    id = Column(Integer, primary_key=True, index=True)
    test_run_id = Column(Integer, ForeignKey("test_runs.id"))
    nodeid = Column(String(500))  # Unique ID of the test
    module_code = Column(String(50)) # e.g. "gift_cards", "auth" - Extracted from filename
    status = Column(String(20))   # passed, failed, skipped
    duration = Column(Float)
    error_message = Column(Text, nullable=True)

    test_run = relationship("TestRun", back_populates="results")
