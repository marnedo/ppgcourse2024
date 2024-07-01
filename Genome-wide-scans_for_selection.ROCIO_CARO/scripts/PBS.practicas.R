# PRACTICAS

library(vcfR)
library(tidyverse)
library(ape)
library(ggtree)
library(GenotypePlot)

vcf <- read.vcfR("3pops.practical.vcf.gz")
poplabs <- read.table("samples.practical.txt")

poplabs <- poplabs[poplabs$V1 %in% colnames(vcf@gt),]
pop_f <- as.factor(poplabs$V2)

# Sequencing of 50 Human Exomes Reveals Adaptation to High Altitude
dff <- pairwise_genetic_diff(vcf, pops = pop_f)
dff <- dff %>% mutate(Tceu_chb = (-log(1-Gst_CEU_CHB)),
               Tceu_yri = (-log(1-Gst_CEU_YRI)),
               Tchb_yri = (-log(1-Gst_CHB_YRI)),
               PBS = (Tceu_chb+Tceu_yri-Tchb_yri)/2 )

dff %>% arrange(-PBS)

# Scan with PBS values
sd.cut <- mean(dff$PBS, na.rm = T) + 2*sd(dff$PBS, na.rm = T)
ggplot(dff, aes(POS,PBS)) + geom_hline(yintercept = sd.cut) + geom_point()
ggsave("PBS.scan.pdf", last_plot(), width = 15, height = 10)

# PBS whole region
PBS_tree <- rtree(n = 3, 
                  rooted = F,
                  br = c(mean(dff$Tceu_chb, na.rm = T),
                         mean(dff$Tceu_yri, na.rm = T),
                         mean(dff$Tchb_yri, na.rm = T)
                         ))

PBS_tree$tip.label <- c("Tceu_chb","Tceu_yri","Tchb_yri")

ggtree(PBS_tree, layout = "daylight") + geom_tiplab() + xlim(-7,7) + ylim(-7,7)
ggsave("PBS.tree.whole.region.pdf", last_plot(), width = 15, height = 10)


# PBS highest snp
dff <- dff[which.max(dff$PBS),]
PBS_tree <- rtree(n = 3, 
                  rooted = F,
                  br = c(mean(dff$Tceu_chb, na.rm = T),
                         mean(dff$Tceu_yri, na.rm = T),
                         mean(dff$Tchb_yri, na.rm = T)
                  ))

PBS_tree$tip.label <- c("Tceu_chb","Tceu_yri","Tchb_yri")

ggtree(PBS_tree, layout = "daylight") + geom_tiplab() + xlim(-7,7) + ylim(-7,7)
ggsave("PBS.tree.highest.snp.pdf", last_plot(), width = 15, height = 10)


#### Visualization of the genotypes
pt_clust <- genotype_plot(vcf_object = vcf, popmap = poplabs)
combine_genotype_plot(pt_clust)
ggsave("haplotype.structure.pdf", last_plot(), width = 15, height = 10)
