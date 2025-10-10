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
    
    input: 
    tuple val(meta), path(reads)

    output:
    path "${meta.id}_${meta.run}_fastqc.zip"
    path "${meta.id}_${meta.run}_fastqc.html"

    script:
    """
    touch "${meta.id}_${meta.run}_fastqc.zip"
    touch "${meta.id}_${meta.run}_fastqc.html"
    """
}
