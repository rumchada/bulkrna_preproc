//STAR Indexing
//STAR_ALIGN.nf module has bugs swap out for hisat2 indexing with splice and exon aware indexing
process star_index {
    
    publishDir "${params.final_outdir}", mode: "copy"

    input:
    path genome_fa
    path gtf

    output:
    path "index_files", emit: index
    
    //need to add runThreadN for cloud compatibility but that's
    // for the end
    script:
    """
    mkdir -p index_files

    STAR --runMode genomeGenerate \
            --genomeDir index_files \
            --genomeFastaFiles ${genome_fa} \
            --sjdbGTFfile ${gtf}
    """

    }