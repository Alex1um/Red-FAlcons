from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from ...external.oauth2.core import get_current_user
from ...external.oauth2.schemas import TokenData
from .core import get_shops
from .schemas import StoreOut


shops_router = APIRouter(tags=["stores"])


@shops_router.get(
    "/stores", summary="Get closest shops.", response_model=list[StoreOut]
)
async def find_shops_view(
    db: AsyncSession = Depends(get_session),
):
    return await get_shops(db)
