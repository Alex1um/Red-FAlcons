from asyncpg import Connection
from fastapi import APIRouter, Depends

from ...external.postgres import get_database


auth_router = APIRouter(prefix="/auth", tags=["auth"])
