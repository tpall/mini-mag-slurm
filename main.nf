#!/usr/bin/env nextflow
nextflow.enable.dsl=2
nextflow.preview.output = true

include { samplesheetToList } from 'plugin/nf-schema'
include { SETUP } from './modules/setup.nf'
include { PREPROCESSING } from './modules/preprocessing.nf'

workflow PREPROC_IDX_SETUP {

    main:
    ch_versions = Channel.empty()
    SETUP(params.phix_accession, params.host_index_url)
    ch_phix_index = SETUP.out.phix_index
    ch_host_index = SETUP.out.host_index
    ch_versions = ch_versions.mix(SETUP.out.versions)

    emit:
    phix_index = ch_phix_index
    host_index = ch_host_index
    versions = ch_versions

}

// Defaulting workflow
workflow {
    
    Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))
            .map { 
                meta, r1, r2 -> 
                meta.run = meta.run == [] ? "0" : meta.run
                return [meta, [r1, r2]]
                }
            .set { ch_input }

    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    SETUP(params.phix_accession, params.host_index_url)
    ch_phix_index = SETUP.out.phix_index
    ch_host_index = SETUP.out.host_index
    ch_versions = ch_versions.mix(SETUP.out.versions)
    PREPROCESSING(ch_input, ch_host_index, ch_phix_index)
    ch_versions = ch_versions.mix(PREPROCESSING.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(PREPROCESSING.out.multiqc_files)

    publish:
    reads = PREPROCESSING.out.reads
}

output {
    reads {
        path 'trimmed_reads'
    }    
}