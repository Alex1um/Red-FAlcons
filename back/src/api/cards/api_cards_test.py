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

from .core import get_store_name, get_store_query, find_nearest_shop, calculate_length

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

async def init_all():
    await drop_tables()
    await init_tables()
    user = User()
    user.id = 123
    user.username = "UserName"
    user.password = "password123"
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    db.add(user)
    store = Store()
    store.id = 1
    store.name = "storeName"
    store.query = 'node["shop"="supermarket"]'
    db.add(store)
    await db.commit()


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

    store = Store()
    store.id = 1
    store.name = "storeName"
    store.query = 'node["shop"="supermarket"]'
    db.add(store)

    card = Card()
    card.id = 1
    card.owner_id = 1
    card.store_id = 1
    card.code = 123456
    db.add(card)

    await db.commit()

@pytest.fixture
async def client():
    await init_db()
    yield TestClient(app)

@pytest.mark.asyncio
async def test_get_store_name(client):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    assert await get_store_name(1, db) == "storeName"

@pytest.mark.asyncio
async def test_get_store_query(client):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    assert await get_store_query(1, db) == 'node["shop"="supermarket"]'

@pytest.mark.asyncio
async def test_overpass_query(client):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    overpass = Overpass()
    user_lat = 54.844064962175764
    user_lon = 83.09090571747782
    query = await get_store_query(1, db)
    shops = overpass.query(
        query + "(around:1000," + str(user_lat) + "," + str(user_lon) + "); out body;"
    ).elements()
    assert len(shops) == 1
    assert shops[0].lat() == 54.8411954
    assert shops[0].lon() == 83.1020793

@pytest.mark.asyncio
async def test_find_nearest_shop(client):
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    actual_dist = await find_nearest_shop(
            54.844064962175764,
            83.09090571747782,
            await get_store_query(1, db))
    expected_dist = await calculate_length(
                    54.844064962175764,
                    83.09090571747782,
                    54.8411954, 83.1020793)
    print(expected_dist)
    assert actual_dist == expected_dist
