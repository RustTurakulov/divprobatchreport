# divprobatchreport
R code for reporting DivPro batch outcome

This code uses AGRF divPro pipeline output folder "secondary_analysis" and produce HTML report with alpha and beta diversity scores and some figures cellected from QC folder. The main goal is quickly visualize batch outcome for technical and biological interpretation and detect outliers and hiddent data structure. 

Use this code with Docker container with all R libraries requared from this [repository](https://hub.docker.com/r/trust1/r4htmlbox): 

### Convert docker container to singularity image
Do it once before the first use. 

```

singularity pull r4htmlbox.sif docker://trust1/r4htmlbox:v0

```

### Usage example (with singularity container):

```

singularity run --bind /:/mnt \
$HOME/r4htmlbox.sif \
Rscript /mnt$HOME/divprobatchreport/divpro_2_html.R \
/data/Bioinfo/data-proj-rust/fastq4html \
/data/Bioinfo/data-proj-rust/fastq4html

```
This one assuming `r4htmlbox.sif` container in you home folder.
The divprobatchreport cloned in you home folder and script with supplements is on this path:
`$HOME/divprobatchreport/divpro_2_html.R`. 
The DivPro pipeline output is on this path: 
`/data/Bioinfo/data-proj-rust/fastq4html` 
Result will be ouputed into the same folder where the data source (last line). 

### Same things on the real run:

```

singularity run --bind /:/mnt \
$HOME/r4htmlbox.sif \
Rscript /mnt$HOME/divprobatchreport/divpro_2_html.R \
/data/Analysis/NextSeq2K/230927_VH01472_26_AACYN2WM5/contracts/NXGSQCAGRF23091021-2 \
/data/Bioinfo/data-proj-rust/fastq4html

```





