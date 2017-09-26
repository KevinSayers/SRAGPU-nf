# SRAGPU-nf
This is a Nextflow workflow that demonstrates the use of GPU enabled Singularity containers. The two sample processing workflows `main.nf` and `nvBowtie_WF.nf` utilize GPU enable short read aligners, BarraCUDA and nvBowtie respectively. Additionally, `classify.nf` is a single step machine learning classification to illustrate that TensorFlow Docker Hub images can be pulled and automatically converted to Singularity images. The GPU pass through will still work for containers generated from these images. 

# GPU pass through
Singularity will automatically mount the necessary NVIDIA CUDA libraries into containers if the `--nv` flag is specified. This can be configured in the `nextflow.config` as shown below.

```
singularity{
	enabled = true
	runOptions = '--nv'
}
```