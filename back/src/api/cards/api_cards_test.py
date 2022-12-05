# from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
import asyncio

import pytest
from fastapi.testclient import TestClient
# from ...settings import settings
from ...create_app import app
from ...external.db.session import get_session

# DATABASE_URL = (
#     f"postgresql+asyncpg://{settings.postgres_user}:"
#     f"{settings.postgres_password}"
#     f"@{settings.postgres_host}:"
#     f"{settings.postgres_port}/{settings.postgres_database_name}_test"
# )

DATABASE_URL = "postgresql+asyncpg://admin:admin@127.0.0.1:5432/quickwallet_test"


engine = create_async_engine(DATABASE_URL, echo=True)
async_test_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)

Base = declarative_base()


async def get_test_session() -> AsyncSession:
    async with async_test_session() as session:
        yield session

app.dependency_overrides[get_session] = get_test_session

# Base.metadata.create_all(bind=engine)
async def init_models():
    async with engine.begin() as conn:
        # await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

asyncio.run(init_models())

@pytest.fixture
def client():
    return TestClient(app)
