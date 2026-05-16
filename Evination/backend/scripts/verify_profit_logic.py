from app.database import SessionLocal
from app.models.tax_commission_m import TaxCommissionMaster, MasterType
from app.models.expense_m import Expense
from app.services.report_service import ReportService
from datetime import date
import sys

def verify_profit():
    db = SessionLocal()
    try:
        print("🚀 Starting Logic Verification...")
        
        # 1. Create Tax Master
        tax = TaxCommissionMaster(
            name="Test GST",
            rate=0.18,
            type=MasterType.TAX,
            effective_date=date.today(),
            is_active=True
        )
        db.add(tax)
        print("✓ Created Tax Master")
        
        # 2. Create Expense
        expense = Expense(
            title="Server Cost",
            amount=500.0,
            category="Infrastructure",
            expense_date=date.today()
        )
        db.add(expense)
        print("✓ Created Expense (500.0)")
        
        db.commit()
        
        # 3. Test Report Service
        # Note: We might see 0 revenue if no orders are completed, 
        # but we should see the Expense and the formula working (negative profit).
        service = ReportService(db)
        # 1 is typically the Org ID seeded
        report = service.get_profit_report(1) 
        
        print("\n📊 Report Output:")
        for k, v in report.items():
            print(f"   {k}: {v}")
            
        # Verify Expense is included
        if report['platform_expenses'] >= 500.0:
            print("\n✅ SUCCESS: Expenses correctly factored into report.")
        else:
            print("\n❌ FAILURE: Expenses not found in report.")
            sys.exit(1)

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    verify_profit()
