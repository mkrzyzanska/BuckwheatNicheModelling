# R scripts, data and outputs for the manuscript 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'

This repository contains scripts relevant data and outputs used in the following manuscript:

*Krzyzanska. M. Harriet V. Hunt, Enrico R. Crema, Martin K. Jones. 2021. 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'*

 
The repository is organised into four main directories: [data](data), [notebooks](notebooks), [R](R), [stan_models](stan_models) and [outputs](outputs). The [data](data) directory contains data which was compiled for the analysis and is not available online in other places. All the other other data needed for the analysis can be obtained with the script included in this repository. [Notebooks](notebooks) directory includes Jupyter Notebooks written in R with all the scripts for data extraction, and model preparation, as well as scripts for generating figures and and other relevant output files. [R](R) directory contains R scripts with utility functions and plotting themes used in the scripts; [stan_models](stan_models) directory contains the code for the stan model and [outputs](outputs) direcotry contains all of the outputs of the analysis (including intermediary outputs, provided that they don't exceed 100 MB - in which case they can be reproduced with the scripts provided).

## [Data](data)

Data directory contains a dataset with the locations of fagopyrum macro and micro remains from China [ESM_2](data/ESM_2.csv), based on [Hunt et al. 2018](https://doi.org/10.1007/s00334-017-0649-4)  In addition to that ([ESM 3](data/ESM_3.pdf)) contains a full list of references to the original publications in which those were publisehd.

## [Notebooks]

The script is divided into 5 notebooks:

 1. [Data extraction](notebooks/01_Data_extraction.ipynb): downloads and extract relevant datasets and prepares the following plots:
     - [Buckwheat production in the world (ESM_4)](outputs/ESM_4.tiff)

csv file with the locations and matadata for buck macro and microfossils found in China 

 Codes and data for preparing Buckwheat Species Distribution Models for China
 
 Packages to install:
 
 install.packages("here",
 
 Codes includes additional functions 

