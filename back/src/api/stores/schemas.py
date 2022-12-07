from pydantic import BaseModel


class StoreOut(BaseModel):
    id: int
    name: str
    default_code_type: int

    class Config:
        orm_mode = True
