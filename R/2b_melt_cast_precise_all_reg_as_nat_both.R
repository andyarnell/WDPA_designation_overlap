#install.packages("sqldf")
#library(sqldf)
library(foreign)
#install.packages("reshape2")
library(reshape2)
library(plyr)
library(sp)  # raster data
library(rgdal)
library(gdata)

###############
#single input dataset 
#national level analysis
in.folder<-"C:/Data/wdpa_desig/scratch/both_realms_dt_erase/both_scales/precise_int_dbfs"
in.folder<-"C:/Data/wdpa_desig/scratch/both_realms_dt_erase/both_scales/precise_int_dbfs"




out.folder<-"C:/Data/wdpa_desig/scratch/both_realms_dt_erase/both_scales/output_fcs/merged/land/regional"
out.folder<-"C:/Data/wdpa_desig/scratch/both_realms_dt_erase/both_scales/output_fcs/merged/land/national"


setwd(in.folder)
getwd()
dataset2<-read.dbf("preciseAdminIntUnionFC.dbf")#header=TRUE,sep=",")
str(dataset2)
names(dataset2)
tmp<-dataset2
#tmp$ISO3batch<-tmp$ISO3_1
tmp$ISO3batch<-tmp$ISO3_edt
tmp$count<-1

#to make fit with style of previous scripts
tmp$GID<-0
str(tmp)
tmp<-subset(tmp,tmp$type=="Land")


str(tmp)
#REGIONAL
tmp<-subset(tmp,tmp$GEOandUNEP==tmp$GEOandUN_1)

#NATIONAL
tmp<-subset(tmp,as.character(tmp$ISO3batch)==as.character(tmp$ISO3_1))


tmp<-drop.levels(tmp)
str(tmp)


#remove designations of same type in same place
tmp<-unique(tmp[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","GEOandUNEP","AREA_GEO","INSIDE_X","INSIDE_Y","count")])

summary(tmp$DESIG_ENG)
tmp$DESIG_ENG<-as.character(tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="National","National",tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="Regional","National",tmp$DESIG_ENG)
tmp$DESIG_ENG<-as.factor(tmp$DESIG_ENG)

reshapedTypeAll<-dcast(tmp,GID+GEOandUNEP+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_ENG,value.var="count",sum)

round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5
  z = trunc(z)
  z = z/10^n
  z*posneg
}

names(reshapedTypeAll)
tmp$DESIG_ENG
#reshapedTypeAll
head(reshapedTypeAll[,7:(length(names(reshapedTypeAll)))])
#sum across rows for total count of desig
reshapedTypeAll$countSum <- rowSums(reshapedTypeAll[,7:(length(names(reshapedTypeAll)))])

#checks
subset(reshapedTypeAll,reshapedTypeAll$countSum==0)

#create a column for merging/joining datasets
reshapedTypeAll$xy<-paste0(round(reshapedTypeAll$INSIDE_X,5),"_",round(reshapedTypeAll$INSIDE_Y,5))

head(reshapedTypeAll)
names(reshapedTypeAll)

unique(reshapedTypeAll["xy"])

fileTypeAll<-"reshapedTypeAll.csv"
names(reshapedTypeAll)
names(reshapedTypeAll[c(2,3,4,5,6,11,12)])

setwd(out.folder)

#saving to csv for joining to shapes
write.csv((reshapedTypeAll[c(2,3,4,5,6,11,12)]),fileTypeAll,na="0",row.names=FALSE)

#getting rid of small polys fro alternative version
reshapedTypeAllSR<-subset(reshapedTypeAll,reshapedTypeAll$AREA_GEO>= 0.001)

fileTypeAllSR<-"reshapedTypeAllSR_reg_as_nat.csv"
head(reshapedTypeAllSR)

#saving to csv for joining to shapes
write.csv(reshapedTypeAllSR,fileTypeAllSR,na="0",row.names=FALSE)




head(reshapedTypeAllSR)

reshapedTypeAllSR_AGG<-aggregate(reshapedTypeAllSR[c(6)],by=list(reshapedTypeAllSR$"GEOandUNEP", reshapedTypeAllSR$"ISO3",reshapedTypeAllSR$"National",reshapedTypeAllSR$"Ramsar Site, Wetland of International Importance",
                                                                 reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"),FUN=sum)


head(reshapedTypeAllSR)
names(reshapedTypeAllSR)
dfLength<-(length(names(reshapedTypeAllSR)))
names(reshapedTypeAllSR_AGG)<-c(names(reshapedTypeAllSR[c(2,3)]), names(reshapedTypeAllSR[7:(dfLength-2)]),names(reshapedTypeAllSR[6]))
head(reshapedTypeAllSR_AGG)

fileTypeAllSR_AGG<-"reshapedTypeAllSR_AGG_reg_as_nat.csv"

write.csv(reshapedTypeAllSR_AGG,fileTypeAllSR_AGG,na="0",row.names=FALSE)

