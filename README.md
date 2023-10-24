# 16s analysis with QIIME2 and Visualization with R

Our fastq files are _paired-end_, _demultiplexed_ and have the type _PairedEndManifestPhred33V2_. Your fastq files can have **any** format, just change the 
correspondig parameters at the input process. 
Due to company confidentiality I can't provide you the fastq files, but I am going to explain everything you need to run your own analysis!


### ABOUT FASTQ FILES:

There are two fastq files for each sample in the study, each containing the forward or reverse reads for the sample, respectively. 
The names of the files should include the following information (**For PairedEndManifestPhred33V2**):

• Sample identifier

• Barcode sequence or a barcode identifier

• Lane number 

• Direction of the read:

      R1 = Forward read
      R2 = Reverse read
    
• Set number

_Example_ : A0C_S96_L001_R1_001.fastq and A0C_S96_L001_R2_001.fastq

The **steps** for our analysis are:

1. Import raw files into Qiime2

2. Use of DADA2 tool for:
   
     • Filtering
   
     • Dereplication
   
     • Chimera Identification
   
     • Merging paired-end reads
   
3. Taxonomic Analysis and some filtering

4. Phylogenetic tree

5. Rarefaction curves and calculation of Diversity metrics











