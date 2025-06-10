import tensorflow as tf
from tensorflow.keras import backend as K
from tensorflow.keras import layers

def squash(vectors, epsilon=1e-7):
    s_squared_norm = K.sum(K.square(vectors), -1, keepdims=True)
    scale = s_squared_norm / (1.0 + s_squared_norm) / (K.sqrt(s_squared_norm + epsilon))
    return scale * vectors

class CapsuleLayer(layers.Layer):
    def __init__(self, num_capsules, dim_capsule, routings=3, **kwargs):
        super(CapsuleLayer, self).__init__(**kwargs)
        self.num_capsules = num_capsules
        self.dim_capsule = dim_capsule
        self.routings = routings

    def build(self, input_shape):
        input_num_capsules, input_dim_capsule = input_shape[1], input_shape[2]
        self.W = self.add_weight(
            shape=[self.num_capsules, input_num_capsules, self.dim_capsule, input_dim_capsule],
            initializer='glorot_uniform',
            trainable=True
        )

    def call(self, inputs):
        inputs_expand = K.expand_dims(K.expand_dims(inputs, 1), -1)
        W_expand = K.expand_dims(self.W, 0)
        u_hat = tf.matmul(W_expand, inputs_expand)
        b = tf.zeros_like(u_hat[..., 0])

        for i in range(self.routings):
            c = tf.nn.softmax(b, axis=1)
            s = tf.reduce_sum(c[..., None] * u_hat, axis=2)
            v = squash(s)
            if i < self.routings - 1:
                b += tf.reduce_sum(u_hat * v[:, :, None, :, :], axis=-1)
        return v

class Length(layers.Layer):
    def call(self, inputs, **kwargs):
        return tf.sqrt(tf.reduce_sum(tf.square(inputs), -1))
