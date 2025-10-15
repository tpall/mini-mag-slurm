/*
 * SHORTREAD_PREPROCESSING: Preprocessing and QC for short reads
 */

include { FASTQC as FASTQC_RAW } from './fastqc'
include { FASTQC as FASTQC_TRIMMED } from './fastqc'
include { FASTP } from './fastp'
include { BOWTIE2_REMOVAL_ALIGN as BOWTIE2_HOST_REMOVAL_ALIGN } from './bowtie2_removal_align'
include { BOWTIE2_REMOVAL_ALIGN as BOWTIE2_PHIX_REMOVAL_ALIGN } from './bowtie2_removal_align'
// include { CAT_FASTQ } from '.cat/fastq'
// include { BBMAP_BBNORM } from './bbmap/bbnorm'

workflow PREPROCESSING {
    take:
    ch_input   // [ [meta] , fastq1, fastq2] 
    ch_host_index        // path to host index
    ch_phix_index        // path to phix index

    main:
    ch_multiqc_files = Channel.empty()
    ch_versions = Channel.empty()
    
    // Initial QC of raw reads
    FASTQC_RAW(ch_input)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_RAW.out.zip)
    ch_versions = ch_versions.mix(FASTQC_RAW.out.versions)
    
    // Trim adapters and low-quality bases
    FASTP(ch_input)
    ch_short_reads_prepped = FASTP.out.reads
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json)
    ch_versions = ch_versions.mix(FASTP.out.versions)
    
    // Host genome removal
    BOWTIE2_HOST_REMOVAL_ALIGN(ch_short_reads_prepped, ch_host_index)
    ch_short_reads_hostremoved = BOWTIE2_HOST_REMOVAL_ALIGN.out.reads
    ch_multiqc_files = ch_multiqc_files.mix(BOWTIE2_HOST_REMOVAL_ALIGN.out.log)
    ch_versions = ch_versions.mix(BOWTIE2_HOST_REMOVAL_ALIGN.out.versions)
    
    // PhiX removal
    if ( ! params.keep_phix ) {
        BOWTIE2_PHIX_REMOVAL_ALIGN(ch_short_reads_hostremoved, ch_phix_index)
    ch_short_reads_phixremoved = BOWTIE2_PHIX_REMOVAL_ALIGN.out.reads
    ch_multiqc_files = ch_multiqc_files.mix(BOWTIE2_PHIX_REMOVAL_ALIGN.out.log)
    ch_versions = ch_versions.mix(BOWTIE2_PHIX_REMOVAL_ALIGN.out.versions)
    ch_short_reads_contaminants_removed = ch_short_reads_phixremoved
    } else {
        ch_short_reads_contaminants_removed = ch_short_reads_hostremoved
    }
    
    // QC of trimmed reads
    FASTQC_TRIMMED(ch_short_reads_contaminants_removed)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC_TRIMMED.out.zip)
    ch_versions = ch_versions.mix(FASTQC_TRIMMED.out.versions)
    
    // // Run/Lane merging
    // ch_short_reads_forcat = ch_short_reads_phixremoved
    //         .map { meta, reads ->
    //             def meta_new = meta - meta.subMap('run')
    //             [meta_new, reads]
    //         }
    //         .groupTuple()
    //         .branch { _meta, reads ->
    //             cat: reads.size() >= 2
    //             skip_cat: true
    //         }
    // CAT_FASTQ(ch_short_reads_forcat.cat.map { meta, reads -> [meta, reads.flatten()] })
    
    // // Ensure we don't have nests of nests so that structure is in form expected for assembly
    // ch_short_reads_catskipped = ch_short_reads_forcat.skip_cat.map { meta, reads ->
    //         def new_reads = meta.single_end ? reads[0] : reads.flatten()
    //         [meta, new_reads]
    //         }
    // // Combine single run and multi-run-merged data
    // ch_short_reads = Channel.empty()
    // ch_short_reads = CAT_FASTQ.out.reads.mix(ch_short_reads_catskipped)
    
    // // Digital normalization for assembly
    // BBMAP_BBNORM(ch_short_reads)
    // ch_short_reads_assembly = BBMAP_BBNORM.out.fastq
    
    emit:
    reads = ch_short_reads_contaminants_removed
    multiqc_files = ch_multiqc_files
    versions = ch_versions
}