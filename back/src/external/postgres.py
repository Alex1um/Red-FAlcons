import sys
from typing import AsyncIterator

from asyncpg import Connection, create_pool
from asyncpg.pool import Pool
from loguru import logger

from ..settings import settings


class DataBase:
    pool: Pool = None  # type: ignore


db = DataBase()


async def connect_postgres(test_db: str = None):
    if test_db:
        db_name = test_db
    else:
        db_name = settings.postgres_database_name

    logger.info("Initializing PostgreSQL connection")

    try:
        db.pool = await create_pool(  # type: ignore
            user=settings.postgres_user,
            password=settings.postgres_password,
            host=settings.postgres_host,
            port=settings.postgres_port,
            database=db_name,
            min_size=0,
            max_size=30,
            max_inactive_connection_lifetime=60,
        )
    except Exception as exc:
        logger.error("Failed connect to PostgreSQL")
        logger.error(str(exc))
        sys.exit(1)

    logger.info("Successfully initialized PostgreSQL connection")


async def disconnect_postgres():
    logger.info("Closing PostgreSQL connection")
    await db.pool.close()


async def get_database() -> AsyncIterator[Connection]:
    # https://fastapi.tiangolo.com/tutorial/dependencies/dependencies-with-yield/#a-database-dependency-with-yield

    connection = await db.pool.acquire()
    try:
        yield connection
    finally:
        await db.pool.release(connection)
