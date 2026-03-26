from models.mood_model import get_all_moods
from datetime import datetime, timedelta

def get_weekly_insights(user_id):
    today = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today - timedelta(days=6)

    moods = get_all_moods(user_id)
    daily_moods = {}
    totals = {"happy": 0, "sad": 0, "neutral": 0}
    mood_sum = 0
    mood_count = 0
    def get_label(value):
        if value >= 4:
            return "sad"
        elif value <= 2:
            return "happy"
        else:
            return "neutral"

    for i in range(7):
        day_date = week_start + timedelta(days=i)
        day_name = day_date.strftime("%A")
        mood_entry = next(
            (m for m in moods if m["created_at"].date() == day_date.date()), None
        )
        if mood_entry:
            label = get_label(mood_entry["mood"])
            daily_moods[day_name] = {
                "value": mood_entry["mood"],
                "label": label,
                "note": mood_entry.get("note", "")
            }
            totals[label] += 1
            mood_sum += mood_entry["mood"]
            mood_count += 1
        else:
            daily_moods[day_name] = {"value": None, "label": None, "note": ""}
    if mood_count == 0:
        average = 0
        trend = "neutral"
    else:
        average = round(mood_sum / mood_count, 1)
        first_half = [v["value"] for d, v in list(daily_moods.items())[:3] if v["value"] is not None]
        second_half = [v["value"] for d, v in list(daily_moods.items())[3:] if v["value"] is not None]
        trend = "neutral"
        if first_half and second_half:
            if sum(second_half)/len(second_half) > sum(first_half)/len(first_half):
                trend = "improved"
            elif sum(second_half)/len(second_half) < sum(first_half)/len(first_half):
                trend = "reduced"

    summary = "Your mood improved toward the weekend." if trend == "improved" else \
              "Your mood reduced toward the weekend." if trend == "reduced" else \
              "Your mood stayed stable this week."

    return {
        "summary": summary,
        "average": average,
        "trend": trend,
        "daily_moods": daily_moods,
        "totals": totals
    }
