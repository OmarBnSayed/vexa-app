import numpy as np
from utils.preprocessing import extract_frames, detect_and_crop_face, apply_clahe
from tensorflow.keras.preprocessing.image import img_to_array

class Predictor:
    def __init__(self, model):
        self.model = model

    def preprocess_frame(self, frame):
        face = detect_and_crop_face(frame)
        if face is None:
            return None
        face = apply_clahe(face)
        face = face.astype("float32") / 255.0
        face = img_to_array(face)
        return face

    def predict_video(self, video_path):
        frames = extract_frames(video_path, num_frames=7)
        processed_faces = []
        for frame in frames:
            face = self.preprocess_frame(frame)
            if face is not None:
                processed_faces.append(face)

        if not processed_faces:
            return None, None, None

        faces_array = np.array(processed_faces)
        predictions = self.model.predict(faces_array)

        labels = (predictions > 0.5).astype(int)
        majority_vote = int(np.round(np.mean(labels)))

        final_confidence = float(np.mean(predictions))

        return majority_vote, final_confidence, faces_array
