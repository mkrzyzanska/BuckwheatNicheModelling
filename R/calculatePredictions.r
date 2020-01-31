library(stringr)
calculatePredictions <- function(fit, data, posterior,n,counterfactual){
    code<-fit@stanmodel@model_code
    equation<-gsub(".*\nmodel","",code)
    equation <- gsub(",.*","",equation)
    equation<-gsub(".*alpha","",equation)
    equation <- gsub(c("\n"),"",equation)
    equation <- gsub(c(" "),"",equation)
    
    ### Include interactions:
    n_inter<-str_count(code, pattern = "vector\\[N\\] inter")
    for(i in 1:n_inter){
        print(i)
        query<-paste(".*inter",i," (.+) //.*",sep="")
        gsub(query, "\\1", code)
        inter<-gsub(query, "\\1", code)
        inter<-gsub(";.*","",inter)
        inter<-gsub("=","",inter)
        inter<-gsub(" ","",inter)
        inter<-gsub("\\.","",inter)
        equation<-gsub(paste("inter",i,sep=""),inter,equation)
      }

    if(is.null(posterior)){
    posterior <- rstan::extract(fit)}
    names<-names(posterior)
    names<-names[grep("beta",names)]
    sample<-sort(sample(1:length(posterior[[1]]),n, replace = FALSE))  

    ### Do the code for each county:
    ### County is a list of 1: 20..   
    predictions <-c()
    for (county in 1:nrow(data)){
        print(paste("Processing county number: ",county,sep=""))
        ### Start by redefining formula
        formula<-equation[1]
        ### Substitute the values of the variables to the equation
        for(var in 1:length(data)){
            formula<-gsub(paste("x",var,sep=""),data[county,var],formula)
        } 
        ### Now get the formula and value for each combination of parameters:
        county_pred<-c()
        for(i in sample){
            print(paste("Sample ",i," of ", n, " county ",county," of ", nrow(data),sep=""))
            it_eq<-formula
            for (name in names){
                it_eq<-gsub(name,posterior[name][[1]][i],it_eq)
            }
            ##If the predictions are for the counterfactual plots, don't include the spatial random effect
            if(counterfactual==TRUE){it_eq<-gsub('phi','0',it_eq)}
            else{it_eq<-gsub('phi',posterior['phi'][[1]][i,county],it_eq)}
            it_eq<-paste(posterior['alpha'][[1]][i],it_eq,sep="")
            pred<-eval(parse(text=it_eq))
            #county_pred[i]<-pred
            county_pred <- c(county_pred,pred)
        }
        predictions<-cbind(predictions,county_pred)}
    return(predictions)
}