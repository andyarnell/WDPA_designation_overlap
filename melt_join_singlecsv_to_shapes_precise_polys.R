
#install.packages("reshape2")
library(reshape2)
library(foreign)
library(sp)  # raster data
library(rgdal)
#install.packages("foreach")
library(foreach)

#rm(list=ls())


in.folder<-"c:/Data/wdpa_desig/scratch/national/output_fcs/merged"

in.folder2<-("C:/Data/wdpa_desig/scratch/national/precise_temp_fcs/temp.gdb") #("C:/Data/wdpa_desig/scratch/national/fnets/fnets.gdb")

out.folder<-"c:/Data/wdpa_desig/scratch/national/output_fcs/wdpa_fcs_joined"


setwd(in.folder)
getwd()
gridStats<-read.csv("reshapedTypeAll.csv")#header=TRUE,sep=",")
#gridStats<-reshapedTypeAllSR
#str(reshapedTypeAllSR)

str(gridStats)


#head(reshapedTypeAllSR$INSIDE_Y)

#signif(reshapedTypeAllSR$INSIDE_Y,5)

# The input file geodatabase
fgdb = in.folder2
# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
print(fc_list)
# Read the feature class
#fc = readOGR(dsn=fgdb,layer="fnet_AFG")

#gridShape = readOGR(dsn=fgdb,layer=fc_list[1])

#print(gridShape@data$INSIDE_X)

#gridStats=read.csv(fName)
#names(gridStats)



#joinGrid<-merge(gridShape, gridStats,by.x="INSIDE_X", by.y="INSIDE_X")
#print(str(joinGrid@data))


fc_list<-fc_list[lapply(fc_list,function(x) length(grep("preciseAdminIntUnionUniqFC",x,value=FALSE))) == 1]
#gridShape = readOGR(dsn=fgdb,layer=fc_list[1])

fc_list<-sort(fc_list)

#head(gridShape@data$INSIDE_X)
names(gridStats)
#head(gridStats[c(7:12,14)])
#gridStats$countSum<-rowSums(gridStats[c(7:12,14)])
gridStats<-gridStats[c("countSum","INSIDE_X","INSIDE_Y")]
names(gridStats)
#summary(gridStats$countSum)
round(gridStats$INSIDE_X,5)

gridStats$xy<-paste0(round(gridStats$INSIDE_X,1),"_",round(gridStats$INSIDE_Y,1))

head(gridStats$xy)


#loop through and join unpivoted tables to shapes for viewing
for (i in 34:length(fc_list)){
  print(i)
  #setwd(in.folder2)
  # Read the feature class
  gridShape = readOGR(dsn=fgdb,layer=fc_list[i])
  #print(summary(gridShape@data))
  #gridShape@data[1]<-NULL
  #gridShape@data[2]<-NULL
  #head(gridShape@data)
  gridShape@data$xy<-paste0(round(gridShape@data$INSIDE_X,1),"_",round(gridShape@data$INSIDE_Y,1))
  joinGrid<-merge(gridShape, gridStats,by.x="xy", by.y="xy")
  #joinGrid<-subset(joinGrid,joinGrid@data$countSum>0)
  droplevels(joinGrid@data)
  #print(head(joinGrid@data))
  print (subset(joinGrid@data,joinGrid@data$countSum==0))
  outfile<-fc_list[i]
  if(!file.exists(outfile)){
    writeOGR(joinGrid, out.folder, outfile, "ESRI Shapefile")
  }
  #rm(gridShape)
  #rm(joinGrid)
  #rm(gridStats)
}



head(gridShape@data)
head(joinGrid@data)

# 
# 
# if(!file.exists(outfile)){
#   
#   # Read the feature class
#   gridShape = readOGR(dsn=fgdb,layer=filenamesEdt)
#   print(head(gridShape@data))
#   #gridShape = readOGR(".", filenamesEdt)
#   joinGrid<-merge(gridShape, gridStats,by.x="GID", by.y="GID")
#   #print(head(joinGrid@data))
#   
#   joinGrid<-subset(joinGrid,joinGrid@data$countSum>0)
#   
#   droplevels(joinGrid@data)
#   print(str(joinGrid@data))
#   writeOGR(joinGrid, out.folder, filenamesEdt, "ESRI Shapefile")
#   rm(gridShape)
#   rm(joinGrid)
#   #rm(gridStats)
#   
# } 
# 
# joinGrid<-subset(joinGrid,joinGrid@data$sum>0)
# droplevels(joinGrid@data)
# str(joinGrid@data)
# 
# plot(joinGrid)
# head(gridShape@data)
# head(gridStats)
# gridShape=fc
# plot(gridShape)
# gridShape$GID<-1:nrow(gridShape)
# 
# head(gridShape@data)
# head(gridStats)
# #gridShape = readOGR(".", "fnet_ESP")
# 
# 
# require(rgdal)
# 

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
#plot(fc)
