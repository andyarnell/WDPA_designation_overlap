#install.packages("sqldf")
#library(sqldf)
library(foreign)
#install.packages("reshape2")
library(reshape2)
library(plyr)
library(sp)  # raster data
library(rgdal)


setwd("C:/Data/wdpa_desig/scratch/national/precise_int_dbfs")
out.folder<-("C:/Data/wdpa_desig/scratch/national/precise_reshape_dbfs")
out.folder2<-("C:/Data/wdpa_desig/scratch/national/precise_reshape_dbfs_sr")


##import look up table csv derived from desig-eng and desig_type columns in WDPA
desigTypeLUT<-read.csv("C:/Data/wdpa_desig/scratch/lookup_tables/wdpa_attr.csv")
desigTypeLUT<-(desigTypeLUT[,1:2])
desigTypeLUT<-subset(desigTypeLUT,!desig_type=="")
desigTypeLUT<-droplevels(desigTypeLUT)
tail(desigTypeLUT)
levels(desigTypeLUT$desig_type)

# listDBF=list.files(getwd(),full.names=TRUE)
# listDBF
getwd()

filenames <- Sys.glob("*.dbf")
filenames

#length<-1
#

filenames<-filenames[lapply(filenames,function(x) length(grep("AdminIntUnion",x,value=FALSE))) == 1]
length(filenames)
fName<-filenames[2:2]
fName[1]
 f<-read.dbf(fName)
