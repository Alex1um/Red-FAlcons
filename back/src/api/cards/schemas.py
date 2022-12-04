from datetime import datetime
from pydantic import BaseModel


class CardResponse(BaseModel):
    store_name: str
    code: int
    created_at: datetime

    class Config:
        orm_mode = True
