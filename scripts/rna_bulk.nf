
params {
    // input/output
    sample_sheet: Path = null
    final_outdir: String = null

    // initial ref files
    genome_fa: Path = null
    gtf: Path = null

   //binary trim arguments
   trim: Boolean = false
   min_length: Integer = 0
   quality: Integer = 0

   //cloud computing option (address by Sunday)
   //profile: String = null

}

//In an ideal scenario I'd have MultiQC overviews
include { FASTQC as FASTQC_RAW 
            FASTQC as FASTQC_TRIMMED } from '../modules/FASTQC.nf'

// no time to integrate dynamic trimming, but would be so cool
// need to add cloud or HPC compatibility by Sun (noted on Fri, 8/21/26)
// instead boring binary cutting option
include { trim } from '../modules/trim.nf'

//STAR Indexing
//include { star_index } from "../modules/STAR_INDEX.nf"
//STAR Alignment
// Spliced Transcripts Aligner could not read the unzipped
// A little extra gzip commands will be needed in the script of ALIGN process
// crossing my finger Nextflow has built in infrastructure to not publish internal script directories
// include { ALIGN } from "../modules/STAR_ALIGN.nf"
//quality checking alignment
// Abandoned STAR Alignment when bug could not be fixed on time. Pivot to the

include { hisat_index } from  "../modules/hisat2_index.nf"


include { HISAT_ALIGN } from "../modules/HISAT2_ALIGN.nf"


include { flagstat } from "../modules/flag_stat.nf"

//count matrixing

include { featureCounts } from "../modules/counts.nf"

//merge and clean either doing it in R. R script located in R file

include { merge_counts } from "../modules/merge_counts"

workflow {
    // input the sample sheet

    main:

    // Check if user even provided a sample_sheet
    if (! params.sample_sheet){
        error "Please provide a path to samplesheet with --sample_sheet"
    }

    if (! params.final_outdir){
        error ("Please give a name to the final output directory with --final_outdir")
    }

    //For the final structure
    //each ending directory should have the labeled ${final_outdir} so that the user can
    //distinguish between sample sheet they put in
    //ideally, the resulting day folder should have all of the final files in there

    // Day1 --> fastq, helper_files, alignment_outputs, indexing_files, count_vertices
    // Day2 -->

    // Ideally the sample_sheet will provide the location of paired end reads using paths

    // TASK1: Parse the sample sheet and make sure it has all the valid columns and 
    //       files before starting the pipeline


    //sample sheet channel
    samplesheet_ch = channel.fromPath(params.sample_sheet)
                            // parse Csv by .splitCsv() by row with header
                            .splitCsv(header: true)
                            //debugging line for viewing
                            .view{ csv ->  "after splitCsv: $csv"}


    //take from the inital split channel and conver to individual reads

    //columns wise validation
    validation_step = samplesheet_ch.map { row ->

    def required_columns = ['sample', 'fastq_1', 'fastq_2']
    def actual_columns = row.keySet()

    def missing = required_columns.findAll {
        !actual_columns.contains(it)
    }

    if (missing) {

        error """
        Invalid samplesheet.

        Missing required columns: ${missing}

        Required columns: ${required_columns}

        Found columns: ${actual_columns}
        """
    }

    log.info "Samplesheet columns validated: ${actual_columns}"
    }//valid step end bracket


    reads_ch = samplesheet_ch.map {
            row -> 

            //define the row read on and two as files
            //usually the normal loadings is paired end reads. 
            // However a customer could have single end reads due to budget
            //checking if the directory exists
            def r1 = file(row.fastq_1, checkifExists:true)

            //if the row contains a second fasta file, flag it as paired end within
            if (row.fastq_2){
                def r2 = file(row.fastq_2, checkifExists:true)

                //store them in tuple with denotations
                // of paired-end or single end reads
                tuple(
                    row.sample,
                    'PE',
                    [r1, r2]
                )}
            else {
                tuple(
                    row.sample,
                    'SE',
                    [r1])
            }
        } //end of map channel bracket



    //TASK2: Run FASTQC on each replicate provided within the sample sheet
    //Once this has ran provide an oppurtunity to the client to check their read quality reports

    // Initial FASTQC Process
    FASTQC_RAW(reads_ch)

    //trimming split
    if (params.trim) {

        log.info "Trimming enabled - cutting reads by parameter Please look at the resulting FASTQC report"
        
        //cutadapet Process
        //Cutadapt Process
        //trimmed reads do not need to put onto the disk
        trimmed_reads_ch = trim(reads_ch)

        //I may change this if there in an option for outputing the htmls
        FASTQC_TRIMMED(trimmed_reads_ch.out.trimmed_reads)

        alignment_reads_ch = trimmed_reads_ch.out.trimmed_reads

    } else {
        // else: use the original reads channel for alignment
        log.info "Trimming disabled - using original reads"
        log.info "Please Check FASTQC report"
        alignment_reads_ch = reads_ch
    }


    //TASK3: Alignment to the user input genome
    // Need to print out alignment results from flag
    //need to manage intermediate files
    // delete all irrelevant files

    //STAR Indexing process
    hisat_index(params.genome_fa, params.gtf)

    //STAR Alignment process
    //inputs: 
    //pass resulting channel reads (raw or trimmed on ALIGN)
    //pass emited directory on alignment
    HISAT_ALIGN(alignment_reads_ch, 
                hisat_index.out.index,
                params.genome_fa)



    //alignment QC
    flagstat(HISAT_ALIGN.out.bam_tuple)

    featureCounts(HISAT_ALIGN.out.bam_tuple, params.gtf)

    //finally .collect() comes in handy because this process
    // requires all of the alignment to be finished
    //Note to self: external scripts need to be defined 
    def r_script = file('./R/bam_to_matrix.R')
    merge_counts(r_script, featureCounts.out.counts.collect())


    publish:
    fastqc_results = FASTQC_RAW.out
    index_out = hisat_index.out
    align = HISAT_ALIGN.out
    flag_stat = flagstat.out
    counts = featureCounts.out
    matrix = merge_counts.out


}


// TASK 6 (Cloud Computing)
// overall plan:
// Get this thing working locally
// Add the nextflow.config for local and awsbatch profile
// test AWS credentials
//