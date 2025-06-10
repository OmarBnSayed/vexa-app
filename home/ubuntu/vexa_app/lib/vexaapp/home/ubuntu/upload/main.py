from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import shutil
import os
import numpy as np

from models.model_loader import ModelLoader
from models.predictor import Predictor
from models.explainer import generate_gradcam, generate_lime, plot_to_base64

app = FastAPI()

# ✅ SET YOUR FUSION MODEL PATH HERE:
FUSION_MODEL_PATH = "fusion_model.keras"  # <--- CHANGE THIS IF YOUR MODEL IS IN ANOTHER LOCATION

# Load the fusion model once at startup
model_loader = ModelLoader(FUSION_MODEL_PATH)
model = model_loader.get_model()
predictor = Predictor(model)

@app.post("/predict")
async def predict(video: UploadFile = File(...)):
    try:
        # Save uploaded video temporarily
        temp_video_path = f"temp_videos/{video.filename}"
        os.makedirs(os.path.dirname(temp_video_path), exist_ok=True)
        with open(temp_video_path, "wb") as buffer:
            shutil.copyfileobj(video.file, buffer)

        # Predict
        label, confidence, frames = predictor.predict_video(temp_video_path)
        if label is None:
            return JSONResponse(content={"error": "No faces detected"}, status_code=400)

        selected_frame = frames[0]

        # GradCAM & LIME
        gradcam_heatmap = generate_gradcam(model, selected_frame)
        gradcam_base64 = plot_to_base64(gradcam_heatmap)

        lime_explanation = generate_lime(model, selected_frame)
        lime_base64 = plot_to_base64(lime_explanation)

        # Clean up
        os.remove(temp_video_path)

        return {
            "prediction": "Real" if label == 0 else "Fake",
            "confidence": confidence,
            "gradcam_image": gradcam_base64,
            "lime_image": lime_base64
        }

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
