from models.mood_model import add_mood, get_today_mood, get_all_moods

def log_mood(user_id, mood_value):
    mood_id, error = add_mood(user_id, mood_value)
    if error:
        return None, error
    return mood_id, None
def fetch_today_mood(user_id):
    return get_today_mood(user_id)
def fetch_all_moods(user_id):
    return get_all_moods(user_id)
