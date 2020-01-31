
### Set working directory:
setwd("G:\\My Drive\\SDM_China")
#setwd("/export/home/mk843/mnt/")
### Load libraries
library(rstan)
library(rgdal)
library("bayesplot")
library("ggplot2")
library('grid') # For plotting with ggplot and grid
library('rethinking') # use this for the link function and generating predictions
library("maptools")
library("rgdal")
library("tidyr")
library("dplyr")
library("ggpubr")
library("cowplot")
### Define the path in which to save models:
### Define the model to run
mname<-'parabolic_simple_iCAR'
##### Define the paths to required inputs:
#path2model<-paste('outputs/models/',mname,'.rds',sep="")
path2model<-paste('outputs\\models\\',mname,'.rds',sep="")
path2files <- paste('outputs\\')
path2predictions <- paste('outputs/05_01_Posterior_Predictions_',mname,'.csv',sep="")
path2stats<- "outputs\\03_01_Env_Mean_and_SD.csv"
#### Define the paths to outpurs

path2trace <- paste('outputs\\06_01_Traceplot_',mname,'.png',sep="")
path2posterior <- paste('outputs\\06_02_Posterior_distribution_',mname,'.png',sep="")
path2posterior_areas <- paste('outputs\\06_03_Posterior_distribution_area_',mname,'.png',sep="")
path2pairs <- paste('outputs\\06_04_Pairs_plot_',mname,'.png',sep="")
path2cf_plots <-paste('outputs\\06_05_Counterfactual_predictions_',mname,'.png',sep="")
path2predictions_plots <- paste('outputs\\06_06_Posterior_Predictions_',mname,'.png',sep="")
path2intervals<- paste('outputs\\06_07_Intervals_',mname,'.png',sep="")
path2intervals_exp<- paste('outputs\\06_08_Intervals__exp_',mname,'.png',sep="")
#path2counterfactual <-paste('outputs\\05_03',mname,'.csv',sep="")

### Define the data to import of posterior predictive checks:
china<-readOGR(dsn = "data/china_data", layer = "china_data")
predictions<-read.csv(path2prediction)
data<-china@data[c('BIO10_sd','BIO17_sd','BIO4_sd','BIO9_sd','npp_sd')]
stats<-read.csv(path2stats)
fit<-readRDS(path2model)

### Get the list of layers with data for counterfactual predictions
cfiles<-list.files(path=path2files,full.names=TRUE)
cfiles<-subset(cfiles,lapply(cfiles, grepl,pattern="Counterfactual_predictions")==TRUE &lapply(cfiles, grepl,pattern=mname)==TRUE)

# Get posterior
posterior <- rstan::extract(fit) # This should be equivalent with extract samples, but need to double chaeck that
#Get parameters from fit
parameters <- names(posterior)
# Get np_cp
np_cp <- nuts_params(fit)

#### This plots the mcmc chains

saved <- options(repr.plot.width=7.25, repr.plot.height=11.69)
saved$repr.plot.width <- 7.25
saved$repr.plot.height<-11.69
options(saved)
color_scheme_set("blue")
traceplot<-mcmc_trace(fit,
           n_warmup=fit@stan_args[[1]]$warmup, #number of warmup iterations to include
           regex_pars = c("alpha","beta"), #which parameters to show
           np = np_cp,
           facet_args=list(ncol=2)) + #options for how many plots to show per row
  #labs(title ="Traceplot of the MCMC",x="\nIterations") + # Define the titles of the plots and labs
  theme(plot.margin = unit(c(1,0,0,0), "cm")) + # defines the margins
  legend_move(position = "bottom")+ # moves legend to the bottom
  theme(text = element_text(family = "sans"))+ # defines the font of the text
  facet_text(family = "sans") + #defines the font of the text
  theme(panel.spacing = unit(0.5, "lines"))+ # Spacing between the panels
  theme(legend.key.size=(unit(1,"cm")))+
  guides(color = guide_legend(override.aes = list(size = 0.75)))

