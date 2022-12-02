from fastapi import FastAPI

from .api.auth.views import auth_router
from .external.postgres import connect_postgres, disconnect_postgres


app = FastAPI(
    title="Quick wallet app",
)


def create_app():
    app.include_router(auth_router)

    app.add_event_handler("startup", connect_postgres)
    app.add_event_handler("shutdown", disconnect_postgres)

    return app
