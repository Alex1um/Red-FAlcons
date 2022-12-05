from sqlalchemy import Column, ForeignKey, Integer, String, text, TIMESTAMP
from sqlalchemy.orm import relationship

from .session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    username = Column(String, nullable=False, unique=True)
    password = Column(String, nullable=False)
    created_at = Column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )


class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    owner_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    store_id = Column(
        Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False
    )
    code = Column(Integer, nullable=False)
    created_at = Column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    owner = relationship("User", foreign_keys=[owner_id])
    store = relationship("Store", foreign_keys=[store_id])


class Store(Base):
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    name = Column(String, nullable=False)
    query = Column(String, nullable=False)
