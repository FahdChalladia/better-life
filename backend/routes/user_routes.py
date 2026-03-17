from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.user_service import delete_user, update_name, update_password, update_email



user_bp = Blueprint("user", __name__)

@user_bp.route("/delete", methods=["DELETE"])
@jwt_required()
def delete_user_route():
    user_id = get_jwt_identity()
    data = request.get_json()
    if not data or "password" not in data:
        return jsonify({"error": "Password required"}), 400

    success, error = delete_user(user_id, data["password"])
    if not success:
        return jsonify({"error": error}), 400

    return jsonify({"message": "User deleted successfully"}), 200

@user_bp.route("/update-name", methods=["PUT"])
@jwt_required()
def update_name_route():
    user_id = get_jwt_identity()
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "Name required"}), 400

    success, error = update_name(user_id, data["name"])
    if not success:
        return jsonify({"error": error}), 400

    return jsonify({"message": "Name updated successfully"}), 200

@user_bp.route("/update-password", methods=["PUT"])
@jwt_required()
def update_password_route():
    user_id = get_jwt_identity()
    data = request.get_json()
    if not data or "current_password" not in data or "new_password" not in data:
        return jsonify({"error": "Both current_password and new_password required"}), 400

    success, error = update_password(user_id, data["current_password"], data["new_password"])
    if not success:
        return jsonify({"error": error}), 400

    return jsonify({"message": "Password updated successfully"}), 200

@user_bp.route("/update-email", methods=["PUT"])
@jwt_required()
def update_email_route():
    user_id = get_jwt_identity()
    data = request.get_json()
    if not data or "email" not in data:
        return jsonify({"error": "Email required"}), 400

    success, error = update_email(user_id, data["email"])
    if not success:
        return jsonify({"error": error}), 400

    return jsonify({"message": "Email updated successfully"}), 200
