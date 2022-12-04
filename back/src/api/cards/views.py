from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from ...external.oauth2.core import get_current_user
from ...external.oauth2.schemas import TokenData
from .core import get_all_cards
from .schemas import CardOut


cards_router = APIRouter(prefix="/cards", tags=["cards"])


@cards_router.get("/all", summary="Get all cards.", response_model=list[CardOut])
async def get_all_cards_view(
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    return await get_all_cards(int(token_data.id), db)


# For Josh Woods to change
@cards_router.get("/geo", summary="Get cards sorted by geo.")
async def get_geo_cards_view(
    latitude: float,
    longitude: float,
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    pass
