from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.insight_service import get_weekly_insights

insight_bp = Blueprint("insight", __name__)

@insight_bp.route("/insights/weekly", methods=["GET"])
@jwt_required()
def weekly_insights():
    user_id = get_jwt_identity()
    data = get_weekly_insights(user_id)
    return jsonify(data), 200