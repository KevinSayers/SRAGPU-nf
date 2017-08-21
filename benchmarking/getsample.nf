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

process getSample{
	publishDir './', mode: 'copy' 

	errorStrategy 'retry'
    maxRetries 3
	maxForks 4
	container = "docker://sayerskt/sratoolkit"
	input:
	val sampleID from sampleList

	output:
	file "SRR5023465_1.fastq" into readone, reads1
	file "SRR5023465_2.fastq" into readtwo, reads2

	"""
	fastq-dump SRR5023465 --split-files
	"""
	
}