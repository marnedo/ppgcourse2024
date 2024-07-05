#!/bin/bash

REG="11:20000000-23000000"

samtools faidx http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz $REG > hs37d5.fa.gz
samtools faidx hs37d5.fa.gz

parallel --header : "samtools view -o {sample}.{pop}.bam http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/{1}/alignment/{sample}.chrom11.ILLUMINA.bwa.{pop}.low_coverage.{date}.bam $REG" :::: samples.annot
rm *.bai
parallel samtools index ::: *.bam

ls *.bam | sort -t "." -k 2,2 > samples.bam_list
