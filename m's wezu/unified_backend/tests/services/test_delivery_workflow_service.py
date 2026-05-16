from sqlmodel import select

from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus, UserType
from app.services.delivery_workflow_service import RoundRobinAdminAssignmentStrategy


def _mk_user(
    email: str,
    *,
    status: UserStatus = UserStatus.ACTIVE,
    user_type: UserType = UserType.CUSTOMER,
    superuser: bool = False,
) -> User:
    return User(
        email=email,
        phone_number=email.replace("@", "").replace(".", "")[:12],
        full_name=email.split("@")[0],
        status=status,
        user_type=user_type,
        is_superuser=superuser,
    )


def _mk_role(name: str) -> Role:
    return Role(name=name, level=100, is_active=True)


def _exclude_seed_admin_candidates(session) -> None:
    existing_users = session.exec(select(User)).all()
    for user in existing_users:
        user.is_deleted = True
    session.add_all(existing_users)
    session.commit()


def test_assign_admin_user_id_prefers_active_admins(session):
    _exclude_seed_admin_candidates(session)
    active_admin = _mk_user(
        "delivery-active-admin@test.com",
        status=UserStatus.ACTIVE,
    )
    inactive_admin = _mk_user(
        "delivery-inactive-admin@test.com",
        status=UserStatus.INACTIVE,
    )
    admin_role = _mk_role("operations_admin")
    session.add(active_admin)
    session.add(inactive_admin)
    session.add(admin_role)
    session.commit()
    session.refresh(active_admin)
    session.refresh(inactive_admin)
    session.refresh(admin_role)

    session.add(UserRole(user_id=active_admin.id, role_id=admin_role.id))
    session.add(UserRole(user_id=inactive_admin.id, role_id=admin_role.id))
    session.commit()

    assigned_admin_id = RoundRobinAdminAssignmentStrategy().pick_admin_user_id(
        session,
        tenant_id=None,
    )

    assert assigned_admin_id == active_admin.id


def test_assign_admin_user_id_falls_back_to_inactive_admins(session):
    _exclude_seed_admin_candidates(session)
    inactive_admin = _mk_user(
        "delivery-fallback-admin@test.com",
        status=UserStatus.INACTIVE,
    )
    admin_role = _mk_role("operations_admin")
    session.add(inactive_admin)
    session.add(admin_role)
    session.commit()
    session.refresh(inactive_admin)
    session.refresh(admin_role)

    session.add(UserRole(user_id=inactive_admin.id, role_id=admin_role.id))
    session.commit()

    assigned_admin_id = RoundRobinAdminAssignmentStrategy().pick_admin_user_id(
        session,
        tenant_id=None,
    )

    assert assigned_admin_id == inactive_admin.id


def test_assign_admin_user_id_includes_admin_user_type_without_role_links(session):
    _exclude_seed_admin_candidates(session)
    admin_user = _mk_user(
        "delivery-user-type-admin@test.com",
        status=UserStatus.ACTIVE,
        user_type=UserType.ADMIN,
    )
    session.add(admin_user)
    session.commit()
    session.refresh(admin_user)

    assigned_admin_id = RoundRobinAdminAssignmentStrategy().pick_admin_user_id(
        session,
        tenant_id=None,
    )

    assert assigned_admin_id == admin_user.id
