from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import Optional, List, Tuple, Dict, Any
from fastapi.encoders import jsonable_encoder
from datetime import datetime
from app.models.audit_log import AuditLog, AuditActionType
from app.models.user import User
from app.models.store import Store
from app.models.organization import Organization


class AuditService:
    """Service for compliance-ready audit logging and reporting"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def log_action(
        self,
        user_id: Optional[int],
        action: AuditActionType,
        entity_type: str,
        entity_id: Optional[int] = None,
        old_values: Optional[Dict[str, Any]] = None,
        new_values: Optional[Dict[str, Any]] = None,
        description: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        request_path: Optional[str] = None,
        request_method: Optional[str] = None,
        organization_id: Optional[int] = None,
        store_id: Optional[int] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> AuditLog:
        """Create an audit log entry"""
        log = AuditLog(
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            old_values=jsonable_encoder(old_values) if old_values else None,
            new_values=jsonable_encoder(new_values) if new_values else None,
            description=description,
            ip_address=ip_address,
            user_agent=user_agent,
            request_path=request_path,
            request_method=request_method,
            organization_id=organization_id,
            store_id=store_id,
            metadata=metadata,
            created_by=user_id
        )
        self.db.add(log)
        self.db.commit()
        self.db.refresh(log)
        return log
    
    def get_audit_log(self, log_id: int) -> Optional[AuditLog]:
        """Get a single audit log entry"""
        return self.db.query(AuditLog).filter(
            AuditLog.id == log_id,
            AuditLog.inactive == False
        ).first()
    
    def get_audit_trail(
        self,
        entity_type: Optional[str] = None,
        entity_id: Optional[int] = None,
        user_id: Optional[int] = None,
        action: Optional[AuditActionType] = None,
        organization_id: Optional[int] = None,
        store_id: Optional[int] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 50
    ) -> Tuple[List[AuditLog], int]:
        """Retrieve audit logs with filters"""
        query = self.db.query(AuditLog).filter(AuditLog.inactive == False)
        
        if entity_type:
            query = query.filter(AuditLog.entity_type == entity_type)
        
        if entity_id:
            query = query.filter(AuditLog.entity_id == entity_id)
        
        if user_id:
            query = query.filter(AuditLog.user_id == user_id)
        
        if action:
            query = query.filter(AuditLog.action == action)
        
        if organization_id:
            query = query.filter(AuditLog.organization_id == organization_id)
        
        if store_id:
            query = query.filter(AuditLog.store_id == store_id)
        
        if date_from:
            query = query.filter(AuditLog.created_at >= date_from)
        
        if date_to:
            query = query.filter(AuditLog.created_at <= date_to)
        
        total = query.count()
        offset = (page - 1) * page_size
        logs = query.order_by(AuditLog.created_at.desc()).offset(offset).limit(page_size).all()
        
        return logs, total
    
    def get_entity_history(
        self,
        entity_type: str,
        entity_id: int,
        page: int = 1,
        page_size: int = 50
    ) -> Tuple[List[AuditLog], int]:
        """Get complete history for a specific entity"""
        return self.get_audit_trail(
            entity_type=entity_type,
            entity_id=entity_id,
            page=page,
            page_size=page_size
        )
    
    def get_user_activity(
        self,
        user_id: int,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 50
    ) -> Tuple[List[AuditLog], int]:
        """Get all activity for a specific user"""
        return self.get_audit_trail(
            user_id=user_id,
            date_from=date_from,
            date_to=date_to,
            page=page,
            page_size=page_size
        )
    
    def export_audit_report(
        self,
        organization_id: Optional[int] = None,
        store_id: Optional[int] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        entity_types: Optional[List[str]] = None,
        actions: Optional[List[AuditActionType]] = None
    ) -> Dict[str, Any]:
        """Generate audit report for compliance"""
        query = self.db.query(AuditLog).filter(AuditLog.inactive == False)
        
        if organization_id:
            query = query.filter(AuditLog.organization_id == organization_id)
        
        if store_id:
            query = query.filter(AuditLog.store_id == store_id)
        
        if date_from:
            query = query.filter(AuditLog.created_at >= date_from)
        
        if date_to:
            query = query.filter(AuditLog.created_at <= date_to)
        
        if entity_types:
            query = query.filter(AuditLog.entity_type.in_(entity_types))
        
        if actions:
            query = query.filter(AuditLog.action.in_(actions))
        
        logs = query.order_by(AuditLog.created_at.desc()).all()
        
        # Summary statistics
        action_counts = {}
        entity_counts = {}
        user_counts = {}
        
        for log in logs:
            # Count by action
            action_key = log.action.value if log.action else "UNKNOWN"
            action_counts[action_key] = action_counts.get(action_key, 0) + 1
            
            # Count by entity type
            entity_counts[log.entity_type] = entity_counts.get(log.entity_type, 0) + 1
            
            # Count by user
            user_key = str(log.user_id) if log.user_id else "SYSTEM"
            user_counts[user_key] = user_counts.get(user_key, 0) + 1
        
        return {
            "report_generated_at": datetime.utcnow().isoformat(),
            "filters": {
                "organization_id": str(organization_id) if organization_id else None,
                "store_id": str(store_id) if store_id else None,
                "date_from": date_from.isoformat() if date_from else None,
                "date_to": date_to.isoformat() if date_to else None,
                "entity_types": entity_types,
                "actions": [a.value for a in actions] if actions else None
            },
            "summary": {
                "total_entries": len(logs),
                "by_action": action_counts,
                "by_entity_type": entity_counts,
                "unique_users": len(user_counts)
            },
            "entries": [
                {
                    "id": str(log.id),
                    "timestamp": log.created_at.isoformat() if log.created_at else None,
                    "user_id": str(log.user_id) if log.user_id else None,
                    "action": log.action.value if log.action else None,
                    "entity_type": log.entity_type,
                    "entity_id": str(log.entity_id) if log.entity_id else None,
                    "description": log.description,
                    "ip_address": log.ip_address
                }
                for log in logs[:1000]  # Limit to 1000 entries in export
            ]
        }
    
    def get_login_history(
        self,
        user_id: Optional[int] = None,
        organization_id: Optional[int] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 50
    ) -> Tuple[List[AuditLog], int]:
        """Get login/logout history for security auditing"""
        return self.get_audit_trail(
            entity_type="User",
            user_id=user_id,
            action=AuditActionType.LOGIN,
            organization_id=organization_id,
            date_from=date_from,
            date_to=date_to,
            page=page,
            page_size=page_size
        )
    
    def get_prescription_audit(
        self,
        prescription_id: Optional[int] = None,
        store_id: Optional[int] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 50
    ) -> Tuple[List[AuditLog], int]:
        """Get prescription-related audit trail for compliance"""
        return self.get_audit_trail(
            entity_type="Prescription",
            entity_id=prescription_id,
            store_id=store_id,
            date_from=date_from,
            date_to=date_to,
            page=page,
            page_size=page_size
        )
    
    def get_controlled_substance_audit(
        self,
        store_id: Optional[int] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """Special audit for controlled substance transactions"""
        # Get inventory adjustments and orders involving controlled substances
        query = self.db.query(AuditLog).filter(
            AuditLog.inactive == False,
            AuditLog.entity_type.in_(["InventoryBatch", "Order", "OrderItem"]),
            AuditLog.action.in_([AuditActionType.CREATE, AuditActionType.UPDATE, AuditActionType.DELETE])
        )
        
        if store_id:
            query = query.filter(AuditLog.store_id == store_id)
        
        if date_from:
            query = query.filter(AuditLog.created_at >= date_from)
        
        if date_to:
            query = query.filter(AuditLog.created_at <= date_to)
        
        logs = query.order_by(AuditLog.created_at.desc()).all()
        
        return {
            "report_type": "CONTROLLED_SUBSTANCE_AUDIT",
            "generated_at": datetime.utcnow().isoformat(),
            "total_transactions": len(logs),
            "entries": [
                {
                    "id": str(log.id),
                    "timestamp": log.created_at.isoformat() if log.created_at else None,
                    "user_id": str(log.user_id) if log.user_id else None,
                    "action": log.action.value if log.action else None,
                    "entity_type": log.entity_type,
                    "entity_id": str(log.entity_id) if log.entity_id else None,
                    "details": log.new_values,
                    "ip_address": log.ip_address
                }
                for log in logs[:500]
            ]
        }
