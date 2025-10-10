## Mini-MAG-slurm

The idea is to create a **minimal** Nextflow metagenomics workflow, similar to nf-core/mag, runnable on a SLURM array.

Maybe there is nothing here yet. I might be failed with this project. It's ok.
But I will try again.

### Usage

```bash
nextflow run main.nf -profile slurm --reads '*_R{1,2}.fastq.gz' --outdir results
```

### Requirements

- Nextflow>=24.04.0 (we assume that these vesions come with array job support)
- Singularity
- SLURM cluster
- Input fastq files named as `SAMPLEID_R1.fastq.gz` and `SAMPLEID_R2.fastq.gz`
- Reference human genome, and databases for GTDB-Tk, DRAM (see `conf/params.config` for details)

### Workflow Steps

1. Quality control of raw reads with FastQC
3. Read trimming with fastp
4. Host (human) read removal with Bowtie2
5. PhiX read removal with Bowtie2
6. Post-trimming quality control with FastQC
7. Concatenate reads from multiple runs for each sample
8. Normalize read coverage with BBNorm
9. Assembly with MEGAHIT
10. Assembly quality assessment with QUAST
11. Map reads to contigs with Bowtie2
12. Binning with MetaBAT2, CONCOCT, and MaxBin2
13. Bin refinement with DAS Tool
14. Bin quality assessment refined bins with CheckM
15. Taxonomic assignment of refined bins with GTDB-Tk
16. Reporting with MultiQC
17. Functional annotation with DRAM

