#!/usr/bin/env nextflow
nextflow.enable.dsl=2
include { samplesheetToList } from 'plugin/nf-schema'
params.input = "samplesheet.csv"
params.host_removal_genome = "assets/removal_genomes/human_g1k_v37.fasta"

include { FASTQC } from 'modules/fastqc'
include { FASTP } from 'modules/fastp'
include { BOWTIE2_REMOVAL_BUILD } from 'modules/bowtie2_removal_build'

// Define the workflow
workflow {
        
        Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))
            .map { 
                meta, r1, r2 -> 
                meta.run = meta.run == [] ? "0" : meta.run
                return [meta, [r1, r2]]
                }
            .set { input_ch }

        // Step 1: Quality control of raw reads with FastQC
        FASTQC(input_ch)
        // Step 2: Trim adapters and low-quality bases with fastp
        FASTP(input_ch)

        // Step 3: Build Bowtie2 index for host genome removal
        Channel.fromPath(params.host_removal_genome).set { host_fasta_ch }
        BOWTIE2_REMOVAL_BUILD(host_fasta_ch)


}
