from sqlalchemy import Column, Integer, String, Boolean, Text, ForeignKey, DateTime, Float, JSON, Table
from sqlalchemy.orm import relationship
from app.db.base_class import Base, TimestampMixin
from datetime import datetime

# --- SHARED / META ---
class AuditLog(Base, TimestampMixin):
    __tablename__ = "cms_audit_logs"
    id = Column(Integer, primary_key=True, index=True)
    action = Column(String(100))
    content_type = Column(String(50))
    content_id = Column(Integer)
    admin_id = Column(Integer, ForeignKey("users.id", name="fk_audit_user"), nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    description = Column(Text)
    old_value = Column(Text, nullable=True)
    new_value = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)

class ContentTag(Base, TimestampMixin):
    __tablename__ = "cms_content_tags"
    id = Column(Integer, primary_key=True, index=True)
    content_id = Column(Integer, index=True)
    content_type = Column(String(50))
    tag_name = Column(String(100), index=True)

# --- WEB PAGES ---
class WebPage(Base, TimestampMixin):
    __tablename__ = "web_pages"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    slug = Column(String(255), unique=True, index=True)
    content = Column(Text) 
    featured_image_url = Column(String(500), nullable=True)
    status = Column(String(50), default="draft")
    is_published = Column(Boolean, default=False)
    scheduled_publish_at = Column(DateTime, nullable=True)
    published_at = Column(DateTime, nullable=True)
    published_by = Column(Integer, ForeignKey("users.id", name="fk_page_pub_user"), nullable=True)
    sections = Column(Text, nullable=True) 
    meta_title = Column(String(255), nullable=True)
    meta_description = Column(String(500), nullable=True)
    meta_keywords = Column(String(500), nullable=True)
    is_homepage = Column(Boolean, default=False)
    visibility = Column(String(50), default="public") # public, hidden, password
    password = Column(String(255), nullable=True)
    updated_by = Column(Integer, ForeignKey("users.id", name="fk_page_upd_user"), nullable=True)
    is_deleted = Column(Boolean, default=False)
    
    versions = relationship("WebPageVersion", back_populates="page", cascade="all, delete-orphan")
    analytics = relationship("PageAnalytics", back_populates="page", cascade="all, delete-orphan")

class WebPageVersion(Base, TimestampMixin):
    __tablename__ = "web_page_versions"
    id = Column(Integer, primary_key=True, index=True)
    page_id = Column(Integer, ForeignKey("web_pages.id", name="fk_page_ver"))
    version_number = Column(Integer)
    content = Column(Text)
    featured_image_url = Column(String(500), nullable=True)
    meta_title = Column(String(255), nullable=True)
    meta_description = Column(String(500), nullable=True)
    meta_keywords = Column(String(500), nullable=True)
    is_homepage = Column(Boolean, default=False)
    visibility = Column(String(50), default="public")
    status = Column(String(50))
    created_by = Column(Integer, ForeignKey("users.id", name="fk_page_ver_user"), nullable=True)
    restored_from = Column(Integer, nullable=True)
    
    page = relationship("WebPage", back_populates="versions")

class PageAnalytics(Base, TimestampMixin):
    __tablename__ = "page_analytics"
    id = Column(Integer, primary_key=True, index=True)
    page_id = Column(Integer, ForeignKey("web_pages.id", name="fk_page_ana"))
    viewed_at = Column(DateTime, default=datetime.utcnow)
    viewer_id = Column(String(255), nullable=True)
    time_on_page = Column(Integer, default=0)
    referrer_url = Column(String(500), nullable=True)
    device_type = Column(String(50), nullable=True)
    
    page = relationship("WebPage", back_populates="analytics")

# --- BLOG POSTS ---
class BlogPost(Base, TimestampMixin):
    __tablename__ = "blog_posts"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    slug = Column(String(255), unique=True, index=True)
    excerpt = Column(String(500), nullable=True)
    content = Column(Text)
    author_id = Column(Integer, ForeignKey("users.id", name="fk_blog_auth"))
    status = Column(String(50), default="draft")
    is_published = Column(Boolean, default=False)
    category = Column(String(100), nullable=True)
    tags = Column(String(255), nullable=True)
    featured_image_url = Column(String(500), nullable=True)
    scheduled_publish_at = Column(DateTime, nullable=True)
    published_at = Column(DateTime, nullable=True)
    view_count = Column(Integer, default=0)
    meta_title = Column(String(255), nullable=True)
    meta_description = Column(String(500), nullable=True)
    meta_keywords = Column(String(500), nullable=True)
    is_deleted = Column(Boolean, default=False)
    allow_comments = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    
    author = relationship("User")
    versions = relationship("BlogPostVersion", back_populates="post", cascade="all, delete-orphan")
    comments = relationship("BlogComment", back_populates="post", cascade="all, delete-orphan")
    analytics = relationship("BlogAnalytics", back_populates="post", cascade="all, delete-orphan")

