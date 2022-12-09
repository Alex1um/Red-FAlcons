from sqlalchemy import Column, ForeignKey, Integer, String, text, TIMESTAMP
from sqlalchemy.orm import Mapped, relationship

from .session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    username = Column(String, nullable=False, unique=True)
    password = Column(String, nullable=False)
    created_at = Column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    cards: Mapped[list["Card"]] = relationship(back_populates="owner", lazy="selectin")


class Card(Base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    owner_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    store_id = Column(
        Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False
    )
    code = Column(String, nullable=False)
    code_type = Column(Integer, nullable=False)
    created_at = Column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    owner: Mapped["User"] = relationship(back_populates="cards", lazy="selectin")
    store: Mapped["Store"] = relationship(back_populates="cards", lazy="selectin")


class Store(Base):
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, nullable=False, autoincrement=True)
    name = Column(String, nullable=False)
    query = Column(String, nullable=False)
    default_code_type = Column(Integer, nullable=False)

    cards: Mapped[list["Card"]] = relationship(back_populates="store", lazy="selectin")
