import sys
import os
from unittest.mock import patch

sys.path.append(os.path.join(os.getcwd(), "backend"))

os.environ["DATABASE_URL"] = "postgresql://user:pass@localhost/db"
os.environ["SECRET_KEY"] = "super-secret-key"

try:
    from app.models import (
        StockTransfer, StockAdjustment,
        Invoice, Transaction,
        Patient, Doctor, Ward,
        Employee, Attendance, Shift,
        Module, OrganizationModule,
        LabTest, LabRequest, LabResult,
        InsuranceProvider, PatientPolicy, Claim,
        Plan, Subscription, PlatformInvoice,
        StoreLicense, DrugRecall,
        ReportJob, ScheduledReport, DashboardConfig,
        DemandForecast, SupplierScorecard, ReorderRule,
        ExternalSystem, IntegrationLog, ApiKey,
        UserDevice
    )
    print("✅ All System Models (Phase 1, 2, & 3) imported successfully.")
except Exception as e:
    print(f"❌ Error importing models: {e}")
    sys.exit(1)
