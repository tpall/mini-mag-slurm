
process FETCH {

    tag "${url.simpleName}"

    input:
        path url

    output:
        path "*.{bt2,bt2l}", emit: index

    script:
    """ 
    tar -xf ${url}
    rm *.tar
    """
}
