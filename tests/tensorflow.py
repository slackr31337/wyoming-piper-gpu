import tensorflow as tf

print(tf.config.list_physical_devices())

a = tf.random.normal(shape=[5], dtype=tf.float32)
b =  tf.nn.relu(a)

with tf.device("/APU:0"):
  c = tf.nn.relu(a)

with tf.device("/CPU:0"):
  c = tf.nn.relu(a)

@tf.function  # Defining a tf.function
def run():
  d = tf.random.uniform(shape=[100], dtype=tf.float32)
  e = tf.nn.relu(d)

run()
