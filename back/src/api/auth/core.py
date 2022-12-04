from fastapi import HTTPException, status
from loguru import logger
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .schemas import UserCreate
from ...db.models import User


pass_context = CryptContext(["bcrypt"], deprecated="auto")


async def create_user(user: UserCreate, db: AsyncSession) -> User:
    query = select(User).where(User.email == user.email)
    res = await db.execute(query)
    old_user = res.scalars().first()

    if old_user is not None:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Email is already taken",
        )

    # Hashing pass
    hashed_pass = pass_context.hash(user.password)
    user.password = hashed_pass

    new_user = User(**user.dict())
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    return new_user
