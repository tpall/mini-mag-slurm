process BOWTIE2_BUILD {
    
    tag "${fasta.simpleName}"

    container "staphb/bowtie2:2.5.4"

    input:
    path fasta

    output:
    path "*.{bt2,bt2l}", emit: index
    path "versions.yml", emit: versions

    script:
    """
    bowtie2-build --threads ${task.cpus} ${fasta} ${fasta.simpleName}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}