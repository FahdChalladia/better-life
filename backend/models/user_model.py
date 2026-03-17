from extensions import mongo
from datetime import datetime
from bson.objectid import ObjectId

def get_user_collection():
    return mongo.db.users

def create_user(name, email, password_hash, country, birth_date):
    user = {
        "name": name,
        "email": email.lower(),
        "password": password_hash,
        "country": country,
        "birth_date": birth_date,
        "created_at": datetime.utcnow()
    }
    result = get_user_collection().insert_one(user)
    return str(result.inserted_id)

def find_by_email(email):
    return get_user_collection().find_one({"email": email.lower()})

def find_by_id(user_id):
    return get_user_collection().find_one({"_id": ObjectId(user_id)})
