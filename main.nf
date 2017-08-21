transcriptFile = file('Homo_sapiens.GRCh38.cdna.all.fa')
refindex = file('Homo_sapiens.GRCh38.cdna.all.fa.fai')

sampleList = Channel.fromPath('newSamples.txt').splitText()
//THIS WORKFLOW HAS SOFTCLIPS OFF FOR BARRACUDA

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
	publishDir 's3://msthesis/vcfout/', mode: 'copy' 

	input:
	file ref from transcriptFile
	file refi from refindex
	file opossum from bamOut
	file bamIndex from indexBamOut

	output:
	file "${opossum.baseName.split('_')[0]}_wfvariants.vcf" into platypusOut

	"""
	python /Platypus/bin/Platypus.py callVariants --bamFiles=${opossum} --refFile=${ref} --output="${opossum.baseName.split('_')[0]}_wfvariants.vcf"

	"""

}
