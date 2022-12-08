from fastapi import APIRouter, status, Depends
from fastapi.security.oauth2 import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.session import get_session
from ...external.oauth2.schemas import TokenData
from .core import create_user, get_token, delete_user
from .schemas import Token, UserIn, UserOut
from ...external.oauth2.core import get_current_user

auth_router = APIRouter(prefix="/auth", tags=["auth"])


@auth_router.post(
    "/register", status_code=status.HTTP_201_CREATED, response_model=UserOut
)
async def create_user_view(user: UserIn, db: AsyncSession = Depends(get_session)):
    return await create_user(user, db)


@auth_router.post("/login", response_model=Token)
async def login_view(
    user_credentials: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_session),
):
    return await get_token(user_credentials, db)

@auth_router.delete(
    "/delete", status_code=status.HTTP_204_NO_CONTENT
)
async def delete_user_view(
    token_data: TokenData = Depends(get_current_user),
    db: AsyncSession = Depends(get_session)
):
    return await delete_user(int(token_data.id), db)

