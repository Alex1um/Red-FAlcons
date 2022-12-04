from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, status, Depends
from fastapi.security.oauth2 import OAuth2PasswordRequestForm

from .core import create_user, get_user, get_token
from .oauth2 import get_current_user
from .schemas import UserCreate, UserResponse
from ...db.session import get_session


auth_router = APIRouter(prefix="/auth", tags=["auth"])


@auth_router.post(
    "/register", status_code=status.HTTP_201_CREATED, response_model=UserResponse
)
async def create_user_view(user: UserCreate, db: AsyncSession = Depends(get_session)):
    return await create_user(user, db)


@auth_router.post("/login")
async def login_view(
    user_credentials: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_session),
):
    return await get_token(user_credentials, db)


@auth_router.get("/{id}", response_model=UserResponse)
async def get_user_view(
    id: int,
    db: AsyncSession = Depends(get_session),
    user_id: int = Depends(get_current_user),
):
    return await get_user(id, db)
