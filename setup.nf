process setup{
	container = "docker://sayerskt/samtools"
	publishDir './', mode: 'copy', overwrite: true

	output:
	file "Homo_sapiens.GRCh38.cdna.all.fa" into reference
	file "Homo_sapiens.GRCh38.cdna.all.fa.fai" into refindex

	"""
	wget ftp://ftp.ensembl.org/pub/release-88/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
	gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz
	samtools faidx Homo_sapiens.GRCh38.cdna.all.fa
	"""

}
process barracudaIndex{
	container = 'shub://KevinSayers/BarraCUDA_Singularity'
	
	storeDir 'index/'
	input:
	file ref from transcriptFile

	output:
	file "${reference.baseName}.*" into indexOut, indexFiles

	"""
	barracuda index -p ${reference.baseName} ${ref}

	"""
	
}