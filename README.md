# SRAGPU-nf
This is a Nextflow workflow that demonstrates the use of GPU enabled Singularity containers. The two sample processing workflows `main.nf` and `nvBowtie_WF.nf` utilize GPU enable short read aligners, BarraCUDA and nvBowtie respectively. Additionally, `classify.nf` is a single step machine learning classification to illustrate that TensorFlow Docker Hub images can be pulled and automatically converted to Singularity images. The GPU pass through will still work for containers generated from these images.

Additional information is available at: https://github.com/KevinSayers/MastersThesis

# Requirements
* Nextflow version >= 0.25.5
* Singularity

# GPU pass through
Singularity will automatically mount the necessary NVIDIA CUDA libraries into containers if the `--nv` flag is specified. This can be configured in the `nextflow.config` as shown below.

```
singularity{
	enabled = true
	runOptions = '--nv'
}
```

# Short read aligners
Two workflows are provided to demonstrate the use of Singularity containers with GPU short read aligners.

To run either first run `nextflow run setup.nf` this will download and extract the necessary reference sequence. The first alinger is BarraCUDA, this aligner can be used by executing `nextflow run main.nf` . The other aligner is the nvBowtie, a version of Bowtie2 developed by NVIDIA. This aligner can be run using `nextflow run nvBowtie_WF.nf`. Either workflow will automatically pull the relevant Singularity container from a publicly available repository. 

# TensorFlow
The `classify.nf` workflow also shows the pulling of a GPU enabled Docker Hub image. This workflow will automatically pull the latest Python 3 TensorFlow GPU Docker image. It then trains a SVM model to classify samples based on one-hot encoded variants in the `transcriptomepreprocessed` file. Nextflow automatically converts the Docker Hub image to Singularity, and the GPU pass through enables the container to be used. 


