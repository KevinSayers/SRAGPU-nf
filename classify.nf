params.featureFile = file('transcriptomepreprocessed')
params.classifierFile = file('svm.py')

process runTF{
	container = 'docker://tensorflow/tensorflow:nightly-gpu-py3'
	input:
	file classifier from params.classifierFile
	file data from params.featureFile

	output:
	stdout result

	"""
	python3 ${classifier}
	"""
}
