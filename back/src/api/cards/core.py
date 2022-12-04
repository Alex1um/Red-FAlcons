from loguru import logger
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import Card
from .schemas import CardIn


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


async def create_card(card: CardIn, user_id: int, db: AsyncSession) -> Card:
    """
    Creates new card in DB.

    Returns Card obj.
    """
    card_dict = card.dict()
    card_dict["owner_id"] = user_id

    new_card = Card(**card_dict)
    db.add(new_card)
    await db.commit()
    await db.refresh(new_card)

    logger.info("Added new card to DB.")

    return new_card
