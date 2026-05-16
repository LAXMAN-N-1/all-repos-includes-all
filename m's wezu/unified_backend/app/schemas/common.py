from __future__ import annotations

from pydantic import BaseModel, Field
from typing import Optional, Generic, TypeVar, List

T = TypeVar('T')

class ResponseBase(BaseModel):
    success: bool = True
    message: str = "Success"


class CursorMeta(BaseModel):
    limit: int
    has_more: bool = False
    next_cursor: Optional[str] = None


class DataResponse(ResponseBase, Generic[T]):
    data: Optional[T] = None
    meta: Optional[CursorMeta] = None

class ErrorResponse(ResponseBase):
    success: bool = False
    error_code: Optional[str] = None

class PaginationParams(BaseModel):
    page: int = 1
    limit: int = 10
    
class PaginatedResponse(ResponseBase, Generic[T]):
    data: List[T]
    total: int
    page: int
    limit: int
    total_pages: int


class PaginationMeta(BaseModel):
    """Offset pagination metadata retained for compatibility."""
    total: int = 0
    skip: int = 0
    limit: int = 10
    has_more: bool = False
    page: int = 1
    total_pages: int = 0


class DataResponseWithPagination(ResponseBase, Generic[T]):
    """Response wrapper that can carry offset or cursor metadata."""
    data: List[T] = Field(default_factory=list)
    pagination: Optional[PaginationMeta] = None
    meta: Optional[CursorMeta] = None
