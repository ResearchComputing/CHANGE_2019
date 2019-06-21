#!/bin/bash
#SBATCH --time=01:00:00      
#SBATCH --qos=blanca-ics      
#SBATCH --partition=blanca-ics                            
#SBATCH --account=blanca-ics                            
#SBATCH --nodes=1
#SBATCH --ntasks=1             
#SBATCH --job-name=qiime2    
#SBATCH --output=qiime2.%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=john.doe@colorado.edu #change to your email address!

#This example script does the qiime2 gneiss tutorial at:
#https://docs.qiime2.org/2019.4/tutorials/gneiss/

#purge any loaded modules
module purge

#activate your qiime2 environment
source /curc/sw/anaconda3/2019.03/bin/activate
source activate /projects/$USER/software/anaconda/envs/qiime2-2019.4

#go to the directory where you want to run the job
mkdir -p /rc_scratch/$USER/qiime2_testing
cd /rc_scratch/$USER/qiime2_testing

wget https://data.qiime2.org/2019.4/tutorials/gneiss/sample-metadata.tsv
wget https://data.qiime2.org/2019.4/tutorials/gneiss/table.qza
wget https://data.qiime2.org/2019.4/tutorials/gneiss/taxa.qza

#option 1: correlation clustering
qiime gneiss correlation-clustering \
--i-table table.qza \
--o-clustering hierarchy.qza

#option 2: gradient-clustering
qiime gneiss gradient-clustering \
--i-table table.qza \
--m-gradient-file sample-metadata.tsv \
--m-gradient-column Age \
--o-clustering gradient-hierarchy.qza

#ILR transform
qiime gneiss ilr-hierarchical \
--i-table table.qza \
--i-tree hierarchy.qza \
--o-balances balances.qza

#generate regression
qiime gneiss ols-regression \
  --p-formula "Subject+Sex+Age+BMI+sCD14ugml+LBPugml+LPSpgml" \
  --i-table balances.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization regression_summary.qzv

#generate heat map
qiime gneiss dendrogram-heatmap \
  --i-table table.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Subject \
  --p-color-map seismic \
  --o-visualization heatmap.qzv
