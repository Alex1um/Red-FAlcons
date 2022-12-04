from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, status, Depends

from .core import create_user
from .schemas import UserCreate, UserResponse
from ...db.session import get_session

auth_router = APIRouter(tags=["auth"])


@auth_router.post(
    "/users", status_code=status.HTTP_201_CREATED, response_model=UserResponse
)
async def create_user_view(user: UserCreate, db: AsyncSession = Depends(get_session)):
    return await create_user(user, db)
