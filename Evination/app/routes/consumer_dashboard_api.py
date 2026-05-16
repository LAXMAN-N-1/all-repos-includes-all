from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.dependencies import get_customer_user
from app.schemas.analytics_schema import (
    CustomerFavoriteItem, CustomerSuggestedItem, CustomerHistoryItem
)
from app.utils.logger_config import setup_logger

router = APIRouter(prefix="/api/consumer/dashboard", tags=["Consumer Analytics"])
logger = setup_logger(__name__)

@router.get("/favorites", response_model=List[CustomerFavoriteItem])
def get_customer_favorites(
    db: Session = Depends(get_db),
    user=Depends(get_customer_user)
):
    """
    Returns exact 'Favorite Events' list from React design.
    Requires customer authentication.
    """
    try:
        logger.info(f"Fetching favorites for customer user_id={user.id}")
        
        # TODO: Replace with actual database query based on user preferences
        favorites = [
            {"title": 'Wedding Planning', "image_url": "https://images.unsplash.com/photo-1621796825409-52931132f227?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwY2VyZW1vbnklMjBiZWF1dGlmdWx8ZW58MXx8fHwxNzYzNDg4ODcwfDA&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Create your dream wedding with expert planners', "rating": 4.9, "bookings_count": 1250},
            {"title": 'Engagement Party', "image_url": "https://images.unsplash.com/photo-1762709117970-95eed4f7e1f5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbmdhZ2VtZW50JTIwcGFydHklMjByb21hbnRpY3xlbnwxfHx8fDE3NjM0ODk2NzJ8MA&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Romantic celebrations for your special moment', "rating": 4.8, "bookings_count": 856},
            {"title": 'Anniversary Celebration', "image_url": "https://images.unsplash.com/photo-1763429727882-3b8a7f6c5392?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbm5pdmVyc2FyeSUyMGNlbGVicmF0aW9uJTIwZWxlZ2FudHxlbnwxfHx8fDE3NjM0ODk2NzJ8MA&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Elegant anniversary events to remember', "rating": 4.7, "bookings_count": 642},
            {"title": 'Gala Dinner', "image_url": "https://images.unsplash.com/photo-1759124650033-86c0623481c8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxnYWxhJTIwZGlubmVyJTIwZWxlZ2FudHxlbnwxfHx8fDE3NjM0NTc5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Sophisticated dining experiences', "rating": 4.9, "bookings_count": 923},
        ]
        
        logger.info(f"Successfully fetched {len(favorites)} favorites for user_id={user.id}")
        return favorites
        
    except Exception as e:
        logger.error(f"Error fetching favorites for user_id={user.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch favorite events"
        )

@router.get("/suggested", response_model=List[CustomerSuggestedItem])
def get_customer_suggested(
    db: Session = Depends(get_db),
    user=Depends(get_customer_user)
):
    """
    Returns exact 'Suggested Events' list from React design.
    Requires customer authentication.
    """
    try:
        logger.info(f"Fetching suggested events for customer user_id={user.id}")
        
        # TODO: Replace with AI-based recommendations based on user history
        suggested = [
            {"title": 'Corporate Events', "image_url": "https://images.unsplash.com/photo-1762765684665-6b6855bb6fe6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3Jwb3JhdGUlMjBldmVudCUyMHZlbnVlfGVufDF8fHx8MTc2MzQ2OTkyMnww&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Professional corporate event management', "badge_text": 'Trending'},
            {"title": 'Birthday Celebrations', "image_url": "https://images.unsplash.com/photo-1650584997985-e713a869ee77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiaXJ0aGRheSUyMHBhcnR5JTIwY2VsZWJyYXRpb258ZW58MXx8fHwxNzYzNDY5NDQ4fDA&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Memorable birthday parties for all ages', "badge_text": 'Popular'},
            {"title": 'Conference & Seminars', "image_url": "https://images.unsplash.com/photo-1762968269894-1d7e1ce8894e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25mZXJlbmNlJTIwc2VtaW5hciUyMGJ1c2luZXNzfGVufDF8fHx8MTc2MzQ4OTY3M3ww&ixlib=rb-4.1.0&q=80&w=1080", "description": 'Professional business event solutions', "badge_text": 'New'},
        ]
        
        logger.info(f"Successfully fetched {len(suggested)} suggested events for user_id={user.id}")
        return suggested
        
    except Exception as e:
        logger.error(f"Error fetching suggested events for user_id={user.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch suggested events"
        )

@router.get("/history", response_model=List[CustomerHistoryItem])
def get_customer_history(
    db: Session = Depends(get_db),
    user=Depends(get_customer_user)
):
    """
    Returns exact 'Previous Events' list from React design.
    Requires customer authentication.
    """
    try:
        logger.info(f"Fetching event history for customer user_id={user.id}")
        
        # TODO: Replace with actual database query for user's past events
        history = [
            {"title": 'Baby Shower', "image_url": "https://images.unsplash.com/photo-1758548204223-b830a3224f73?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYWJ5JTIwc2hvd2VyJTIwY2VsZWJyYXRpb258ZW58MXx8fHwxNjM0NTgwNjF8MA&ixlib=rb-4.1.0&q=80&w=1080", "date": 'Oct 15, 2025', "status": 'Completed'},
            {"title": 'Graduation Party', "image_url": "https://images.unsplash.com/photo-1758682016284-78f5266d5743?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxnYWxhJTIwZGlubmVyJTIwZWxlZ2FudHxlbnwxfHx8fDE3NjM0NTc5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080", "date": 'Sep 28, 2025', "status": 'Completed'},
            {"title": 'Retirement Celebration', "image_url": "https://images.unsplash.com/photo-1657194664889-e17053b5ef4f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyZXRpcmVtZW50JTIwcGFydHklMjBjZWxlYnJhdGlvbnxlbnwxfHx8fDE3NjM0ODk3ODV8MA&ixlib=rb-4.1.0&q=80&w=1080", "date": 'Aug 12, 2025', "status": 'Completed'},
        ]
        
        logger.info(f"Successfully fetched {len(history)} history items for user_id={user.id}")
        return history
        
    except Exception as e:
        logger.error(f"Error fetching event history for user_id={user.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch event history"
        )
