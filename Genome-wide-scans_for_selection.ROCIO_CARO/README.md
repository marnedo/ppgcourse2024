

# Genome Wide Scans - Practical

**Instructor:** Jorge García Calleja
Based on material build by: Rocío Caro Consuegra

In this practical session we are going to compute some positive selection methods under different possible scenarios. First, we will compute two linkage disequilibrium based tests designed to detect positive selection: the integrated haplotype score (Voight et al., 2006) and the cross-population extended haplotype homozygosity (Sabeti et al., 2007). To do so, we will be using selscan (Szpiech et al., 2014; https://github.com/szpiech/selscan). Next, we will compute one method based on differences on allele frequencies between populations, the Population Branch Statistic method (Xin Yi et al. 2010). We will use different R packages: vcfR, ape and tidyverse . 

The rationale behind these three statistics rely on the different hypotheses and data we may be working with. With iHS, we have one population in which we are interested in, and we want to see outliers from the neutral whole genome background. With XP-EHH we have two populations for which we want to inspect the alleles that are most differentiated, as they can be subject to positive evolutionary forces. Population differentiation is also the basis of PBS, but the difference relies in that we normally have an outgroup population more distantly related that will allow knowing which is the population subject to selection. 

### Data description and access

We will focus on an already known signal that affects the SLC24A5 gene, located in chromosome 15. The solute carrier family 24 member 5 gene (SLC24A5) plays a role in human skin pigmentation. The ancestral allele of a coding polymorphism (rs1426654) is almost fixed in African and East Asian populations (93 to 100 %), whereas in Europeans, the derived allele is the almost fixed one (98.7 to 100%). (Lamason et al., 2005)

To analyze this, we have sequencing data available from the 1000 Genomes dataset (http://www.internationalgenome.org/). For this session, we provide trimmed versions of chromosome 15 for a European an African population and a Chinese population (CEU [Utah residents with Northern and Western European ancestry], YRI [Yoruba in Ibadan, Nigeria] and CHB [Han Chinese in Beijing],], respectively).

### Selscan

There are multiple softwares that you can use to compute LD-based selection scans, but we are focusing on Selscan (Szpiech et al., 2014; https://github.com/szpiech/selscan).

#### iHS: integrated haplotype score

For the calculation of iHS at a site, selscan first calculates the integrated haplotype homozygosity (iHH) for the ancestral (0) and for the derived (1) haplotypes separately. The unstandardized iHS is the natural logarithm of iHH1/iHH0. This means that in loci with positive (negative) iHS values, the derived (ancestral) allele seems adaptive for a particular selective pressure. Note that Voight et al., 2006 defined it the other way around (iHH0/iHH1).

```bash
selscan --ihs --hap <hapfile> --map <mapfile> --out <outfile>
# or
selscan --ihs --vcf <vcffile> --map <mapfile> --out <outfile>
```

For standardization, iHS scores are normalized by frequency bins across the genome by subtracting the means and dividing it by the standard deviations within that bin. 

```bash
norm --ihs --files <file1.*.out> ... <fileN.*.out>
```

##### Input files

The required input files are:

- **hap**: Variant information coded as 0s and 1s where each row represents an haploid copy and each column the sorted loci separated by whitespace. This format can be obtained from a VCF file. For the latest versions of selscan, you can directly use the **VCF** file. In any case, remember that data has to be phased and polarised (coded as ancestral/derived instead of reference/alternative as usual).
- **map**: Contains genetic and physical map information. The first column contains the chromosome, the second the SNP id, the third the genetic position and the fourth the physical position. In case there is no information about the genetic position, use the physical position again in its place (if left empty, selscan won't work).
- **out**: Gives a base name for the output file.

##### Computing iHS

Once we have all the input files ready, we can run selscan as follows:

```bash
# iHS computation
selscan --ihs --hap $HAP_FILE --map $MAP_FILE --out $IHS_FILE --threads 8

#### For YRI ####
HAP_FILE=data/YRI/YRI.recode.vcf.hap
MAP_FILE=data/YRI/YRI_filled.map
IHS_FILE=YRI

# iHS computation
selscan --ihs --hap $HAP_FILE --map $MAP_FILE --out $IHS_FILE --threads 8
```

The option --threads is used to parallelize jobs and speed up the process. Check in your own servers the capacity of the system.

And for the normalization:

```bash
# Normalizing iHS for Utah residents (CEPH) with Northern and Western European ancestry
NORM_IHS_FILE=CEU.ihs.out
norm --ihs --files $NORM_IHS_FILE 2> stderr.CEU.norm.txt

# Normalizing iHS for Yoruba in Ibadan, Nigeria
NORM_IHS_FILE=YRI.ihs.out
norm --ihs --files $NORM_IHS_FILE 2> stderr.YRI.norm.txt
```

##### Output files

Selscan generates two output files:

- An **.out** file organized in the following columns:

  - locus ID
  - physical position
  - derived allele frequency 
  - Integrated haplotype homozygosity of the derived allele (iHH1)
  - Integrated haplotype homozygosity of the ancestral allele (iHH0)
  - unstandardized iHS

- A **.log** file containing the runtime parameters. It will also include information about the excluded loci. Loci might be excluded because of:

  - a minor allele frequency below 0.05
  - reaching a gap over 200kbp
  - reaching the chromosome edge before the EHH has decayed below 0.05

  These are the parameters by default, but they can be modified  using --maf, --max-gap, or --cutoff respectively.

When normalizing, we obtain two extra files:

- **[100bins].norm**, which is organized as the **.out** file but with two extra columns:
  - standardized iHS
  - 1 if |standardized iHS| >= 2, and 0 otherwise

-  Outputting the standard error output to a file and we will obtained another file with some information of the run and a four columns table:
  - bin, indicating the frequency bin
  - num, indicating the number of SNPs that fall within that bin
  - mean
  - variance

  By default, normalization will be computed by 100 frequency bins in the range [0, 1]. This parameter can also be modified using --bins. In case we would rather use windows of a constant bp size, see --bp-win. Be careful because this will mean a varying number of SNPs within each window.

#### XP-EHH: cross-population extended haplotype homozygosity

For the calculation of XP-EHH between two populations A and B, selscan computes iHH for each population independently. The unstandardized XP-EHH is the natural logarithm of iHHA/iHHB.  Loci with positive values of XP-EHH will indicate a signal of selection in population A, and loci with negative values in population B.

```bash
selscan --xpehh --hap <pop1_hapfile> --ref <pop2_hapfile> --map <mapfile> --out
<outfile>
# or
selscan --xpehh --vcf <pop1_vcffile> --vcf-ref <pop2_vcffile> --map <mapfile> --out
<outfile>
```

For standardization, XP-EHH scores are normalized by subtracting the genome-wide mean and dividing it by the standard deviation.

```bash
norm --xpehh --files <file1.*.out> ... <fileN.*.out>
```

##### Input files

For XP-EHH, the required input files are the same than in iHS plus a **--ref** file. This is a .hap formatted file (or .vcf) from the reference population (population B). 

Note that **--hap** and **--ref** must contain the same loci. In this case, the files do not need to be coded as ancestral/derived (as it happened for the computation of iHS), they just need to be consistent between them. Finally **--map** might be the .map file of any of the two populations, as long as they contain the information about the exact same loci.

##### Computing XP-EHH

Once we have all the input files ready, we can compute XP-EHH as:

```bash
# XPEHH computation for YRI vs CEU
HAP1=data/YRI/YRI.recode.vcf.hap
HAP2=data/CEU/CEU.recode.vcf.hap
MAP=data/CEU/CEU_filled.map
XPEHH_FILE=YRIvsCEU

# modules
module load selscan

# selscan 
selscan --xpehh --hap $HAP1 --ref $HAP2 --map $MAP --out $XPEHH_FILE --threads 8
```

And for the normalization:

```bash
# Normalization
NORM_XPEHH_FILE=YRIvsCEU.xpehh.out
norm --xpehh --files $NORM_XPEHH_FILE 2> stderr.xp.txt
```

##### Output files

Again, selscan generates two output files:

- An **.out** file organized in the following columns:
  - locus ID
  - physical position
  - Population A allele frequency 
  - Integrated haplotype homozygosity of the population A allele (iHHA)
  - Population B allele frequency 
  - Integrated haplotype homozygosity of the population B allele (iHH0)
  - unstandardized XP-EHH
- A **.log** file with the same parameters as in the iHS .log file.

When normalizing, we obtain two extra files:

- **.norm**, which is organized as the **.out** file but with two extra columns:
  - standardized XP-EHH
  - 1 if |standardized XP-EHH| >= 2, and 0 otherwise

In case we redirect the standard error to a file, the file will also contain information about the normalization. For XP-EHH, this means a three column table with a single row containing the number of SNPs being analized, their XP-EHH mean and their XP-EHH variance.

### PBS

Sometimes, you don't have the possibility to perform haplotype based statistics. For example, with non model organisms whose recombination maps are not available and phasing is not an option. Although selscan provides two statistics (namely nSL and XP-nSL) that replace iHS and XP-EHH to perform these scans on unphased data, there are other options of interest. Population Branch Statistic (PBS), introduced in Xin Yi et al (2010) relies on allele frequency differentiation between populations. The interesting part of this method is that introducing a third population which acts as outgroup, we can infer the direction of selection (which it wouldn't be possible with Fst). 

```R
library(vcfR)
library(tidyverse)
library(ape)
library(ggtree)
library(GenotypePlot)

# We use vcfR to upload our vcf of interest and the labels
vcf <- read.vcfR("/yourfolder/3pops.practical.vcf.gz")
poplabs <- read.table("/yourfolder/samples.practical.txt")

poplabs <- poplabs[poplabs$V1 %in% colnames(vcf@gt),]
pop_f <- as.factor(poplabs$V2)

# Sequencing of 50 Human Exomes Reveals Adaptation to High Altitude
# We use the vcfR internal function to calculate genetic difference
# between populations, which must be provided as factors
dff <- pairwise_genetic_diff(vcf, pops = pop_f)

# We then use the Gst (that are an Fst statistic)
# and transform then into branch lenghts using the -log(1-Gst)
dff <- dff %>% mutate(Tceu_chb = (-log(1-Gst_CEU_CHB)),
               Tceu_yri = (-log(1-Gst_CEU_YRI)),
               Tchb_yri = (-log(1-Gst_CHB_YRI)),
               PBS = (Tceu_chb+Tceu_yri-Tchb_yri)/2 )

dff %>% arrange(-PBS)

```

Now we have the branch lengths between each of the populations and the PBS statistic for every single SNP. We can plot it as a normal whole genome scan and look at the highest values. 

```R
# For simplicity we will just take as cut values, values over 2 SD
sd.cut <- mean(dff$PBS, na.rm = T) + 2*sd(dff$PBS, na.rm = T)
ggplot(dff, aes(POS,PBS)) + geom_hline(yintercept = sd.cut) + geom_point()
```

We can finally plot the tree structure as a very intuitive way of showing the rationale behind this statistic. We know that CEU and CHB are less divergent than CEU to YRI and CHB to YRI, so in normality we expect that those branches are larger. But if we look at the branch length at the highest PBS value, we can observe that the CEU to CHB branch is the larger one, due to the effect of positive selection in these gene. 

### Visual inspection of the genotypes/haplotypes

Normally, we want to confirm our results. One common method is looking at the haplotypes in the region (or genotypes if we can not perform phasing). As expected by theory, regions under selection will tend to have one haplotype selected reducing the genetic diversity in the region. Let's test that using the same dataset as early. 

```R
library(GenotypePlot)

#### Visualization of the genotypes
pt_clust <- genotype_plot(vcf_object = vcf, popmap = poplabs)
combine_genotype_plot(pt_clust)
ggsave("haplotype.structure.pdf", last_plot(), width = 15, height = 10)
```

In these plot we can observe big differences between CEU and CHB and YRI populations. In CHB and YRI the region is highly heterozygotic, whereas in CEU the region is consistently homozygotic and the number of different rows (different haplotypes) is fewer than the other two  populations. 

### Bibliography

1000 Genomes Project Consortium. (2015). A global reference for human genetic variation. *Nature*, *526*(7571), 68.

Lamason, R. L., Mohideen, M. A. P., Mest, J. R., Wong, A. C., Norton, H. L., Aros, M. C., ... & Sinha, S. (2005). SLC24A5, a putative cation exchanger, affects pigmentation in zebrafish and humans. *Science*, *310*(5755), 1782-1786.

Sabeti, P. C., Varilly, P., Fry, B., Lohmueller, J., Hostetter, E., Cotsapas, C., ... & Schaffner, S. F. (2007). Genome-wide detection and characterization of positive selection in human populations. *Nature*, *449*(7164), 913.

Szpiech, Z. A., & Hernandez, R. D. (2014). selscan: an efficient multithreaded program to perform EHH-based scans for positive selection. Molecular biology and evolution, 31(10), 2824-2827.

Voight, B. F., Kudaravalli, S., Wen, X., & Pritchard, J. K. (2006). A map of recent positive selection in the human genome. *PLoS biology*, *4*(3), e72.