class BlogPostVersion(Base, TimestampMixin):
    __tablename__ = "blog_post_versions"
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("blog_posts.id", name="fk_blog_ver"))
    version_number = Column(Integer)
    content = Column(Text)
    status = Column(String(50))
    created_by = Column(Integer, ForeignKey("users.id", name="fk_blog_ver_user"), nullable=True)
    restored_from = Column(Integer, nullable=True)
    
    post = relationship("BlogPost", back_populates="versions")

class BlogComment(Base, TimestampMixin):
    __tablename__ = "blog_comments"
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("blog_posts.id", name="fk_blog_com"))
    comment_text = Column(Text)
    commenter_name = Column(String(255))
    commenter_email = Column(String(255))
    status = Column(String(50), default="pending") # pending, approved, rejected
    is_approved = Column(Boolean, default=False)
    approved_at = Column(DateTime, nullable=True)
    approved_by = Column(Integer, ForeignKey("users.id", name="fk_blog_com_appr"), nullable=True)
    
    post = relationship("BlogPost", back_populates="comments")

class BlogAnalytics(Base, TimestampMixin):
    __tablename__ = "blog_analytics"
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("blog_posts.id", name="fk_blog_ana"))
    viewed_at = Column(DateTime, default=datetime.utcnow)
    viewer_id = Column(String(255), nullable=True)
    time_on_page = Column(Integer, default=0)
    referrer_url = Column(String(500), nullable=True)
    
    post = relationship("BlogPost", back_populates="analytics")

# --- RECIPES ---
recipes_products_table = Table('recipes_products', Base.metadata,
    Column('recipe_id', Integer, ForeignKey('recipes.id', name="fk_rp_req")),
    Column('product_id', Integer, ForeignKey('products.id', name="fk_rp_prod")),
    Column('quantity_needed', Float),
    Column('unit', String(50))
)

class Recipe(Base, TimestampMixin):
    __tablename__ = "recipes"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    slug = Column(String(255), unique=True, index=True)
    description = Column(Text)
    featured_image_url = Column(String(500), nullable=True)
    cuisine_type = Column(String(100), nullable=True)
    difficulty_level = Column(String(50), nullable=True)
    meal_type = Column(String(100), nullable=True)
    prep_time = Column(Integer, nullable=True) # minutes
    cook_time = Column(Integer, nullable=True) # minutes
    total_time = Column(Integer, nullable=True) # minutes
    servings = Column(Integer, nullable=True)
    calories_per_serving = Column(Integer, nullable=True)
    status = Column(String(50), default="draft")
    is_published = Column(Boolean, default=False)
    scheduled_publish_at = Column(DateTime, nullable=True)
    published_at = Column(DateTime, nullable=True)
    avg_rating = Column(Float, default=0.0)
    total_reviews_count = Column(Integer, default=0)
    meta_title = Column(String(255), nullable=True)
    meta_description = Column(String(500), nullable=True)
    is_deleted = Column(Boolean, default=False)

    ingredients = relationship("RecipeIngredient", back_populates="recipe", cascade="all, delete-orphan")
    steps = relationship("RecipeStep", back_populates="recipe", cascade="all, delete-orphan", order_by="RecipeStep.step_number")
    nutrition = relationship("RecipeNutrition", back_populates="recipe", uselist=False, cascade="all, delete-orphan")
    reviews = relationship("RecipeReview", back_populates="recipe", cascade="all, delete-orphan")
    analytics = relationship("RecipeAnalytics", back_populates="recipe", cascade="all, delete-orphan")
    linked_products = relationship("Product", secondary=recipes_products_table)
    versions = relationship("RecipeVersion", back_populates="recipe", cascade="all, delete-orphan")

    @property
    def linked_product_ids(self):
        return [p.id for p in self.linked_products]

class RecipeVersion(Base, TimestampMixin):
    __tablename__ = "recipe_versions"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_rec_ver"))
    version_number = Column(Integer)
    data_snapshot = Column(JSON) # Store entire recipe state as JSON to avoid excessive tables
    status = Column(String(50))
    created_by = Column(Integer, ForeignKey("users.id", name="fk_rec_ver_user"), nullable=True)
    restored_from = Column(Integer, nullable=True)
    
    recipe = relationship("Recipe", back_populates="versions")

class RecipeIngredient(Base, TimestampMixin):
    __tablename__ = "recipe_ingredients"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_ring_rec"))
    ingredient_name = Column(String(255))
    quantity = Column(Float)
    unit = Column(String(50))
    sort_order = Column(Integer, default=0)
    
    recipe = relationship("Recipe", back_populates="ingredients")

