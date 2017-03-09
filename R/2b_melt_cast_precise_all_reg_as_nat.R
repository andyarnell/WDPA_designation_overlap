#install.packages("sqldf")
#library(sqldf)
library(foreign)
#install.packages("reshape2")
library(reshape2)
library(plyr)
library(sp)  # raster data
library(rgdal)


###############
#a single input dataset 
in.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/land/output_fcs/merged_textfiles")
in.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/marine/output_fcs/merged_textfiles")



#global level analysis

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/land/output_fcs/merged_textfiles/global")

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/marine/output_fcs/merged_textfiles/global")



#regional level analysis

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/land/output_fcs/merged_textfiles/regional")

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/marine/output_fcs/merged_textfiles/regional")

#national level analysis

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/land/output_fcs/merged_textfiles/national")

out.folder<-("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/marine/output_fcs/merged_textfiles/national")


setwd(in.folder)
getwd()
dataset2<-read.csv("merged_aggsr_admin.csv")#header=TRUE,sep=",")
names(dataset2)

head(dataset2)

tmp<-dataset2
tmp$ISO3batch<-tmp$ISO3
tmp$count<-1

str(tmp)
names(tmp)

#GLOBAL there isn't and subsetting - just miss out the other steps
count(unique(tmp$wdpaid))

#######################################################

####FIXING REGIONAL ISSUES - regional only

#UMI is split between two unep regions 
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="UMI"& tmp$GEOandUN_1=="Latin America + Caribbean"] <- "Asia + Pacific"
tmp$GEOandUN_1[tmp$GEOandUNEP=="Latin America + Caribbean" & tmp$ISO3=="UMI"& tmp$GEOandUN_1=="Asia + Pacific"] <- "Latin America + Caribbean"  
#all in abnj can be grouped into abnj - asked PAP (Naomi) and Marine programme (Ruth)
tmp$GEOandUN_1[tmp$GEOandUNEP=="ABNJ" & tmp$GEOandUN_1!="ABNJ"] <- "ABNJ"  


#overseas territories were coded to be in whichever region they fell in physically 
#New caledonia overseas territory (or similar terminology) of France
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="NCA"& tmp$GEOandUN_1=="Europe" & tmp$ISO3_1=='FRA'] <- "Asia + Pacific" 
#greenland overseas territory (or similar terminology) of denmark
tmp$GEOandUN_1[tmp$GEOandUNEP=="Polar" & tmp$ISO3== "GRL" & tmp$GEOandUN_1=="Europe" & tmp$ISO3_1=='DNK'] <- "Polar"
#Heard Island and McDonald Islands overseas territory (or similar terminology) of great britain
tmp$GEOandUN_1[tmp$GEOandUNEP=="Polar" & tmp$ISO3=="HMD"& tmp$GEOandUN_1=="Asia + Pacific" & tmp$ISO3_1=='AUS'] <- "Polar"  
#saint helena overseas territory (or similar terminology) of great britain
tmp$GEOandUN_1[tmp$GEOandUNEP=="Africa" & tmp$ISO3=="SHN"& tmp$GEOandUN_1=="Europe" & tmp$ISO3_1=='GBR'] <- "Africa"  
#United States Minor Outlying Islands overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="UMI"& tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Asia + Pacific"  
#simialrly but from the other angle, those UMI in USA are changed to North America region
tmp$GEOandUN_1[tmp$GEOandUNEP=="North America" & tmp$ISO3=="USA" & tmp$GEOandUN_1=="Asia + Pacific" & tmp$ISO3_1=='UMI']<- "North America"
# american samoa overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="ASM"& tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Asia + Pacific"
#puerto rica overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Latin America + Caribbean" & tmp$ISO3=="PRI" & tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Latin America + Caribbean"
#virgin islands (US virgin islands) overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Latin America + Caribbean" & tmp$ISO3=="VIR" & tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Latin America + Caribbean"
#palau overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="PLW" & tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Asia + Pacific"  
#Réunion island overseas territory (or similar terminology) of france
tmp$GEOandUN_1[tmp$GEOandUNEP=="Africa" & tmp$ISO3=="REU" & tmp$GEOandUN_1=="Europe" & tmp$ISO3_1=='FRA'] <- "Africa"  
#Micronesia, Federated States of.  overseas territory (or similar terminology) of usa
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="FSM" & tmp$GEOandUN_1=="North America" & tmp$ISO3_1=='USA'] <- "Asia + Pacific"  
#New caledonia overseas territory (or similar terminology) of france
tmp$GEOandUN_1[tmp$GEOandUNEP=="Asia + Pacific" & tmp$ISO3=="NCL" & tmp$GEOandUN_1=="Europe" & tmp$ISO3_1=='FRA'] <- "Asia + Pacific"  
#the mar and esp codes for marine area (in africa region) around some spanish islands (europe region) wasn't clear so left as it was left 


####
missing<-subset(tmp,tmp$GEOandUNEP!=tmp$GEOandUN_1)
droplevels(missing)
str(missing)
((missing[,c("GEOandUNEP","ISO3","GEOandUN_1","ISO3_1","AREA_GEO")])[order(missing$AREA_GEO),])

