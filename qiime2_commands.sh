# manifest_data.txt : A .txt file that contains a column with the ID of each sample,
# a second column with the path in our PC that contains forward reads and a third column containing the path for reverse reads  

#Import raw files into qiime, please check the format of manifest_data.txt
#Depending on your own data you can change the semantic type and/or the format of your files
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \ #Semantic type 
--input-path manifest_data.txt\ #Data directory
--input-format PairedEndFastqManifestPhred33V2 \ #Format of files
--output-path demux-paired-end.qza #Name for output file

#My moto is: visualize, visualize, visualize. So let's... visualize our input data in order to be sure that the import part is correct, but also to make some decisions for the future
qiime demux summarize \
--i-data paired-end-demux.qza \ #Input file
--o-visualization paired-end-demux.qzv #Output file

#!Important! To be able to see paired-end-demux.qzv just drop that file here -> https://view.qiime2.org/


####################################################DADA2 TOOL###########################################################

#DADA2 tool, depending on your data, choose your own lengths to trim and truncate
#trim : Cuts at the 3' end, trunc : Cuts at the 5' end
#To decide where to trim and truncate observe the Interactive Quality Plot of paired-end-demux.qzv and observe where the quality score falls

qiime dada2 denoise-paired \
--i-demultiplexed-seqs paired-end-demux.qza \ #Ιnput file
--p-trim-left-f 17 \ #Length of forward primer
--p-trunc-len-f 277 \ #Position to truncate in forward reads
--p-trim-left-r 21 \ #Length of reverse primer
--p-trunc-len-r 205 \ #Position to truncate in reverse reads
--o-table table.qza \ #Feature table
--o-representative-sequences rep_seqs.qza \ #the sequences of the exact sequence variants (features); they are joined paired-end reads
--o-denoising-stats denoising_stats.qza #summary of the denoising stats

#Let's visualize the 3 outputs from DADA2 tool

#Representative sequences
qiime feature-table tabulate-seqs \ 
--i-data rep_seqs.qza \ #Input file name
--o-visualization rep_seqs.qzv #Output file name


#Denoising stats
qiime metadata tabulate \ 
--m-input-file denoising_stats.qza \ #Input file name
--o-visualization denoising_stats.qzv #Output file name


#Feature table
qiime feature-table summarize \ 
--i-table table.qza \ #Input file name
--o-visualization table.qzv #Output file name 


##############################################TAXONOMIC ANALYSIS###################################################
#In this step we will classify each Amplicon Sequence Variant (ASV) to the database entry that best matches it. 
#In our case a classifier has already been trained for the V3-V4 region of the 16s rRNA gene using the SILVA database.
#You have to create your own classifier.

qiime feature-classifier classify-sklearn \ 
 --i-classifier classifier-16S-V3V4-99-silva-138.qza \ #Input classifier
 --i-reads /work_2/tsiogeo/dada2/rep_seqs.qza \ #Representative sequences
 --output-dir /work_2/tsiogeo/taxonomy #Where to save the output

#Visualize  
 qiime metadata tabulate
 --m-input-file /work_2/tsiogeo/taxonomy/classification.qza #Input filename
 --o-visualization /work_2/tsiogeo/taxonomy/classification.qzv #Output filename


##############################################FILTERING############################################################

# You can remove ASVs that have been identified as mitochondria or chloroplasts or that have not been matched to any bacterium
qiime taxa filter-table \ 
--i-table /work_2/tsiogeo/dada2/table.qza \ #Feature table we are filtering
--i-taxonomy /work_2/tsiogeo/taxonomy/classification.qza \ #File that has all the taxonomy assignments
--p-exclude Mitochondria,Chloroplast,Unassigned \ #Remove ASVs that have been identified as Mitochondria or Chloroplast
--o-filtered-table /work_2/tsiogeo/taxonomy/NoMitoNoChloroNoUnass_table.qza #Where to save at


# We visualize it again
qiime feature-table summarize \ 
--i-table /work_2/tsiogeo/taxonomy/NoMitoNoChloroNoUnass_table.qza \ #Input file name
 --o-visualization /work_2/tsiogeo/taxonomy/NoMitoNoChloroNoUnass_table.qzv \ #Output file


# We will create a graph showing the relative abundance of bacteria between the samples:
qiime taxa barplot \
 --i-table /work_2/tsiogeo/taxonomy/NoMitoNoChloroNoUnass_table.qza \ #Filtered feature table to build our barplot
--i-taxonomy /work_2/tsiogeo/taxonomy/classification.qza \ #Classification file
 --m-metadata-file GRBR_New16S_Metadata.txt \ #Metadata file
 --o-visualization /work_2/tsiogeo/taxonomy/barchart.qzv \ #Where to save barchart


##############################################PHYLOGENETIC TREE############################################################ 
#It will align the sequences, filter out those that cannot give me phylogenetic information, and build the phylogenetic tree. 
qiime phylogeny align-to-tree-mafft-fasttree \ 
--i-sequences /work_2/tsiogeo/dada2/rep_seqs.qza \ #sequences to align
--o-alignment /work_2/tsiogeo/tree/aligned_16S_representative_seqs.qza \ #Perform the alignment
--o-masked-alignment /work_2/tsiogeo/tree/masked_aligned_16S_representative_seqs.qza \ #Mask sites in the alignment that are not phylogenetically informative
--o-tree /work_2/tsiogeo/tree/16S_unrooted_tree.qza \ #Generate phylogenetic tree
--o-rooted-tree /work_2/tsiogeo/tree/16S_rooted_tree.qza #Apply mid-point rooting to the tree


##############################################RAREFACTION CURVES############################################################ 
#The diagram that will appear in the output shows the number of sequences that were needed in order to completely find the bacterial community of the samples

qiime diversity alpha-rarefaction \ 
 --i-table /work_2/tsiogeo/dada2/table.qza \ #Data to use
 --i-phylogeny /work_2/tsiogeo/tree/16S_rooted_tree.qza \ #Phylogenetic tree
 --p-max-depth 15167 \ #Maximum rarefaction depth. I use the median number of reads from table.qza
 --o-visualization 16S_alpha_rarefaction.qzv \ #Output file


##############################################DIVERSITY METRICS############################################################ 
#To select the sampling depth, what we do is to open table.qzv and in the Interactive Sample Detail tab select a Sampling Depth that is as large as possible,
#to keep more sequences per sample but at the same time exclude as much as few samples as possible. It is not required to calculate them, but you will need them if you want to make more visualizations with R

qiime diversity core-metrics-phylogenetic \
 --i-phylogeny /work_2/tsiogeo/tree/16S_rooted_tree.qza \ #Rooted tree
 --i-table /work_2/tsiogeo/dada2/table.qza \ #Data to use
--p-sampling-depth 9661\ #Sampling depth
 --m-metadata-file GRBR_New16S_Metadata.txt \ #Metadata file
 --output-dir /work_2/tsiogeo/diversity_metrics \#Directory to save diversity metrics
