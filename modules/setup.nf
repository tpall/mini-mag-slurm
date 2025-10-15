
include { DATASETS_DOWNLOAD as DOWNLOAD_PHIX } from './download/datasets'
include { BOWTIE2_BUILD as BOWTIE2_PHIX_BUILD } from './bowtie2_build'
include { FETCH as DOWNLOAD_HOST_INDEX } from './download/fetch'

workflow SETUP {
    take:
    ch_phix_accession   // [phix accession]
    ch_host_index_url   // [host index path/url]

    main:
    ch_versions = Channel.empty()

    // Download and build PhiX index
    DOWNLOAD_PHIX(ch_phix_accession)
    ch_phix_fasta = DOWNLOAD_PHIX.out.fasta
    ch_versions = ch_versions.mix(DOWNLOAD_PHIX.out.versions)

    BOWTIE2_PHIX_BUILD(ch_phix_fasta)
    ch_phix_index = BOWTIE2_PHIX_BUILD.out.index
    ch_versions = ch_versions.mix(BOWTIE2_PHIX_BUILD.out.versions)

    // Download host index
    DOWNLOAD_HOST_INDEX(ch_host_index_url)
    ch_host_index = DOWNLOAD_HOST_INDEX.out.index

    emit:
    phix_index = ch_phix_index
    host_index = ch_host_index
    versions = ch_versions
}
