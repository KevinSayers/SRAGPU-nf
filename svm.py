# import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
import random
import pickle
# Create graph
sess = tf.Session()



# Declare batch size
batch_size = 100

data = open('transcriptomepreprocessed','r')
temp = []

for i in data:
    temp.append(i.strip().split(','))
#random.shuffle(temp)

trainingdata = []
traininglabels = []

# BELOW HERE IS DIFFERENT
for j in temp[0:342]:
    trainingdata.append(np.asarray(j[2:]))
    if j[1] == "triple-negative breast cancer (TNBC)":
        traininglabels.append(np.asarray([1]))
    else:
        traininglabels.append(np.asarray([-1]))

testdata = []
testlabels = []
for j in temp[343:]:
    testdata.append(np.asarray(j[2:]))
    if j[1] == "triple-negative breast cancer (TNBC)":
        testlabels.append(np.asarray([1]))
    else:
        testlabels.append(np.asarray([-1]))


print (len(trainingdata[0]))
inputs = len(trainingdata[0]) #12360
classes = 2
hidden = 500

traininglabels = np.asarray(traininglabels)
traininglabels = np.reshape(traininglabels,(len(traininglabels),1))

testlabels = np.asarray(testlabels)
testlabels = np.reshape(testlabels,(len(testlabels),1))

trainingdata = np.asarray(trainingdata)
testdata = np.asarray(testdata)
testdata = testdata.astype(int)
trainingdata = trainingdata.astype(int)

# Initialize placeholders
x = tf.placeholder(tf.float32, [None, inputs])
y_ = tf.placeholder(tf.float32, [None, 1])

# Create variables for linear regression
A = tf.Variable(tf.random_normal(shape=[inputs,1]))
b = tf.Variable(tf.random_normal(shape=[1,1]))

# Declare model operations
model_output = tf.subtract(tf.matmul(x, A), b)

# Declare vector L2 'norm' function squared
l2_norm = tf.reduce_sum(tf.square(A))

# Declare loss function
# Loss = max(0, 1-pred*actual) + alpha * L2_norm(A)^2
# L2 regularization parameter, alpha
alpha = tf.constant([0.001])
# Margin term in loss
classification_term = tf.reduce_mean(tf.maximum(0., tf.subtract(1., tf.multiply(model_output, y_))))
# Put terms together
loss = tf.add(classification_term, tf.multiply(alpha, l2_norm))

# Declare prediction function
prediction = tf.sign(model_output)
accuracy = tf.reduce_mean(tf.cast(tf.equal(prediction, y_), tf.float32))

# Declare optimizer
my_opt = tf.train.AdamOptimizer(0.0005)
train_step = my_opt.minimize(loss)

# Initialize variables


# Training loop

alltrain = []
alltst = []
allloss = []
for j in range(0,5):
    init = tf.global_variables_initializer()
    sess.run(init)

    loss_vec = []
    train_accuracy = []
    test_accuracy = []
    losspts = []

    for i in range(2000):
        sess.run(train_step, feed_dict={x: trainingdata, y_: traininglabels})

        temp_loss = sess.run(loss, feed_dict={x: trainingdata, y_: traininglabels})
        loss_vec.append(temp_loss)

        train_acc_temp = sess.run(accuracy, feed_dict={
            x: trainingdata,
            y_: traininglabels})
        train_accuracy.append(train_acc_temp)

        test_acc_temp = sess.run(accuracy, feed_dict={
            x: testdata,
            y_: testlabels})
        test_accuracy.append(test_acc_temp)

    alltrain.append(train_accuracy)
    allloss.append(loss_vec)
    alltst.append(test_accuracy)

# plt.title('Training accuracy')
# plt.ylabel('Accuracy')
# plt.xlabel('iteration')
# for i in alltrain:
#     plt.plot(i)
# plt.savefig('finalsvmtrain.png')
# plt.clf()

# plt.title('Training loss')
# plt.ylabel('loss')
# plt.xlabel('iteration')
# for i in allloss:
#     plt.plot(i)
# plt.savefig('finalsvmloss.png')
# plt.clf()


# plt.title('Testing accuracy')
# plt.ylabel('Accuracy')
# plt.xlabel('iteration')
# for i in alltst:
#     plt.plot(i)
# plt.savefig('finalsvmtest.png')
# plt.clf()