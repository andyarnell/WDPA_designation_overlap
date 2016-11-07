
#install.packages("reshape2")
library(reshape2)
library(foreign)
library(sp)  # raster data
library(rgdal)
#install.packages("foreach")
library(foreach)

#rm(list=ls())


in.folder<-("C:/Data/wdpa_desig/scratch/national/precise_reshape_dbfs_sr")
in.folder2<-("C:/Data/wdpa_desig/scratch/national/fnets/fnets.gdb")

setwd(in.folder)
out.folder<-("C:/Data/wdpa_desig/scratch/national/precise_output_fcs")

# listDBF=list.files(getwd(),full.names=TRUE)
# listDBF

filenames <- Sys.glob("*.csv")
filenames
filenames<-filenames[lapply(filenames,function(x) length(grep("sum_",x,value=FALSE))) == 1]

fName<-filenames[2:2]
fName
f<-read.csv(fName)
head(f)


#gsub(".dbf",".csv","john.dbf")

#gsub(".dbf",".csv",paste0(out.folder,"/",filenames[i]))

length<-length(filenames)
#(filenames)
#length = 7
tmp.all=NULL

tmp = read.csv(filenames[1])
filenames

#filenameEdt<-gsub(".csv","", filename)

# The input file geodatabase
fgdb = in.folder2
# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
print(fc_list)
# Read the feature class
#fc = readOGR(dsn=fgdb,layer="fnet_AFG")


fc_list<-fc_list[lapply(fc_list,function(x) length(grep("fnet_",x,value=FALSE))) == 0]

#fc_list<-fc_list[lapply(fc_list,function(x) length(grep("CHN",x,value=FALSE))) == 0]
fc_list<-fc_list[lapply(fc_list,function(x) length(grep("BRA",x,value=FALSE))) == 0]
fc_list<-fc_list[lapply(fc_list,function(x) length(grep("CAN",x,value=FALSE))) == 0]
fc_list<-fc_list[lapply(fc_list,function(x) length(grep("AUS",x,value=FALSE))) == 0]
fc_list<-fc_list[lapply(fc_list,function(x) length(grep("IND",x,value=FALSE))) == 0]

fc_list<-fc_list[lapply(fc_list,function(x) length(grep("RUS",x,value=FALSE))) == 0]
fc_list<-fc_list[lapply(fc_list,function(x) length(grep("USA",x,value=FALSE))) == 0]
fc_list[194]

#if precise version then $sum should be $countSum and vice versa if normal outputs 




#loop through and join unpivoted tables to shapes for viewing
for (i in 194:length){
  setwd(in.folder)
  print(i)
  gridStats=read.csv(filenames[i])
  filenamesEdt<-gsub(".csv","", filenames[i])
  setwd(in.folder2)
  print (filenamesEdt)
#   filenamesEdt<-strsplit(filenamesEdt, "_")
#   filenamesEdt<-unlist(filenamesEdt)
#   filenamesEdt<-filenamesEdt[4]
  filenamesEdt<-gsub("sum_","fnetwdpa_", filenamesEdt)
  filenamesEdt<-gsub("_preciseIntUnionFC","", filenamesEdt)
  print (filenamesEdt)
  outfile<-paste0(out.folder,"/",filenamesEdt,".shp")
  print(outfile)
  # Read the feature class
  gridShape = readOGR(dsn=fgdb,layer=filenamesEdt)
  print(head(gridShape@data))
  #gridShape = readOGR(".", filenamesEdt)
  joinGrid<-merge(gridShape, gridStats,by.x="GID", by.y="GID")
  #print(head(joinGrid@data))
  joinGrid<-subset(joinGrid,joinGrid@data$countSum>0)
  droplevels(joinGrid@data)
  print(str(joinGrid@data))
  if(!file.exists(outfile)){
    writeOGR(joinGrid, out.folder, filenamesEdt, "ESRI Shapefile")
  }
  rm(gridShape)
  rm(joinGrid)
  rm(gridStats)
}




if(!file.exists(outfile)){
  
  # Read the feature class
  gridShape = readOGR(dsn=fgdb,layer=filenamesEdt)
  print(head(gridShape@data))
  #gridShape = readOGR(".", filenamesEdt)
  joinGrid<-merge(gridShape, gridStats,by.x="GID", by.y="GID")
  #print(head(joinGrid@data))
  
  joinGrid<-subset(joinGrid,joinGrid@data$countSum>0)
  
  droplevels(joinGrid@data)
  print(str(joinGrid@data))
  writeOGR(joinGrid, out.folder, filenamesEdt, "ESRI Shapefile")
  rm(gridShape)
  rm(joinGrid)
  rm(gridStats)
  
} 

joinGrid<-subset(joinGrid,joinGrid@data$sum>0)
droplevels(joinGrid@data)
str(joinGrid@data)

plot(joinGrid)
head(gridShape@data)
head(gridStats)
gridShape=fc
plot(gridShape)
gridShape$GID<-1:nrow(gridShape)

head(gridShape@data)
head(gridStats)
#gridShape = readOGR(".", "fnet_ESP")


require(rgdal)


#################################
# # The input file geodatabase
# fgdb = "C:/Data/wdpa_desig/scratch/grids/grids.gdb"
# 
# # List all feature classes in a file geodatabase
# subset(ogrDrivers(), grepl("GDB", name))
# fc_list = ogrListLayers(fgdb)
# print(fc_list)
# 
# # Read the feature class
# fc = readOGR(dsn=fgdb,layer="fnetwdpa_YEM")
# 
# # Determine the FC extent, projection, and attribute information
# summary(fc)

# View the feature class
plot(fc)
