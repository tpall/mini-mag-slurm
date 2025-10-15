// Module: FastQC
process FASTQC {
    
    tag "${meta.sample}"

    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
    label 'process_medium'

    input: 
    tuple val(meta), path(reads)

    output:
    path "*_fastqc.zip", emit: zip
    path "*_fastqc.html", emit: html
    path  "versions.yml" , emit: versions

    script:
    """
    fastqc \\
        --threads ${task.cpus} \\
        ${reads.join(' ')}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed '/FastQC v/!d; s/.*v//' )
    END_VERSIONS
    """
}