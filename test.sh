

#Import raw files into qiime
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \ #Semantic type 
--input-path manifest_data.txt\ #Data directory
--input-format PairedEndFastqManifestPhred33V2 \ #Format of files
--output-path demux-paired-end.qza #Name for output file
