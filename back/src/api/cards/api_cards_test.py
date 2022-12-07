from fastapi import Depends
from OSMPythonTools.overpass import Overpass
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker
import asyncio

from sqlalchemy import select

import pytest
from fastapi.testclient import TestClient
from ...settings import settings
from ...create_app import app
from ...external.db.session import Base, get_session, engine
from ...external.db.models import User, Card, Store

from .core import get_store_name, get_all_cards, \
    get_store_query, find_nearest_shop, \
    calculate_length, get_sorted_card_list

DATABASE_URL = (
    f"postgresql+asyncpg://{settings.postgres_user}:"
    f"{settings.postgres_password}"
    f"@{settings.postgres_host}:"
    f"{settings.postgres_port}/{settings.postgres_database_name}_test"
)

engine = create_async_engine(DATABASE_URL, echo=True)
async_test_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


async def get_test_session() -> AsyncSession:
    async with async_test_session() as session:
        yield session

app.dependency_overrides[get_session] = get_test_session


async def init_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def drop_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.fixture
async def init_db():
    await drop_tables()
    await init_tables()

    db_gen = get_test_session()
    db = await db_gen.__anext__()

    user = User()
    user.id = 1
    user.username = "userName"
    user.password = "password123"
    db.add(user)
    await db.commit()
    await db.refresh(user)

    store1 = Store()
    store1.id = 1
    store1.name = "storeName"
    store1.query = 'node["brand:wikidata"="Q610492"]["shop"="supermarket"]'
    db.add(store1)
    await db.commit()
    await db.refresh(store1)

    store2 = Store()
    store2.id = 2
    store2.name = "secondStoreName"
    store2.query = 'node["brand:wikidata"="Q4281631"]["shop"="supermarket"]'
    db.add(store2)
    await db.commit()
    await db.refresh(store2)

    store3 = Store()
    store3.id = 3
    store3.name = "thirdStoreName"
    store3.query = 'node["name:en"="Bystronom"]["shop"="supermarket"]'
    db.add(store3)
    await db.commit()
    await db.refresh(store3)

    card1 = Card()
    card1.id = 1
    card1.owner_id = 1
    card1.store_id = 1
    card1.code = 123456
    db.add(card1)
    await db.commit()
    await db.refresh(card1)

    card2 = Card()
    card2.id = 2
    card2.owner_id = 1
    card2.store_id = 2
    card2.code = 234567
    db.add(card2)
    await db.commit()
    await db.refresh(card2)

    card3 = Card()
    card3.id = 3
    card3.owner_id = 1
    card3.store_id = 3
    card3.code = 345678
    db.add(card3)
    await db.commit()
    await db.refresh(card3)

@pytest.fixture
async def client():
    await init_db()
    yield TestClient(app)

@pytest.mark.asyncio
async def test_get_all_cards(init_db):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    user_id = 1
    cards_list = await get_all_cards(user_id, db)
    cards_ids = [elem.id for elem in cards_list]
    assert cards_ids == [1, 2, 3]

@pytest.mark.asyncio
async def test_get_store_name(init_db):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    assert await get_store_name(1, db) == "storeName"

@pytest.mark.asyncio
async def test_get_store_query(init_db):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    assert await get_store_query(1, db) == 'node["brand:wikidata"="Q610492"]["shop"="supermarket"]'

@pytest.mark.asyncio
async def test_overpass_query():
    overpass = Overpass()
    user_lat = 54.844064962175764
    user_lon = 83.09090571747782
    query = 'node["shop"="supermarket"]'
    shops = overpass.query(
        query + "(around:2000, " + str(user_lat) + ", " + str(user_lon) + "); out body;"
    ).elements()
    assert len(shops) == 2
    assert shops[0].lat() == 54.8411954
    assert shops[0].lon() == 83.1020793
    assert shops[1].lat() == 54.8478849
    assert shops[1].lon() == 83.0637395

@pytest.mark.asyncio
async def test_find_nearest_shop(init_db):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    user_lat = 54.844064962175764
    user_lon = 83.09090571747782
    store_id = 2
    actual_dist = await find_nearest_shop(
            user_lat,
            user_lon,
            await get_store_query(store_id, db))
    store_lat = 54.8411954
    store_lon = 83.1020793
    expected_dist = await calculate_length(
                    user_lat, user_lon,
                    store_lat, store_lon)
    assert actual_dist == expected_dist

@pytest.mark.asyncio
async def test_get_sorted_card_list(init_db):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    user_lat = 54.844064962175764
    user_lon = 83.09090571747782
    user_id = 1
    cards_list = await get_sorted_card_list(user_id, db, user_lat, user_lon)
    cards_ids = [elem.id for elem in cards_list]
    assert cards_ids == [2, 1, 3]
