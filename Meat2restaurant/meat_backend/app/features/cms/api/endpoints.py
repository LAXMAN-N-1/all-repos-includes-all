from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import or_, func, case
from datetime import datetime
from app import models, schemas
from app.api import deps

# Compatibility Aliases for Models
WebPage = models.WebPage
WebPageVersion = models.WebPageVersion
BlogPost = models.BlogPost
BlogPostVersion = models.BlogPostVersion
BlogComment = models.BlogComment
Recipe = models.Recipe
RecipeVersion = models.RecipeVersion
FAQ = models.FAQ
FAQVersion = models.FAQVersion
FAQVote = models.FAQVote
LegalDocument = models.LegalDocument
LegalDocumentVersion = models.LegalDocumentVersion
AboutStore = models.AboutStore
RecipeIngredient = models.RecipeIngredient
RecipeStep = models.RecipeStep
RecipeNutrition = models.RecipeNutrition
RecipeReview = models.RecipeReview
TeamMember = models.TeamMember
Certification = models.Certification
Award = models.Award
TimelineEvent = models.TimelineEvent
AboutStoreVersion = models.AboutStoreVersion
Product = models.Product

# Compatibility Aliases for Schemas
WebPageCreate = schemas.WebPageCreate
WebPageUpdate = schemas.WebPageUpdate
WebPageOut = schemas.WebPageOut
WebPageVersionOut = schemas.WebPageVersionOut
BlogPostCreate = schemas.BlogPostCreate
BlogPostUpdate = schemas.BlogPostUpdate
BlogPostOut = schemas.BlogPostOut
BlogPostVersionOut = schemas.BlogPostVersionOut
RecipeCreate = schemas.RecipeCreate
RecipeUpdate = schemas.RecipeUpdate
RecipeOut = schemas.RecipeOut
FAQCreate = schemas.FAQCreate
FAQUpdate = schemas.FAQUpdate
FAQOut = schemas.FAQOut
LegalDocumentCreate = schemas.LegalDocumentCreate
LegalDocumentUpdate = schemas.LegalDocumentUpdate
LegalDocumentOut = schemas.LegalDocumentOut
LegalDocumentVersionOut = schemas.LegalDocumentVersionOut
AboutStoreCreate = schemas.AboutStoreCreate
AboutStoreUpdate = schemas.AboutStoreUpdate
AboutStoreOut = schemas.AboutStoreOut
TeamMemberCreate = schemas.TeamMemberCreate
TeamMemberUpdate = schemas.TeamMemberUpdate
TeamMemberOut = schemas.TeamMemberOut
CertificationCreate = schemas.CertificationCreate
CertificationOut = schemas.CertificationOut
AwardCreate = schemas.AwardCreate
AwardOut = schemas.AwardOut
TimelineEventCreate = schemas.TimelineEventCreate
TimelineEventOut = schemas.TimelineEventOut

router = APIRouter()

# --- HELPER FUNCS ---
def save_webpage_version(db: Session, page: WebPage, user_id: int, restored_from: int = None):
    count = db.query(WebPageVersion).filter(WebPageVersion.page_id == page.id).count()
    version = WebPageVersion(
        page_id=page.id, version_number=count + 1, content=page.content or "", 
        featured_image_url=page.featured_image_url, 
        meta_title=page.meta_title, meta_description=page.meta_description, meta_keywords=page.meta_keywords,
        is_homepage=page.is_homepage, visibility=page.visibility,
        status=page.status, 
        created_by=user_id, restored_from=restored_from
    )
    db.add(version)

def save_blog_version(db: Session, post: BlogPost, user_id: int, restored_from: int = None):
    count = db.query(BlogPostVersion).filter(BlogPostVersion.post_id == post.id).count()
    version = BlogPostVersion(
        post_id=post.id, version_number=count + 1, content=post.content or "", 
        status=post.status, created_by=user_id, restored_from=restored_from
    )
    db.add(version)

def save_legal_version(db: Session, doc: LegalDocument, user_id: int, restored_from: int = None):
    count = db.query(LegalDocumentVersion).filter(LegalDocumentVersion.document_id == doc.id).count()
    version = LegalDocumentVersion(
        document_id=doc.id, version_number=count + 1, content=doc.content or "", 
        status=doc.status, created_by=user_id, effective_date=doc.effective_date
    )
    db.add(version)

def save_faq_version(db: Session, faq: FAQ, user_id: int, restored_from: int = None):
    count = db.query(FAQVersion).filter(FAQVersion.faq_id == faq.id).count()
    version = FAQVersion(
        faq_id=faq.id, version_number=count + 1, answer=faq.answer or "",
        status=faq.status, created_by=user_id, restored_from=restored_from
    )
    db.add(version)

# --- Web Pages ---