traceplot
#family sets the type of the family font to use
ggsave(path2trace,traceplot,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in", device='png')

## This does not want to change the size of the symbols
#saved <- options(repr.plot.width=4.25, repr.plot.height=6.69)
saved$repr.plot.width <- 3.25
saved$repr.plot.height<-3.69
options(saved)
color_scheme_set("brightblue")
posterior_plot<-mcmc_intervals(fit,regex_pars = c("alpha","beta")) +
theme(text = element_text(family = "sans"), # defines the font of the text
      axis.text=element_text(size=8),# defines the size of the axis labels
      panel.grid.major.y=element_line(color="lightgray",size=0.1))
### Transform ggplot to grid table, to change the size of the data points
posterior_plot <- ggplot_build(posterior_plot) #Builds the qtable from posterior plot
posterior_plot$data[[3]]$size <- rep(1,length(posterior_plot$data[[3]]$size)) # This define the size of the quartile markers
posterior_plot$data[[4]]$size <- rep(2,length(posterior_plot$data[[4]]$size)) # This defines the size of the median points
posterior_plot <- ggplot_gtable(posterior_plot)
grid.draw(posterior_plot)
ggsave(path2posterior,posterior_plot,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in", device='png')

## This does not want to change the size of the symbols
#saved <- options(repr.plot.width=4.25, repr.plot.height=6.69)
saved$repr.plot.width <- 3.25
saved$repr.plot.height<- 3.69
options(saved)
color_scheme_set("brightblue")
posterior_areas<-mcmc_areas(fit,regex_pars = c("alpha","beta")) +
theme(text = element_text(family = "sans"), # defines the font of the text
      axis.text=element_text(size=8),# defines the size of the axis labels
      panel.grid.major.y=element_line(color="lightgray",size=0.1))
posterior_areas
ggsave(path2posterior_areas,posterior_areas,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in", device='png')

### Bayesplot:
saved$repr.plot.width <- 20.25
saved$repr.plot.height<- 20.69
options(saved)
color_scheme_set("blue")
pairs<-mcmc_pairs(fit, regex_pars = c("alpha","beta"),
           off_diag_args = list(size = 0.01))
pairs
ggsave(path2pairs,pairs,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in",device='png')

names <- c("BIO10 Mean Temperature of Warmest Quarter","BIO17 Precipitation of Driest Quarter","BIO4 Temperature Seasonality","BIO9 Mean Temperature of Driest Quarter","Net Primary Productivity")
units <- c("°C","mm","°C","°C"," mass of carbon per unit area per year")
range<-apply(data,2,range)

counterfactual_plots<-c()
for(i in 1:5){
cpredictions<-read.csv(cfiles[i])
    color_scheme_set("brightblue")
    y<-as.numeric(colMeans(cpredictions))
    yrep=as.matrix(cpredictions)
    yvals<-seq(from = range[1,i], to = range[2,i],length.out=ncol(yrep))
    if(names[i]=="BIO4 Temperature Seasonality"){
      true_range<-(range[,i]*stats[i,'sd']+stats[i,'mean'])/100
      true_breaks<-seq(from=floor(true_range[1]), to=ceiling(true_range[2]),by=round(ceiling((true_range[2])-floor(true_range[1]))/5))
      tmp_breaks<-as.numeric(scale(true_breaks*100,center=stats[i,'mean'],scale=stats[i,'sd']))
      adjustment<-tmp_breaks[2]-tmp_breaks[1]
      breaks<-seq(from=1-abs((tmp_breaks[1]-(range[1,i]))/adjustment),to=ncol(cpredictions)+abs((tmp_breaks[length(tmp_breaks)]-(range[2,i]))/adjustment),length.out=length(true_breaks))
    }
    else {
        true_range<-(range[,i]*stats[i,'sd']+stats[i,'mean'])
        true_breaks<-seq(from=floor(true_range[1]), to=ceiling(true_range[2]),by=round(ceiling((true_range[2])-floor(true_range[1]))/5))
        tmp_breaks<-as.numeric(scale(true_breaks,center=stats[i,'mean'],scale=stats[i,'sd']))
        adjustment<-tmp_breaks[2]-tmp_breaks[1]
        breaks<-seq(from=1-abs((tmp_breaks[1]-(range[1,i]))/adjustment),to=ncol(cpredictions)+abs((tmp_breaks[length(tmp_breaks)]-(range[2,i]))/adjustment),length.out=length(true_breaks))
    }
    
    plot<-ppc_ribbon(y,yrep, prob = 0.5, prob_outer = 0.9,size = 1)+
        ggtitle(names[i])+
        scale_y_continuous("Predicted suitability")+
        scale_x_continuous(units[i],breaks=breaks,labels=true_breaks)+
        theme(text = element_text(family = "sans",size=6),plot.title = element_text(hjust = 0.5),axis.title = element_text(size = 8),axis.text = element_text(size = 6))+
        bayesplot:::scale_color_ppc_dist(labels = c("Mean", "Confidence \ninterval")) + 
        bayesplot:::scale_fill_ppc_dist(labels = c("Mean", "Confidence \ninterval"))
counterfactual_plots[[i]]<-plot 
}

### Arrange the plots on the page
saved <- options(repr.plot.width=7.25, repr.plot.height=11.69)
saved$repr.plot.width <- 7.25
saved$repr.plot.height<-11.69
cf_plots<-ggarrange(counterfactual_plots[[1]],counterfactual_plots[[2]],counterfactual_plots[[3]],counterfactual_plots[[4]],counterfactual_plots[[5]],ncol=2,nrow=3)
cf_plots

### Save the plot
save_plot(cf_plots, filename =path2cf_plots,base_width = saved$repr.plot.width, base_height = saved$repr.plot.height, units = "in",device='png',scale = 1,dpi = 300)

## Calculate means and confidence interval
means_pred<-apply(predictions,2, mean)
quantiles_pred<-apply(predictions,2, quantile,probs = c(0.05, 0.95))
pred<-t(rbind(quantiles_pred, means_pred))
exp_pred<-exp(pred)
colnames(pred)<-paste(colnames(pred),"_log",sep="")
pred<-cbind(pred,exp_pred)
china@data<-cbind(china@data,pred)

# add to data a new column termed "id" composed of the rownames of data
china@data$id <- rownames(china@data)
# create a data.frame from our spatial object
predDF <- fortify(china, region = "id")
# gather data by category
categories <- gather(china@data, category, predictions, logArea,means_pred_log,'5%_log','95%_log')
# merge the "fortified" data with the data from our spatial object
predDF <- left_join(predDF, categories, by = "id")

saved <- options(repr.plot.width=7.25, repr.plot.height=5)
saved$repr.plot.width <- 7.25
saved$repr.plot.height<-5
posterior_pred<-ggplot(predDF, aes(x = long, y = lat,group=group,fill=predictions)) + 
geom_polygon(aes(x = long, y = lat))+
facet_wrap(~category)+
scale_fill_gradient(low = "lightyellow", high = "red")+
coord_equal()+
theme(
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_line(colour = "lightgrey"),
)
posterior_pred

ggsave(path2predictions_plots,posterior_pred,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in",device='png')

#An S by N matrix of draws from the posterior predictive distribution, where S is the size of the posterior sample (or subset of the posterior sample used to generate yrep) and N is the number of observations (the length of y). The columns of yrep should be in the same order as the data points in y for the plots to make sense. See Details for additional instructions.
y=china@data$logArea
yrep=as.matrix(predictions[order(y)])
names<-china@data$NAME_3[order(y)]
y=y[order(y)]

saved <- options(repr.plot.width=7.25, repr.plot.height=11.69)
saved$repr.plot.width <- 7.25
saved$repr.plot.height<-11.69
options(saved)

intervals<-ppc_intervals(y,yrep, prob = 0.5, prob_outer = 0.9,size = 0.5, fatten = 3)+
ggtitle("Model predictions of the cultivated area as fraction for each\ncounty compared with the observed values. \n
         The lines represent 50% and 90% confidence intervals.")+
#scale_x_continuous("Counties",breaks = 1:length(names) ,labels=length(names,expand=c(0,0))+
scale_x_continuous("Counties",breaks=NULL,labels=NULL)+
scale_y_continuous("Logarithm of the cultivated area as a fraction.")+
theme(text = element_text(family = "sans",size=12),plot.title = element_text(hjust = 0.5),axis.title = element_text(size = 12))+
bayesplot:::scale_color_ppc_dist(labels = c("Observed", "Predicted")) + 
bayesplot:::scale_fill_ppc_dist(labels = c("Observed", "Predicted"))+
theme(axis.text.y=element_text( size=10, angle=0))+
coord_flip()
intervals
#ggsave(path2intervals,intervals,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in",device='png',scale = 10)
### Rows are the posterior sample
### Columns are the observations

ggsave(path2intervals,intervals,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in",device='png',scale = 1,dpi = 300)

y=china@data$logArea
yrep=as.matrix(predictions[order(y)])
names<-china@data$NAME_3[order(y)]
y=y[order(y)]
y=exp(y)
yrep=exp(yrep)

saved <- options(repr.plot.width=7.25, repr.plot.height=11.69)
saved$repr.plot.width <- 7.25
saved$repr.plot.height<-11.69
#saved$repr.plot.width <- 10
#saved$repr.plot.height<-100
options(saved)

intervals_exp<-ppc_intervals(y,yrep, prob = 0.5, prob_outer = 0.9,size = 0.5, fatten = 3)+
ggtitle("Model predictions of the cultivated area as fraction for each\ncounty compared with the observed values. \n
         The lines represent 50% and 90% confidence intervals.")+
#scale_x_continuous("Counties",breaks = 1:length(names) ,labels=length(names,expand=c(0,0))+
scale_x_continuous("Counties",breaks=NULL,labels=NULL)+
scale_y_continuous("Logarithm of the cultivated area as a fraction.")+
theme(text = element_text(family = "sans",size=12),plot.title = element_text(hjust = 0.5),axis.title = element_text(size = 12))+
bayesplot:::scale_color_ppc_dist(labels = c("Observed", "Predicted")) + 
bayesplot:::scale_fill_ppc_dist(labels = c("Observed", "Predicted"))+
theme(axis.text.y=element_text( size=10, angle=0))+
coord_flip()
intervals_exp

ggsave(path2intervals_exp,intervals_exp,width = saved$repr.plot.width, height = saved$repr.plot.height, units = "in",device='png',scale = 1,dpi = 300)
