"""
Unit test for invoice scheduler logic (no server required)
Tests the billing cycle calculation and invoice generation logic
"""
from datetime import date, timedelta
from app.services.invoice_scheduler import should_generate_invoice, get_invoice_date_range
from app.features.customers.models.customer import Customer, BillingCycle

def test_billing_cycle_logic():
    print("=" * 70)
    print("INVOICE SCHEDULER LOGIC TEST (Unit Test)")
    print("=" * 70)
    
    # Test 1: Weekly billing cycle
    print("\n[Test 1] Weekly Billing Cycle")
    customer_weekly = Customer(
        id=1,
        name="Weekly Restaurant",
        email="weekly@test.com",
        customer_type="b2b",
        billing_cycle=BillingCycle.WEEKLY,
        last_combined_invoice_date=None
    )
    
    result = should_generate_invoice(None, customer_weekly, date.today())
    print(f"   Customer: {customer_weekly.name}")
    print(f"   Billing Cycle: {customer_weekly.billing_cycle}")
    print(f"   Last Invoice Date: {customer_weekly.last_combined_invoice_date}")
    print(f"   Should Generate Today: {result}")
    assert result == True, "Should generate for first time"
    print("   ✅ PASS: Generates invoice for first time")
    
    # Test 2: Weekly - 5 days since last invoice
    print("\n[Test 2] Weekly - 5 Days Since Last Invoice")
    customer_weekly.last_combined_invoice_date = date.today() - timedelta(days=5)
    result = should_generate_invoice(None, customer_weekly, date.today())
    print(f"   Last Invoice Date: {customer_weekly.last_combined_invoice_date}")
    print(f"   Days Since Last: 5")
    print(f"   Should Generate Today: {result}")
    assert result == False, "Should NOT generate (only 5 days)"
    print("   ✅ PASS: Does not generate too early")
    
    # Test 3: Weekly - 7 days since last invoice
    print("\n[Test 3] Weekly - 7 Days Since Last Invoice")
    customer_weekly.last_combined_invoice_date = date.today() - timedelta(days=7)
    result = should_generate_invoice(None, customer_weekly, date.today())
    print(f"   Last Invoice Date: {customer_weekly.last_combined_invoice_date}")
    print(f"   Days Since Last: 7")
    print(f"   Should Generate Today: {result}")
    assert result == True, "Should generate after 7 days"
    print("   ✅ PASS: Generates after 7 days")
    
    # Test 4: 10-day billing cycle
    print("\n[Test 4] 10-Day Billing Cycle")
    customer_10day = Customer(
        id=2,
        name="10-Day Restaurant",
        email="10day@test.com",
        customer_type="b2b",
        billing_cycle=BillingCycle.TEN_DAYS,
        last_combined_invoice_date=date.today() - timedelta(days=10)
    )
    result = should_generate_invoice(None, customer_10day, date.today())
    print(f"   Customer: {customer_10day.name}")
    print(f"   Billing Cycle: {customer_10day.billing_cycle}")
    print(f"   Days Since Last: 10")
    print(f"   Should Generate Today: {result}")
    assert result == True, "Should generate after 10 days"
    print("   ✅ PASS: Generates after 10 days")
    
    # Test 5: Monthly billing cycle
    print("\n[Test 5] Monthly Billing Cycle")
    customer_monthly = Customer(
        id=3,
        name="Monthly Restaurant",
        email="monthly@test.com",
        customer_type="b2b",
        billing_cycle=BillingCycle.MONTHLY,
        last_combined_invoice_date=date.today() - timedelta(days=30)
    )
    result = should_generate_invoice(None, customer_monthly, date.today())
    print(f"   Customer: {customer_monthly.name}")
    print(f"   Billing Cycle: {customer_monthly.billing_cycle}")
    print(f"   Days Since Last: 30")
    print(f"   Should Generate Today: {result}")
    assert result == True, "Should generate after 28+ days"
    print("   ✅ PASS: Generates after 30 days")
    
    # Test 6: Immediate billing cycle (should skip)
    print("\n[Test 6] Immediate Billing Cycle (Should Skip)")
    customer_immediate = Customer(
        id=4,
        name="Immediate Restaurant",
        email="immediate@test.com",
        customer_type="b2b",
        billing_cycle=BillingCycle.IMMEDIATE,
        last_combined_invoice_date=None
    )
    result = should_generate_invoice(None, customer_immediate, date.today())
    print(f"   Customer: {customer_immediate.name}")
    print(f"   Billing Cycle: {customer_immediate.billing_cycle}")
    print(f"   Should Generate Today: {result}")
    assert result == False, "Should NOT generate for immediate billing"
    print("   ✅ PASS: Skips immediate billing cycle")
    
    # Test 7: Date range calculation
    print("\n[Test 7] Date Range Calculation")
    customer_weekly.last_combined_invoice_date = date.today() - timedelta(days=7)
    start_date, end_date = get_invoice_date_range(customer_weekly, date.today())
    print(f"   Last Invoice Date: {customer_weekly.last_combined_invoice_date}")
    print(f"   Start Date: {start_date}")
    print(f"   End Date: {end_date}")
    print(f"   Days in Range: {(end_date - start_date).days}")
    assert start_date == customer_weekly.last_combined_invoice_date + timedelta(days=1)
    assert end_date == date.today()
    print("   ✅ PASS: Date range calculated correctly")
    
    # Summary
    print("\n" + "=" * 70)
    print("✅ ALL TESTS PASSED!")
    print("=" * 70)
    print("\n📊 Test Summary:")
    print("   - Weekly billing cycle: ✅")
    print("   - 10-day billing cycle: ✅")
    print("   - Monthly billing cycle: ✅")
    print("   - Immediate billing cycle (skip): ✅")
    print("   - First-time generation: ✅")
    print("   - Date range calculation: ✅")
    print("\n💡 The invoice scheduler logic is working correctly!")
    print("   When the server is running, call POST /api/invoices/auto-generate-all")
    print("   to automatically generate invoices for all eligible customers.")
    print()

if __name__ == "__main__":
    try:
        test_billing_cycle_logic()
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
