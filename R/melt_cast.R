

#install.packages("reshape2")
library(reshape2)
library(foreign)
library(sp)  # raster data
library(rgdal)
#install.packages("foreach")
library(foreach)

#rm(list=ls())

setwd("C:/Data/wdpa_desig/scratch/national/tab_int_dbfs")
out.folder<-("C:/Data/wdpa_desig/scratch/national/reshape")


# listDBF=list.files(getwd(),full.names=TRUE)
# listDBF

filenames <- Sys.glob("*.dbf")
filenames
fName<-filenames[0:1]
f<-read.dbf(fName)
head(f)

#gsub(".dbf",".csv","john.dbf")

gsub(".dbf",".csv",paste0(out.folder,"/",filenames[i]))

listExcept<-c('CHN','BRA','CAN','AUS','IND','RUS') ##missed out USA too



#(filenames)

tmp.all=NULL

tmp = read.dbf(filenames[1])
head(tmp)
intersect(listExcept,filenames)
filenames<-setdiff(filenames,intersect(listExcept,filenames))##remove those in exception list
filenames<-filenames[lapply(filenames,function(x) length(grep("CHN",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("BRA",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("CAN",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("AUS",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("IND",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("RUS",x,value=FALSE))) == 0]
filenames<-filenames[lapply(filenames,function(x) length(grep("USA",x,value=FALSE))) == 0]

filenames
length<-length(filenames)

#loop through and unpivot tables and save as csvs (according to names from edited list above)in the output folder
for (i in 66:length){
  tmp = read.dbf(filenames[i])
  print (filenames)
  tmp<-(tmp[,c(1,3,4,5,6)])
  head(tmp)
  print (i)
  tmp.all=rbind(tmp.all,tmp)
  reshaped<-dcast(tmp,GID+ISO3~DESIG_ENG,value.var="AREA",sum)
  width<- length(names(reshaped))
  reshaped$sum <- if (width == 3) 1 else rowSums( reshaped[,3:length(names(reshaped))]>0)
  reshaped$sumOvr10thha <- if (width == 3) 1 else rowSums( reshaped[,3:((length(names(reshaped)))-1)]>0.001)
  reshaped$sumOvr1ha <- if (width == 3) 1 else rowSums( reshaped[,3:((length(names(reshaped)))-2)]>0.01)
  reshaped$sumOvr10ha <- if (width == 3) 1 else rowSums( reshaped[,3:((length(names(reshaped)))-3)]>0.1)
  reshaped$sumOvr50ha <- if (width == 3) 1 else rowSums( reshaped[,3:((length(names(reshaped)))-4)]>0.5)
  reshaped.sum <-reshaped[,c("ISO3","GID","sum","sumOvr10thha","sumOvr1ha","sumOvr10ha")]
  write.csv(reshaped,gsub(".dbf",".csv",paste0(out.folder,"/",filenames[i])),na="0",row.names=FALSE )
  write.csv(reshaped.sum,gsub(".dbf",".csv",paste0(out.folder,"/","sum_",filenames[i])),na="0",row.names=FALSE )
  print (paste0(out.folder,"/","sum_",filenames[i]))
  }

head(reshapedSum)

# 
# 
# ##################################
# foreach (i = 1:length) %dopar% {
#   tmp = read.dbf(filenames[i])
#   tmp<-(tmp[,c(1,3,4,5,6)])
#   #head(tmp)
#   tmp.all=rbind(tmp.all,tmp)
#   reshaped<-dcast(tmp,OBJECTID_1+ISO3~DESIG_ENG,value.var="AREA",sum)
#   #reshaped$countSum <- rowSums( reshaped[,3:length(names(reshaped))]>0) 
#   paste0(out.folder,"/",filenames[i])
#   write.csv(reshaped,gsub(".dbf",".csv",paste0(out.folder,"/",filenames[i])),na="0",row.names=FALSE)
#   return(NULL)
# }
# 
# 
# 
# #grid<-
# 
# head(tmp.all)
# 
# names(tmp.all)
# append.
# 
# 
# reshaped.all<-dcast(tmp.all,OBJECTID_1+ISO3~DESIG_ENG,value.var="AREA",sum)
# str(reshaped.all)
# tail(reshaped.all)
# summary(reshaped.all)
# #write.csv(reshaped.all,paste0(out.folder,"/","reshapedall.csv"),na="0",row.names=FALSE )
# #write.csv(reshaped.all,"C:/Data/test/reshaped/reshapedall.csv"),na="0",row.names=FALSE )
# fileOut<-"C:/Data/test/reshaped/reshapedall.dbf"
# write.dbf(reshaped.all, fileOut, factor2char = TRUE, max_nchar = 254)
# 
# #tmp.test=NULL
# 
# #for (i in 1:400){
# #  tmp.test=rbind(tmp.test,tmp.all)}
# 
# #str(tmp.test)
# #test<-read.dbf(fileOut)
# #summary(test)
