"""Import all models for Alembic"""
from app.models.base import BaseModel
from app.models.organization import Organization
from app.models.user import User, UserRole, user_stores
from app.models.store import Store
from app.models.role import Role, role_permissions, role_menus
from app.models.permission import Permission
from app.models.menu import Menu
from app.models.medicine import Medicine, DrugSchedule, DrugCategory
from app.models.supplier import Supplier
from app.models.inventory import InventoryBatch
from app.models.prescription import Prescription, PrescriptionStatus
from app.models.order import Order, OrderStatus, PaymentStatus, PaymentMethod
from app.models.order_item import OrderItem
from app.models.audit_log import AuditLog, AuditActionType
from app.models.procurement_order import ProcurementOrder, ProcurementStatus
from app.models.customer import Customer
from app.models.saas_config import Module, OrganizationModule
from app.models.notification import Alert
from app.models.inventory_transfer import StockTransfer, StockAdjustment
from app.models.financials import Invoice, Transaction
from app.models.clinical import Patient, Doctor, Ward
from app.models.hr import Employee, Attendance, Shift
from app.models.lab import LabTest, LabRequest, LabResult
from app.models.insurance import InsuranceProvider, PatientPolicy, Claim
from app.models.subscription import Plan, Subscription, PlatformInvoice
from app.models.compliance import StoreLicense, DrugRecall
from app.models.reporting import ReportJob, ScheduledReport, DashboardConfig
from app.models.inventory_intelligence import DemandForecast, SupplierScorecard, ReorderRule
from app.models.integration import ExternalSystem, IntegrationLog, ApiKey
from app.models.mobile import UserDevice
from app.models.customer_ai import Conversation, Message, MedicalCondition, SymptomProductMap

__all__ = [
    'BaseModel',
    'Organization',
    'User',
    'UserRole',
    'Store',
    'Role',
    'Permission',
    'Menu',
    'Medicine',
    'DrugSchedule',
    'DrugCategory',
    'Supplier',
    'InventoryBatch',
    'Prescription',
    'PrescriptionStatus',
    'Order',
    'OrderStatus',
    'PaymentStatus',
    'PaymentMethod',
    'OrderItem',
    'AuditLog',
    'AuditActionType',
    'ProcurementOrder',
    'ProcurementStatus',
    'Customer',
    'user_stores',
    'role_permissions',
    'role_menus',
    'Module',
    'OrganizationModule',
    'StockTransfer',
    'StockAdjustment',
    'Invoice',
    'Transaction',
    'Patient',
    'Doctor',
    'Ward',
    'Employee',
    'Attendance',
    'Shift',
    'LabTest',
    'LabRequest',
    'LabResult',
    'InsuranceProvider',
    'PatientPolicy',
    'Claim',
    'Plan',
    'Subscription',
    'PlatformInvoice',
    'StoreLicense',
    'DrugRecall',
    'ReportJob',
    'ScheduledReport',
    'DashboardConfig',
    'DemandForecast',
    'SupplierScorecard',
    'ReorderRule',
    'ExternalSystem',
    'IntegrationLog',
    'ApiKey',
    'UserDevice',
    'Alert',
    'Conversation',
    'Message',
    'MedicalCondition',
    'SymptomProductMap',
]
