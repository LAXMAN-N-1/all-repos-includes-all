from fpdf import FPDF
import os
import math
from datetime import datetime
from app.core.config import settings

class InvoicePDF(FPDF):
    def header(self):
        # Logo
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        logo_path = os.path.join(base_dir, "app", "static", "images", "logo_invoice.png")
        if os.path.exists(logo_path):
            # FPDF can't handle JPEG with .png extension well
            self.image(logo_path, 10, 8, 30, type='JPEG' if '.png' in logo_path.lower() else '')
        
        self.set_font('Arial', 'B', 12)
        self.cell(80)
        self.cell(30, 10, 'B2B MEAT PLATFORM', 0, 0, 'C')
        self.ln(20)

    def footer(self):
        self.set_y(-15)
        self.set_font('Arial', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

class InvoiceService:
    def __init__(self):
        # Base directory of the project (one level up from 'app')
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        self.output_dir = os.path.join(base_dir, "static", "invoices")
        
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir, exist_ok=True)

    def generate_pdf(self, invoice, customer, items=None):
        """
        Generate a PDF for a regular invoice following ERP-Grade Blueprint (A-H).
        """
        # MANDATORY PRE-PDF VALIDATION
        item_total = sum(item.total_price for item in items) if items else 0.0
        # Subtotal should ideally match item total, but legacy data may include fees in subtotal
        if not math.isclose(invoice.subtotal, item_total, rel_tol=1e-5):
             delivery_fee = invoice.order.delivery_fee if (invoice.order and invoice.order.delivery_fee) else 0.0
             platform_fee = invoice.order.platform_fee if (invoice.order and invoice.order.platform_fee) else 0.0
             if math.isclose(invoice.subtotal, item_total + delivery_fee + platform_fee, abs_tol=0.02):
                 print(f"INFO: [PDF-VAL] Invoice {invoice.id} subtotal includes fees. Proceeding.")
             elif math.isclose(invoice.subtotal, item_total + delivery_fee, abs_tol=0.02):
                 print(f"INFO: [PDF-VAL] Invoice {invoice.id} subtotal includes delivery fee. Proceeding.")
             else:
                 print(f"WARNING: [PDF-VAL] Subtotal mismatch: {invoice.subtotal} != {item_total}. Data may be inconsistent.")
        
        # Total Due MUST be consistent with items + fees
        delivery_fee = invoice.order.delivery_fee if (invoice.order and invoice.order.delivery_fee) else 0.0
        platform_fee = invoice.order.platform_fee if (invoice.order and invoice.order.platform_fee) else 0.0
        expected_total = item_total - invoice.discount_amount + invoice.tax_total + delivery_fee + platform_fee
        
        if not math.isclose(invoice.amount_due, expected_total, rel_tol=1e-5):
             print(f"DEBUG: [PDF-VAL] Total Due mismatch: {invoice.amount_due} != {expected_total} (Items: {item_total}, Fee: {delivery_fee}, Plat: {platform_fee})")
             assert math.isclose(invoice.amount_due, expected_total, abs_tol=0.05), f"Validation Failed: Mathematical inconsistency {invoice.amount_due} != {expected_total}"

        pdf = InvoicePDF()
        pdf.add_page()
        pdf.set_font('Arial', '', 10)

        # --- SECTION A: Header ---
        pdf.set_font('Arial', 'B', 16)
        pdf.cell(0, 10, "INVOICE", ln=1, align='R')
        pdf.set_font('Arial', '', 10)
        pdf.cell(130, 6, f"Invoice ID: INV-{invoice.id:05d}", ln=0)
        pdf.cell(60, 6, f"Date: {invoice.created_at.strftime('%Y-%m-%d')}", ln=1, align='R')
        pdf.cell(130, 6, "", ln=0)
        pdf.cell(60, 6, f"Due Date: {invoice.due_date.strftime('%Y-%m-%d')}", ln=1, align='R')
        pdf.cell(130, 6, f"Status: {invoice.status.upper()}", ln=1)
        pdf.ln(5)

        # --- SECTION B: Customer Details ---
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(0, 8, "Billed To:", ln=1)
        pdf.set_font('Arial', '', 11)
        pdf.cell(0, 5, customer.name, ln=1)
        pdf.cell(0, 5, customer.email or "", ln=1)
        pdf.cell(0, 5, customer.phone or "", ln=1)
        pdf.cell(0, 5, customer.address or "No registered address", ln=1)
        pdf.ln(5)

        # --- SECTION C: Order Reference ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "Order Reference:", ln=1)
        pdf.set_font('Arial', '', 10)
        pdf.cell(60, 5, f"Order ID: {invoice.order_id or 'N/A'}", ln=0)
        if invoice.order:
            pdf.cell(60, 5, f"Order Date: {invoice.order.created_at.strftime('%Y-%m-%d')}", ln=0)
            pdf.cell(60, 5, f"Terms: {invoice.order.payment_terms or 'Due on Receipt'}", ln=1)
        else:
            pdf.ln(5)
        pdf.ln(5)

        # --- SECTION D: Line Items ---
        pdf.set_fill_color(240, 240, 240)
        pdf.set_font('Arial', 'B', 10)
        pdf.cell(90, 8, "Product Description", 1, 0, 'C', 1)
        pdf.cell(25, 8, "Qty", 1, 0, 'C', 1)
        pdf.cell(35, 8, "Unit Price", 1, 0, 'C', 1)
        pdf.cell(40, 8, "Line Total", 1, 1, 'C', 1)

        pdf.set_font('Arial', '', 10)
        if items:
            for item in items:
                prod_name = item.product.name if (item.product and item.product.name) else f"Product ID: {item.product_id}"
                # Truncate if too long to prevent overlap (width 90mm ~ 45-50 chars)
                if len(prod_name) > 45:
                    prod_name = prod_name[:42] + "..."
                
                pdf.cell(90, 8, prod_name, 1)
                pdf.cell(25, 8, str(item.quantity), 1, 0, 'C')
                pdf.cell(35, 8, f"${item.unit_price:,.2f}", 1, 0, 'C')
                pdf.cell(40, 8, f"${item.total_price:,.2f}", 1, 1, 'C')
        else:
            pdf.cell(190, 8, "No items listed", 1, 1, 'C')
        pdf.ln(5)

        # --- SECTION E & F: Parallel Columns (Calculation & Credit) ---
        block_start_y = pdf.get_y()
        
        # Right Side: Calculation Block
        pdf.set_font('Arial', '', 11)
        pdf.set_x(130)
        pdf.cell(30, 8, "Subtotal:", 0)
        pdf.cell(30, 8, f"${invoice.subtotal:,.2f}", 0, 1, 'R')
        
        if invoice.discount_amount > 0:
            pdf.set_x(130)
            pdf.set_text_color(200, 0, 0)
            pdf.cell(30, 8, f"Discount ({invoice.discount_percentage}%):", 0)
            pdf.cell(30, 8, f"-${invoice.discount_amount:,.2f}", 0, 1, 'R')
            pdf.set_text_color(0, 0, 0)
            
        if invoice.tax_total > 0:
            pdf.set_x(130)
            pdf.cell(30, 8, "Tax:", 0)
            pdf.cell(30, 8, f"${invoice.tax_total:,.2f}", 0, 1, 'R')
            
        # Add Fees
        if invoice.order:
            if invoice.order.delivery_fee > 0:
                pdf.set_x(130)
                pdf.cell(30, 8, "Delivery Fee:", 0)
                pdf.cell(30, 8, f"${invoice.order.delivery_fee:,.2f}", 0, 1, 'R')
            if invoice.order.platform_fee > 0:
                pdf.set_x(130)
                pdf.cell(30, 8, "Platform Fee:", 0)
                pdf.cell(30, 8, f"${invoice.order.platform_fee:,.2f}", 0, 1, 'R')

        pdf.set_x(130)
        pdf.line(130, pdf.get_y(), 190, pdf.get_y())
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(30, 10, "Total Due:", 0)
        pdf.cell(30, 10, f"${invoice.amount_due:,.2f}", 0, 1, 'R')
        calc_end_y = pdf.get_y()

        # Left Side: Credit Info (Reset to block_start_y)
        pdf.set_y(block_start_y)
        pdf.set_x(10)
        pdf.set_font('Arial', 'B', 10)
        pdf.cell(100, 6, "Credit Information:", ln=1) # Width limited to 100
        pdf.set_font('Arial', '', 9)
        pdf.set_x(10)
        pdf.cell(100, 5, f"Credit Line Applied: ${invoice.amount_due:,.2f}", ln=1)
        remaining_credit = customer.credit_limit - customer.current_balance
        pdf.set_x(10)
        pdf.cell(100, 5, f"Projected Remaining Credit: ${remaining_credit:,.2f}", ln=1)
        credit_end_y = pdf.get_y()
        
        # --- SECTION G: Payment Instructions ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "Payment Instructions:", ln=1)
        pdf.set_font('Arial', '', 10)
        pdf.multi_cell(0, 5, "Please remit payment via Bank Transfer or UPI.\n"
                             "Bank: HDFC Bank | AC: 50100XXXXXXX | IFSC: HDFC0001234\n"
                             f"MANDATORY REFERENCE ID: PAY-INV-{invoice.id:05d}")
        pdf.ln(5)

        # --- SECTION H: Audit Note ---
        pdf.set_font('Arial', 'I', 9)
        pdf.set_text_color(100, 100, 100)
        pdf.multi_cell(0, 5, "This invoice represents a single order. Payment restores credit line immediately upon processing.")

        file_name = f"invoice_{invoice.id}.pdf"
        file_path = os.path.join(self.output_dir, file_name)
        pdf.output(file_path, 'F')
        return f"/static/invoices/{file_name}"

    def generate_combined_pdf(self, combined_invoice, customer, sub_invoices):
        """
        Generate a PDF for a combined/consolidated invoice following ERP-Grade Blueprint (A-J).
        """
        # 1. Statement Subtotal MUST be sum of individual invoice net amounts (amount_due)
        # statement_subtotal = Σ(individual_invoice.amount_due)
        expected_subtotal = sum((inv.amount_due or 0.0) for inv in sub_invoices)
        
        assert math.isclose(combined_invoice.subtotal, expected_subtotal, abs_tol=0.02), f"Validation Failed: Statement Subtotal {combined_invoice.subtotal} != {expected_subtotal}"
        
        # 2. Discount Total MUST be Subtotal * Rate
        discount_rate = (combined_invoice.discount_percentage / 100.0)
        expected_discount = combined_invoice.subtotal * discount_rate
        assert math.isclose(combined_invoice.discount_amount, expected_discount, abs_tol=0.02), f"Validation Failed: Discount Math {combined_invoice.discount_amount} != {expected_discount}"
        
        # 3. Total Payable MUST be Subtotal - Discount
        expected_total = combined_invoice.subtotal - combined_invoice.discount_amount
        assert math.isclose(combined_invoice.total_amount, expected_total, abs_tol=0.02), f"Validation Failed: Statement Total {combined_invoice.total_amount} != {expected_total}"

        # 4. Product Summary is informational only. Financial totals come from invoices.

        pdf = InvoicePDF()
        pdf.add_page()
        pdf.set_font('Arial', '', 10)

        # --- SECTION A: Header ---
        pdf.set_font('Arial', 'B', 16)
        pdf.cell(0, 10, "STATEMENT OF ACCOUNT", ln=1, align='C')
        pdf.set_font('Arial', '', 10)
        pdf.cell(0, 5, "(Combined Invoice)", ln=1, align='C')
        pdf.ln(5)
        
        pdf.cell(130, 6, f"Combined Invoice ID: STMT-{combined_invoice.id:05d}", ln=0)
        pdf.cell(60, 6, f"Generation Date: {combined_invoice.invoice_date.strftime('%Y-%m-%d')}", ln=1, align='R')
        
        # Calculate Period
        if sub_invoices:
            sorted_dates = sorted([inv.created_at for inv in sub_invoices])
            start_date = sorted_dates[0]
            end_date = sorted_dates[-1]
        else:
            start_date = end_date = combined_invoice.invoice_date
            
        pdf.cell(130, 6, f"Billing Period: {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}", ln=0)
        if combined_invoice.due_date:
            pdf.set_text_color(200, 0, 0)
            pdf.cell(60, 6, f"Payment Due Date: {combined_invoice.due_date.strftime('%Y-%m-%d')}", ln=1, align='R')
            pdf.set_text_color(0, 0, 0)
        else:
            pdf.ln(6)
        pdf.cell(0, 6, f"Status: {combined_invoice.status.upper()}", ln=1)
        pdf.ln(5)

        # --- SECTION B: Customer Details ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "Customer Details:", ln=1)
        pdf.set_font('Arial', '', 10)
        pdf.cell(0, 5, customer.name, ln=1)
        pdf.cell(0, 5, customer.address or "No registered address", ln=1)
        pdf.cell(0, 5, f"Email: {customer.email}", ln=1)
        pdf.ln(5)

        # --- SECTION C: Credit Summary ---
        pdf.set_fill_color(245, 245, 245)
        pdf.rect(10, pdf.get_y(), 190, 25, 'F')
        pdf.set_y(pdf.get_y() + 2)
        
        pdf.set_font('Arial', 'B', 9)
        pdf.set_x(15)
        pdf.cell(45, 5, "Credit Limit", 0)
        pdf.cell(45, 5, "Credit Used (This)", 0)
        pdf.cell(45, 5, "Payments Received", 0)
        pdf.cell(45, 5, "Available Credit*", 1)
        
        pdf.set_font('Arial', '', 11)
        pdf.set_x(15)
        pdf.cell(45, 8, f"${customer.credit_limit:,.2f}", 0)
        pdf.cell(45, 8, f"${combined_invoice.total_amount:,.2f}", 0)
        pdf.cell(45, 8, "$0.00", 0) # Placeholder for payments received in this cycle
        available = customer.credit_limit - combined_invoice.total_amount
        pdf.cell(45, 8, f"${available:,.2f}", 1)
        
        pdf.set_font('Arial', 'I', 8)
        pdf.set_x(15)
        pdf.cell(0, 5, "* Available credit if this statement is settled immediately.", ln=1)
        pdf.ln(5)

        # --- SECTION D: Billing Summary ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "Billing Summary:", ln=1)
        pdf.set_font('Arial', '', 10)
        total_orders = len(set(inv.order_id for inv in sub_invoices if inv.order_id))
        pdf.cell(60, 5, f"Total Invoices Included: {len(sub_invoices)}", ln=0)
        pdf.cell(60, 5, f"Total Orders Covered: {total_orders}", ln=0)
        pdf.set_font('Arial', 'B', 10)
        pdf.cell(70, 5, f"Total Payable: ${combined_invoice.total_amount:,.2f}", ln=1, align='R')
        pdf.ln(5)

        # --- SECTION E: Product Consolidation Summary (INFORMATIONAL ONLY) ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "1. Product Consolidation Summary (Informational Only):", ln=1)
        pdf.set_font('Arial', 'I', 8)
        pdf.cell(0, 5, "Product summary is for readability only. Financial totals come from authoritative invoices.", ln=1)
        pdf.set_fill_color(230, 230, 230)
        pdf.set_font('Arial', 'B', 9)
        pdf.cell(80, 7, "Product Name", 1, 0, 'C', 1)
        pdf.cell(20, 7, "Qty", 1, 0, 'C', 1)
        pdf.cell(25, 7, "Orders", 1, 0, 'C', 1)
        pdf.cell(30, 7, "Avg Unit Price", 1, 0, 'C', 1)
        pdf.cell(35, 7, "Total", 1, 1, 'C', 1)

        pdf.set_font('Arial', '', 9)
        aggregated_items = {}
        for inv in sub_invoices:
            if inv.order and inv.order.items:
                for item in inv.order.items:
                    key = (item.product_id, item.unit_price)
                    if key not in aggregated_items:
                        prod_name = item.product.name if item.product else f"Product ID: {item.product_id}"
                        aggregated_items[key] = {"name": prod_name, "qty": 0, "order_ids": set(), "unit_price": item.unit_price, "total": 0.0}
                    aggregated_items[key]["qty"] += item.quantity
                    aggregated_items[key]["order_ids"].add(inv.order_id)
                    aggregated_items[key]["total"] += item.total_price

        for details in aggregated_items.values():
            prod_name = details["name"]
            # Truncate if long (width 80mm ~ 40-45 chars)
            if len(prod_name) > 42:
                prod_name = prod_name[:39] + "..."
                
            pdf.cell(80, 7, prod_name, 1)
            pdf.cell(20, 7, str(details["qty"]), 1, 0, 'C')
            pdf.cell(25, 7, str(len(details["order_ids"])), 1, 0, 'C')
            pdf.cell(30, 7, f"${details['unit_price']:,.2f}", 1, 0, 'C')
            pdf.cell(35, 7, f"${details['total']:,.2f}", 1, 1, 'C')
        pdf.ln(5)

        # --- SECTION F: Individual Invoice Breakdown ---
        if pdf.get_y() > 220: pdf.add_page()
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "2. Individual Invoice Breakdown:", ln=1)
        pdf.set_font('Arial', 'B', 9)
        pdf.cell(30, 7, "Invoice ID", 1, 0, 'C', 1)
        pdf.cell(30, 7, "Order ID", 1, 0, 'C', 1)
        pdf.cell(35, 7, "Date", 1, 0, 'C', 1)
        pdf.cell(30, 7, "Status", 1, 0, 'C', 1)
        pdf.cell(65, 7, "Amount Due", 1, 1, 'C', 1)

        pdf.set_font('Arial', '', 9)
        for inv in sub_invoices:
            pdf.cell(30, 7, f"INV-{inv.id:05d}", 1, 0, 'C')
            pdf.cell(30, 7, str(inv.order_id or "N/A"), 1, 0, 'C')
            pdf.cell(35, 7, inv.created_at.strftime('%Y-%m-%d'), 1, 0, 'C')
            pdf.cell(30, 7, inv.status.upper(), 1, 0, 'C')
            pdf.cell(65, 7, f"${inv.amount_due:,.2f}", 1, 1, 'R')
        pdf.ln(5)

        # --- SECTION G: Payment History (If any) ---
        # For simplicity, if no payments linked, show message
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "3. Recent Payments / Credits:", ln=1)
        pdf.set_font('Arial', 'I', 9)
        pdf.cell(0, 7, "No payments recorded for this billing cycle.", ln=1)
        pdf.ln(5)

        # --- SECTION H: Final Calculation Block ---
        if pdf.get_y() > 230: pdf.add_page()
        curr_y = pdf.get_y()
        pdf.set_x(120)
        pdf.set_font('Arial', '', 11)
        pdf.cell(40, 7, "Statement Subtotal:", 0)
        pdf.cell(30, 7, f"${combined_invoice.subtotal:,.2f}", 0, 1, 'R')
        
        if combined_invoice.discount_amount > 0:
            pdf.set_x(120)
            pdf.set_text_color(200, 0, 0)
            pdf.cell(40, 7, f"Discount ({combined_invoice.discount_percentage}%):", 0)
            pdf.cell(30, 7, f"-${combined_invoice.discount_amount:,.2f}", 0, 1, 'R')
            pdf.set_text_color(0, 0, 0)
            
        pdf.set_x(120)
        pdf.line(120, pdf.get_y(), 190, pdf.get_y())
        pdf.ln(1)
        pdf.set_x(120)
        pdf.set_font('Arial', 'B', 12)
        pdf.cell(40, 10, "Total Payable:", 0)
        pdf.cell(30, 10, f"${combined_invoice.total_amount:,.2f}", 0, 1, 'R')
        pdf.ln(5)

        # --- SECTION I: Payment Instructions ---
        pdf.set_font('Arial', 'B', 11)
        pdf.cell(0, 8, "Payment Instructions:", ln=1)
        pdf.set_font('Arial', '', 10)
        pdf.multi_cell(0, 5, "Please settle the outstanding balance via Bank Transfer or UPI.\n"
                             "Bank: HDFC Bank | AC: 50100XXXXXXX | IFSC: HDFC0001234\n"
                             f"MANDATORY REFERENCE ID: PAY-STMT-{combined_invoice.id:05d}")
        pdf.ln(5)

        # --- SECTION J: Audit & Legal Note ---
        pdf.set_font('Arial', 'I', 9)
        pdf.set_text_color(100, 100, 100)
        pdf.multi_cell(0, 5, "Audit Note: This combined invoice was generated as per the admin-defined billing schedule and includes all unpaid orders up to the cutoff date. Payment of this statement validates the order fulfillment and restores the customer's credit line.")

        file_name = f"combined_invoice_{combined_invoice.id}.pdf"
        file_path = os.path.join(self.output_dir, file_name)
        pdf.output(file_path, 'F')
        return f"/static/invoices/{file_name}"
        
        # Output
        file_name = f"combined_invoice_{combined_invoice.id}.pdf"
        file_path = os.path.join(self.output_dir, file_name)
        pdf.output(file_path, 'F')
        return f"/static/invoices/{file_name}"

invoice_service = InvoiceService()
