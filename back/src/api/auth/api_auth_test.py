from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker

import pytest
from fastapi.testclient import TestClient
from ...settings import settings
from ...create_app import app
from ...external.db.session import Base, get_session, engine
from ...external.db.models import User
from . import schemas
from .utils import hash_password, verify
from sqlalchemy import select

import requests

DATABASE_URL = (
    f"postgresql+asyncpg://{settings.postgres_user}:"
    f"{settings.postgres_password}"
    f"@{settings.postgres_host}:"
    f"{settings.postgres_port}/{settings.postgres_database_name}" #_test
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
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

# @pytest.fixture
# def client():
#     yield TestClient(app)

# test_app = TestClient(app)

app_address = "http://127.0.0.1:8000"

@pytest.mark.asyncio
async def test_create_user():
    res = requests.post(app_address + "/auth/register",
        json={"username": "userName", "password": "password123"})
    print(res.json())
    assert res.status_code == 201
    new_user = schemas.UserOut(**res.json())
    assert new_user.id == 1
    assert new_user.username == "userName"
    db_gen = get_test_session()
    db = await db_gen.__anext__()
    query = select(User).where(User.username == new_user.username)
    res = await db.execute(query)
    user = res.scalars().first()
    assert verify("password123", user.password)

@pytest.mark.asyncio
async def test_create_user_duplicate():
    duplicate_attempt = requests.post(app_address + "/auth/register",
        json={"username": "userName", "password": "password123"})
    assert duplicate_attempt.status_code == 422
    assert duplicate_attempt.json().get("detail") == "Username is already taken"

@pytest.mark.asyncio
async def test_login():
    files = {'username': (None, 'userName'),
             'password': (None, 'password123')}
    res = requests.post(app_address + "/auth/login", files = files)
    print(res.json())
    assert res.status_code == 200
    assert res.json().get("access_token") != ""


@pytest.mark.asyncio
async def test_login_wrong_username():
    files = {'username': (None, 'qwe'),
             'password': (None, 'password123')}
    res = requests.post(app_address + "/auth/login", files = files)
    print(res.json())
    assert res.status_code == 403

@pytest.mark.asyncio
async def test_login_wrong_password():
    files = {'username': (None, 'qwe'),
             'password': (None, 'password321')}
    res = requests.post(app_address + "/auth/login", files = files)
    print(res.json())
    assert res.status_code == 403

@pytest.mark.asyncio
async def test_get_user():
    files = {'username': (None, 'qwe'),
             'password': (None, 'password321')}
    res = requests.post(app_address + "/auth/login", files = files)
    print(res.json())
    assert res.status_code == 403