head(f)
f$ISO3batch<-substr(fName, 0, 3)
f$count<-1
f<-unique(f[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","AREA_GEO","INSIDE_X","INSIDE_Y","count")])
head(f)
reshapedf<-dcast(f,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_ENG,value.var="count",sum)
# 
# head(reshapedf)

filenames[1]



###############################
#loop through and unpivot tables and save as csvs (according to names from edited list above)in the output folder
for (i in 1:1){#length(filenames)){
  fname<-filenames[i]
  #fname<-
  #iso3<-"AUS"
  #fname<-paste0(iso3,"_preciseAdminIntUnionFC.dbf")
  print (fname)
  tmp = read.dbf(fname)
  tmp$ISO3batch<-substr(fname, 0, 3)
  tmp$count<-1
  
  tmp<-unique(tmp[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","AREA_GEO","INSIDE_X","INSIDE_Y","count")])
  reshaped<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_ENG,value.var="count",sum)
  #getting values for internation, regional and national
  reshapedType<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_TYPE,value.var="count",sum)
  reshapedType<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_TYPE+DESIG_ENG,value.var="count",sum)
  head(reshaped)
  head(reshapedType)
  reshapedType$int<-0
  reshapedType$reg<-0
  reshapedType$nat<-0
  
  if("International" %in% colnames(reshapedType))
  {
    reshapedType$int<-reshapedType$International
    reshapedType$International<-NULL
  }
  if("Regional" %in% colnames(reshapedType))
  {
    reshapedType$reg<-reshapedType$Regional
    reshapedType$Regional<-NULL
  }

  if("National" %in% colnames(reshapedType))
  {
    reshapedType$nat<-reshapedType$National
    reshapedType$National<-NULL
  }
  
  #print (head(reshaped))
  #if only one extra column (i.e. has 6 columns then don't sum accross them as there is only one to sum)
  if (length(names(reshaped))==6) {
    colnames(reshaped)[6]<-"countSum"
  } else {reshaped$countSum <- rowSums( reshaped[,6:length(names(reshaped))] )
  }

  
  ####international replacements####
  if("World Heritage Site" %in% colnames(reshaped))
  {
    
    reshaped$whsCount<-reshaped$"World Heritage Site"
  } else 
  {
    reshaped$whsCount<-0  
  }
  if("Ramsar Site, Wetland of International Importance" %in% colnames(reshaped))
  {
    
    reshaped$rmsrCount<-reshaped$"Ramsar Site, Wetland of International Importance"
  } else 
  {
    reshaped$rmsrCount<-0  
  }
  if("UNESCO-MAB Biosphere Reserve" %in% colnames(reshaped))
  {
    reshaped$mabCount<-reshaped$"UNESCO-MAB Biosphere Reserve"
  } else 
  {
    reshaped$mabCount<-0  
  }

  ####regional replacements####
  
  
  if("Baltic Sea Protected Area (HELCOM)" %in% colnames(reshaped))
  {
    
    reshaped$helcomCount<-reshaped$"Baltic Sea Protected Area (HELCOM)"
  } else 
  {
    reshaped$helcomCount<-0  
  }
  
  
  if("Marine Protected Area (CCAMLR)" %in% colnames(reshaped))
  {
    
    reshaped$CCAMLRCount<-reshaped$"Marine Protected Area (CCAMLR)"
  } else 
  {
    reshaped$CCAMLRCount<-0  
  }
  
  
  if("Marine Protected Area (OSPAR)" %in% colnames(reshaped))
  {
    
    reshaped$OSPARCount<-reshaped$"Marine Protected Area (OSPAR)"
  } else 
  {
    reshaped$OSPARCount<-0  
  }
  
  
  if("Site of Community Importance (Habitats Directive)" %in% colnames(reshaped))
  {
     
     reshaped$habdirCount<-reshaped$"Site of Community Importance (Habitats Directive)"
  } else 
  {
    reshaped$habdirCount<-0  
  }


  if("Special Protection Area (Birds Directive)" %in% colnames(reshaped))
  {
    reshaped$spabdCount<-reshaped$"Special Protection Area (Birds Directive)"
  } else 
  {
    reshaped$spabdCount<-0  
  }


  if("Specially Protected Area (Cartagena Convention)" %in% colnames(reshaped))
  {
    
    reshaped$spaccCount<-reshaped$"Specially Protected Area (Cartagena Convention)"
  } else 
  {
    reshaped$spaccCount<-0  
  }
  if("Specially Protected Areas of Mediterranean Importance (Barcelona Convention)" %in% colnames(reshaped))
  {
    reshaped$spabcCount<-reshaped$"Specially Protected Areas of Mediterranean Importance (Barcelona Convention)"
  } else 
  {
    reshaped$spabcCount<-0  
  }
  
##### regional end ######
  colNum<-which( colnames(reshaped)=="countSum" )
  reshaped$nat <- (reshaped$countSum) - (rowSums(reshaped[,(colNum+1):length(names(reshaped))]))
  reshaped$reg <- (rowSums(reshaped[,(colNum+4):(length(names(reshaped))-1)]))
  reshaped$int <- (rowSums(reshaped[,(colNum+1):(colNum+3)]))
  
  reshapedType2<-reshaped[,-c(6:(colNum-1))]


  reshapedType$countSum <- rowSums( reshapedType[,6:length(names(reshapedType))])
  
#getting rid of small polys fro alternative version
reshapedTypeSR<-subset(reshapedType,reshapedType$AREA_GEO>= 0.001)
reshapedSR<-subset(reshaped,reshaped$AREA_GEO>= 0.001)
#finding max overlap in a grid cell
#if only one row then skip aggregating
if (length(reshaped$GID)>1){
  reshapedMax<-aggregate(reshaped,by=list(reshaped$GID),FUN=max)
} else {
  reshapedMax<-reshaped
}

reshapedMax<-reshapedMax[,c("GID","countSum")]
#if only one row then skip aggregating
if (length(reshapedSR$GID)>1){
  reshapedMaxSR<-aggregate(reshapedSR,by=list(reshapedSR$GID),FUN=max)
} else {
    reshapedMaxSR<-reshapedSR
  }
  reshapedMaxSR<-reshapedMaxSR[,c("GID","countSum")]
  #if only one row then skip aggregating
  if (length(reshapedSR$GID)>1){
    reshapedTypeSR_AGG<-aggregate(reshapedTypeSR[c(1,5:9)] ,by=list(reshapedTypeSR$int,reshapedTypeSR$reg,reshapedTypeSR$nat,reshapedTypeSR$countSum),FUN=sum)
    reshapedTypeSR_AGG$int<-NULL
    reshapedTypeSR_AGG$reg<-NULL
    reshapedTypeSR_AGG$nat<-NULL
    reshapedTypeSR_AGG$countSum<-NULL
    reshapedTypeSR_AGG$GID<-NULL
  
  colnames(reshapedTypeSR_AGG)<-c("int","reg","nat","countSum","AREA_GEO")
  } else {
    reshapedTypeSR_AGG<-reshapedTypeSR[c(1,5:9)]
  }
  head(reshapedTypeSR_AGG)
  reshapedTypeSR_AGG$ISO3batch<-substr(filenames[i], 0, 3)
  if (exists("reshapedTypeSR_AGG$Na")){
    reshapedTypeSR_AGG$Na<-NULL
  }
  #reshapedTypeSR_AGG$percent<-reshapedTypeSR_AGG$AREA_GEO/sum(reshapedTypeSR_AGG$AREA_GEO))*100
  ###saving
  paste0(out.folder,"/",filenames[i])
  fileInt<-gsub(".dbf",".csv",paste0("int_",filenames[i]))
  fileInt<-paste0(out.folder,"/",fileInt)
  write.csv(reshaped,fileInt,na="0",row.names=FALSE)
  fileSum<-gsub(".dbf",".csv",paste0("sum_",filenames[i]))
  fileSum<-paste0(out.folder,"/",fileSum)
  write.csv(reshapedMax,fileSum,na="0",row.names=FALSE )
  fileType<-gsub(".dbf",".csv",paste0("type_",filenames[i]))
  fileType<-paste0(out.folder,"/",fileType)
  write.csv(reshapedType,fileType,na="0",row.names=FALSE )
  ##saving versions with small polygons (slithers) removed
  #paste0(out.folder2,"/",filenames[i])
  fileIntSR<-gsub(".dbf",".csv",paste0("int_",filenames[i]))
  fileIntSR<-paste0(out.folder2,"/",fileIntSR)
  write.csv(reshapedSR,fileIntSR,na="0",row.names=FALSE)
  fileSumSR<-gsub(".dbf",".csv",paste0("sum_",filenames[i]))
  fileSumSR<-paste0(out.folder2,"/",fileSumSR)
  write.csv(reshapedMaxSR,fileSumSR,na="0",row.names=FALSE )
  fileTypeSR<-gsub(".dbf",".csv",paste0("type_",filenames[i]))
  fileTypeSR<-paste0(out.folder2,"/",fileTypeSR)
  write.csv(reshapedTypeSR,fileTypeSR,na="0",row.names=FALSE )
  fileTypeSR_AGG<-gsub(".dbf",".csv",paste0("agg_type_",filenames[i]))
  fileTypeSR_AGG<-paste0(out.folder2,"/",fileTypeSR_AGG)
  write.csv(reshapedTypeSR_AGG,fileTypeSR_AGG,na="0",row.names=FALSE )
  print(i)
  print(fileInt)
}
  




