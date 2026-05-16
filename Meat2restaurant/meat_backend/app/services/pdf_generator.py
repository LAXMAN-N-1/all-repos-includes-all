import os
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.units import inch

class PDFGenerator:
    def __init__(self, output_dir="static/invoices"):
        self.output_dir = output_dir
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
        self.styles = getSampleStyleSheet()

    def generate_invoice(self, order_data):
        """
        order_data = {
            "order_id": "M2R-847291",
            "date": "2026-03-10",
            "customer_name": "Ahmed",
            "customer_phone": "+1234567890",
            "store": "Dallas (DFW)",
            "items": [
                {"name": "Goat Curry Cut", "qty": "2 boxes (80 lbs)", "price": "$719.20"},
                {"name": "Whole Chicken", "qty": "1 box (40 lbs)", "price": "$159.60"}
            ],
            "subtotal": "$878.80",
            "tax": "$72.50",
            "total": "$951.30",
            "payment_method": "Cash on Delivery"
        }
        """
        filename = f"invoice_{order_data['order_id']}.pdf".replace("#", "")
        filepath = os.path.join(self.output_dir, filename)
        
        doc = SimpleDocTemplate(filepath, pagesize=letter)
        elements = []

        # Header
        header_style = ParagraphStyle(
            'HeaderStyle',
            parent=self.styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor("#2E7D32"),
            alignment=1, # Center
            spaceAfter=20
        )
        elements.append(Paragraph("Meat2Restaurant", header_style))
        elements.append(Paragraph("Your Trusted Zabiha Halal Butcher", self.styles['Normal']))
        elements.append(Spacer(1, 0.2 * inch))

        # Order Info
        info_data = [
            [f"Order ID: {order_data['order_id']}", f"Date: {order_data['date']}"],
            [f"Customer: {order_data['customer_name']}", f"Phone: {order_data['customer_phone']}"],
            [f"Store: {order_data['store']}", f"Payment: {order_data['payment_method']}"]
        ]
        info_table = Table(info_data, colWidths=[3 * inch, 3 * inch])
        info_table.setStyle(TableStyle([
            ('FONTNAME', (0,0), (-1,-1), 'Helvetica'),
            ('FONTSIZE', (0,0), (-1,-1), 10),
            ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ]))
        elements.append(info_table)
        elements.append(Spacer(1, 0.3 * inch))

        # Items Table
        items_header = ["Product", "Quantity", "Price"]
        table_data = [items_header]
        for item in order_data['items']:
            table_data.append([item['name'], item['qty'], item['price']])

        items_table = Table(table_data, colWidths=[3 * inch, 2 * inch, 1.5 * inch])
        items_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#E8F5E9")),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.white),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 10),
        ]))
        elements.append(items_table)
        elements.append(Spacer(1, 0.4 * inch))

        # Totals
        totals_data = [
            ["", "Subtotal:", order_data['subtotal']],
            ["", "Tax (8.25%):", order_data['tax']],
            ["", "Total Amount:", order_data['total']]
        ]
        totals_table = Table(totals_data, colWidths=[3 * inch, 2 * inch, 1.5 * inch])
        totals_table.setStyle(TableStyle([
            ('ALIGN', (1, 0), (2, -1), 'RIGHT'),
            ('FONTNAME', (1, 2), (2, 2), 'Helvetica-Bold'),
            ('FONTSIZE', (1, 2), (2, 2), 12),
            ('TOPPADDING', (1, 2), (2, 2), 10),
        ]))
        elements.append(totals_table)

        # Footer
        elements.append(Spacer(1, 0.5 * inch))
        footer_style = ParagraphStyle(
            'FooterStyle',
            parent=self.styles['Normal'],
            fontSize=10,
            alignment=1, # Center
            textColor=colors.grey
        )
        elements.append(Paragraph("Thank you for choosing Meat2Restaurant!", footer_style))
        elements.append(Paragraph("Zabiha Halal Certified Fresh Meats", footer_style))

        doc.build(elements)
        return filepath

pdf_generator = PDFGenerator()
