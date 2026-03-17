from models.user_model import create_user, find_by_email
import bcrypt
from flask_jwt_extended import create_access_token
from werkzeug.security import check_password_hash ,generate_password_hash
from extensions import mongo
from datetime import timedelta

def register_user(name, email, password, country, birth_date):
    if find_by_email(email):
        return None, "Email already exists"

    password_hash = generate_password_hash(password)
    user_id = create_user(
        name=name,
        email=email,
        password_hash=password_hash,
        country=country,
        birth_date=birth_date
    )

    return user_id, None


def login_user(email, password):
    user = mongo.db.users.find_one({"email": email})
    if not user:
        return None, "Invalid credentials"
    if not check_password_hash(user["password"], password):
        return None, "Invalid credentials"
    access_token = create_access_token(
        identity=str(user["_id"]),
        expires_delta=timedelta(days=21)
    )
    return access_token, None