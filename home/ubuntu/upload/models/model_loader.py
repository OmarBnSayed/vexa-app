from tensorflow.keras.models import load_model
from .capsule_layers import CapsuleLayer, Length, squash

class ModelLoader:
    def __init__(self, model_path):
        self.model = self.load_fusion_model(model_path)

    def load_fusion_model(self, model_path):
        model = load_model(model_path, custom_objects={
            "CapsuleLayer": CapsuleLayer,
            "Length": Length,
            "squash": squash
        })
        print(f"✅ Fusion model loaded from {model_path}")
        return model

    def get_model(self):
        return self.model
