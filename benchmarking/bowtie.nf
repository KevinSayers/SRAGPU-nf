params.mode = "nvBowtie"
reference = "Homo_sapiens.GRCh38.cdna.all.fa"

readone = file('SRR5023465_1.fastq')
readtwo = file('SRR5023465_2.fastq')

process bowtie2Index{
        container = 'docker://biocontainers/bowtie2'
        input:
        file ref from file(reference)

        output:
        file "${ref.baseName}.*" into indexOut, indexFiles

        """
        bowtie2-build --threads 4 ${ref} ${ref.baseName}
        """

}

process bowtie2Align{
        publishDir 's3://msthesis/testing/', mode: 'copy'
        container = 'docker://biocontainers/bowtie2'
        input:
        file indexs from indexOut
        file ref from file(reference)
        file first from readone
        file second from readtwo

        output:
        file "bowtie.sam" into mapOut

        """
        bowtie2 -p 4 -x ${ref.baseName} -1 ${first} -2 ${second} -S bowtie.sam
        """
}

workflow.onComplete {
    println "Workflow execution time: $workflow.duration"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}

