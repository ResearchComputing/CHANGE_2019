

# Blanca QIIME2 Tutorial
#### 2019-06-21

This tutorial demonstrates how to install and use the microbiome analysis package [QIIME2](https://docs.qiime2.org/2019.4/getting-started/) on the CU Research Computing Blanca computing cluster.

## Logging in to Blanca

From a terminal on your local computer (laptop or desktop machine), login as follows, substituting your username for `johndoe`.
``` ssh -X johndoe@blogin01.rc.colorado.edu```
(enter identikey and password, accept duo push to phone)

## Installing qiime2

Installaton on Blanca follows the ["native" installaton instructions for qiime2](https://docs.qiime2.org/2019.4/install/native/)

### Create a space for the new environment

```
[johndoe@blogin01]$ cd /projects/$USER
[johndoe@blogin01]$ mkdir -p software/anaconda/envs
[johndoe@blogin01]$ cd software/anaconda/envs
```

### Initialize the CURC Anaconda distribution and create the QIIME2 environment

```
[johndoe@blogin01]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@blogin01]$ wget https://data.qiime2.org/distro/core/qiime2-2019.4-py36-linux-conda.yml
(base) [johndoe@blogin01]$ conda env create --prefix=$PWD/qiime2-2019.4 --file qiime2-2019.4-py36-linux-conda.yml
(this will take about 30 min)
(base) [johndoe@blogin01]$ rm qiime2-2019.4-py36-linux-conda.yml
```

### Activate and test the installation with the QIIME --help function

You should already be in the 'base' CURC Anaconda environment based on the previous steps.  Now activate the QIIME2 environment:

```
(base) [johndoe@bnode0409]$ conda activate /projects/$USER/software/anaconda/envs/qiime2-2019.4
```

...you'll know you've activated it because `qiime2-2019.4` should preceed your prompt.

```
(qiime2-2019.4) [johndoe@bnode0409]$  mkdir -p /rc_scratch/$USER/qiime2-chronic-fatigue-syndrome-tutorial
```

## Example: Using qiime2 interactively on Blanca

We will use the QIIME2 tutorial on [Differential Abundance Analysis with Gneiss](https://docs.qiime2.org/2019.4/tutorials/gneiss/) to demonstrate using qiime in an interactive job.

### Start an interactive session on a blanca-ics compute node and activate the QIIME2 environment:

```
[johndoe@blogin01]$ sinteractive --partition=blanca-ics --account=blanca-ics --ntasks=1 --time=03:00:00
[johndoe@bnode0409]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@bnode0409]$ conda activate /projects/$USER/software/anaconda/envs/qiime2-2019.4
```

### Set up your workding directory and download needed data:

#### Create a working directoy on `rc_scratch` and `cd` to it:
```
(qiime2-2019.4) [johndoe@bnode0409]$  mkdir -p /rc_scratch/$USER/qiime2-chronic-fatigue-syndrome-tutorial
(qiime2-2019.4) [johndoe@bnode0409]$ cd /rc_scratch/$USER/qiime2-chronic-fatigue-syndrome-tutorial
```

#### Download the datasets needed to complete the tutorial:
```
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/sample-metadata.tsv
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/table.qza
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/taxa.qza
```

### Perform Correlation Clustering
```
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss correlation-clustering \
--i-table table.qza \
--o-clustering hierarchy.qza
```

### Alternately, perform Gradient Clustering
```
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss gradient-clustering \
--i-table table.qza \
--m-gradient-file sample-metadata.tsv \
--m-gradient-column Age \
--o-clustering gradient-hierarchy.qza
```

### Now build a linear model from the correlation clustering results

#### Perform an isometric log ratio (ILR) transform
```
(qiime2-2019.4) [johndoe@bnode0409]$ qiime2-chronic-fatigue-syndrome-tutorial]$ qiime gneiss ilr-hierarchical \
--i-table table.qza \
--i-tree hierarchy.qza \
--o-balances balances.qza
```

#### Run a linear regression on the balances
```
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss ols-regression \
  --p-formula "Subject+Sex+Age+BMI+sCD14ugml+LBPugml+LPSpgml" \
  --i-table balances.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization regression_summary.qzv
```

### Create a heatmap

```
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss dendrogram-heatmap \
  --i-table table.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Subject \
  --p-color-map seismic \
  --o-visualization heatmap.qzv
```

### Vizualize the results

#### Method 1: Transfer files back to your local machine (laptop)

We went through Globus file transfers in a previous class and you should now have [Globus Connect Personal](https://www.globus.org/globus-connect-personal) on your laptop If you don't, you can get set up in about 5 minutes [here](https://curc.readthedocs.io/en/latest/compute/data-transfer.html)

Once you have _Globus Connect Personal_ installed on your laptop, go to https://app.globus.org, find _CU Boulder Research Computing_ in the _Collection Box_ dialog box, and login using your identikey credentials and the Duo app on your phone.  This will open up your filesystem on Blanca.

Once you've logged in, navigate to /rc_scratch/<yourusername>/ in the "Path" dialog box at the top.  Then click on the "qiime2-chronic-fatigue-syndrome-tutorial" directory to go inside.  
 
Now go to the "Panels" option at top and click the two-panel icon.  You should now see two panels on your screen.  For the one that you aren't already logged into, search for the name of your Globus Connect Personal endpoint in "Collection Box" (this is the endpoint name you provided for your laptop when you set up Globus Connect Personal, e.g., "John Doe's laptop"). This will open up the filesystem on your laptop.  

Now select the _.qza_ files on Blanca that you want to transfer to your laptop, and click the arrow transfer them.
 
Now open the [QIIME 2 Viewer](https://view.qiime2.org/) in your browser and drag the _.qza_ files into the viewer to view them!

* Rather view the files on Blanca? You can use VNC viewer per the VNC section of the [slides](./CHANGE_GuiOnBlanca.pdf) we previously presented. Once you've established a VNC remote desktop session on your laptop, open a terminal in your VNC session, source activate your `qiime2-2019.4` environment per the steps above, `cd` to the directory containing the _.qzv_ files, and use the qiime command-line viewer, e.g., ```qiime tools view heatmap.qzv```.  


### Using qiime2 in batch mode with job scripts

To run the gneiss tutorial in batch mode, you can download the job script called [blanca_qiime2_gneiss.sh](./blanca_qiime2_gneiss.sh), to `blogin01` and submit it using ```sbatch blanca_qime2_gneiss```

```
#!/bin/bash
#SBATCH --time=01:00:00      
#SBATCH --qos=blanca-ics      
#SBATCH --partition=blanca-ics                            
#SBATCH --account=blanca-ics                            
#SBATCH --nodes=1
#SBATCH --ntasks=1             
#SBATCH --job-name=qiime2    
#SBATCH --output=qiime2.%j.out

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
```

Once your batch job is complete, you can follow the steps above transfer the resulting output files back to your laptop or use the qiime command-line viewer, per the steps above.

#### See Also

* [QIIME2 Documentation](https://docs.qiime2.org/2019.4/getting-started/)
* [CURC Documentation](https://curc.readthedocs.io/en/latest/)
