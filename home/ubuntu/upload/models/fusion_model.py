import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.saving import register_keras_serializable

@register_keras_serializable()
class FusionModel(Model):
    def __init__(self, models=None, fusion_weights=None, **kwargs):
        super(FusionModel, self).__init__(**kwargs)
        self.models = models if models is not None else []
        self.fusion_weights = fusion_weights if fusion_weights is not None else []

    def call(self, inputs, training=False):
        # Ensure we have models to fuse
        if not self.models or not self.fusion_weights:
            raise ValueError("FusionModel must have models and fusion_weights.")

        # Compute predictions from each model
        preds = [model(inputs, training=training) for model in self.models]

        # Safety check: all predictions must be same shape
        for i, pred in enumerate(preds):
            if pred.shape != preds[0].shape:
                raise ValueError(f"Mismatch in model output shapes: model {i} = {pred.shape}, model 0 = {preds[0].shape}")

        # Weighted sum
        fused = tf.zeros_like(preds[0])
        for pred, w in zip(preds, self.fusion_weights):
            fused += w * pred

        return fused

    def get_config(self):
        config = super(FusionModel, self).get_config()
        config.update({
            "fusion_weights": self.fusion_weights
        })
        return config

    @classmethod
    def from_config(cls, config):
        fusion_weights = config.pop('fusion_weights', None)
        instance = cls(models=[], fusion_weights=fusion_weights, **config)
        return instance
