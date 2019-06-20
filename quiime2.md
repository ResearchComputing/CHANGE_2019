Notes on what to cover:
Logging in to Blanca
Installing qiime2
Using qiime2 interactively
Using qiime2 in batch mode with job scripts
Transferring qiime2 results back to your laptop (Globus)
Notes on additional aspects:
-viewing qiime2 results while on Blanca

-----

Logging in to Blanca
ssh johndoe@blogin01.rc.colorado.edu
(enter identikey and password, accept duo push to phone)


Installing qiime2
This installaton follows the "native" installaton instructions of qiime2
https://docs.qiime2.org/2019.4/install/native/

[johndoe@blogin01]$ cd /projects/$USER
[johndoe@blogin01]$ mkdir -p software/anaconda/envs
[johndoe@blogin01]$ cd software/anaconda/envs

[johndoe@blogin01]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@blogin01]$ wget https://data.qiime2.org/distro/core/qiime2-2019.4-py36-linux-conda.yml
(base) [johndoe@blogin01]$ conda env create --prefix=$PWD/qiime2-2019.4 --file qiime2-2019.4-py36-linux-conda.yml
(this will take about 30 min)
(base) [johndoe@blogin01]$ rm qiime2-2019.4-py36-linux-conda.yml

Using qiime2 interactively (example)
We will use the following tutorial to demonstrate using qiime in an interactive job:
https://docs.qiime2.org/2019.4/tutorials/gneiss/

Let's start an interactive session on a blanca-ics compute node:
[johndoe@blogin01]$ sinteractive --partition=blanca-ics --account=blanca-ics --ntasks=1 --time=03:00:00
[johndoe@bnode0409]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@bnode0409]$ conda activate /projects/$USER/software/anaconda/envs/qiime2-2019.4

Let's set up our example environment and get the data we need:
(qiime2-2019.4) [johndoe@bnode0409]$  mkdir -p /rc_scratch/$USER/qiime2-chronic-fatigue-syndrome-tutorial
(qiime2-2019.4) [johndoe@bnode0409]$ cd /rc_scratch/$USER/qiime2-chronic-fatigue-syndrome-tutorial
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/sample-metadata.tsv
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/table.qza
(qiime2-2019.4) [johndoe@bnode0409]$ wget https://data.qiime2.org/2019.4/tutorials/gneiss/taxa.qza

