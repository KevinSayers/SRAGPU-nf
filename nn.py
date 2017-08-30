#!python3
import tensorflow as tf 
import numpy as np 
import random
import sys
import matplotlib.pyplot as plt


def runModel(encodedFile):
	data = open(encodedFile,'r')
	temp = []

	for i in data:
		temp.append(i.strip().split(','))
	#random.shuffle(temp)

	trainingdata = []
	traininglabels = []
	counttrain = 0
	# BELOW HERE IS DIFFERENT
	for j in temp[0:342]:
		trainingdata.append(np.asarray(j[2:]))
		if j[1] == "triple-negative breast cancer (TNBC)":
			traininglabels.append(np.asarray([1,0]))
			counttrain += 1
		else:
			traininglabels.append(np.asarray([0,1]))

	testdata = []
	testlabels = []
	counttest= 0
	for j in temp[343:]:
		testdata.append(np.asarray(j[2:]))
		if j[1] == "triple-negative breast cancer (TNBC)":
			testlabels.append(np.asarray([1,0]))
			counttest += 1
		else:
			testlabels.append(np.asarray([0,1]))
	print(counttrain)
	print(counttest)


	print (len(trainingdata[0]))
	inputs = len(trainingdata[0])
	classes = 2
	hidden = 250

	traininglabels = np.asarray(traininglabels)
	traininglabels = np.reshape(traininglabels,(len(traininglabels),classes))

	testlabels = np.asarray(testlabels)
	testlabels = np.reshape(testlabels,(len(testlabels),classes))

	trainingdata = np.asarray(trainingdata)
	testdata = np.asarray(testdata)
	testdata = testdata.astype(int)
	trainingdata = trainingdata.astype(int)


	x = tf.placeholder(tf.float32, [None, len(trainingdata[0])])
# W = tf.Variable(tf.zeros([540728, 2]))
	W = tf.Variable(tf.truncated_normal([inputs, 2], stddev=0.1))
	b = tf.Variable(tf.constant(0.5))

	y = tf.matmul(x, W) + b
	y_ = tf.placeholder(tf.float32, [None, 2])

	cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=y_, logits=y))
	train_step = tf.train.GradientDescentOptimizer(0.0005).minimize(cross_entropy)

	correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
	accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

	
	alltrain = []
	alltst = []
	allloss = []

	for j in range(0,5):
		sess = tf.InteractiveSession()
		tf.global_variables_initializer().run()
		datapoints = []
		testing = []
		loss = []

		for _ in range(20):
			#print (tf.Tensor.eval(wout))
			sess.run(train_step, feed_dict={x: trainingdata, y_: traininglabels})
			
			datapoints.append(sess.run(accuracy, feed_dict={x: trainingdata, y_: traininglabels}))
			testing.append(sess.run(accuracy, feed_dict={x: testdata, y_: testlabels}))
			loss.append(sess.run(cross_entropy, feed_dict={x: testdata, y_: testlabels}))

		finallabels = sess.run(y, feed_dict={x: testdata})
		tnbc_true = 0
		tnbc_false = 0
		tnbc_true_neg = 0 
		tnbc_false_neg = 0
		
		for i in range(0, len(testlabels)):
			actual = testlabels[i].argmax(axis=0)
			testresult = finallabels[i].argmax(axis=0)
			if actual == 0 and testresult == 0:
				tnbc_true += 1
			if actual == 0 and testresult == 1:
				tnbc_false += 1
			if actual == 1 and testresult == 1:
				tnbc_true_neg += 1
			if actual == 1 and testresult == 0:
				tnbc_false_neg += 1
		sensitivity = tnbc_true/(tnbc_true+tnbc_false)
		specificity = tnbc_true_neg/(tnbc_true_neg+tnbc_false_neg)
		print (tnbc_true)
		print (tnbc_false)
		print ("Sensitivity:%s"%(sensitivity))
		print ("Specificity:%s"%(specificity))

		alltrain.append(datapoints)
		alltst.append(testing)
		allloss.append(loss)
	
	plt.title('Training accuracy')
	plt.ylabel('Accuracy')
	plt.xlabel('iteration')
	for i in alltrain:
		plt.plot(i)
	plt.show()

	plt.title('Training loss')
	plt.ylabel('loss')
	plt.xlabel('iteration')
	for i in allloss:
		plt.plot(i)
	plt.show()

	
	plt.title('Testing accuracy')
	plt.ylabel('Accuracy')
	plt.xlabel('iteration')
	for i in alltst:
		plt.plot(i)
	plt.show()
	
	# plt.plot(datapoints)
	# plt.show()
	# plt.title('Training loss')
	# plt.ylabel('loss')
	# plt.xlabel('iteration')
	# plt.plot(loss)
	# plt.show()
	# plt.title('Testing accuracy')
	# plt.ylabel('Accuracy')
	# plt.xlabel('iteration')
	# plt.plot(testing)
	# plt.show()

	# counter = 1
	# for i in testlabels:
	# 	print (str(counter) + str(i))
	# 	counter += 1

def main():
	#runModel(sys.argv[1])
	runModel('transcriptomepreprocessed')

if __name__ == "__main__":
	main()