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

}

// Module: FastQC
process FASTQC {
    tag "${meta.id}"
    publishDir "results/fastqc", mode: 'copy', overwrite: true

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' :
        'biocontainers/fastqc:0.12.1--hdfd78af_0' }"
    // label 'process_medium'

    input: 
    tuple val(meta), path(reads)

    output:
    path "${prefix}_fastqc.zip"
    path "${prefix}_fastqc.html"

    script:
    def prefix = meta.run == "0" ? "${meta.sample}" : "${meta.sample}_run${meta.run}"

    """
    fastqc \\
        --threads ${task.cpus} \\
        ${reads.join(' ')} \\
    """
}
