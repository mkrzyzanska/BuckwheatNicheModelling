#Function to Prepare the innere borders of the potential niche:
getNicheOutline<-function(columns,threshold_min,threshold_max,facets,sf_object){
    if(is.null(threshold_min)){threshold_min=-Inf} # If min is not given set it to  -infinity
    if(is.null(threshold_max)){threshold_max=Inf} # If max is not given set it to infinity 
    if(is.null(facets)){facets=columns}
    column<-columns[1]
    facet<-facets[1]
    print(columns)
    sb<-as_Spatial(st_union(sf_object[as.data.frame(sf_object[,column])[,1]>=threshold_min[1] & as.data.frame(sf_object[,column])[,1]<=threshold_max[1],]))
    sb<-SpatialPolygonsDataFrame(sb,data=data.frame(id=1,facet=facet,row.names=row.names(sb)))
    borders<-sb
    for (i in 2:length(columns)){
        print(i)
        column<-columns[i]
        facet<-facets[i]
        if(length(threshold_min)>1){t_min=threshold_min[i]}else{t_min=threshold_min}
        if(length(threshold_max)>1){t_max=threshold_max[i]}else{t_max=threshold_max}
        print(t_min)
        print(t_max)
        sb<-as_Spatial(st_union(sf_object[as.data.frame(sf_object[,column])[,1]>=t_min & as.data.frame(sf_object[,column])[,1]<=t_max,]))
        print(column)
        sb<-SpatialPolygonsDataFrame(sb,data=data.frame(id=i,facet=facet,row.names=row.names(sb)))
        borders<-rbind(borders,sb)
    }
    return(borders)
}