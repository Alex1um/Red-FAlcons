from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from ...external.oauth2.core import get_current_user
from ...external.oauth2.schemas import TokenData
from .core import get_shops


shops_router = APIRouter(tags=["shops"])


@shops_router.get("/shops", summary="Get closest shops.")
async def find_shops_view(
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session),
):
    return await get_shops(1, 2)
