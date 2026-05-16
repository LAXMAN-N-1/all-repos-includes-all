from datetime import UTC, datetime, timedelta

from app.api.deps import RBACScopeContext
from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus
from app.schemas.rbac import UserRoleAssign
from app.services.access_control_service import access_control_service


def _mk_user(email: str, *, superuser: bool = False) -> User:
    return User(
        email=email,
        phone_number=email.replace("@", "").replace(".", "")[:12],
        full_name=email.split("@")[0],
        is_superuser=superuser,
        status=UserStatus.ACTIVE,
    )


def test_assign_role_sets_actor_metadata_and_primary_role(session):
    actor = _mk_user("rbac-actor@test.com", superuser=True)
    target = _mk_user("rbac-target@test.com")
    role = Role(name="rbac_sync_role", level=10, is_active=True)
    session.add(actor)
    session.add(target)
    session.add(role)
    session.commit()
    session.refresh(actor)
    session.refresh(target)
    session.refresh(role)

    context = RBACScopeContext(
        user=actor,
        scope="global",
        auth_subject="supabase|actor-123",
    )
    access_control_service.assign_role_to_user(
        session,
        context,
        user_id=int(target.id),
        payload=UserRoleAssign(role_id=int(role.id), notes="initial grant"),
    )

    link = session.get(UserRole, (target.id, role.id))
    session.refresh(target)

    assert link is not None
    assert link.assigned_by_user_id == actor.id
    assert link.assigned_by_subject == "supabase|actor-123"
    assert target.role_id == role.id


def test_primary_role_pointer_recomputes_on_assignment_delete(session):
    actor = _mk_user("rbac-owner@test.com", superuser=True)
    target = _mk_user("rbac-target2@test.com")
    high = Role(name="rbac_high_priority", level=100, is_active=True)
    low = Role(name="rbac_low_priority", level=10, is_active=True)
    session.add(actor)
    session.add(target)
    session.add(high)
    session.add(low)
    session.commit()
    session.refresh(target)
    session.refresh(high)
    session.refresh(low)

    session.add(
        UserRole(
            user_id=target.id,
            role_id=low.id,
            assigned_by_user_id=actor.id,
            effective_from=datetime.now(UTC) - timedelta(minutes=2),
        )
    )
    session.add(
        UserRole(
            user_id=target.id,
            role_id=high.id,
            assigned_by_user_id=actor.id,
            effective_from=datetime.now(UTC) - timedelta(minutes=1),
        )
    )
    session.commit()
    session.refresh(target)
    assert target.role_id == high.id

    context = RBACScopeContext(user=actor, scope="global")
    removed = access_control_service.remove_role_from_user(
        session,
        context,
        user_id=int(target.id),
        role_id=int(high.id),
    )
    assert removed is True
    session.refresh(target)
    assert target.role_id == low.id