class RecipeStep(Base, TimestampMixin):
    __tablename__ = "recipe_steps"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_rstep_rec"))
    step_number = Column(Integer)
    step_title = Column(String(255), nullable=True)
    step_description = Column(Text)
    time_in_minutes = Column(Integer, nullable=True)
    step_image_url = Column(String(500), nullable=True)
    
    recipe = relationship("Recipe", back_populates="steps")

class RecipeNutrition(Base, TimestampMixin):
    __tablename__ = "recipe_nutrition"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_rnut_rec"))
    calories = Column(Integer)
    protein_g = Column(Float)
    carbs_g = Column(Float)
    fats_g = Column(Float)
    fiber_g = Column(Float)
    sodium_mg = Column(Float)
    
    recipe = relationship("Recipe", back_populates="nutrition")

class RecipeReview(Base, TimestampMixin):
    __tablename__ = "recipe_reviews"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_rrev_rec"))
    customer_id = Column(Integer, nullable=True)
    customer_name = Column(String(255))
    rating = Column(Integer) # 1-5
    review_text = Column(Text)
    status = Column(String(50), default="pending")
    is_approved = Column(Boolean, default=False)
    approved_at = Column(DateTime, nullable=True)
    helpful_count = Column(Integer, default=0)
    
    recipe = relationship("Recipe", back_populates="reviews")

class RecipeAnalytics(Base, TimestampMixin):
    __tablename__ = "recipe_analytics"
    id = Column(Integer, primary_key=True, index=True)
    recipe_id = Column(Integer, ForeignKey("recipes.id", name="fk_rana_rec"))
    viewed_at = Column(DateTime, default=datetime.utcnow)
    viewer_id = Column(String(255), nullable=True)
    time_on_page = Column(Integer, default=0)
    product_clicked = Column(Integer, nullable=True) # Product ID
    
    recipe = relationship("Recipe", back_populates="analytics")

# --- FAQs ---
class FAQ(Base, TimestampMixin):
    __tablename__ = "faqs"
    id = Column(Integer, primary_key=True, index=True)
    question = Column(String(500), index=True)
    answer = Column(Text)
    category = Column(String(100), index=True)
    status = Column(String(50), default="published")
    is_featured = Column(Boolean, default=False)
    helpful_count = Column(Integer, default=0)
    unhelpful_count = Column(Integer, default=0)
    helpful_percentage = Column(Float, default=0.0)
    view_count = Column(Integer, default=0)
    display_order = Column(Integer, default=0)
    tags = Column(String(255), nullable=True)
    meta_title = Column(String(255), nullable=True)
    meta_description = Column(String(500), nullable=True)
    is_deleted = Column(Boolean, default=False)

    votes = relationship("FAQVote", back_populates="faq", cascade="all, delete-orphan")
    analytics = relationship("FAQAnalytics", back_populates="faq", cascade="all, delete-orphan")
    versions = relationship("FAQVersion", back_populates="faq", cascade="all, delete-orphan")

class FAQVersion(Base, TimestampMixin):
    __tablename__ = "faq_versions"
    id = Column(Integer, primary_key=True, index=True)
    faq_id = Column(Integer, ForeignKey("faqs.id", name="fk_faq_ver_faq"))
    version_number = Column(Integer)
    answer = Column(Text)
    status = Column(String(50))
    created_by = Column(Integer, ForeignKey("users.id", name="fk_faq_ver_user"), nullable=True)
    restored_from = Column(Integer, nullable=True)

    faq = relationship("FAQ", back_populates="versions")

class FAQVote(Base, TimestampMixin):
    __tablename__ = "faq_votes"
    id = Column(Integer, primary_key=True, index=True)
    faq_id = Column(Integer, ForeignKey("faqs.id", name="fk_faq_vote_faq"))
    voter_id = Column(String(255)) # IP or Session
    vote_type = Column(String(50)) # helpful, not_helpful
    voted_at = Column(DateTime, default=datetime.utcnow)
    
    faq = relationship("FAQ", back_populates="votes")

class FAQAnalytics(Base, TimestampMixin):
    __tablename__ = "faq_analytics"
    id = Column(Integer, primary_key=True, index=True)
    faq_id = Column(Integer, ForeignKey("faqs.id", name="fk_faq_ana_faq"))
    viewed_at = Column(DateTime, default=datetime.utcnow)
    viewer_id = Column(String(255), nullable=True)
    
    faq = relationship("FAQ", back_populates="analytics")

