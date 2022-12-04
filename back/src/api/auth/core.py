from fastapi import HTTPException, status
from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .schemas import UserCreate
from .utils import hash_password
from ...db.models import User


async def create_user(user: UserCreate, db: AsyncSession) -> User:
    """
    Creates user in DB

    Checks if user not in DB and add user to DB.
    Returns user object from DB.
    """
    query = select(User).where(User.email == user.email)
    res = await db.execute(query)
    old_user = res.scalars().first()

    if old_user is not None:
        logger.info(f"User with email {user.email} already exists.")
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Email is already taken",
        )

    hashed_pass = hash_password(user.password)
    user.password = hashed_pass

    new_user = User(**user.dict())
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    logger.info("Added new user to DB.")

    return new_user