(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss correlation-clustering \
--i-table table.qza \
--o-clustering hierarchy.qza
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss gradient-clustering \
--i-table table.qza \
--m-gradient-file sample-metadata.tsv \
--m-gradient-column Age \
--o-clustering gradient-hierarchy.qza
(qiime2-2019.4) [johndoe@bnode0409]$ qiime2-chronic-fatigue-syndrome-tutorial]$ qiime gneiss ilr-hierarchical \
--i-table table.qza \
--i-tree hierarchy.qza \
--o-balances balances.qza
(qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss ols-regression \
  --p-formula "Subject+Sex+Age+BMI+sCD14ugml+LBPugml+LPSpgml" \
  --i-table balances.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization regression_summary.qzv
 (qiime2-2019.4) [johndoe@bnode0409]$ qiime gneiss dendrogram-heatmap \
  --i-table table.qza \
  --i-tree hierarchy.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Subject \
  --p-color-map seismic \
  --o-visualization heatmap.qzv

Now let's copy the data back to our local computer (e.g., laptop) so that we can visualize it. 

We went through Globus file transfers in a previous class and you should now have Globus Connect Personal on your laptop If you don't, you can get set up in about 5 minutes [here](https://curc.readthedocs.io/en/latest/compute/data-transfer.html)

Once you have Globus Connect Personal installed on your laptop, go to https://app.globus.org and login to "CU Boulder Research Computing" (search for this string in the "Collection Box".  Use your identikey credentials and the Duo app on your phone to login.  This will open up your filesystem on Blanca.

Once you've logged in, navigate to /rc_scratch/<yourusername>/ in the "Path" dialog box at the top.  Then click on the "qiime2-chronic-fatigue-syndrome-tutorial" directory to go inside.  
 
Now go to the "Panels" option at top and click the two-panel icon.  You should now see two panels on your screen.  For the one that you aren't already logged into, search for the name of your Globus Connect Personal endpoint in "Collection Box" (this is the endpoint name you provided for your laptop when you set up Globus Connect Personal, e.g., "John Doe's laptop"). This will open up the filesystem on your laptop.  

Now select the _.qza_ files on Blanca that you want to transfer to your laptop, and click the arrow transfer them.
 
Now open the [QIIME 2 Viewer](https://view.qiime2.org/) in your browser and drag the _.qza_ files into the viewer to view them!

* Rather view the files on Blanca? You can use VNC viewer per the [slides](./CHANGE_GuiOnBlanca.pdf) we previously presented (see the section on VNC). Once you've established a VNC remote desktop session on your laptop, open a terminal in your VNC session, source activate your `qiime2-2019.4` environment per the steps above, cd to the directory containing the _.qzv_ files, and use the qiime command-line viewer, e.g., ```qiime tools view heatmap.qzv```.  


Using qiime2 in batch mode with job scripts

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


Once your batch job is complete, you can follow the steps above transfer the resulting output files back to your laptop or use the qiime command-line viewer, per the steps above.





# Using Python with Anaconda

To support the diverse python workflows and high levels of customization Research Computing users require, [Anaconda](http://anaconda.com) is installed on the CURC system. Anaconda is an open-source _python_ and _R_ distribution that uses the _conda_ package manager to easily install software and packages. The following documentation describes how to activate the CURC Anaconda distribution and our default environments, as well as how to create and activate your own custom Anaconda environments. Additional documentation on the [CURC JupyterHub](../gateways/jupyterhub.md) is available for users desiring to interact with their custom environments via [Jupyter notebooks](https://jupyter.org). 

_Note: CURC also hosts several python modules for those users who prefer modules over Anaconda. Type ```module spider python``` for a list of available python versions. Each module employs the Intel python distribution and has numerous pre-installed packages which can be queried by typing ```pip freeze```._ 

## Using the CURC Anaconda environment

Follow these steps from a Research Computing terminal session. 

### Activate the CURC Anaconda environment

#### ___For python2___:
```
[johndoe@shas0137 ~]$ source /curc/sw/anaconda2/2019.03/bin/activate
(base) [johndoe@shas0137 ~]$ conda activate idp
```

#### ___For python3___:
```
[johndoe@shas0137 ~]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@shas0137 ~]$ conda activate idp
```

The first command activates the "base" python2 or python3 environment, which uses the Anaconda python distribution.  You will know that you have properly activated the environment because you should see _`(base)`_ in front of your prompt. E.g.: 

```
(base) [johndoe@shas0137 ~]$
```

The second command (_conda activate idp_) activates the Intel python distribution (idp), which is optimized for many mathematics functions and will run more efficiently on the Intel architecture of Summit and Blanca. You will know that you have properly activated the environment because you should see _`(idp)`_ in front of your prompt. E.g.: 

```
(idp) [johndoe@shas0137 ~]$
```

_*We strongly recommend using the Intel python distribution on Summit_.

### Using python in Anaconda

#### To list the packages currently installed in the environment:

```
(idp) [johndoe@shas0137 ~]$ conda list
```

#### To add a new package named "foo" to the environment:

```
(idp) [johndoe@shas0137 ~]$ conda add foo 
```

#### To list the conda environments currently available:

```
(idp) [johndoe@shas0137 ~]$ conda env list
```

#### To deactivate an environment:

```
(idp) [johndoe@shas0137 ~]$ conda deactivate
```

#### To create a new environment in a predetermined location in your /projects directory.  

*Note: In the examples below the environment is created in /projects/$USER/software/anaconda/envs. This assumes that the software, anaconda, and envs directories already exist in /projects/$USER. Environments can be installed in any writable location the user chooses.

 ##### 1a Activate the conda environment if you haven't already done so.
 
```
[johndoe@shas0137 ~]$ source /curc/sw/anaconda3/2019.03/bin/activate
(base) [johndoe@shas0137 ~]$ conda activate idp
```

 ##### 2a. _Ceate a custom environment "from scratch"_: Here we create a new environment called _mycustomenv_:

```
(idp) [johndoe@shas0137 ~]$ conda create --prefix /projects/$USER/software/anaconda/envs/mycustomenv
```

 or if you want a specific version of python other than the default installed in the CURC Anaconda base environment:

```
(idp) [johndoe@shas0137 ~]$ conda create --prefix /projects/$USER/software/anaconda/envs/mycustomenv python==2.7.16
```

 ##### 2b. _Ceate a custom environment by cloning a preexisting environment_: Here we clone the preexisting Intel Python3 distribution in the CURC Anaconda environment, creating a new environment called _mycustomenv_:

```
(idp) [johndoe@shas0137 ~]$ conda create --clone idp --prefix /projects/$USER/software/anaconda/envs/mycustomenv
```

##### 3. Activate your new environment

```
(idp) [johndoe@shas0137 ~]$ conda activate /projects/$USER/software/anaconda/envs/mycustomenv
```

##### Notes on creating environments:
* You can create an environment in any directory location you prefer (as long as you have access to that directory).  We recommend using your _`/projects`_ directory because it is much larger than your _`/home`_ directory).

* Although we don't show it here, it is expected that you will be installing whatever software and packages you need in this environment, as you normally would with conda).

* We [strongly recommend] cloning the [Intel Python distribution](https://software.intel.com/en-us/distribution-for-python) if you will be doing any computationally-intensive work, or work that requires parallelization. The Intel Python distribution will run more efficiently on our Intel architecture than other python distributions.

#### Troubleshooting

If you are having trouble loading a package, you can use `conda list` or `pip freeze` to list the available packages and their verion numbers in your current conda environment. Use `conda install <packagname>` to add a new package or `conda install <packagename==version>` for a specific verison; e.g., `conda install numpy=1.16.2`.

Sometimes conda environments can "break" if two packages in the environment require different versions of the same shared library.  In these cases you try a couple of things.
* Reinstall the packages all within the same _install_ command (e.g., `conda install <package1> <package2>`).  This forces conda to attempt to resolve shared library conflicts. 
* Create a new environment and reinstall the packages you need (preferably installing all with the same `conda install` command, rather than one-at-a-time, in order to resolve the conflicts).

#### See Also

* [CURC JupyterHub](../gateways/jupyterhub.md)
