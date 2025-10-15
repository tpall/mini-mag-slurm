/*
 * Bowtie2 for read removal
 */
process BOWTIE2_REMOVAL_ALIGN {
    
    tag "${meta.sample}"

    container "staphb/bowtie2:2.5.4"

    input:
    tuple val(meta), path(reads)
    path  index

    output:
    tuple val(meta), path("*.unmapped*.fastq.gz") , emit: reads
    path  "*.mapped*.read_ids.txt" , emit: read_ids
    tuple val(meta), path("*.bowtie2.log") , emit: log
    path "versions.yml" , emit: versions

    script:
    prefix = "${meta.sample}_${meta.run}__${task.process}"
    INDEX = index[0].name.replaceAll(/\.\d\.bt2$/,'')
    
    """
    bowtie2 -p ${task.cpus} \
            -x ${INDEX} \
            -1 ${reads[0]} \
            -2 ${reads[1]} \
            --un-conc-gz ${prefix}.unmapped_R%.fastq.gz \
            --al-conc-gz ${prefix}.mapped_R%.fastq.gz \
            1> /dev/null \
            2> ${prefix}.bowtie2.log
    gunzip -c ${prefix}.mapped_R1.fastq.gz | awk '{if(NR%4==1) print substr(\$0, 2)}' | LC_ALL=C sort > ${prefix}.mapped_R1.read_ids.txt
    gunzip -c ${prefix}.mapped_R2.fastq.gz | awk '{if(NR%4==1) print substr(\$0, 2)}' | LC_ALL=C sort > ${prefix}.mapped_R2.read_ids.txt
    rm -f ${prefix}.mapped*.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}