# --- ABOUT US & TEAM ---
class AboutStore(Base, TimestampMixin):
    __tablename__ = "about_store"
    id = Column(Integer, primary_key=True, index=True)
    company_description = Column(Text)
    mission_statement = Column(Text)
    vision_statement = Column(Text)
    values = Column(JSON, nullable=True)
    company_image_url = Column(String(500), nullable=True)
    is_current = Column(Boolean, default=True)
    updated_by = Column(Integer, ForeignKey("users.id", name="fk_about_upd"), nullable=True)

    versions = relationship("AboutStoreVersion", back_populates="about_store", cascade="all, delete-orphan")
    certifications = relationship("Certification", back_populates="about_store", cascade="all, delete-orphan")
    awards = relationship("Award", back_populates="about_store", cascade="all, delete-orphan")
    timeline_events = relationship("TimelineEvent", back_populates="about_store", cascade="all, delete-orphan")

class AboutStoreVersion(Base, TimestampMixin):
    __tablename__ = "about_store_versions"
    id = Column(Integer, primary_key=True, index=True)
    about_store_id = Column(Integer, ForeignKey("about_store.id", name="fk_about_ver_about"))
    version_number = Column(Integer)
    company_description = Column(Text)
    mission_statement = Column(Text)
    vision_statement = Column(Text)
    values = Column(JSON, nullable=True)
    created_by = Column(Integer, ForeignKey("users.id", name="fk_about_ver_user"), nullable=True)

    about_store = relationship("AboutStore", back_populates="versions")

class TeamMember(Base, TimestampMixin):
    __tablename__ = "team_members"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))
    job_title = Column(String(255))
    email = Column(String(255), nullable=True)
    phone = Column(String(50), nullable=True)
    photo_url = Column(String(500), nullable=True)
    photo_thumbnail_url = Column(String(500), nullable=True)
    bio = Column(Text, nullable=True)
    department = Column(String(100), nullable=True)
    linkedin_url = Column(String(500), nullable=True)
    skills = Column(JSON, nullable=True)
    is_active = Column(Boolean, default=True)
    display_order = Column(Integer, default=0)
    is_deleted = Column(Boolean, default=False)

class Certification(Base, TimestampMixin):
    __tablename__ = "certifications"
    id = Column(Integer, primary_key=True, index=True)
    about_us_id = Column(Integer, ForeignKey("about_store.id", name="fk_cert_about"))
    cert_name = Column(String(255))
    cert_body = Column(String(255))
    cert_image_url = Column(String(500), nullable=True)
    issue_date = Column(DateTime, nullable=True)
    expiration_date = Column(DateTime, nullable=True)
    cert_url = Column(String(500), nullable=True)

    about_store = relationship("AboutStore", back_populates="certifications")

class Award(Base, TimestampMixin):
    __tablename__ = "awards"
    id = Column(Integer, primary_key=True, index=True)
    about_us_id = Column(Integer, ForeignKey("about_store.id", name="fk_award_about"))
    award_name = Column(String(255))
    organization = Column(String(255))
    award_date = Column(DateTime, nullable=True)
    award_image_url = Column(String(500), nullable=True)

    about_store = relationship("AboutStore", back_populates="awards")

class TimelineEvent(Base, TimestampMixin):
    __tablename__ = "timeline_events"
    id = Column(Integer, primary_key=True, index=True)
    about_us_id = Column(Integer, ForeignKey("about_store.id", name="fk_time_about"))
    event_year = Column(Integer)
    event_title = Column(String(255))
    event_description = Column(Text)
    event_image_url = Column(String(500), nullable=True)
    position = Column(Integer, default=0)

    about_store = relationship("AboutStore", back_populates="timeline_events")

# --- LEGAL DOCUMENTS ---
class LegalDocument(Base, TimestampMixin):
    __tablename__ = "legal_documents"
    id = Column(Integer, primary_key=True, index=True)
    document_type = Column(String(100), index=True) # terms_of_service, privacy_policy, refund_policy
    content = Column(Text)
    version_number = Column(Integer, default=1)
    status = Column(String(50), default="draft")
    is_current = Column(Boolean, default=False)
    effective_date = Column(DateTime, nullable=True)
    scheduled_effective_date = Column(DateTime, nullable=True)
    published_at = Column(DateTime, nullable=True)
    published_by = Column(Integer, ForeignKey("users.id", name="fk_legal_pub"), nullable=True)

class LegalDocumentVersion(Base, TimestampMixin):
    __tablename__ = "legal_document_versions"
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("legal_documents.id", name="fk_legal_ver"))
    version_number = Column(Integer)
    content = Column(Text)
    status = Column(String(50))
    created_by = Column(Integer, ForeignKey("users.id", name="fk_legal_ver_user"), nullable=True)
    effective_date = Column(DateTime, nullable=True)
