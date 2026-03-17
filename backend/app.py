from flask import Flask
from config import Config
from extensions import mongo, jwt
from routes.auth_routes import auth_bp
from routes.mood_routes import mood_bp
from routes.user_routes import user_bp
from routes.insight_routes import insight_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    mongo.init_app(app)
    jwt.init_app(app)
    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(mood_bp, url_prefix="/moods")
    app.register_blueprint(user_bp, url_prefix="/user")
    app.register_blueprint(insight_bp, url_prefix="")
    @app.route("/")
    def home():
        return "Backend is running ! but my life is going backwards <3"

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)
