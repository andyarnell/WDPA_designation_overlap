
#install.packages("reshape2")
library(reshape2)
library(foreign)
library(sp)  # raster data
library(rgdal)
#install.packages("foreach")
library(foreach)

#rm(list=ls())
"C:\Data/wdpa_desig/scratch/national_dt_erase/land/precise_int_dbfs/"

in.folder<-("C:/Data/wdpa_desig/scratch/national_dt_erase/land/precise_int_dbfs") 
out.folder<-("C:/Data/wdpa_desig/scratch/national_dt_erase/land/output_fcs/merged")

setwd(in.folder)

file_list <- list.files()

#file_list <- Sys.glob("agg*")

file_list<-file_list[lapply(file_list,function(x) length(grep("*.dbf*",x,value=FALSE))) == 1]
file_list<-file_list[lapply(file_list,function(x) length(grep("*.xml",x,value=FALSE))) == 0]
file_list<-file_list[lapply(file_list,function(x) length(grep("preciseAdminIntUnionFC*",x,value=FALSE))) == 1]

#file_list<-file_list[lapply(file_list,function(x) length(grep("ATF",x,value=FALSE))) == 1]

file1<-file_list[1]
test<-read.dbf(file1)

head(test)

(head(round(tmp$INSIDE_X,10)))
x=test$INSIDE_X#round2(tmp$INSIDE_X,3)
tail(formatC(x, format="f", digits=8))


setwd("C:/Data/wdpa_desig/raw")

#dataset(merge)
file2<-"ISO_regions.csv"
myData <- read.csv(file=file2, header=TRUE, sep=",")
myData<-(myData[c(3,5)])
#dataset.merge<-merge(dataset,myData,by.x="ISO3_1",by.y="ISO3")



setwd(in.folder)

if (exists("dataset")){
  rm(dataset)
}


for (file in file_list){
  
  # if the merged dataset doesn't exist, create it
  print (file)
  

  if (!exists("dataset")){
    dataset <- read.dbf(file)
    dataset[1]<-NULL
    dataset<-merge(dataset,myData,by.x="ISO3_1",by.y="ISO3")
    names(dataset)
    #if(!dataset$GEOandUNEP=="Europe"){
    #  rm(dataset)
    #}
    #names(dataset[1])<-paste("FID")
    
  }
  
  # if the merged dataset does exist, append to it
  if (exists("dataset")){
    temp_dataset <- read.dbf(file)
    temp_dataset[1]<-NULL
    temp_dataset<-merge(temp_dataset,myData,by.x="ISO3_1",by.y="ISO3")
    names(temp_dataset) <- names(dataset)
    dataset<-rbind(dataset, temp_dataset)
    #if(temp_dataset$GEOandUNEP=="Europe"){
    #  names(temp_dataset) <- names(dataset)
    #  dataset<-rbind(dataset, temp_dataset)
    #  print ("correct region")
    #} 
    
    #rm(temp_dataset)
    
  }
}

droplevels(dataset)
unique(dataset$ISO3)

str(dataset)


(head(round(dataset$INSIDE_X,10)))
x=head(dataset2$INSIDE_X)#round2(tmp$INSIDE_X,3)
tail(formatC(x, format="f", digits=8))


# 
# all.files<-file_list
# for(i in all.files) {
#   if (i==all.files[1]) new.data <- read.dbf(i) else {
#     new.data <- rbind(new.data, read.dbf(i))}} 
# 
# library(reshape)
# 
# all.files<-all.files[1:3]
#   
# merged.files <-merge_recurse(read.dbf(all.files))

str(dataset)
#str(temp_dataset)
#colnames(dataset)<-c("int", "reg",	"nat",	"countSum","AREA_GEO","ISO3batch")


write.csv(dataset,paste0(out.folder,"/","merged_aggsr_admin.csv"), na="0",row.names=FALSE )

  #rm(dataset)

head(dataset)



