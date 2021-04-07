# R scripts, data and outputs for the manuscript 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'

This repository contains scripts relevant data and outputs used in the following manuscript:

*Krzyzanska. M. Harriet V. Hunt, Enrico R. Crema, Martin K. Jones. 2021. 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'*

 
The repository is organised into four main directories: [data](data), [notebooks](notebooks), [R](R), [stan_models](stan_models) and [outputs](outputs). The [data](data) directory contains data which was compiled for the analysis and is not available online in other places. All the other other data needed for the analysis can be obtained with the script included in this repository. [Notebooks](notebooks) directory includes Jupyter Notebooks written in R with all the scripts for data extraction, and model preparation, as well as scripts for generating figures and and other relevant output files. [R](R) directory contains R scripts with utility functions and plotting themes used in the scripts; [stan_models](stan_models) directory contains the code for the stan model and [outputs](outputs) direcotry contains all of the outputs of the analysis (including intermediary outputs, provided that they don't exceed 100 MB - in which case they can be reproduced with the scripts provided).

## [Data](data)

Data directory contains a dataset with the locations of fagopyrum macro and micro remains from China [ESM_2](data/ESM_2.csv), based on [Hunt et al. 2018](https://doi.org/10.1007/s00334-017-0649-4)  In addition to that ([ESM 3](data/ESM_3.pdf)) contains a full list of references to the original publications in which those were published.

## [Notebooks](notebooks)

The script is divided into 7 notebooks:

 1. [Data extraction](notebooks/01_Data_extraction.ipynb): downloads and extract relevant datasets and prepares the following plots and tables:
     - [Buckwheat production in the world (ESM_4)](outputs/ESM_4.tiff)
     - [Buckwheat production in China (ESM 5)](outputs/ESM_5.tiff)
     - [Names of environmental predictors](outputs/01_01_Predictor_variables.csv)
     - [Fagopyrum pollen diagrams (ESM_1)](outputs/ESM_1.pdf) from the pollen database compiled by [Cao et al. 2013](https://doi.org/10.1016/j.revpalbo.2013.02.003)
     - [Location of sites and pollen sections in China with identifications of Fagopyrum (Figure 1)](outputs/Fig1.tiff)
2. [Predictors autocorrelation analysis](notebooks/02_Predictors_autocorrelation_analysis.ipynb): carries out the analysis of autocorrelation between environmental variables and selects predictors from the clusters of highly correlated variables. It also produces the figures showing autocorrelation:
    - [Correlation plot for environmental variables](outputs/02_02_Predictors_corrplot.tiff)
    - [Dendrogram with selected variables highlited (ESM 6)](outputs/ESM_6.pdf)
3. [Data preparation](notebooks/03_Data_preparation.ipynb): puts the data into a format required by the model and produces the maps of environmnetlal conditions for China:
    - [Present environmental conditions (ESM 12a)](outputs/ESM_12a.tiff)
    - Past environmental conditions for 1000-8000 BP: [BI09 (ESM 12b)](outputs/ESM_12b.tiff), [BIO10 (ESM 12c)](outputs/ESM_12c.tiff), [BIO4 (ESM 12d)](outputs/ESM_12d.tiff), [NPP (ESM 12e)](outputs/ESM_12e.tiff), [BIO17 (ESM 12f)](outputs/ESM_12f.tiff)
    
4. [Run model](notebooks/04_Run_model.ipynb): runs the [stan mode](stan_models/parabolic_iCAR.stan) 
5. [Posterior predictions calculation](notebooks/05_Posterior_predictions_calculation.ipynb): calculates predicted climate suitability for the present environmental conditions, past (1000-8000 BP and 15 000 BP) and produces counterfactual predictions.
6. [Model diagnostics](notebooks/06_Model_diagnostics.ipynb): produces [model summary (ESM 8)](outputs/ESM_8.csv) and the plots of model diagnostics:
    - [Traceplots of Markov's chains (ESM 7)](outputs/ESM_7.pdf)
    - [Parameter estimates](outputs/06_01_Parameters_posterior.tiff) and their [density plot](outputs/06_02_Parameters_posterior_density.tiff)
    - Parameter pairs plot
    - [Counterfactual plots (Figure 2)](outputs/Fig2.tiff)
    - [Posterior predictions check (ESM 10)](outputs/ESM_10.pdf)
    
7. [Predictions_plots](notebooks/07_Predictions_plots.ipynb) Produces plots of predictions and difference between the predictions and observations:
    - [Distribution of prediction errors and confidence intervals (ESM 9)](outputs/ESM_9.pdf)
    - [Maps with posterior predictions for the present, compared against observed log area under cultivation and confidence intervals (ESM 11)](outputs/ESM_11.tiff)
    - [Maps with predictions of climate suitability over the past 8000 years (Figure 4)](outputs/Fig4.tiff)
    - [Predicted log area under cultivation for that past 8000 years, overlayed with locations containing past buckwheat record (Figure 3)](outputs/Fig3.tiff) 
    
## Required software:

- [Stan](https://mc-stan.org/)
- [Jupyter notebook](https://jupyter.org/) with [R kernel](https://github.com/IRkernel/IRkernel) or [GoogleColab](https://colab.research.google.com/) to open the notebooks in a browser
- R packages:

```
install.packages(c("here","rgdal","tmap","ncdf4","stringr","raster","rioja","maptools","prettymapr","data.table","corrplot","dendextend","spdep","geosphere","data.table","RColorBrewer","viridis","rstan","ggplot2","bayesplot","grid","gridExtra","ggridges","matrixStats","rgeos","tidyr","ggbeeswarm","tmap","stringr","sf"))

'''

