# manifest_data.txt : A .txt file that contains a column with the ID of each sample,
# a second column with the path in our PC that contains forward reads and a third column containing the path for reverse reads  

#Import raw files into qiime, please check the format of manifest_data.txt
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \ #Semantic type 
--input-path manifest_data.txt\ #Data directory
--input-format PairedEndFastqManifestPhred33V2 \ #Format of files
--output-path demux-paired-end.qza #Name for output file

# My moto is: visualize, visualize, visualize. So let's... visualize our input data in order to be sure that the import part is correct 
qiime demux summarize \
--i-data paired-end-demux.qza \ #Input file
--o-visualization paired-end-demux.qzv #Output file

#!Important! To be able to see paired-end-demux.qzv just drop this file here -> https://view.qiime2.org/

# DADA2 tool 
qiime dada2 denoise-paired \
--i-demultiplexed-seqs paired-end-demux.qza \ #Ιnput file
--p-trim-left-f 17 \ #Length of forward primer
--p-trunc-len-f 277 \ #Position to truncate in forward reads
--p-trim-left-r 21 \ #Length of reverse primer
--p-trunc-len-r 205 \ #Position to truncate in reverse reads
--o-table table.qza \ #Feature table
--o-representative-sequences rep_seqs.qza \ #the sequences of the exact sequence variants (features); they are joined paired-end reads
--o-denoising-stats denoising_stats.qza #summary of the denoising stats





