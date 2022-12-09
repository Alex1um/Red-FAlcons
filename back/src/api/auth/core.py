from fastapi import HTTPException, status
from fastapi.security.oauth2 import OAuth2PasswordRequestForm
from loguru import logger
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import User
from ...external.oauth2.core import create_access_token
from .schemas import UserIn
from .utils import hash_password, verify


async def create_user(user: UserIn, db: AsyncSession) -> User:
    """
    Creates user in DB.

    Checks if user with this email not in DB and add user to DB.
    Returns user object from DB.
    """
    query = select(User).where(User.username == user.username)
    res = await db.execute(query)
    old_user = res.scalars().first()

    if old_user is not None:
        logger.info(f"User {user.username} already exists.")
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


async def delete_user(user_id: int, db: AsyncSession) -> None:
    """
    Deletes user from DB.
    """
    query = delete(User).where(User.id == user_id)
    await db.execute(query)
    await db.commit()
    logger.info(f"Deleted user with id: {user_id} from DB.")


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
    logger.info("Generated acces_token")

    return {"access_token": access_token, "token_type": "Bearer"}
