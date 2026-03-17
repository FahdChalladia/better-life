from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash , check_password_hash
from extensions import mongo
from datetime import datetime
from bson.objectid import ObjectId
from services.auth_service import login_user , register_user
from models.user_model import create_user, find_by_email


auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    required_fields = ["name", "email", "password", "country", "birth_date"]

    if not data or not all(field in data for field in required_fields):
        return jsonify({
            "error": f"Required fields missing: {', '.join(required_fields)}"
        }), 400

    name = data["name"].strip()
    email = data["email"].strip().lower()
    password = data["password"]
    country = data["country"].strip()
    birth_date = data["birth_date"].strip()
    try:
        birth_date_obj = datetime.fromisoformat(birth_date)
        if birth_date_obj >= datetime.utcnow():
            return jsonify({"error": "Birth date must be in the past"}), 400
    except ValueError:
        return jsonify({"error": "Invalid birth_date format, use YYYY-MM-DD"}), 400

    user_id, error = register_user(
        name=name,
        email=email,
        password=password,
        country=country,
        birth_date=birth_date
    )

    if error:
        return jsonify({"error": error}), 400

    return jsonify({
        "message": "User registered successfully",
        "user_id": user_id
    }), 201

@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    token, error = login_user(email, password)
    if error:
        return jsonify({"error": error}), 401

    return jsonify({"access_token": token}), 200
