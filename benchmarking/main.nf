transcriptFile = file('Homo_sapiens.GRCh38.cdna.all.fa')
refindex = file('Homo_sapiens.GRCh38.cdna.all.fa.fai')

readone = file('SRR5023465_1.fastq')
readtwo = file('SRR5023465_2.fastq')
process barracudaIndex{
	//jhcontainer = 'shub://KevinSayers/BarraCUDA_Singularity'

	input:
	file ref from transcriptFile

	output:
	file "${ref.baseName}.*" into indexOut, indexFiles

	"""
	barracuda index -p ${ref.baseName} ${ref}

	"""
	
}

process barracudaAln{
	//kljcontainer = 'shub://KevinSayers/BarraCUDA_Singularity'
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
	//lkkjcontainer = 'shub://KevinSayers/BarraCUDA_Singularity'
	publishDir 's3://msthesis/testing/', mode: 'copy' 

	maxForks 1

	input:
	file indexs from indexFiles
	file first from readone
	file second from readtwo
	file firstsai from saione
	file secondsai from saitwo
	
	output:
	file "barracuda.sam" into mapOut
	"""
	barracuda sampe ${transcriptFile.baseName} ${firstsai} ${secondsai} ${first} ${second} > barracuda.sam
	"""
}

workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}
