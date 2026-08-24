process hisat_index {

    publishDir "${params.final_outdir}", mode: "copy"

    input:
    path genome_fa
    path gtf

    output:
    path "index_files", emit: index

    script:
    //extracting from genome name provided by user
    def index_name = genome_fa.baseName

    """
    mkdir -p index_files

    hisat2_extract_splice_sites.py ${gtf} \
        > index_files/splice_sites.txt

    hisat2_extract_exons.py ${gtf} \
        > index_files/exons.txt

    hisat2-build \
        --ss index_files/splice_sites.txt \
        --exon index_files/exons.txt \
        ${genome_fa} \
        index_files/${index_name}
    """
}