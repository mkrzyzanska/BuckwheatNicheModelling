# R scripts, data and outputs for the manuscript 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'

This repository contains scripts relevant data and outputs used in the following manuscript:

*Krzyzanska. M. Harriet V. Hunt, Enrico R. Crema, Martin K. Jones. 2021. 'Modelling the potential niche of domesticated buckwheat in China: archaeological evidence, environmental constraints, and climate change.'*

 
The repository is organised into four main directories: [data](data), [notebooks](notebooks), [R](R), [stan_models](stan_models) and [outputs](outputs). The [data](data) directory contains data which was compiled for the analysis and is not available online in other places. All the other data needed for the analysis can be obtained with the script included in this repository. [Notebooks](notebooks) directory includes Jupyter Notebooks written in R with all the scripts for data extraction, and model preparation, as well as scripts for generating figures and other relevant output files. [R](R) directory contains R scripts with utility functions and plotting themes used in the scripts; [stan_models](stan_models) directory contains the code for the stan model and [outputs](outputs) directory contains all of the outputs of the analysis (including intermediary outputs, provided that they don't exceed 100 MB - in which case they can be reproduced with the scripts provided).

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
2. [Predictors' autocorrelation analysis](notebooks/02_Predictors_autocorrelation_analysis.ipynb): carries out the analysis of autocorrelation between environmental variables and selects predictors from the clusters of highly correlated variables. It also produces the figures showing autocorrelation:
    - [Correlation plot for environmental variables](outputs/02_02_Predictors_corrplot.tiff)
    - [Dendrogram with selected variables highlighted (ESM 6)](outputs/ESM_6.pdf)
3. [Data preparation](notebooks/03_Data_preparation.ipynb): puts the data into a format required by the model and produces the maps of 4.	environmental conditions for China:
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
    
7. [Predictions plots](notebooks/07_Predictions_plots.ipynb) Produces plots of predictions and difference between the predictions and observations:
    - [Distribution of prediction errors and confidence intervals (ESM 9)](outputs/ESM_9.pdf)
    - [Maps with posterior predictions for the present, compared against observed log area under cultivation and confidence intervals (ESM 11)](outputs/ESM_11.tiff)
    - [Maps with predictions of climate suitability over the past 8000 years (Figure 4)](outputs/Fig4.tiff)
    - [Predicted log area under cultivation for that past 8000 years, overlayed with locations containing past buckwheat record (Figure 3)](outputs/Fig3.tiff) 
    
## Required software:

- [Stan](https://mc-stan.org/)
- [Jupyter notebook](https://jupyter.org/) with [R kernel](https://github.com/IRkernel/IRkernel) or [GoogleColab](https://colab.research.google.com/) to open the notebooks in a browser
- R packages:

```
install.packages(c("here","rgdal","tmap","ncdf4","stringr","raster","rioja","maptools","prettymapr","data.table","corrplot","dendextend","spdep","geosphere","RColorBrewer","viridis","rstan","ggplot2","bayesplot","grid","gridExtra","ggridges","matrixStats","rgeos","tidyr","ggbeeswarm","sf"))
```

Package versions (installed and jupyter):
``` 
[1] "R 4.0.3"
[1] "-------------"
[1] "abind 1.4.5" [1] "assertthat 0.2.1" [1] "base 4.0.3" [1] "base64enc 0.1.3" [1] "bayesplot 1.7.2" [1] "beeswarm 0.2.3" [1] "boot 1.3.25"
[1] "callr 3.5.1" [1] "class 7.3.17" [1] "classInt 0.4.3" [1] "cli 2.1.0" [1] "cluster 2.1.0" [1] "coda 0.19.4" [1] "codetools 0.2.16"
[1] "colorspace 2.0.0" [1] "compiler 4.0.3" [1] "corrplot 0.85" [1] "crayon 1.3.4" [1] "crosstalk 1.1.0.1" [1] "curl 4.3" 
[1] "data.table 1.13.2" [1] "datasets 4.0.3" [1] "DBI 1.1.0" [1] "deldir 0.2.3" [1] "dendextend 1.14.0" [1] "dichromat 2.0.0" 
[1] "digest 0.6.27" [1] "dplyr 1.0.5" [1] "e1071 1.7.4" [1] "ellipsis 0.3.1" [1] "evaluate 0.14" [1] "expm 0.999.5" [1] "fansi 0.4.1" 
[1] "foreign 0.8.80" [1] "gdata 2.18.0" [1] "generics 0.1.0" [1] "geosphere 1.5.10" [1] "ggbeeswarm 0.6.0" [1] "ggplot2 3.3.2" 
[1] "ggridges 0.5.2" [1] "glue 1.4.2" [1] "gmodels 2.18.1" [1] "graphics 4.0.3" [1] "grDevices 4.0.3" [1] "grid 4.0.3" [1] "gridExtra 2.3" 
[1] "gtable 0.3.0" [1] "gtools 3.8.2" [1] "here 1.0.1" [1] "htmltools 0.5.0" [1] "htmlwidgets 1.5.2" [1] "inline 0.3.16" 
[1] "IRdisplay 0.7.0" [1] "IRkernel 1.1.1" [1] "jsonlite 1.7.1" [1] "KernSmooth 2.23.17" [1] "lattice 0.20.41" [1] "leafem 0.1.3" 
[1] "leaflet 2.0.3" [1] "leafsync 0.1.0" [1] "LearnBayes 2.15.1" [1] "lifecycle 1.0.0" [1] "loo 2.4.1" [1] "lwgeom 0.2.5" [1] "magrittr 1.5"
[1] "maptools 1.0.2" [1] "MASS 7.3.53" [1] "Matrix 1.2.18" [1] "matrixStats 0.57.0" [1] "methods 4.0.3" [1] "mgcv 1.8.33" 
[1] "munsell 0.5.0" [1] "ncdf4 1.17" [1] "nlme 3.1.149" [1] "parallel 4.0.3" [1] "pbdZMQ 0.3.3.1" [1] "permute 0.9.5" [1] "pillar 1.4.6"
[1] "pkgbuild 1.1.0" [1] "pkgconfig 2.0.3" [1] "plyr 1.8.6" [1] "png 0.1.7" [1] "prettymapr 0.2.2" [1] "prettyunits 1.1.1" 
[1] "processx 3.4.4" [1] "ps 1.4.0" [1] "purrr 0.3.4" [1] "R6 2.5.0" [1] "raster 3.4.5" [1] "RColorBrewer 1.1.2" [1] "Rcpp 1.0.5" 
[1] "RcppParallel 5.0.2" [1] "repr 1.1.0" [1] "rgdal 1.5.23" [1] "rgeos 0.5.5" [1] "rioja 0.9.26" [1] "rlang 0.4.10" [1] "rprojroot 2.0.2"
[1] "rstan 2.21.2" [1] "scales 1.1.1" [1] "sf 0.9.7" [1] "sp 1.4.4" [1] "spData 0.3.8" [1] "spdep 1.1.5" [1] "splines 4.0.3" 
[1] "StanHeaders 2.21.0.6" [1] "stars 0.5.1" [1] "stats 4.0.3" [1] "stats4 4.0.3" [1] "stringi 1.5.3" [1] "stringr 1.4.0"
[1] "tibble 3.0.4" [1] "tidyr 1.1.2" [1] "tidyselect 1.1.0" [1] "tmap 3.3.1" [1] "tmaptools 3.1" [1] "tools 4.0.3" [1] "units 0.6.7" 
[1] "utils 4.0.3" [1] "uuid 0.1.4" [1] "V8 3.4.0" [1] "vctrs 0.3.6"[1] "vegan 2.5.7" [1] "vipor 0.4.5" [1] "viridis 0.5.1" 
[1] "viridisLite 0.3.0" [1] "withr 2.3.0" [1] "XML 3.99.0.5"
``` 
## Funding:


This research was funded by the [Leverhulme Trust Research Project Grant (ref. RPG-2017-1): *Crops, pollinators and people: the long-term dynamics of a critical symbiosis.*](https://www.leverhulme.ac.uk/research-project-grants/crops-pollinators-and-people-long-term-dynamics-critical-symbiosis-0)

## External datasets references:


*Beyer RM, Krapp M, Manica A (2020) High-resolution terrestrial climate, bioclimate and vegetation for the last 120,000 years. Scientific Data 7:236. https://doi.org/10.1038/s41597-020-0552-1* [dataset](https://figshare.com/articles/dataset/LateQuaternary_Environment_nc/12293345)  

*Cao X, Ni J, Herzschuh U, et al (2013) A late Quaternary pollen dataset from eastern continental Asia for vegetation and climate reconstructions: Set up and evaluation. Review of Palaeobotany and Palynology 194:21–37. https://doi.org/10.1016/j.revpalbo.2013.02.003* 

*[DIVA-GIS](https://www.diva-gis.org/gdata)*  

*Hunt HV, Shang X, Jones MK (2018) Buckwheat: a crop from outside the major Chinese domestication centres? A review of the archaeobotanical, palynological and genetic evidence. Veget Hist Archaeobot. https://doi.org/10.1007/s00334-017-0649-4*  

*Monfreda C, Ramankutty N, Foley JA (2008) Farming the planet: 2. Geographic distribution of crop areas, yields, physiological types, and net primary production in the year 2000: GLOBAL CROP AREAS AND YIELDS IN 2000. Global Biogeochemical Cycles 22:n/a-n/a. https://doi.org/10.1029/2007GB002947* [dataset](http://www.earthstat.org/harvested-area-yield-175-crops/)  

*[@naturalearthdata.com](https://www.naturalearthdata.com/)*  

**Full list of references for buckwheat archaeological records is given in [ESM 3](data/ESM_3.pdf).**

## Licence

[CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/)