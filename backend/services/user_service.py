from extensions import mongo
from werkzeug.security import check_password_hash, generate_password_hash
from bson.objectid import ObjectId

def delete_user(user_id, password):
    user = mongo.db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        return False, "User not found"

    stored_password = user["password"]
    if isinstance(stored_password, bytes):
        stored_password = stored_password.decode("utf-8")

    if not check_password_hash(stored_password, password):
        return False, "Password incorrect"

    mongo.db.users.delete_one({"_id": ObjectId(user_id)})
    return True, None

def update_password(user_id, current_password, new_password):
    user = mongo.db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        return False, "User not found"

    stored_password = user["password"]
    if isinstance(stored_password, bytes):
        stored_password = stored_password.decode("utf-8")

    if not check_password_hash(stored_password, current_password):
        return False, "Current password incorrect"

    hashed = generate_password_hash(new_password)
    mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"password": hashed}}
    )
    return True, None
def update_name(user_id, new_name):
    result = mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"name": new_name}}
    )
    if result.modified_count == 0:
        return False, "Update failed"
    return True, None
def update_email(user_id, new_email):
    user = mongo.db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        return False, "User not found"
    if mongo.db.users.find_one({"email": new_email, "_id": {"$ne": ObjectId(user_id)}}):
        return False, "Email already in use"

    mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"email": new_email}}
    )
    return True, None