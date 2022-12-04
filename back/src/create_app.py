from fastapi import FastAPI

from .api.auth.views import auth_router
from .api.cards.views import cards_router
from .api.shops.views import shops_router
from .external.db.session import Base, engine


app = FastAPI(
    title="Quick wallet app",
)


@app.on_event("startup")
async def init_tables():
    async with engine.begin() as conn:
        # await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)


def create_app():
    app.include_router(auth_router)
    app.include_router(cards_router)
    app.include_router(shops_router)
    return app
