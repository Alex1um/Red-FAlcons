import math
from OSMPythonTools.overpass import Overpass
from loguru import logger
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import Card, Store
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


async def get_store_name(store_id: int, db: AsyncSession) -> str:
    query = select(Store).where(Store.id == store_id)
    query_result = await db.execute(query)
    return query_result.first().tuple()[0].name



async def get_store_query(store_id: int, db: AsyncSession) -> str:
    query = select(Store).where(Store.id == store_id)
    query_result = await db.execute(query)
    return query_result.first().tuple()[0].query



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


async def get_sorted_card_list(
    user_id: int, db: AsyncSession, user_lat: float, user_lon: float
):
    cards = await get_all_cards(user_id, db)
    cards_map = {card.store_id: card for card in cards}

    distance_map = dict()
    for card in cards:
        query = await get_store_query(card.store_id, db)
        distance_map[card.store_id] = await find_nearest_shop(user_lat, user_lon, query)
    logger.debug(f"{distance_map}")
    cards_id_list = [
        key[0] for key in sorted(distance_map.items(), key=lambda elem: elem[1])
    ]
    logger.debug(f"{cards_id_list}")

    cards_list = [cards_map[id] for id in cards_id_list]
    return cards_list


async def find_nearest_shop(user_lat, user_lon, query) -> float:
    overpass = Overpass()
    shops = overpass.query(
        query + "(around:1000," + str(user_lat) + "," + str(user_lon) + "); out body;"
    ).elements()
    min_dist = 1000000
    for shop in shops:
        dist = await calculate_length(user_lat, user_lon, shop.lat(), shop.lon())
        min_dist = dist if dist < min_dist else min_dist
    return min_dist


async def calculate_length(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6372795
    delta = abs(lat1 - lat2)
    num = (math.cos(lat2) * math.sin(delta)) ** 2 + \
        (math.cos(lat1) * math.sin(lat2) - \
         math.sin(lat1) * math.cos(lat2) * math.cos(delta)) ** 2
    num = math.sqrt(num)
    denom = math.sin(lat1) * math.sin(lat2) + \
            math.cos(lat1) * math.cos(lat2) * math.cos(delta)
    arctg = math.atan2(num, denom)
    return R * arctg
