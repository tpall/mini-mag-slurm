#!/usr/bin/env nextflow
nextflow.enable.dsl=2
include { samplesheetToList } from 'plugin/nf-schema'
params.input = "samplesheet.csv"

// Define the workflow
workflow {
        
        Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))
            .map { 
                meta, r1, r2 -> 
                meta.run = meta.run == [] ? "0" : meta.run
                return [meta, [r1, r2]]
                }
            .set { ch_input }

        // Step 1: Quality control of raw reads with FastQC
        FASTQC(ch_input)
        // Step 2: Trim adapters and low-quality bases with fastp
        FASTP(ch_input)

}

// Module: FastQC
process FASTQC {
    publishDir "results/fastqc", mode: 'copy', overwrite: true

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' :
        'biocontainers/fastqc:0.12.1--hdfd78af_0' }"
    // label 'process_medium'

    input: 
        tuple val(meta), path(reads)

    output:
        path "*_fastqc.zip"
        path "*_fastqc.html"

    script:
    """
    fastqc \\
        --threads ${task.cpus} \\
        ${reads.join(' ')} \\
    """
}

// Module: fastp
process FASTP {
    publishDir "results/fastp", mode: 'copy', overwrite: true

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/88/889a182b8066804f4799f3808a5813ad601381a8a0e3baa4ab8d73e739b97001/data' :
        'community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690' }"
    // label 'process_medium'

    input:
        tuple val(meta), path(reads)

    output:
        path "*.fastq.gz"
        path "*.html"
        path "*.json"

    script:
    def prefix = "${meta.sample}_${meta.run}"

    """
    fastp \\
        -i ${reads[0]} -I ${reads[1]} \\
        -o ${prefix}_fastp_R1.fastq.gz -O ${prefix}_fastp_R2.fastq.gz \\
        -h ${prefix}_fastp.html \\
        -j ${prefix}_fastp.json \\
        -w ${task.cpus} \\
        --detect_adapter_for_pe \\
    """
}
