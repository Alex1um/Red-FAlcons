from datetime import datetime
from pydantic import BaseModel


class CardOut(BaseModel):
    store_name: str
    code: int
    created_at: datetime

    class Config:
        orm_mode = True
