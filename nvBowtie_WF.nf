params.mode = "nvBowtie"
params.reference = "Homo_sapiens.GRCh38.cdna.all.fa"
params.autosetup = 'true'

sampleList = Channel.fromPath('newSamples.txt').splitText()


log.info """
         G P U  P I P E L I N E    
         =============================
         date: ${workflow.start}
         reference: ${params.reference}
         aligner: ${params.mode}
         softclips: ${params.softclips}
         executor: ${workflow.profile}
         """
         .stripIndent()
         """
         """

if(params.autosetup == 'true')
	process setup{
		container = "docker://sayerskt/samtools"
		publishDir './', mode: 'copy', overwrite: true
		container = "docker://sayerskt/samtools"

		output:
		file "Homo_sapiens.GRCh38.cdna.all.fa" into reference
		file "Homo_sapiens.GRCh38.cdna.all.fa.fai" into refindex

		"""
		wget ftp://ftp.ensembl.org/pub/release-88/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
		gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz
		samtools faidx Homo_sapiens.GRCh38.cdna.all.fa
		"""

	}

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
process getSample{
	errorStrategy 'retry'
    maxRetries 3
	maxForks 4
	container = "docker://sayerskt/sratoolkit"
	input:
	val sampleID from sampleList

	output:
	file "${sampleID.strip()}_1.fastq" into readone, reads1
	file "${sampleID.strip()}_2.fastq" into readtwo, reads2

	"""
	fastq-dump ${sampleID.strip()} --split-files
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

process addMDTagsBam{
	container = "docker://sayerskt/samtools"

	input:
	file mappedfile from mapOut

	output:
	file "${mappedfile.baseName}.bam" into mdOut

	"""
	samtools view -bS ${mappedfile.baseName}.sam | samtools sort -o ${mappedfile.baseName}.bam

	"""
}

process Opossum{
	container = "docker://sayerskt/opossum"
	input: 
	file inbam from mdOut

	output:
	file "${inbam.baseName}_opossumout.bam" into opossumOut

	"""
	python /Opossum/Opossum.py --BamFile=${inbam} --OutFile=${inbam.baseName}_opossumout.bam --SoftClipsExist=False

	"""

}
process indexBam{
	container = "docker://sayerskt/samtools"

	input:
	file opossumbam from opossumOut

	output:
	file "${opossumbam.baseName}.bam.bai" into indexBamOut
	file "${opossumbam.baseName}.bam" into bamOut

	"""
	samtools index ${opossumbam.baseName}.bam
	"""

}

process platypusnew{
	container = "docker://sayerskt/platypus"
	publishDir 's3://msthesis/nv', mode: 'copy' 

	input:
	file ref from reference
	file refi from refindex
	file opossum from bamOut
	file bamIndex from indexBamOut

	output:
	file "${opossum.baseName.split('_')[0]}_wfvariants.vcf" into platypusOut

	"""
	python /Platypus/bin/Platypus.py callVariants --bamFiles=${opossum} --refFile=${ref} --output="${opossum.baseName.split('_')[0]}_wfvariants.vcf"

	"""

}
	





workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}