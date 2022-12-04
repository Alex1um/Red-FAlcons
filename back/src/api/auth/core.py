from fastapi import HTTPException, status
from fastapi.security.oauth2 import OAuth2PasswordRequestForm
from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .oauth2 import create_access_token
from .schemas import UserCreate, UserLogin
from .utils import hash_password, verify
from ...db.models import User


async def create_user(user: UserCreate, db: AsyncSession) -> User:
    """
    Creates user in DB.

    Checks if user with this email not in DB and add user to DB.
    Returns user object from DB.
    """
    query = select(User).where(User.username == user.username)
    res = await db.execute(query)
    old_user = res.scalars().first()

    if old_user is not None:
        logger.info(f"User with email {user.username} already exists.")
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Username is already taken",
        )

    hashed_pass = hash_password(user.password)
    user.password = hashed_pass

    new_user = User(**user.dict())
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    logger.info("Added new user to DB.")

    return new_user


async def get_user(id: int, db: AsyncSession) -> User:
    """Retrieves user from DB by id."""
    query = select(User).where(User.id == id)
    res = await db.execute(query)
    old_user = res.scalars().first()

    if not old_user:
        logger.info(f"User with id {id} does not exist.")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with id {id} does not exist.",
        )

    return old_user


async def get_token(
    user_credentials: OAuth2PasswordRequestForm, db: AsyncSession
) -> dict[str, str]:
    """Provides access_token and token_type if credentials are right"""
    query = select(User).where(User.username == user_credentials.username)
    res = await db.execute(query)
    user = res.scalars().first()

    if not user:
        logger.info("Invalid Credentials")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid Credentials",
        )

    if not verify(user_credentials.password, user.password):
        logger.info("Invalid Credentials")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid Credentials",
        )

    access_token = create_access_token({"user_id": user.id})

    return {"access_token": access_token, "token_type": "Bearer"}
