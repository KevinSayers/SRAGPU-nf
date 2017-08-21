params.mode = "nvBowtie"
reference = "Homo_sapiens.GRCh38.cdna.all.fa"

readone = file('SRR5023465_1.fastq')
readtwo = file('SRR5023465_2.fastq')

process nvBWTIndex{
	//container = 'shub://KevinSayers/nvBowtie_Singularity'
	input:
	file ref from file(reference)

	output:
	file "${ref.baseName}.*" into indexOut, indexFiles

	"""
	nvBWT ${ref} ${ref.baseName}
	"""

}

process nvBowtieAlign{
	publishDir 's3://msthesis/testing/', mode: 'copy' 
	//container = 'shub://KevinSayers/nvBowtie_Singularity'
	input:
	file indexs from indexOut
	file ref from file(reference)
	file first from readone
	file second from readtwo

	output:
	file "nvbowtie.sam" into mapOut

	"""
	nvBowtie -x ${ref.baseName} -1 ${first} -2 ${second} -S nvbowtie.sam
 	"""
}

workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}
