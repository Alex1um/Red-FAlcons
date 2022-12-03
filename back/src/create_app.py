from fastapi import FastAPI

# from .external.postgres import connect_postgres, disconnect_postgres

from .api.shops.views import shops_router


app = FastAPI(
    title="Quick wallet app",
)


def create_app():
    app.include_router(shops_router)

    # app.add_event_handler("startup", connect_postgres)
    # app.add_event_handler("shutdown", disconnect_postgres)

    return app
