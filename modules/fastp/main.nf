// Module: fastp
process FASTP {

    tag "${meta.sample}"

    container "community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690"
    label 'process_medium'

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("*.fastq.gz"), emit: reads
        tuple val(meta), path("*.html"), emit: html
        tuple val(meta), path("*.json"), emit: json
        path "versions.yml", emit: versions

    script:
    prefix = "${meta.sample}_${meta.run}"

    """
    fastp \\
        -i ${reads[0]} -I ${reads[1]} \\
        -o ${prefix}_fastp_R1.fastq.gz -O ${prefix}_fastp_R2.fastq.gz \\
        -h ${prefix}_fastp.html \\
        -j ${prefix}_fastp.json \\
        -w ${task.cpus} \\
        --detect_adapter_for_pe
    
    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
        END_VERSIONS
    """
}