missing.agg<-aggregate(missing$AREA_GEO,by=list(missing$"GEOandUNEP", missing$"ISO3",missing$"GEOandUN_1",missing$"ISO3_1"),FUN=sum)
names(missing.agg)<-(c("GEOandUNEP","ISO3","GEOandUN_1","ISO3_1","AREA_GEO"))
head(missing.agg)
missing.agg[order(-missing.agg$AREA_GEO),]

sum(missing.agg$AREA_GEO)

missing.coverage<-unique(missing[,c("xy_join","AREA_GEO")])
sum(missing.coverage$AREA_GEO)

sum()
######################################################


#REGIONAL
tmp<-subset(tmp,tmp$GEOandUNEP==tmp$GEOandUN_1)
str(tmp$count)

#NATIONAL
tmp<-subset(tmp,as.character(tmp$ISO3batch)==as.character(tmp$ISO3_1))
          

tmp$GID<-0

tmp<-unique(tmp[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","GEOandUNEP","AREA_GEO","INSIDE_X","INSIDE_Y","xy_join","count")])
#tmp$DESIG_ENG[tmp$DESIG_TYPE=="National"] <- tmp$DESIG_TYPE

str(tmp)

#subset(tmp,tmp$ISO3batch=="")
summary(tmp$DESIG_ENG)
tmp$DESIG_ENG<-as.character(tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="National","National",tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="Regional","National",tmp$DESIG_ENG)
tmp$DESIG_ENG<-as.factor(tmp$DESIG_ENG)

reshapedTypeAll<-dcast(tmp,GID+GEOandUNEP+ISO3batch+INSIDE_X+INSIDE_Y+xy_join+AREA_GEO~DESIG_ENG,value.var="count",sum)



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
head(reshapedTypeAll[,8:(length(names(reshapedTypeAll)))])
#sum across rows for total count of desig
reshapedTypeAll$countSum <- rowSums(reshapedTypeAll[,8:(length(names(reshapedTypeAll)))])


########


######

setwd(out.folder)

#create a column for merging/joining datasets
#reshapedTypeAll$xy<-paste0(round(reshapedTypeAll$INSIDE_X,5),"_",round(reshapedTypeAll$INSIDE_Y,5))

head(reshapedTypeAll)
names(reshapedTypeAll)

#count(unique(reshapedTypeAll["xy"]))

fileTypeAll<-"reshapedTypeAll.csv"
names(reshapedTypeAll)
names(reshapedTypeAll[c(4,5,6,7,12)])
#saving to csv for joining to shapes
write.csv(reshapedTypeAll[c(4,5,6,7,12)],fileTypeAll,na="0",row.names=FALSE)


#getting rid of small polys fro alternative version
reshapedTypeAllSR<-subset(reshapedTypeAll,reshapedTypeAll$AREA_GEO>= 0.001)

fileTypeAllSR<-"reshapedTypeAllSR_reg_as_nat.csv"
head(reshapedTypeAllSR)


#saving to csv for joining to shapes
write.csv(reshapedTypeAllSR,fileTypeAllSR,na="0",row.names=FALSE)

view(reshapedTypeAllSR)


#subset(reshapedTypeAllSR,reshapedTypeAllSR$ISO3=="FRA")

head(reshapedTypeAllSR)


reshapedTypeAllSR_AGG<-aggregate(reshapedTypeAllSR[c(7)],by=list(reshapedTypeAllSR$"GEOandUNEP", reshapedTypeAllSR$"ISO3",reshapedTypeAllSR$"National",reshapedTypeAllSR$"Ramsar Site, Wetland of International Importance",
                                                                 reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"),FUN=sum)

head(reshapedTypeAllSR[c(7)])
head(reshapedTypeAllSR)
names(reshapedTypeAllSR)
dfLength<-(length(names(reshapedTypeAllSR)))
names(reshapedTypeAllSR_AGG)<-c(names(reshapedTypeAllSR[c(2,3)]), names(reshapedTypeAllSR[8:(dfLength-1)]),names(reshapedTypeAllSR[7]))
head(reshapedTypeAllSR_AGG)
#reshapedTypeAllSR_AGG$count<-reshapedTypeAllSR_AGG
reshapedTypeAllSR_AGG$countSum <- rowSums(reshapedTypeAllSR_AGG[,3:6])


fileTypeAllSR_AGG<-"reshapedTypeAllSR_AGG_reg_as_nat.csv"

write.csv(reshapedTypeAllSR_AGG,fileTypeAllSR_AGG,na="0",row.names=FALSE)



######################################
# 
# subset(reshapedTypeAllSR,reshapedTypeAllSR$INSIDE_X==-2571942.536844)
# head(subset(reshapedTypeAllSR,reshapedTypeAllSR$ISO3batch=="GRL"))
# subset(reshapedTypeAllSR,reshapedTypeAllSR$INSIDE_X<=--2569885 & reshapedTypeAllSR$INSIDE_X>=--2569886)
# 

# 
# tmp<-dataset2
# #REGIONAL
# str(tmp)
# 
# 
# str(tmp$count)
# 
# missing<-subset(tmp,tmp$GEOandUNEP!=tmp$GEOandUN_1)
# droplevels(missing)
# str(missing)
# 
# ((missing[,c("GEOandUNEP","GEOandUN_1","ISO3","ISO3_1","AREA_GEO")])[order(missing$AREA_GEO),])
# 
# 
# #NATIONAL
# str(subset(tmp,as.character(tmp$ISO3batch)==as.character(tmp$ISO3_1)))


