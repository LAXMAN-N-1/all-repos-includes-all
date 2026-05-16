from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Protocol

from fastapi import HTTPException
from sqlalchemy import or_
from sqlmodel import Session, select

from app.api import deps
from app.models.order import Order
from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus, UserType
from app.models.warehouse import Warehouse


CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL = "PENDING_ADMIN_APPROVAL"
CANONICAL_ORDER_STATUS_APPROVED = "APPROVED"
CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE = "ASSIGNED_TO_WAREHOUSE"
CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY"
CANONICAL_ORDER_STATUS_DELIVERED = "DELIVERED"
CANONICAL_ORDER_STATUS_REJECTED = "REJECTED"

CANONICAL_ORDER_TERMINAL_STATUSES = {
    CANONICAL_ORDER_STATUS_DELIVERED,
    CANONICAL_ORDER_STATUS_REJECTED,
}

CANONICAL_ORDER_STATUS_TRANSITIONS: dict[str, set[str]] = {
    CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL: {
        CANONICAL_ORDER_STATUS_APPROVED,
        CANONICAL_ORDER_STATUS_REJECTED,
    },
    CANONICAL_ORDER_STATUS_APPROVED: {CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE},
    CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE: {CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY},
    CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY: {CANONICAL_ORDER_STATUS_DELIVERED},
    CANONICAL_ORDER_STATUS_DELIVERED: set(),
    CANONICAL_ORDER_STATUS_REJECTED: set(),
}

LEGACY_TO_CANONICAL_STATUS: dict[str, str] = {
    "pending": CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL,
    "assigned": CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE,
    "in_transit": CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY,
    "out_for_delivery": CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY,
    "delivered": CANONICAL_ORDER_STATUS_DELIVERED,
    "failed": CANONICAL_ORDER_STATUS_REJECTED,
    "cancelled": CANONICAL_ORDER_STATUS_REJECTED,
    "canceled": CANONICAL_ORDER_STATUS_REJECTED,
    "approved": CANONICAL_ORDER_STATUS_APPROVED,
    "pending_admin_approval": CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL,
    "assigned_to_warehouse": CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE,
    "rejected": CANONICAL_ORDER_STATUS_REJECTED,
}


class WarehouseSelectionStrategy(Protocol):
    def select_warehouse_id(
        self,
        session: Session,
        *,
        dealer_id: int,
        explicit_warehouse_id: Optional[int],
    ) -> int:
        ...


class AdminAssignmentStrategy(Protocol):
    def pick_admin_user_id(
        self,
        session: Session,
        *,
        tenant_id: Optional[int],
    ) -> int:
        ...


class DefaultWarehouseSelectionStrategy:
    def select_warehouse_id(
        self,
        session: Session,
        *,
        dealer_id: int,
        explicit_warehouse_id: Optional[int],
    ) -> int:
        del dealer_id
        if explicit_warehouse_id is not None:
            warehouse = session.get(Warehouse, int(explicit_warehouse_id))
            if not warehouse or not bool(getattr(warehouse, "is_active", False)):
                raise HTTPException(status_code=409, detail="Selected warehouse is unavailable")
            return int(warehouse.id)

        first_active = session.exec(
            select(Warehouse.id)
            .where(Warehouse.is_active == True)  # noqa: E712
            .order_by(Warehouse.id.asc())
            .limit(1)
        ).first()
        if first_active is None:
            raise HTTPException(status_code=409, detail="No active warehouse available for assignment")
        return int(first_active)


