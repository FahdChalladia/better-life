from extensions import mongo
from datetime import datetime, timedelta
from bson.objectid import ObjectId

def get_mood_collection():
    return mongo.db.moods
def add_mood(user_id, mood_value, note=""):
    note = note[:60]

    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)
    existing = get_mood_collection().find_one({
        "user_id": ObjectId(user_id),
        "created_at": {"$gte": today_start, "$lt": today_end}
    })
    if existing:
        return None, "Mood already logged today"
    mood = {
        "user_id": ObjectId(user_id),
        "mood": mood_value,
        "note": note,
        "created_at": datetime.utcnow()
    }
    result = get_mood_collection().insert_one(mood)
    return {
        "mood_id": str(result.inserted_id),
        "mood": mood_value,
        "note": note,
        "created_at": mood["created_at"]
    }, None
def get_today_mood(user_id):
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_end = today_start + timedelta(days=1)

    mood = get_mood_collection().find_one({
        "user_id": ObjectId(user_id),
        "created_at": {"$gte": today_start, "$lt": today_end}
    })

    if not mood:
        return None

    return {
        "mood_id": str(mood["_id"]),
        "mood": mood["mood"],
        "note": mood.get("note", ""),
        "created_at": mood["created_at"]
    }
def get_all_moods(user_id):
    moods = list(get_mood_collection().find({"user_id": ObjectId(user_id)}).sort("created_at", 1))
    return [
        {
            "mood_id": str(m["_id"]),
            "mood": m["mood"],
            "note": m.get("note", ""),
            "created_at": m["created_at"]
        } for m in moods
    ]
