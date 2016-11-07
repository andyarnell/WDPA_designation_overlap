
#install.packages("reshape2")
library(reshape2)
library(foreign)
library(sp)  # raster data
library(rgdal)
#install.packages("foreach")
library(foreach)

#rm(list=ls())


in.folder<-("C:/Data/wdpa_desig/scratch/national/precise_reshape_dbfs_sr")
out.folder<-("C:/Data/wdpa_desig/scratch/national/output_fcs/merged")
setwd(in.folder)

file_list <- list.files()

#file_list <- Sys.glob("agg*")

file_list<-file_list[lapply(file_list,function(x) length(grep("agg*",x,value=FALSE))) == 1]
file_list<-file_list[lapply(file_list,function(x) length(grep("preciseAdmin*",x,value=FALSE))) == 1]

file_list

for (file in file_list){
  # if the merged dataset doesn't exist, create it
  print (file)
  if (exists("dataset")){
    rm(dataset)
  }
  if (!exists("dataset")){
    dataset <- read.table(file, header=TRUE, sep=",")
  }
  # if the merged dataset does exist, append to it
  if (exists("dataset")){
    temp_dataset <-read.table(file, header=TRUE, sep=",")
    dataset<-rbind(dataset, temp_dataset)
    rm(temp_dataset)
    
  }
}


#colnames(dataset)<-c("int", "reg",	"nat",	"countSum","AREA_GEO","ISO3batch")

setwd("C:/Data/wdpa_desig/raw")

dataset(merge)
file2<-"ISO_regions.csv"
myData <- read.csv(file=file2, header=TRUE, sep=",")

dataset.merge<-merge(dataset,myData,by.x="ISO3batch",by.y="ISO3")

write.csv(dataset.merge,paste0(out.folder,"/","merged_aggsr_admin.csv"), na="0",row.names=FALSE )

  #rm(dataset)

head(dataset)
