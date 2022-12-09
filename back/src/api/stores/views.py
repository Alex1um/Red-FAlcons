from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from .core import get_shops
from .schemas import StoreOut


shops_router = APIRouter(tags=["stores"])


@shops_router.get(
    "/stores", summary="Get all stores from db.", response_model=list[StoreOut]
)
async def find_shops_view(
    db: AsyncSession = Depends(get_session),
):
    return await get_shops(db)
