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
2. Read trimming with fastp
3. Host read removal with Bowtie2
4. PhiX read removal with Bowtie2
5. Post-trimming quality control with FastQC
6. Normalize read coverage with BBNorm
7. Assembly with MEGAHIT
8. Assembly quality assessment with QUAST
9. Map reads to contigs with Bowtie2
10. Binning with MetaBAT2, CONCOCT, and MaxBin2
11. Bin refinement with DAS Tool
12. Bin quality assessment refined bins with CheckM
13. Taxonomic assignment of refined bins with GTDB-Tk
14. Reporting with MultiQC
15. Functional annotation with DRAM

### Configuration

- `conf/params.config`: Configuration file for parameters and database paths
- `conf/singularity.config`: Configuration file for Singularity container paths
- `conf/slurm.config`: Configuration file for SLURM settings
- `nextflow.config`: Main Nextflow configuration file
- `main.nf`: Main Nextflow workflow script
- `modules/`: Directory containing Nextflow modules for each step
- `scripts/`: Directory containing auxiliary scripts
- `bin/`: Directory containing custom binaries or scripts
- `Dockerfile`: Dockerfile for building the Singularity container
- `README.md`: This readme file
- `LICENSE`: License file
- `.gitignore`: Git ignore file
- `.nextflow.log`: Nextflow log file
- `results/`: Directory for output results (created after running the workflow)
- `work/`: Nextflow work directory (created after running the workflow)
- `.nextflow/`: Nextflow internal files (created after running the workflow)
- `.github/`: GitHub workflows and issue templates (if applicable)
- `tests/`: Directory for test cases (if applicable)
- `docs/`: Directory for documentation (if applicable)
