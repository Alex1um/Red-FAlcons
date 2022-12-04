from passlib.context import CryptContext


pass_context = CryptContext(["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Hash password with 'bcrypt' algorithm"""
    return pass_context.hash(password)
