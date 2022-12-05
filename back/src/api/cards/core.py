import math
from OSMPythonTools.overpass import Overpass
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


async def get_sorted_card_list(user_lat: float, user_lon: float):
    # get cards from db
    cards = []
    distance_map = dict()
    for card in cards:
        distance_map[card.name] = find_nearest_shop(user_lat, user_lon, card.query)
    cards_list = {key for key in sorted(distance_map.items(), key=lambda elem: elem[1])}
    return cards_list


async def find_nearest_shop(user_lat, user_lon, query) -> float:
    overpass = await Overpass()
    shops = await overpass.query(
        query + "(around:1000," + str(user_lat) + "," + str(user_lon) + "); out body;"
    )
    min_dist = 1000
    for shop in shops:
        dist = await calculate_length(user_lat, user_lon, shop.lat(), shop.lon())
        min_dist = dist if dist < min_dist else min_dist
    return min_dist


async def calculate_length(p1_x: float, p1_y: float, p2_x: float, p2_y: float) -> float:
    return math.sqrt((p1_x - p2_x) ** 2 + (p1_y - p2_y) ** 2)
