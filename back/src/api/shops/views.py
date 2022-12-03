from fastapi import APIRouter

from .core import find_shops

shops_router = APIRouter(tags=["shops"])


@shops_router.get("/shops", summary="Get closest shops.")
async def find_shops_view(
    latitude: float,
    longitude: float,
):
    return await find_shops(latitude, longitude)
