from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.engine.row import Row
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import Card


async def get_all_cards(
    user_id: int,
    db: AsyncSession,
) -> list[Card]:
    """Retrieves all cards from DB for that user."""
    query = select(Card).where(Card.owner_id == user_id)
    query_result = await db.execute(query)
    result = []
    for row in query_result.fetchall():
        result.append(row.tuple()[0])
    return result
