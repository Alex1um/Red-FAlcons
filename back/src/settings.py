from pydantic import BaseSettings


class Settings(BaseSettings):
    postgres_host: str
    postgres_port: str
    postgres_user: str
    postgres_password: str
    postgres_database_name: str

    secret: str
    algorithm: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
