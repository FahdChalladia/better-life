import os

class Config:
    MONGO_URI = os.getenv(
        "MONGO_URI",
        "mongodb+srv://fahd:fahd2004@better-life.vq0esnz.mongodb.net/mood_tracker?retryWrites=true&w=majority"
    )
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "supersecretkey")