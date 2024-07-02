#!/bin/bash

wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.fai

cut -f 1,2 samples.annot | tail -n +2 | parallel --dryrun --colsep "\t" -j 10 "wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/{1}/alignment/{1}.chrom11.ILLUMINA.bwa.{2}.*" | bash
touch *.bai
 
ls *.bam | sort -t "." -k 5,5 > samples.bam_list

