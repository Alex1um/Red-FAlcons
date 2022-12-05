from pydantic import BaseModel


class StoreOut(BaseModel):
    id: int
    name: str

    class Config:
        orm_mode = True