class RoundRobinAdminAssignmentStrategy:
    def _admin_user_ids(
        self,
        session: Session,
        *,
        require_active_status: bool,
    ) -> list[int]:
        admin_role_names = deps.ADMIN_ROLE_NAMES | {"admin"}
        rows = session.exec(
            select(User.id)
            .outerjoin(UserRole, UserRole.user_id == User.id)
            .outerjoin(Role, Role.id == UserRole.role_id)
            .where(User.is_deleted == False)  # noqa: E712
            .where(
                or_(
                    User.is_superuser == True,  # noqa: E712
                    User.user_type == UserType.ADMIN,
                    (
                        (Role.name.in_(admin_role_names))
                        & (Role.is_active == True)  # noqa: E712
                    ),
                )
            )
            .where(User.status == UserStatus.ACTIVE if require_active_status else True)
            .distinct()
            .order_by(User.id.asc())
        ).all()
        return [int(row) for row in rows if row is not None]

    def pick_admin_user_id(
        self,
        session: Session,
        *,
        tenant_id: Optional[int],
    ) -> int:
        admin_ids = self._admin_user_ids(session, require_active_status=True)
        if not admin_ids:
            # Some environments keep approver accounts in inactive/suspended
            # states even though they should still own approvals. Fall back to
            # any non-deleted admin identity so order creation can proceed.
            admin_ids = self._admin_user_ids(session, require_active_status=False)
        if not admin_ids:
            raise HTTPException(status_code=409, detail="No admin available for assignment")

        query = select(Order.assigned_admin_id).where(Order.assigned_admin_id.in_(admin_ids))
        if tenant_id is not None:
            query = query.where(Order.tenant_id == int(tenant_id))
        query = query.order_by(Order.order_date.desc(), Order.updated_at.desc()).limit(1)

        last_assigned = session.exec(query).first()
        if last_assigned is None:
            return admin_ids[0]

        try:
            current_idx = admin_ids.index(int(last_assigned))
        except ValueError:
            return admin_ids[0]

        next_idx = (current_idx + 1) % len(admin_ids)
        return int(admin_ids[next_idx])


@dataclass(frozen=True)
class DeliveryWorkflowConfig:
    warehouse_strategy: WarehouseSelectionStrategy
    admin_strategy: AdminAssignmentStrategy


DEFAULT_DELIVERY_WORKFLOW_CONFIG = DeliveryWorkflowConfig(
    warehouse_strategy=DefaultWarehouseSelectionStrategy(),
    admin_strategy=RoundRobinAdminAssignmentStrategy(),
)


def canonicalize_order_status(raw_status: Optional[str]) -> str:
    normalized = str(raw_status or "").strip().upper()
    if not normalized:
        return ""
    compact = normalized.replace("-", "_").replace(" ", "_").lower()
    return LEGACY_TO_CANONICAL_STATUS.get(compact, normalized)


def assert_valid_order_transition(current_status: str, target_status: str) -> None:
    current = canonicalize_order_status(current_status)
    target = canonicalize_order_status(target_status)
    allowed = CANONICAL_ORDER_STATUS_TRANSITIONS.get(current)
    if allowed is None:
        raise HTTPException(status_code=409, detail=f"Unknown current status '{current_status}'")
    if target not in allowed:
        raise HTTPException(
            status_code=409,
            detail=(
                f"Invalid status transition from '{current}' to '{target}'. "
                f"Allowed: {sorted(allowed)}"
            ),
        )


def is_terminal_status(status: str) -> bool:
    return canonicalize_order_status(status) in CANONICAL_ORDER_TERMINAL_STATUSES


def select_source_warehouse_id(
    session: Session,
    *,
    dealer_id: int,
    explicit_warehouse_id: Optional[int],
    config: DeliveryWorkflowConfig = DEFAULT_DELIVERY_WORKFLOW_CONFIG,
) -> int:
    return config.warehouse_strategy.select_warehouse_id(
        session,
        dealer_id=dealer_id,
        explicit_warehouse_id=explicit_warehouse_id,
    )


def assign_admin_user_id(
    session: Session,
    *,
    tenant_id: Optional[int],
    config: DeliveryWorkflowConfig = DEFAULT_DELIVERY_WORKFLOW_CONFIG,
) -> int:
    return config.admin_strategy.pick_admin_user_id(session, tenant_id=tenant_id)
