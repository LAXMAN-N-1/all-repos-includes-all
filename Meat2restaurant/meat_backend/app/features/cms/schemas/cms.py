from typing import Optional, List, Any
from pydantic import BaseModel
from datetime import datetime

# --- SHARED ---
class ContentBase(BaseModel):
    title: str
    slug: str
    content: Optional[str] = None
    is_published: bool = False
    status: str = "draft"
    scheduled_publish_at: Optional[datetime] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    meta_keywords: Optional[str] = None
    is_homepage: bool = False
    visibility: str = "public"

class VersionBase(BaseModel):
    version_number: int
    title: Optional[str] = None
    content: str
    featured_image_url: Optional[str] = None
    status: str
    created_at: datetime
    restored_from: Optional[int] = None
    
# --- PAGES ---
class WebPageVersionOut(VersionBase):
    id: int
    page_id: int
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    meta_keywords: Optional[str] = None
    is_homepage: bool = False
    visibility: str = "public"
    class Config: from_attributes = True

class WebPageCreate(ContentBase):
    sections: Optional[str] = None
    featured_image_url: Optional[str] = None

class WebPageUpdate(BaseModel):
    title: Optional[str] = None
    slug: Optional[str] = None
    content: Optional[str] = None
    is_published: Optional[bool] = None
    status: Optional[str] = None
    scheduled_publish_at: Optional[datetime] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    meta_keywords: Optional[str] = None
    is_homepage: Optional[bool] = None
    visibility: Optional[str] = None
    password: Optional[str] = None
    sections: Optional[str] = None
    featured_image_url: Optional[str] = None

class WebPageOut(ContentBase):
    id: int
    sections: Optional[str] = None
    featured_image_url: Optional[str] = None
    published_at: Optional[datetime] = None
    updated_by: Optional[int] = None
    created_at: datetime
    class Config: from_attributes = True


# --- BLOGS ---
class BlogPostVersionOut(VersionBase):
    id: int
    post_id: int
    class Config: from_attributes = True

class BlogPostCreate(ContentBase):
    author_id: Optional[int] = None
    featured_image_url: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[str] = None
    excerpt: Optional[str] = None
    allow_comments: bool = True
    is_featured: bool = False

class BlogPostUpdate(BaseModel):
    title: Optional[str] = None
    slug: Optional[str] = None
    content: Optional[str] = None
    is_published: Optional[bool] = None
    status: Optional[str] = None
    scheduled_publish_at: Optional[datetime] = None
    author_id: Optional[int] = None
    featured_image_url: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[str] = None
    excerpt: Optional[str] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    meta_keywords: Optional[str] = None
    allow_comments: Optional[bool] = None
    is_featured: Optional[bool] = None

class BlogPostOut(ContentBase):
    id: int
    author_id: Optional[int] = None
    featured_image_url: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[str] = None
    excerpt: Optional[str] = None
    view_count: int = 0
    comment_count: int = 0
    pending_comment_count: int = 0
    published_at: Optional[datetime] = None
    created_at: datetime
    allow_comments: bool = True
    is_featured: bool = False
    class Config: from_attributes = True


# --- RECIPES ---
class RecipeSchemaBase(BaseModel):
    title: str
    slug: str
    description: Optional[str] = None
    featured_image_url: Optional[str] = None
    cuisine_type: Optional[str] = None
    difficulty_level: Optional[str] = None
    meal_type: Optional[str] = None
    prep_time: Optional[int] = None
    cook_time: Optional[int] = None
    total_time: Optional[int] = None
    servings: Optional[int] = None
    calories_per_serving: Optional[int] = None
    status: str = "draft"
    is_published: bool = False
    scheduled_publish_at: Optional[datetime] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None

class RecipeIngredientBase(BaseModel):
    ingredient_name: str
    quantity: float
    unit: str
    sort_order: Optional[int] = 0

class RecipeIngredientCreate(RecipeIngredientBase):
    pass

class RecipeIngredientOut(RecipeIngredientBase):
    id: int
    recipe_id: int
    class Config: from_attributes = True

class RecipeStepBase(BaseModel):
    step_number: int
    step_title: Optional[str] = None
    step_description: str
    time_in_minutes: Optional[int] = None
    step_image_url: Optional[str] = None

class RecipeStepCreate(RecipeStepBase):
    pass

class RecipeStepOut(RecipeStepBase):
    id: int
    recipe_id: int
    class Config: from_attributes = True

class RecipeNutritionBase(BaseModel):
    calories: int
    protein_g: float
    carbs_g: float
    fats_g: float
    fiber_g: float
    sodium_mg: float

class RecipeNutritionCreate(RecipeNutritionBase):
    pass

class RecipeNutritionOut(RecipeNutritionBase):
    id: int
    recipe_id: int
    class Config: from_attributes = True

class RecipeCreate(RecipeSchemaBase):
    ingredients: Optional[List[RecipeIngredientCreate]] = []
    steps: Optional[List[RecipeStepCreate]] = []
    nutrition: Optional[RecipeNutritionCreate] = None
    linked_product_ids: Optional[List[int]] = []

