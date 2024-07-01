#!/bin/bash     

# XPEHH computation for YRI vs CEU
HAP1=data/YRI/YRI.recode.vcf.hap
HAP2=data/CEU/CEU.recode.vcf.hap
MAP=data/CEU/CEU_filled.map
XPEHH_FILE=YRIvsCEU

# modules
module load selscan

# selscan 
selscan --xpehh --hap $HAP1 --ref $HAP2 --map $MAP --out $XPEHH_FILE --threads 8

# Normalization
NORM_XPEHH_FILE=YRIvsCEU.xpehh.out
norm --xpehh --files $NORM_XPEHH_FILE

