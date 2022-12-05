from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from ...external.oauth2.core import get_current_user
from ...external.oauth2.schemas import TokenData
from .core import create_card, get_all_cards, get_sorted_card_list
from .schemas import CardIn, CardOut


cards_router = APIRouter(prefix="/cards", tags=["cards"])


@cards_router.get("/", summary="Get all cards.", response_model=list[CardOut])
async def get_all_cards_view(
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    return await get_all_cards(int(token_data.id), db)


# For Josh Woods to change
@cards_router.get(
    "/geo", summary="Get cards sorted by geo.", response_model=list[CardOut | None]
)
async def get_geo_cards_view(
    latitude: float,
    longitude: float,
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    return await get_sorted_card_list(int(token_data.id), db, latitude, longitude)


@cards_router.post(
    "/new",
    summary="Create new card.",
    status_code=status.HTTP_201_CREATED,
    response_model=CardOut,
)
async def create_card_view(
    card: CardIn,
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    return await create_card(card, int(token_data.id), db)