class RecipeUpdate(BaseModel):
    title: Optional[str] = None
    slug: Optional[str] = None
    description: Optional[str] = None
    featured_image_url: Optional[str] = None
    cuisine_type: Optional[str] = None
    difficulty_level: Optional[str] = None
    meal_type: Optional[str] = None
    prep_time: Optional[int] = None
    cook_time: Optional[int] = None
    total_time: Optional[int] = None
    servings: Optional[int] = None
    calories_per_serving: Optional[int] = None
    status: Optional[str] = None
    is_published: Optional[bool] = None
    scheduled_publish_at: Optional[datetime] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    ingredients: Optional[List[RecipeIngredientCreate]] = None
    steps: Optional[List[RecipeStepCreate]] = None
    nutrition: Optional[RecipeNutritionCreate] = None
    linked_product_ids: Optional[List[int]] = None

class RecipeOut(RecipeSchemaBase):
    id: int
    avg_rating: float = 0.0
    total_reviews_count: int = 0
    published_at: Optional[datetime] = None
    ingredients: List[RecipeIngredientOut] = []
    steps: List[RecipeStepOut] = []
    nutrition: Optional[RecipeNutritionOut] = None
    linked_product_ids: List[int] = []
    class Config: from_attributes = True


# --- FAQ ---
class FAQBase(BaseModel):
    question: str
    answer: str
    category: Optional[str] = None
    display_order: int = 0
    status: str = "published"
    is_featured: bool = False
    tags: Optional[str] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None

class FAQCreate(FAQBase):
    pass

class FAQUpdate(BaseModel):
    question: Optional[str] = None
    answer: Optional[str] = None
    category: Optional[str] = None
    display_order: Optional[int] = None
    status: Optional[str] = None
    is_featured: Optional[bool] = None
    tags: Optional[str] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None

class FAQOut(FAQBase):
    id: int
    helpful_count: Optional[int] = 0
    unhelpful_count: Optional[int] = 0
    helpful_percentage: Optional[float] = 0.0
    view_count: Optional[int] = 0
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    class Config: from_attributes = True


# --- LEGAL DOCS ---
class LegalDocumentVersionOut(BaseModel):
    id: int
    document_id: int
    version_number: int
    content: str
    status: str
    created_at: datetime
    class Config: from_attributes = True

class LegalDocumentBase(BaseModel):
    document_type: str
    content: str
    version_number: int = 1
    status: str = "draft"
    is_current: bool = False
    effective_date: Optional[datetime] = None
    scheduled_effective_date: Optional[datetime] = None

class LegalDocumentCreate(LegalDocumentBase):
    pass

class LegalDocumentUpdate(BaseModel):
    content: Optional[str] = None
    version_number: Optional[int] = None
    status: Optional[str] = None
    is_current: Optional[bool] = None
    effective_date: Optional[datetime] = None
    scheduled_effective_date: Optional[datetime] = None

class LegalDocumentOut(LegalDocumentBase):
    id: int
    published_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    class Config: from_attributes = True


# --- ABOUT STORE ---
class AboutStoreBase(BaseModel):
    company_description: Optional[str] = None
    mission_statement: Optional[str] = None
    vision_statement: Optional[str] = None
    values: Optional[dict] = None # Assuming JSON objects mapped to dict
    company_image_url: Optional[str] = None
    is_current: bool = True

class AboutStoreCreate(AboutStoreBase):
    pass

class AboutStoreUpdate(AboutStoreBase):
    company_description: Optional[str] = None
    mission_statement: Optional[str] = None
    vision_statement: Optional[str] = None
    values: Optional[dict] = None
    company_image_url: Optional[str] = None
    is_current: Optional[bool] = None

class AboutStoreOut(AboutStoreBase):
    id: int
    updated_at: datetime
    class Config: from_attributes = True

class TeamMemberBase(BaseModel):
    name: str
    job_title: str
    email: Optional[str] = None
    phone: Optional[str] = None
    photo_url: Optional[str] = None
    photo_thumbnail_url: Optional[str] = None
    bio: Optional[str] = None
    department: Optional[str] = None
    linkedin_url: Optional[str] = None
    skills: Optional[List[str]] = None
    is_active: bool = True
    display_order: int = 0

class TeamMemberCreate(TeamMemberBase):
    pass

class TeamMemberUpdate(BaseModel):
    name: Optional[str] = None
    job_title: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    photo_url: Optional[str] = None
    photo_thumbnail_url: Optional[str] = None
    bio: Optional[str] = None
    department: Optional[str] = None
    linkedin_url: Optional[str] = None
    skills: Optional[List[str]] = None
    is_active: Optional[bool] = None
    display_order: Optional[int] = None
    is_deleted: Optional[bool] = None

class TeamMemberOut(TeamMemberBase):
    id: int
    created_at: datetime
    class Config: from_attributes = True

class CertificationBase(BaseModel):
    cert_name: str
    cert_body: str
    cert_image_url: Optional[str] = None
    issue_date: Optional[datetime] = None
    expiration_date: Optional[datetime] = None
    cert_url: Optional[str] = None

class CertificationCreate(CertificationBase):
    pass

class CertificationOut(CertificationBase):
    id: int
    about_us_id: int
    class Config: from_attributes = True

class AwardBase(BaseModel):
    award_name: str
    organization: str
    award_date: Optional[datetime] = None
    award_image_url: Optional[str] = None

class AwardCreate(AwardBase):
    pass

class AwardOut(AwardBase):
    id: int
    about_us_id: int
    class Config: from_attributes = True

class TimelineEventBase(BaseModel):
    event_year: int
    event_title: str
    event_description: str
    event_image_url: Optional[str] = None
    position: int = 0

class TimelineEventCreate(TimelineEventBase):
    pass

class TimelineEventOut(TimelineEventBase):
    id: int
    about_us_id: int
    class Config: from_attributes = True
