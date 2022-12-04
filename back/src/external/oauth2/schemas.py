from pydantic import BaseModel


class TokenData(BaseModel):
    id: str | None = None
