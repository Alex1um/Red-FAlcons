import math

from OSMPythonTools.overpass import Overpass
from fastapi import HTTPException, status
from loguru import logger
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import Card, Store, User
from .schemas import CardIn


async def get_all_cards(
    user_id: int,
    db: AsyncSession,
) -> list[Card]:
    """Retrieves all cards from DB for that user."""
    query = select(User).where(User.id == user_id)
    res = await db.execute(query)
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    return user.cards


async def get_store_name(store_id: int, db: AsyncSession) -> str:
    query = select(Store).where(Store.id == store_id)
    query_result = await db.execute(query)
    return query_result.scalar_one().name


async def get_store_query(store_id: int, db: AsyncSession) -> str:
    query = select(Store).where(Store.id == store_id)
    query_result = await db.execute(query)
    return query_result.scalar_one().query


async def create_card(card: CardIn, user_id: int, db: AsyncSession) -> Card:
    """
    Creates new card in DB.

    Returns Card obj.
    """
    query = select(User).where(User.id == user_id)
    res = await db.execute(query)
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    card_dict = card.dict()
    card_dict["owner_id"] = user_id
    new_card = Card(**card_dict)
    user.cards.append(new_card)
    db.add(user)
    await db.commit()
    await db.refresh(new_card)

    logger.info("Added new card to DB.")

    return new_card


async def delete_card(user_id: int, card_id: int, db: AsyncSession) -> None:
    """
    Deletes card from DB.
    """
    query = select(User).where(User.id == user_id)
    res = await db.execute(query)
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    query = (
        delete(Card)
        .where(Card.id == card_id)
        .where(Card.owner == user)
        .returning(Card.id)
    )
    result = await db.execute(query)
    if not result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="You don't have this card"
        )
    await db.commit()
    logger.info(f"Deleted card with id {card_id} from DB.")


async def get_sorted_card_list(
    user_id: int, db: AsyncSession, user_lat: float, user_lon: float
) -> list[Card]:
    cards = await get_all_cards(user_id, db)
    cards_map = {card.id: card for card in cards}

    distance_map = dict()
    for card in cards:
        query = card.store.query
        distance_map[card.id] = await find_nearest_shop(user_lat, user_lon, query)
    logger.debug(f"{distance_map}")
    cards_id_list = [
        key[0] for key in sorted(distance_map.items(), key=lambda elem: elem[1])
    ]
    logger.debug(f"{cards_id_list}")

    cards_list = [cards_map[idx] for idx in cards_id_list]
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


async def calculate_length(
    _lat1: float, _lon1: float, _lat2: float, _lon2: float
) -> float:
    R = 6372795
    lat1 = _lat1 * math.pi / 180.0
    lat2 = _lat2 * math.pi / 180.0
    lon1 = _lon1 * math.pi / 180.0
    lon2 = _lon2 * math.pi / 180.0

    delta = abs(lon1 - lon2)
    num = (math.cos(lat2) * math.sin(delta)) ** 2 + (
        math.cos(lat1) * math.sin(lat2)
        - math.sin(lat1) * math.cos(lat2) * math.cos(delta)
    ) ** 2
    num = math.sqrt(num)
    denom = math.sin(lat1) * math.sin(lat2) + math.cos(lat1) * math.cos(
        lat2
    ) * math.cos(delta)
    arctg = math.atan2(num, denom)
    return R * arctg


async def get_single_card(user_id: int, card_id: int, db: AsyncSession) -> Card:
    """
    Retrieves single card from DB.
    """
    query = select(User).where(User.id == user_id)
    res = await db.execute(query)
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    query = select(Card).where(Card.id == card_id).where(Card.owner == user)
    logger.debug(query)
    result = await db.execute(query)
    card = result.scalar_one_or_none()
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="You don't have this card"
        )
    logger.info(f"Give single card from DB.")
    return card
