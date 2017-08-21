params.mode = "nvBowtie"
params.reference = "Homo_sapiens.GRCh38.cdna.all.fa"
params.autosetup = 'true'

process nvBWTIndex{
	container = 'shub://KevinSayers/nvBowtie_Singularity'
	publishDir 'index/', mode: 'copy', overwrite: true
	input:
	file ref from reference

	output:
	file "${ref.baseName}.*" into indexOut, indexFiles

	"""
	nvBWT ${ref} ${ref.baseName}
	"""

}

process nvBowtieAlign{
	container = 'shub://KevinSayers/nvBowtie_Singularity'
	input:
	file indexs from indexOut
	file ref from file(params.reference)
	file first from readone
	file second from readtwo

	output:
	file "${first.baseName.split('_')[0]}.sam" into mapOut

	"""
	nvBowtie -x ${ref.baseName} -1 ${first} -2 ${second} -S ${first.baseName.split('_')[0]}.sam
 	"""
}

workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}