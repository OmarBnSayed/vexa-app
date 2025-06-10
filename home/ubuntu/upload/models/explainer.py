import numpy as np
import matplotlib.pyplot as plt
import io
import base64
import lime
import lime.lime_image
from skimage.segmentation import mark_boundaries
import tensorflow as tf

def generate_gradcam(model, image):
    grad_model = tf.keras.models.Model(
        [model.inputs], [model.layers[-3].output, model.output]
    )

    with tf.GradientTape() as tape:
        conv_outputs, predictions = grad_model(tf.expand_dims(image, axis=0))
        loss = predictions[:, 0]

    grads = tape.gradient(loss, conv_outputs)
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))
    conv_outputs = conv_outputs.numpy()[0]
    pooled_grads = pooled_grads.numpy()

    for i in range(pooled_grads.shape[-1]):
        conv_outputs[:, :, i] *= pooled_grads[i]

    heatmap = np.mean(conv_outputs, axis=-1)
    heatmap = np.maximum(heatmap, 0)
    heatmap /= np.max(heatmap)

    return heatmap

def plot_to_base64(img):
    buf = io.BytesIO()
    plt.imsave(buf, img, format='png')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    return img_base64

def generate_lime(model, image):
    explainer = lime.lime_image.LimeImageExplainer()
    explanation = explainer.explain_instance(
        np.array(image),
        model.predict,
        top_labels=1,
        hide_color=0,
        num_samples=1000
    )
    temp, mask = explanation.get_image_and_mask(
        explanation.top_labels[0],
        positive_only=True,
        num_features=5,
        hide_rest=False
    )
    return mark_boundaries(temp / 255.0, mask)