@router.get("/pages", response_model=List[WebPageOut])
def read_pages(
    search: Optional[str] = None,
    status: Optional[str] = None,
    visibility: Optional[str] = None,
    sort_by: Optional[str] = "title",
    db: Session = Depends(deps.get_db)
):
    query = db.query(WebPage).filter(WebPage.is_deleted == False)
    
    if search:
        query = query.filter(
            (WebPage.title.ilike(f"%{search}%")) | 
            (WebPage.slug.ilike(f"%{search}%")) |
            (WebPage.content.ilike(f"%{search}%"))
        )
    
    if status:
        query = query.filter(WebPage.status == status)
    
    if visibility:
        query = query.filter(WebPage.visibility == visibility)
        
    if sort_by == "newest":
        query = query.order_by(WebPage.created_at.desc())
    elif sort_by == "updated":
        query = query.order_by(WebPage.updated_at.desc())
    else:
        query = query.order_by(WebPage.title.asc())
        
    return query.all()

@router.post("/pages", response_model=WebPageOut)
def create_page(page_in: WebPageCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    existing = db.query(WebPage).filter(WebPage.slug == page_in.slug, WebPage.is_deleted == False).first()
    if existing:
        raise HTTPException(status_code=400, detail="Page with this slug already exists.")
    
    db_obj = WebPage(**page_in.dict())
    db_obj.updated_by = current_user.id
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    save_webpage_version(db, db_obj, current_user.id)
    db.commit()
    return db_obj

@router.get("/pages/{page_id}", response_model=WebPageOut)
def read_page(page_id: int, db: Session = Depends(deps.get_db)):
    page = db.query(WebPage).filter(WebPage.id == page_id, WebPage.is_deleted == False).first()
    if not page: raise HTTPException(404, "Page not found")
    return page

@router.put("/pages/{page_id}", response_model=WebPageOut)
def update_page(page_id: int, page_in: WebPageUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page = db.query(WebPage).filter(WebPage.id == page_id, WebPage.is_deleted == False).first()
    if not page: raise HTTPException(404, "Page not found")
    
    if page_in.slug is not None and page_in.slug != page.slug:
        existing = db.query(WebPage).filter(WebPage.slug == page_in.slug, WebPage.is_deleted == False).first()
        if existing:
            raise HTTPException(status_code=400, detail="Page with this slug already exists.")
            
    for field, value in page_in.dict(exclude_unset=True).items():
        setattr(page, field, value)
    page.updated_by = current_user.id
    db.add(page)
    db.commit()
    db.refresh(page)
    return page

@router.post("/pages/{page_id}/draft", response_model=WebPageOut)
def draft_page(page_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page = db.query(WebPage).filter(WebPage.id == page_id).first()
    if not page: raise HTTPException(404)
    page.status = "draft"
    page.is_published = False
    save_webpage_version(db, page, current_user.id)
    db.commit()
    db.refresh(page)
    return page

@router.post("/pages/{page_id}/publish", response_model=WebPageOut)
def publish_page(page_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page = db.query(WebPage).filter(WebPage.id == page_id).first()
    if not page: raise HTTPException(404)
    
    if not page.title or not page.content:
        raise HTTPException(status_code=400, detail="Cannot publish a page without a title and content.")
        
    page.status = "published"
    page.is_published = True
    page.published_at = datetime.utcnow()
    page.published_by = current_user.id
    save_webpage_version(db, page, current_user.id)
    db.commit()
    db.refresh(page)
    return page

@router.get("/pages/{page_id}/versions", response_model=List[WebPageVersionOut])
def page_versions(page_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    return db.query(WebPageVersion).filter(WebPageVersion.page_id == page_id).order_by(WebPageVersion.version_number.desc()).all()

@router.post("/pages/{page_id}/restore/{version_id}", response_model=WebPageOut)
def restore_page_version(page_id: int, version_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page = db.query(WebPage).filter(WebPage.id == page_id).first()
    version = db.query(WebPageVersion).filter(WebPageVersion.id == version_id, WebPageVersion.page_id == page_id).first()
    if not page or not version: raise HTTPException(404)
    page.content = version.content
    page.featured_image_url = version.featured_image_url
    page.meta_title = version.meta_title
    page.meta_description = version.meta_description
    page.meta_keywords = version.meta_keywords
    page.status = "draft"
    page.is_published = False
    save_webpage_version(db, page, current_user.id, restored_from=version.id)
    db.commit()
    db.refresh(page)
    return page

@router.delete("/pages/{id}")
def delete_page(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page = db.query(WebPage).filter(WebPage.id == id).first()
    if not page: raise HTTPException(404)
    page.is_deleted = True
    db.commit()
    return {"status": "success"}


# --- Blog Posts ---
@router.get("/blogs", response_model=List[BlogPostOut])
@router.get("/blog", response_model=List[BlogPostOut])
def read_blog_posts(
    db: Session = Depends(deps.get_db),
    q: Optional[str] = None,
    status: Optional[str] = None,
    category: Optional[str] = None,
    author_id: Optional[int] = None,
    sort_by: Optional[str] = "newest"
):
    query = db.query(BlogPost).filter(BlogPost.is_deleted == False)
    
    if q:
        search = f"%{q}%"
        query = query.filter(
            or_(
                BlogPost.title.ilike(search),
                BlogPost.content.ilike(search),
                BlogPost.tags.ilike(search)
            )
        )
    
    if status:
        query = query.filter(BlogPost.status == status)
    
    if category:
        query = query.filter(BlogPost.category == category)
        
    if author_id:
        query = query.filter(BlogPost.author_id == author_id)
        
    if sort_by == "newest":
        query = query.order_by(BlogPost.created_at.desc())
    elif sort_by == "oldest":
        query = query.order_by(BlogPost.created_at.asc())
    elif sort_by == "most_views":
        query = query.order_by(BlogPost.view_count.desc())
    elif sort_by == "most_comments":
        # Requires join with comments
        pass # Will handle below via manual count for now
    
    posts = query.all()
    
    # Attach counts for Pydantic
    for post in posts:
        post.comment_count = db.query(BlogComment).filter(BlogComment.post_id == post.id).count()
        post.pending_comment_count = db.query(BlogComment).filter(BlogComment.post_id == post.id, BlogComment.status == "pending").count()
        
    if sort_by == "most_comments":
        posts.sort(key=lambda x: x.comment_count, reverse=True)
    elif sort_by == "engagement":
        posts.sort(key=lambda x: x.comment_count + x.view_count, reverse=True)
        
    return posts

@router.post("/blogs", response_model=BlogPostOut)
@router.post("/blog", response_model=BlogPostOut)
def create_blog_post(post_in: BlogPostCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    existing = db.query(BlogPost).filter(BlogPost.slug == post_in.slug, BlogPost.is_deleted == False).first()
    if existing:
        raise HTTPException(status_code=400, detail="Blog post with this slug already exists.")
        
    db_obj = BlogPost(**post_in.dict())
    if not db_obj.author_id: db_obj.author_id = current_user.id
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    save_blog_version(db, db_obj, current_user.id)
    db.commit()
    return db_obj

@router.get("/blogs/{post_id}", response_model=BlogPostOut)
@router.get("/blog/{post_id}", response_model=BlogPostOut)
def read_blog_post(post_id: int, db: Session = Depends(deps.get_db)):
    post = db.query(BlogPost).filter(BlogPost.id == post_id, BlogPost.is_deleted == False).first()
    if not post: raise HTTPException(404)
    return post

@router.put("/blogs/{post_id}", response_model=BlogPostOut)
def update_blog_post(post_id: int, post_in: BlogPostUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    post = db.query(BlogPost).filter(BlogPost.id == post_id, BlogPost.is_deleted == False).first()
    if not post: raise HTTPException(404)
    
    if post_in.slug is not None and post_in.slug != post.slug:
        existing = db.query(BlogPost).filter(BlogPost.slug == post_in.slug, BlogPost.is_deleted == False).first()
        if existing:
            raise HTTPException(status_code=400, detail="Blog post with this slug already exists.")
            
    for field, value in post_in.dict(exclude_unset=True).items(): setattr(post, field, value)
    db.commit()
    db.refresh(post)
    return post

@router.post("/blogs/{post_id}/publish", response_model=BlogPostOut)
def publish_blog(post_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    post = db.query(BlogPost).filter(BlogPost.id == post_id).first()
    if not post: raise HTTPException(404)
    
    if not post.title or not post.content or not post.featured_image_url:
        raise HTTPException(status_code=400, detail="Cannot publish a post without a title, content, and featured image.")
        
    post.status = "published"
    post.is_published = True
    post.published_at = datetime.utcnow()
    save_blog_version(db, post, current_user.id)
    db.commit()
    db.refresh(post)
    return post

@router.get("/blogs/{post_id}/versions", response_model=List[BlogPostVersionOut])
def blog_versions(post_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    return db.query(BlogPostVersion).filter(BlogPostVersion.post_id == post_id).order_by(BlogPostVersion.version_number.desc()).all()

@router.delete("/blogs/{id}")
def delete_blog(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    post = db.query(BlogPost).filter(BlogPost.id == id).first()
    if not post: raise HTTPException(404)
    post.is_deleted = True
    db.commit()
    return {"status": "success"}


# --- Recipes ---
@router.get("/recipes", response_model=List[RecipeOut])
def read_recipes(db: Session = Depends(deps.get_db)):
    return db.query(Recipe).filter(Recipe.is_deleted == False).all()

@router.post("/recipes", response_model=RecipeOut)
def create_recipe(rec_in: RecipeCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    rec_data = rec_in.dict(exclude={"ingredients", "steps", "nutrition", "linked_product_ids"})
    
    existing = db.query(Recipe).filter(Recipe.slug == rec_in.slug, Recipe.is_deleted == False).first()
    if existing:
        raise HTTPException(status_code=400, detail="Recipe with this slug already exists.")

    db_obj = Recipe(**rec_data)
    db.add(db_obj)
    db.flush()

    if rec_in.ingredients:
        for ing in rec_in.ingredients:
            db.add(RecipeIngredient(**ing.dict(), recipe_id=db_obj.id))
            
    if rec_in.steps:
        for step in rec_in.steps:
            db.add(RecipeStep(**step.dict(), recipe_id=db_obj.id))
            
    if rec_in.nutrition:
        db.add(RecipeNutrition(**rec_in.nutrition.dict(), recipe_id=db_obj.id))
        
    if rec_in.linked_product_ids:
        products = db.query(Product).filter(Product.id.in_(rec_in.linked_product_ids)).all()
        db_obj.linked_products = products

    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/recipes/{rec_id}", response_model=RecipeOut)
def read_recipe(rec_id: int, db: Session = Depends(deps.get_db)):
    rec = db.query(Recipe).filter(Recipe.id == rec_id, Recipe.is_deleted == False).first()
    if not rec: raise HTTPException(404)
    return rec

@router.put("/recipes/{rec_id}", response_model=RecipeOut)
def update_recipe(rec_id: int, rec_in: RecipeUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    rec = db.query(Recipe).filter(Recipe.id == rec_id, Recipe.is_deleted == False).first()
    if not rec: raise HTTPException(404)
    
    if rec_in.slug is not None and rec_in.slug != rec.slug:
        existing = db.query(Recipe).filter(Recipe.slug == rec_in.slug, Recipe.is_deleted == False).first()
        if existing:
            raise HTTPException(status_code=400, detail="Recipe with this slug already exists.")

    rec_data = rec_in.dict(exclude_unset=True, exclude={"ingredients", "steps", "nutrition", "linked_product_ids"})
    for field, value in rec_data.items(): getattr(rec, field) # To ignore pylint warn empty block
    for field, value in rec_data.items(): setattr(rec, field, value)
    
    if rec_in.ingredients is not None:
        db.query(RecipeIngredient).filter(RecipeIngredient.recipe_id == rec_id).delete()
        for ing in rec_in.ingredients:
            db.add(RecipeIngredient(**ing.dict(), recipe_id=rec_id))

    if rec_in.steps is not None:
        db.query(RecipeStep).filter(RecipeStep.recipe_id == rec_id).delete()
        for step in rec_in.steps:
            db.add(RecipeStep(**step.dict(), recipe_id=rec_id))
            
    if rec_in.nutrition is not None:
        db.query(RecipeNutrition).filter(RecipeNutrition.recipe_id == rec_id).delete()
        db.add(RecipeNutrition(**rec_in.nutrition.dict(), recipe_id=rec_id))

    if rec_in.linked_product_ids is not None:
        products = db.query(Product).filter(Product.id.in_(rec_in.linked_product_ids)).all()
        rec.linked_products = products

    db.commit()
    db.refresh(rec)
    return rec

@router.post("/recipes/{rec_id}/publish", response_model=RecipeOut)
def publish_recipe(rec_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    rec = db.query(Recipe).filter(Recipe.id == rec_id).first()
    if not rec: raise HTTPException(404)
    
    if not rec.title or not rec.description or not rec.ingredients or not rec.steps:
        raise HTTPException(status_code=400, detail="Cannot publish a recipe without a title, description, ingredients, and steps.")
        
    rec.status = "published"
    rec.is_published = True
    rec.published_at = datetime.utcnow()
    db.commit()
    db.refresh(rec)
    return rec

@router.delete("/recipes/{id}")
def delete_recipe(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    rec = db.query(Recipe).filter(Recipe.id == id).first()
    if not rec: raise HTTPException(404)
    rec.is_deleted = True
    db.commit()
    return {"status": "success"}


@router.get("/faqs", response_model=List[FAQOut])
@router.get("/faq", response_model=List[FAQOut])
def read_faqs(
    db: Session = Depends(deps.get_db),
    q: Optional[str] = None,
    category: Optional[str] = None,
    status: Optional[str] = None,
    sort_by: Optional[str] = "display_order" # display_order, newest, helpful, views
):
    query = db.query(FAQ).filter(FAQ.is_deleted == False)
    
    if q:
        query = query.filter(FAQ.question.ilike(f"%{q}%"))
    if category:
        query = query.filter(FAQ.category == category)
    if status:
        query = query.filter(FAQ.status == status)
        
    if sort_by == "newest":
        query = query.order_by(FAQ.created_at.desc())
    elif sort_by == "helpful":
        query = query.order_by(FAQ.helpful_percentage.desc())
    elif sort_by == "views":
        query = query.order_by(FAQ.view_count.desc())
    else:
        query = query.order_by(FAQ.display_order.asc(), FAQ.id.asc())
        
    results = query.all()
    return results

@router.post("/faqs", response_model=FAQOut)
@router.post("/faq", response_model=FAQOut)
def create_faq(faq_in: FAQCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = FAQ(**faq_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    save_faq_version(db, db_obj, current_user.id)
    db.commit()
    return db_obj

@router.put("/faqs/{faq_id}", response_model=FAQOut)
def update_faq(faq_id: int, faq_in: FAQUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    faq = db.query(FAQ).filter(FAQ.id == faq_id).first()
    if not faq: raise HTTPException(404)
    for field, value in faq_in.dict(exclude_unset=True).items(): setattr(faq, field, value)
    db.commit()
    db.refresh(faq)
    save_faq_version(db, faq, current_user.id)
    db.commit()
    return faq

@router.post("/faqs/{faq_id}/publish", response_model=FAQOut)
def publish_faq(faq_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    faq = db.query(FAQ).filter(FAQ.id == faq_id).first()
    if not faq: raise HTTPException(404)
    if not faq.question or not faq.answer:
        raise HTTPException(status_code=400, detail="FAQ must have a question and an answer to be published.")
    faq.status = "published"
    save_faq_version(db, faq, current_user.id)
    db.commit()
    db.refresh(faq)
    return faq

@router.delete("/faqs/{id}")
def delete_faq(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    faq = db.query(FAQ).filter(FAQ.id == id).first()
    if not faq: raise HTTPException(404)
    faq.is_deleted = True
    db.commit()
    return {"status": "success"}

class FAQVoteIn(BaseModel):
    voter_id: str
    vote_type: str # "helpful" or "not_helpful"

@router.post("/faqs/{faq_id}/vote")
def vote_faq(faq_id: int, vote_in: FAQVoteIn, db: Session = Depends(deps.get_db)):
    faq = db.query(FAQ).filter(FAQ.id == faq_id, FAQ.is_deleted == False).first()
    if not faq: raise HTTPException(404)
    
    existing_vote = db.query(FAQVote).filter(FAQVote.faq_id == faq_id, FAQVote.voter_id == vote_in.voter_id).first()
    if existing_vote:
        raise HTTPException(status_code=400, detail="You have already voted on this FAQ.")
        
    vote = FAQVote(faq_id=faq_id, voter_id=vote_in.voter_id, vote_type=vote_in.vote_type)
    db.add(vote)
    
    if vote_in.vote_type == "helpful":
        faq.helpful_count += 1
    elif vote_in.vote_type == "not_helpful":
        faq.unhelpful_count += 1
        
    total_votes = faq.helpful_count + faq.unhelpful_count
    if total_votes > 0:
        faq.helpful_percentage = (faq.helpful_count / total_votes) * 100.0
        
    db.commit()
    return {"status": "success", "helpful_count": faq.helpful_count, "helpful_percentage": faq.helpful_percentage}

class FAQReorderItem(BaseModel):
    id: int
    display_order: int

@router.put("/faqs/reorder")
def reorder_faqs(items: List[FAQReorderItem], db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    for item in items:
        faq = db.query(FAQ).filter(FAQ.id == item.id).first()
        if faq:
            faq.display_order = item.display_order
    db.commit()
    return {"status": "success"}

class FAQBulkActionIn(BaseModel):
    ids: List[int]
    action: str # publish, unpublish, delete

@router.post("/faqs/bulk")
def bulk_action_faqs(
    bulk_in: FAQBulkActionIn, 
    db: Session = Depends(deps.get_db), 
    current_user: models.User = Depends(deps.get_current_active_superuser)
):
    faqs = db.query(FAQ).filter(FAQ.id.in_(bulk_in.ids)).all()
    
    for faq in faqs:
        if bulk_in.action == "publish":
            faq.status = "published"
        elif bulk_in.action == "unpublish":
            faq.status = "draft"
        elif bulk_in.action == "delete":
            faq.is_deleted = True
            
    db.commit()
    return {"status": "success", "count": len(faqs)}


# --- Legal Documents ---
@router.get("/legal", response_model=List[LegalDocumentOut])
def read_legal_docs(db: Session = Depends(deps.get_db)):
    return db.query(LegalDocument).all()

@router.post("/legal", response_model=LegalDocumentOut)
def create_legal_doc(doc_in: LegalDocumentCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = LegalDocument(**doc_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    save_legal_version(db, db_obj, current_user.id)
    db.commit()
    return db_obj

@router.put("/legal/{doc_id}", response_model=LegalDocumentOut)
def update_legal_doc(doc_id: int, doc_in: LegalDocumentUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    # Used for minor typo fixes on live documents
    doc = db.query(LegalDocument).filter(LegalDocument.id == doc_id).first()
    if not doc: raise HTTPException(404)
    for field, value in doc_in.dict(exclude_unset=True).items(): setattr(doc, field, value)
    db.commit()
    db.refresh(doc)
    return doc

class LegalDraftIn(BaseModel):
    content: str
    effective_date: Optional[datetime] = None

@router.post("/legal/{doc_id}/draft")
def create_legal_draft(doc_id: int, draft_in: LegalDraftIn, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    doc = db.query(LegalDocument).filter(LegalDocument.id == doc_id).first()
    if not doc: raise HTTPException(404)
    
    count = db.query(LegalDocumentVersion).filter(LegalDocumentVersion.document_id == doc.id).count()
    version = LegalDocumentVersion(
        document_id=doc.id, 
        version_number=count + 1, 
        content=draft_in.content, 
        status="draft", 
        created_by=current_user.id, 
        effective_date=draft_in.effective_date
    )
    db.add(version)
    db.commit()
    db.refresh(version)
    return {"status": "success", "draft_version_id": version.id}

@router.get("/legal/{doc_id}/draft", response_model=Optional[LegalDocumentVersionOut])
def get_pending_draft(doc_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    # Gets the most recent draft
    return db.query(LegalDocumentVersion).filter(LegalDocumentVersion.document_id == doc_id, LegalDocumentVersion.status == "draft").order_by(LegalDocumentVersion.created_at.desc()).first()

@router.post("/legal/versions/{version_id}/approve", response_model=LegalDocumentOut)
def approve_legal_version(version_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    version = db.query(LegalDocumentVersion).filter(LegalDocumentVersion.id == version_id).first()
    if not version: raise HTTPException(404)
    
    doc = db.query(LegalDocument).filter(LegalDocument.id == version.document_id).first()
    
    # 1. Update Version Status
    version.status = "published"
    
    # 2. Apply to Main Document
    doc.content = version.content
    doc.version_number = version.version_number
    doc.status = "published"
    doc.published_at = datetime.utcnow()
    doc.published_by = current_user.id
    
    # 3. Handle Effective Date Logic
    if version.effective_date:
        doc.effective_date = version.effective_date
        # If effective date is in the future, it's scheduled. Let background job handle activation.
        if version.effective_date > datetime.utcnow():
            doc.is_current = False
            doc.scheduled_effective_date = version.effective_date
        else:
            doc.is_current = True
            doc.scheduled_effective_date = None
            db.query(LegalDocument).filter(LegalDocument.document_type == doc.document_type, LegalDocument.id != doc.id).update({"is_current": False})
    else:
        # Immediate effect
        doc.is_current = True
        doc.effective_date = datetime.utcnow()
        doc.scheduled_effective_date = None
        db.query(LegalDocument).filter(LegalDocument.document_type == doc.document_type, LegalDocument.id != doc.id).update({"is_current": False})

    db.commit()
    db.refresh(doc)
    return doc

@router.post("/legal/versions/{version_id}/reject")
def reject_legal_version(version_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    version = db.query(LegalDocumentVersion).filter(LegalDocumentVersion.id == version_id).first()
    if not version: raise HTTPException(404)
    version.status = "rejected"
    db.commit()
    return {"status": "success"}

@router.get("/legal/{doc_id}/versions", response_model=List[LegalDocumentVersionOut])
def legal_versions(doc_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    return db.query(LegalDocumentVersion).filter(LegalDocumentVersion.document_id == doc_id).order_by(LegalDocumentVersion.version_number.desc()).all()


# --- About Store ---
@router.get("/about", response_model=List[AboutStoreOut])
def read_about_store(db: Session = Depends(deps.get_db)):
    return db.query(AboutStore).all()

@router.post("/about", response_model=AboutStoreOut)
def create_about_store(about_in: AboutStoreCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = AboutStore(**about_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.put("/about/{about_id}", response_model=AboutStoreOut)
def update_about_store(about_id: int, about_in: AboutStoreUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    about = db.query(AboutStore).filter(AboutStore.id == about_id).first()
    if not about: raise HTTPException(404)
    for field, value in about_in.dict(exclude_unset=True).items(): setattr(about, field, value)
    db.commit()
    db.refresh(about)
    return about

@router.delete("/about/{id}")
def delete_about_store(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = db.query(AboutStore).filter(AboutStore.id == id).first()
    if not db_obj: raise HTTPException(404)
    db.delete(db_obj)
    db.commit()
    return {"status": "success"}

# --- Moderation ---
from app.features.cms.models.cms import BlogComment, RecipeReview

class BlogCommentOut(BaseModel):
    id: int
    post_id: int
    comment_text: str
    commenter_name: str
    commenter_email: str
    status: str
    is_approved: bool
    approved_at: Optional[datetime] = None
    created_at: datetime
    class Config: from_attributes = True

@router.get("/blog/comments", response_model=List[BlogCommentOut])
def get_blog_comments(status: Optional[str] = None, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    query = db.query(BlogComment)
    if status:
        query = query.filter(BlogComment.status == status)
    return query.order_by(BlogComment.created_at.desc()).all()

@router.post("/blog/comments/{comment_id}/approve")
def approve_blog_comment(comment_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    comment = db.query(BlogComment).filter(BlogComment.id == comment_id).first()
    if not comment: raise HTTPException(404)
    comment.status = "approved"
    comment.is_approved = True
    comment.approved_at = datetime.utcnow()
    comment.approved_by = current_user.id
    db.commit()
    return {"status": "success"}

@router.post("/blog/comments/{comment_id}/reject")
def reject_blog_comment(comment_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    comment = db.query(BlogComment).filter(BlogComment.id == comment_id).first()
    if not comment: raise HTTPException(404)
    db.delete(comment)
    db.commit()
    return {"status": "success"}

from pydantic import BaseModel
class CommentReplyBase(BaseModel):
    reply_text: str

@router.post("/blog/comments/{comment_id}/reply")
def reply_blog_comment(comment_id: int, reply_in: CommentReplyBase, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    parent_comment = db.query(BlogComment).filter(BlogComment.id == comment_id).first()
    if not parent_comment: raise HTTPException(404)
    
    # Check if parent comment is approved
    if not parent_comment.is_approved:
        # Auto-approve the parent if we're replying to it
        parent_comment.status = "approved"
        parent_comment.is_approved = True
        parent_comment.approved_at = datetime.utcnow()
        parent_comment.approved_by = current_user.id

    reply = BlogComment(
        post_id=parent_comment.post_id,
        comment_text=reply_in.reply_text,
        commenter_name=current_user.full_name or "Admin",
        commenter_email=current_user.email,
        status="approved",
        is_approved=True,
        approved_at=datetime.utcnow(),
        approved_by=current_user.id
    )
    # Note: For true threaded replies we'd need a parent_id field on BlogComment. 
    # Since we don't have it right now, we'll just add it as an approved comment
    # In a full implementation, we'd add parent_id = comment_id.
    db.add(reply)
    db.commit()
    return {"status": "success"}

class RecipeReviewOut(BaseModel):
    id: int
    recipe_id: int
    customer_name: str
    rating: int
    review_text: str
    status: str
    is_approved: bool
    approved_at: Optional[datetime] = None
    created_at: datetime
    class Config: from_attributes = True

@router.get("/recipes/reviews", response_model=List[RecipeReviewOut])
def get_recipe_reviews(status: Optional[str] = None, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    query = db.query(RecipeReview)
    if status:
        query = query.filter(RecipeReview.status == status)
    return query.order_by(RecipeReview.created_at.desc()).all()

@router.post("/recipes/reviews/{review_id}/approve")
def approve_recipe_review(review_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    review = db.query(RecipeReview).filter(RecipeReview.id == review_id).first()
    if not review: raise HTTPException(404)
    review.status = "approved"
    review.is_approved = True
    review.approved_at = datetime.utcnow()
    db.commit()
    
    # Recalculate average rating
    recipe = db.query(Recipe).filter(Recipe.id == review.recipe_id).first()
    if recipe:
        approved_reviews = db.query(RecipeReview).filter(RecipeReview.recipe_id == recipe.id, RecipeReview.is_approved == True).all()
        if approved_reviews:
            recipe.total_reviews_count = len(approved_reviews)
            recipe.avg_rating = sum(r.rating for r in approved_reviews) / len(approved_reviews)
            db.add(recipe)
            db.commit()
    
    return {"status": "success"}

@router.post("/recipes/reviews/{review_id}/reject")
def reject_recipe_review(review_id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    review = db.query(RecipeReview).filter(RecipeReview.id == review_id).first()
    if not review: raise HTTPException(404)
    db.delete(review)
    db.commit()
    return {"status": "success"}

# --- About Us ---
@router.get("/about", response_model=AboutStoreOut)
def get_about_store(db: Session = Depends(deps.get_db)):
    about = db.query(AboutStore).filter(AboutStore.is_current == True).first()
    if not about:
        about = AboutStore(company_description="Welcome to B2B Meat Platform")
        db.add(about)
        db.commit()
        db.refresh(about)
    return about

@router.put("/about", response_model=AboutStoreOut)
def update_about_store(about_in: AboutStoreUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    about = db.query(AboutStore).filter(AboutStore.is_current == True).first()
    if not about: raise HTTPException(404)
    
    # Create version backup
    count = db.query(AboutStoreVersion).filter(AboutStoreVersion.about_store_id == about.id).count()
    version = AboutStoreVersion(
        about_store_id=about.id,
        version_number=count + 1,
        company_description=about.company_description,
        mission_statement=about.mission_statement,
        vision_statement=about.vision_statement,
        values=about.values,
        created_by=current_user.id
    )
    db.add(version)
    
    for field, value in about_in.dict(exclude_unset=True).items(): 
        setattr(about, field, value)
    
    about.updated_by = current_user.id
    db.commit()
    db.refresh(about)
    return about

# --- Team Members ---
@router.get("/team", response_model=List[TeamMemberOut])
def get_team_members(db: Session = Depends(deps.get_db)):
    return db.query(TeamMember).filter(TeamMember.is_deleted == False).order_by(TeamMember.display_order.asc(), TeamMember.id.asc()).all()

@router.post("/team", response_model=TeamMemberOut)
def create_team_member(member_in: TeamMemberCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = TeamMember(**member_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.put("/team/{member_id}", response_model=TeamMemberOut)
def update_team_member(member_id: int, member_in: TeamMemberUpdate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    member = db.query(TeamMember).filter(TeamMember.id == member_id).first()
    if not member: raise HTTPException(404)
    for field, value in member_in.dict(exclude_unset=True).items(): 
        setattr(member, field, value)
    db.commit()
    db.refresh(member)
    return member

@router.delete("/team/{id}")
def delete_team_member(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    member = db.query(TeamMember).filter(TeamMember.id == id).first()
    if not member: raise HTTPException(404)
    member.is_deleted = True
    db.commit()
    return {"status": "success"}

class ReorderItem(BaseModel):
    id: int
    display_order: int

@router.put("/team/reorder")
def reorder_team(items: List[ReorderItem], db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    for item in items:
        member = db.query(TeamMember).filter(TeamMember.id == item.id).first()
        if member: member.display_order = item.display_order
    db.commit()
    return {"status": "success"}

# --- Certifications, Awards, Timeline ---
# Certifications
@router.get("/certifications", response_model=List[CertificationOut])
def get_certs(db: Session = Depends(deps.get_db)):
    return db.query(Certification).all()

@router.post("/certifications", response_model=CertificationOut)
def create_cert(cert_in: CertificationCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    about = db.query(AboutStore).filter(AboutStore.is_current == True).first()
    if not about: raise HTTPException(status_code=400, detail="About Store not found")
    db_obj = Certification(**cert_in.dict(), about_us_id=about.id)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.delete("/certifications/{id}")
def delete_cert(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = db.query(Certification).filter(Certification.id == id).first()
    if not db_obj: raise HTTPException(404)
    db.delete(db_obj)
    db.commit()
    return {"status": "success"}

# Awards
@router.get("/awards", response_model=List[AwardOut])
def get_awards(db: Session = Depends(deps.get_db)):
    return db.query(Award).all()

@router.post("/awards", response_model=AwardOut)
def create_award(award_in: AwardCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    about = db.query(AboutStore).filter(AboutStore.is_current == True).first()
    if not about: raise HTTPException(status_code=400, detail="About Store not found")
    db_obj = Award(**award_in.dict(), about_us_id=about.id)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.delete("/awards/{id}")
def delete_award(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = db.query(Award).filter(Award.id == id).first()
    if not db_obj: raise HTTPException(404)
    db.delete(db_obj)
    db.commit()
    return {"status": "success"}

# Timeline
@router.get("/timeline", response_model=List[TimelineEventOut])
def get_timeline(db: Session = Depends(deps.get_db)):
    return db.query(TimelineEvent).order_by(TimelineEvent.event_year.desc()).all()

@router.post("/timeline", response_model=TimelineEventOut)
def create_timeline(timeline_in: TimelineEventCreate, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    about = db.query(AboutStore).filter(AboutStore.is_current == True).first()
    if not about: raise HTTPException(status_code=400, detail="About Store not found")
    db_obj = TimelineEvent(**timeline_in.dict(), about_us_id=about.id)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.delete("/timeline/{id}")
def delete_timeline(id: int, db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    db_obj = db.query(TimelineEvent).filter(TimelineEvent.id == id).first()
    if not db_obj: raise HTTPException(404)
    db.delete(db_obj)
    db.commit()
    return {"status": "success"}

# --- Analytics ---
    from app.features.cms.models.cms import PageAnalytics, BlogAnalytics, RecipeAnalytics, FAQAnalytics
from sqlalchemy import func

@router.get("/analytics/overview")
def get_cms_analytics(db: Session = Depends(deps.get_db), current_user: models.User = Depends(deps.get_current_active_superuser)):
    page_views = db.query(func.count(PageAnalytics.id)).scalar() or 0
    blog_views = db.query(func.count(BlogAnalytics.id)).scalar() or 0
    recipe_views = db.query(func.count(RecipeAnalytics.id)).scalar() or 0
    faq_views = db.query(func.count(FAQAnalytics.id)).scalar() or 0
    
    total_views = page_views + blog_views + recipe_views + faq_views
    
    return {
        "overview": {
            "total_content_views": total_views,
            "page_views": page_views,
            "blog_views": blog_views,
            "recipe_views": recipe_views,
            "faq_views": faq_views
        },
        "engagement": {
            "pending_blog_comments": db.query(BlogComment).filter(BlogComment.status == "pending").count(),
            "pending_recipe_reviews": db.query(RecipeReview).filter(RecipeReview.status == "pending").count(),
            "total_faq_helpful_votes": db.query(FAQ).with_entities(func.sum(FAQ.helpful_count)).scalar() or 0,
        }
    }
