transcriptFile = file('Homo_sapiens.GRCh38.cdna.all.fa')
refindex = file('Homo_sapiens.GRCh38.cdna.all.fa.fai')


process barracudaIndex{
	container = 'shub://KevinSayers/BarraCUDA_Singularity'
	
	storeDir 'index/'
	input:
	file ref from transcriptFile

	output:
	file "${ref.baseName}.*" into indexOut, indexFiles

	"""
	barracuda index -p ${ref.baseName} ${ref}

	"""
	
}

process barracudaAln{
	container = 'shub://KevinSayers/BarraCUDA_Singularity'
	maxForks 1

	echo true
	input:
	file indexs from indexOut
	file ref from transcriptFile
	file first from readone
	file second from readtwo

	output:
	file "${first.baseName}.sai" into saione
	file "${second.baseName}.sai" into saitwo


	"""
	barracuda aln ${transcriptFile.baseName} ${first} > ${first.baseName}.sai
	barracuda aln ${transcriptFile.baseName} ${second} > ${second.baseName}.sai
	"""
}

process barracudaSampe{
	container = 'shub://KevinSayers/BarraCUDA_Singularity'
	maxForks 1

	input:
	file indexs from indexFiles
	file first from reads1
	file second from reads2
	file firstsai from saione
	file secondsai from saitwo
	
	output:
	file "${first.baseName}.sam" into mapOut
	"""
	barracuda sampe ${transcriptFile.baseName} ${firstsai} ${secondsai} ${first} ${second} > ${first.baseName}.sam
	"""
}

workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}