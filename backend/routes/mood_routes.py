from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.mood_service import log_mood, fetch_today_mood, fetch_all_moods

mood_bp = Blueprint("mood", __name__)

@mood_bp.route("/", methods=["POST"])
@jwt_required()
def add_today_mood():
    data = request.get_json()
    mood_value = data.get("mood")
    if mood_value is None:
        return jsonify({"error": "Mood value is required"}), 400

    user_id = get_jwt_identity()
    mood_id, error = log_mood(user_id, mood_value)
    if error:
        return jsonify({"error": error}), 400

    return jsonify({"message": "Mood logged successfully", "mood_id": mood_id}), 201
@mood_bp.route("/today", methods=["GET"])
@jwt_required()
def today_mood():
    user_id = get_jwt_identity()
    mood = fetch_today_mood(user_id)
    if not mood:
        return jsonify({"message": "No mood logged today"}), 404

    return jsonify({
        "mood_id": str(mood.get("_id")),
        "mood": mood["mood"],
        "created_at": mood["created_at"]
    }), 200

@mood_bp.route("/all", methods=["GET"])
@jwt_required()
def all_moods():
    user_id = get_jwt_identity()
    moods = fetch_all_moods(user_id)

    result = []
    for m in moods:
        result.append({
            "mood_id": str(m.get("_id", "")),
            "value": m.get("mood"),
            "note": m.get("note", ""),
            "created_at": m.get("created_at").isoformat() if m.get("created_at") else None
        })

    return jsonify(result), 200