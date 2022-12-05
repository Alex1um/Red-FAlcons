from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...external.db.models import Store


async def get_shops(db: AsyncSession):
    query = select(Store)
    query_result = await db.execute(query)
    result = []
    for row in query_result.fetchall():
        result.append(row.tuple()[0])
    return result
