#!/usr/bin/R                   #6/10/2023
library(tidyverse)
library(openxlsx);
library(vegan);
library(DT);
library(formattable);
library(kableExtra);
library(plotly);
library(crosstalk);

args = commandArgs(trailingOnly = TRUE)

if(length(args) != 2){
     stop("!!! Crash !!!\n I need path to the DivPro pipeline output directory and destination folder for the report. Like this:\n
     /data/Bioinfo/data-proj-rust/fastq_test\n/home/turakur/\n")
}else{
     sourcefolder = as.character(args[1]);
     sourcefolder <- paste0("/mnt/", sourcefolder);
     destinfolder <- as.character(args[2]);
     destinfolder <- paste0("/mnt/", destinfolder);
}

setwd(sourcefolder);
mainsummary <-  read.csv("secondary_analysis/overall_summary.tsv", sep="\t");
dada2       <-  read.csv("secondary_analysis/dada2/DADA2_table.tsv", sep="\t");

dadaqcR1    <-  paste0(sourcefolder, "/secondary_analysis/dada2/QC/1_ggsave_1.md.err.png");
dadaqcR2    <-  paste0(sourcefolder, "/secondary_analysis/dada2/QC/1_ggsave_2.md.err.png");
dadaqcR1    <-  gsub("/{2,}", "/", dadaqcR1);
dadaqcR2    <-  gsub("/{2,}", "/", dadaqcR2);
qvalpdf1    <-  paste0(sourcefolder, "/secondary_analysis/dada2/QC/FW_qual_stats.pdf");
qvalpdf2    <-  paste0(sourcefolder, "/secondary_analysis/dada2/QC/RV_qual_stats.pdf");
qvalpdf1    <-  gsub("/{2,}", "/", qvalpdf1);
qvalpdf2    <-  gsub("/{2,}", "/", qvalpdf2);
file.copy(c(dadaqcR1, dadaqcR2, qvalpdf1, qvalpdf2), destinfolder);



blast       <-  openxlsx::read.xlsx("secondary_analysis/Results/blast/megablast.xlsx", colNames = FALSE);
blastheader <- c("ASV_ID", "subject_gi", "evalue", "bit_score", "score", "alignment_length", "identity_pcnt", "identical", "positives", "positives_pcnt", "subject_sci_names", "subject_com_names", "subject_blast_names", "subject_super_kingdoms", "subject_title", "sequence");
names(blast)<- blastheader;

DF <- merge(dada2, blast[ ,-16], by="ASV_ID" )

dada <- dada2[,-c(1,ncol(dada2))]; 
row.names(dada) <- dada2$ASV_ID;

## alphadiversity {vegan}
alphashannon  <- diversity(t(dada), index="shannon");

## betadiver {vegan}
betdiv     <- betadiver(t(dada));
betasmeana <- rowMeans(as.matrix(betdiv$a));
betasmeanb <- rowMeans(as.matrix(betdiv$b));
betasmeanc <- rowMeans(as.matrix(betdiv$c));
combined_data <- data.frame(t(rbind(betasmeana, betasmeanb, betasmeanc)));
colnames(combined_data) <- c("a","b","c");


## unique ASV
uniqasv  <- colSums(dada != 0)
totalasv <- colSums(dada)

divtable <- data.frame(t(rbind(alphashannon, betasmeanc, uniqasv, totalasv))); 
divtable$alphashannon <- round(divtable$alphashannon, 1);
divtable$betasmeanc   <- round(divtable$betasmeanc,   1);

setwd(destinfolder);
file.copy("~/divprobatchreport/divpro_2_html.rmd",  "./");
file.copy("~/divprobatchreport/agrflogo.png",       "./");

rmarkdown::render("divpro_2_html.rmd", output_file = "divpro_batchreport.html");

file.remove("divpro_2_html.rmd", 
            "agrflogo.png",
	    "1_ggsave_1.md.err.png",
	    "1_ggsave_2.md.err.png",
	    "FW_qual_stats.pdf",
	    "RV_qual_stats.pdf");
