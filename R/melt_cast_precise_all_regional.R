#install.packages("sqldf")
#library(sqldf)
library(foreign)
#install.packages("reshape2")
library(reshape2)
library(plyr)
library(sp)  # raster data
library(rgdal)


###############
#single dataset 
in.folder<-"c:/Data/wdpa_desig/scratch/regional/output_fcs/merged"
out.folder<-in.folder


setwd(in.folder)
getwd()
dataset2<-read.csv("merged_aggsr_admin.csv")#header=TRUE,sep=",")

head(dataset2)
tmp<-dataset2
tmp$ISO3batch<-tmp$ISO3_1
tmp$count<-1
tmp<-unique(tmp[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","GEOandUNEP","AREA_GEO","INSIDE_X","INSIDE_Y","count")])
#tmp$DESIG_ENG[tmp$DESIG_TYPE=="regional"] <- tmp$DESIG_TYPE



#tmp<-subset(tmp,tmp$DESIG_ENG=="")

tmp<-subset(tmp,!(tmp$ISO3=="ATF" & tmp$GEOandUNEP=="Africa"))
tmp<-subset(tmp,!(tmp$ISO3=="UMI" & tmp$GEOandUNEP=="Asia + Pacific"))

######recoding missing iso3 for a polish site-------fixed so no need no
##subset(tmp,tmp$ISO3batch=="")

#tmp$ISO3batch<-as.character(tmp$ISO3batch)
#tmp$ISO3batch <- ifelse(tmp$ISO3batch=="","POL",tmp$ISO3batch)
#tmp$ISO3batch<-as.factor(tmp$ISO3batch)



#subset(tmp,tmp$ISO3batch=="")


summary(tmp$DESIG_ENG)
tmp$DESIG_ENG<-as.character(tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="regional","regional",tmp$DESIG_ENG)
tmp$DESIG_ENG <- ifelse(tmp$DESIG_TYPE=="Regional","regional",tmp$DESIG_ENG)
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



# (head(round(tmp$INSIDE_X,10)))
# x=tmp$INSIDE_X#round2(tmp$INSIDE_X,3)
# tail(formatC(x, format="f", digits=8))

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
names(reshapedTypeAll[c(4,5,6,16,17)])
#saving to csv for joining to shapes
write.csv(reshapedTypeAll[c(4,5,6,16,17)],fileTypeAll,na="0",row.names=FALSE)




#getting rid of small polys fro alternative version
reshapedTypeAllSR<-subset(reshapedTypeAll,reshapedTypeAll$AREA_GEO>= 0.001)

fileTypeAllSR<-"reshapedTypeAllSR_reg_as_nat.csv"
head(reshapedTypeAllSR)

#saving to csv for joining to shapes
write.csv(reshapedTypeAllSR,fileTypeAllSR,na="0",row.names=FALSE)


#subset(reshapedTypeAllSR,reshapedTypeAllSR$ISO3=="FRA")




head(reshapedTypeAllSR)

#merging columns
#reshapedTypeAllSR$other_regional<-reshapedTypeAllSR$"Specially Protected Area (Cartagena Convention)"+reshapedTypeAllSR$"Specially Protected Areas of Mediterranean Importance (Barcelona Convention)"+reshapedTypeAllSR$"Baltic Sea Protected Area (HELCOM)"
#reshapedTypeAllSR$"Specially Protected Area (Cartagena Convention)"<-NULL
#reshapedTypeAllSR$"Specially Protected Areas of Mediterranean Importance (Barcelona Convention)"<-NULL
#reshapedTypeAllSR$"Baltic Sea Protected Area (HELCOM)"<-NULL


###saving versoin with combined regional columns
#reshapedTypeAllSR[is.na(reshapedTypeAllSR)] <- 0
#fileTypeAllSR_regional_comb<-"reshapedTypeAllSR_regional_comb.csv"
#write.csv(reshapedTypeAllSR,fileTypeAllSR_regional_comb,na="0",row.names=FALSE)




#if (length(reshapedTypeAllSR$GID)>1){
# reshapedTypeAllSR_AGG<-aggregate(reshapedTypeAllSR[c(6)],by=list(reshapedTypeAllSR$"GEOandUNEP", reshapedTypeAllSR$"ISO3",reshapedTypeAllSR$"Baltic Sea Protected Area (HELCOM)",reshapedTypeAllSR$"regional",reshapedTypeAllSR$"Ramsar Site, Wetland of Interregional Importance",                  
#                                                                  reshapedTypeAllSR$"Site of Community Importance (Habitats Directive)",reshapedTypeAllSR$"Special Protection Area (Birds Directive)",                                   
#                                                                  reshapedTypeAllSR$"Specially Protected Area (Cartagena Convention)",reshapedTypeAllSR$"Specially Protected Areas of Mediterranean Importance (Barcelona Convention)",reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"
#                                                                  ),FUN=sum)
# 


#reshapedTypeAllSR_AGG<-aggregate(reshapedTypeAllSR[c(6)],by=list(reshapedTypeAllSR$"GEOandUNEP", reshapedTypeAllSR$"ISO3",reshapedTypeAllSR$"regional",reshapedTypeAllSR$"Ramsar Site, Wetland of Interregional Importance",                  
#                                                                 reshapedTypeAllSR$"Site of Community Importance (Habitats Directive)",reshapedTypeAllSR$"Special Protection Area (Birds Directive)", reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"
#                                                                 ,reshapedTypeAllSR$"other_regional"),FUN=sum)

reshapedTypeAllSR_AGG<-aggregate(reshapedTypeAllSR[c(6)],by=list(reshapedTypeAllSR$"GEOandUNEP", reshapedTypeAllSR$"ISO3",reshapedTypeAllSR$"regional",reshapedTypeAllSR$"Ramsar Site, Wetland of Interregional Importance",
                                                                 reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"),FUN=sum)



names(reshapedTypeAllSR)
dfLength<-(length(names(reshapedTypeAllSR)))
names(reshapedTypeAllSR_AGG)<-c(names(reshapedTypeAllSR[c(2,3)]), names(reshapedTypeAllSR[7:(dfLength-2)]),names(reshapedTypeAllSR[6]))
head(reshapedTypeAllSR_AGG)

fileTypeAllSR_AGG<-"reshapedTypeAllSR_AGG_reg_as_nat.csv"

write.csv(reshapedTypeAllSR_AGG,fileTypeAllSR_AGG,na="0",row.names=FALSE)

# mytable<-table(reshapedTypeAllSR$"Site of Community Importance (Habitats Directive)")
# mytable<-table(reshapedTypeAllSR$"regional",reshapedTypeAllSR$"Ramsar Site, Wetland of Interregional Importance",                  
#       reshapedTypeAllSR$"Site of Community Importance (Habitats Directive)",reshapedTypeAllSR$"Special Protection Area (Birds Directive)", reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"
#       ,reshapedTypeAllSR$other_regional,reshapedTypeAllSR$"regional",reshapedTypeAllSR$"Ramsar Site, Wetland of Interregional Importance",                  
# #       reshapedTypeAllSR$"Site of Community Importance (Habitats Directive)",reshapedTypeAllSR$"Special Protection Area (Birds Directive)", reshapedTypeAllSR$"UNESCO-MAB Biosphere Reserve",reshapedTypeAllSR$"World Heritage Site"
# #       ,reshapedTypeAllSR$other_regional)
#   
# plot (mytable)
#       
# #reshapedTypeAllSR$"Special Protection Area (Birds Directive)") 
# 
# plot(fileTypeAllSR_AGG)
# 
# 
# 
# 
# Here is an entirely vectorised solution using expand.grid to compute indices and colSums and matrix to wrap up the result.
# 
# #  Some reproducible 6x6 sample data
# set.seed(1)
# 
# s <- sum(matrix[,1]==matrix[,2])
# my_data<-reshapedTypeAllSR
# matrix <- cor(my_data)

#}

       #     reshapedTypeAllSR_AGG$int<-NULL
  #     reshapedTypeAllSR_AGG$reg<-NULL
  #     reshapedTypeAllSR_AGG$nat<-NULL
  #     reshapedTypeAllSR_AGG$countSum<-NULL
  #     reshapedTypeAllSR_AGG$GID<-NULL
  #   
  #   colnames(reshapedTypeAllSR_AGG)<-c("int","reg","nat","countSum","AREA_GEO")
  #   } else {
  #     reshapedTypeAllSR_AGG<-reshapedTypeAllSR[c(1,5:9)]


# setwd("C:/Data/wdpa_desig/scratch/regional/precise_int_dbfs")
# out.folder<-("C:/Data/wdpa_desig/scratch/regional/precise_reshape_dbfs")
# out.folder2<-("C:/Data/wdpa_desig/scratch/regional/precise_reshape_dbfs_sr")


# ##import look up table csv derived from desig-eng and desig_type columns in WDPA
# desigTypeLUT<-read.csv("C:/Data/wdpa_desig/scratch/lookup_tables/wdpa_attr.csv")
# desigTypeLUT<-(desigTypeLUT[,1:2])
# desigTypeLUT<-subset(desigTypeLUT,!desig_type=="")
# desigTypeLUT<-droplevels(desigTypeLUT)
# tail(desigTypeLUT)
# levels(desigTypeLUT$desig_type)
# 
# # listDBF=list.files(getwd(),full.names=TRUE)
# # listDBF
# getwd()
# 
# filenames <- Sys.glob("*.dbf")
# filenames
# 
# #length<-1
# #
# 
# filenames<-filenames[lapply(filenames,function(x) length(grep("AdminIntUnion",x,value=FALSE))) == 1]
# length(filenames)
# fName<-filenames[2:2]
# fName[1]
#  f<-read.dbf(fName)
# head(f)
# f$ISO3batch<-substr(fName, 0, 3)
# f$count<-1
# f<-unique(f[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","AREA_GEO","INSIDE_X","INSIDE_Y","count")])
# head(f)
# reshapedf<-dcast(f,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_ENG,value.var="count",sum)
# # 
# # head(reshapedf)
# 
# filenames[1]
# 

# ###############################
# #loop through and unpivot tables and save as csvs (according to names from edited list above)in the output folder
# for (i in 1:1){#length(filenames)){
#   fname<-filenames[i]
#   #fname<-
#   #iso3<-"AUS"
#   #fname<-paste0(iso3,"_preciseAdminIntUnionFC.dbf")
#   print (fname)
#   tmp = read.dbf(fname)
#   tmp$ISO3batch<-substr(fname, 0, 3)
#   tmp$count<-1
#   
#   length (unique(tmp$ISO3))
#   tmp<-unique(tmp[c("GID","DESIG_ENG","DESIG_TYPE","ISO3batch","AREA_GEO","INSIDE_X","INSIDE_Y","count")])
#   reshaped<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_ENG,value.var="count",sum)
#   #getting values for internation, regional and regional
#   reshapedType<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_TYPE,value.var="count",sum)
#   reshapedType<-dcast(tmp,GID+ISO3batch+INSIDE_X+INSIDE_Y+AREA_GEO~DESIG_TYPE+DESIG_ENG,value.var="count",sum)
#   head(reshaped)
#   head(reshapedType)
#   reshapedType$int<-0
#   reshapedType$reg<-0
#   reshapedType$nat<-0
#   
#   if("Interregional" %in% colnames(reshapedType))
#   {
#     reshapedType$int<-reshapedType$Interregional
#     reshapedType$Interregional<-NULL
#   }
#   if("Regional" %in% colnames(reshapedType))
#   {
#     reshapedType$reg<-reshapedType$Regional
#     reshapedType$Regional<-NULL
#   }
# 
#   if("regional" %in% colnames(reshapedType))
#   {
#     reshapedType$nat<-reshapedType$regional
#     reshapedType$regional<-NULL
#   }
#   
#   #print (head(reshaped))
#   #if only one extra column (i.e. has 6 columns then don't sum accross them as there is only one to sum)
#   if (length(names(reshaped))==6) {
#     colnames(reshaped)[6]<-"countSum"
#   } else {reshaped$countSum <- rowSums( reshaped[,6:length(names(reshaped))] )
#   }
# 
#   
#   ####interregional replacements####
#   if("World Heritage Site" %in% colnames(reshaped))
#   {
#     
#     reshaped$whsCount<-reshaped$"World Heritage Site"
#   } else 
#   {
#     reshaped$whsCount<-0  
#   }
#   if("Ramsar Site, Wetland of Interregional Importance" %in% colnames(reshaped))
#   {
#     
#     reshaped$rmsrCount<-reshaped$"Ramsar Site, Wetland of Interregional Importance"
#   } else 
#   {
#     reshaped$rmsrCount<-0  
#   }
#   if("UNESCO-MAB Biosphere Reserve" %in% colnames(reshaped))
#   {
#     reshaped$mabCount<-reshaped$"UNESCO-MAB Biosphere Reserve"
#   } else 
#   {
#     reshaped$mabCount<-0  
#   }
# 
#   ####regional replacements####
#   
#   
#   if("Baltic Sea Protected Area (HELCOM)" %in% colnames(reshaped))
#   {
#     
#     reshaped$helcomCount<-reshaped$"Baltic Sea Protected Area (HELCOM)"
#   } else 
#   {
#     reshaped$helcomCount<-0  
#   }
#   
#   
#   if("Marine Protected Area (CCAMLR)" %in% colnames(reshaped))
#   {
#     
#     reshaped$CCAMLRCount<-reshaped$"Marine Protected Area (CCAMLR)"
#   } else 
#   {
#     reshaped$CCAMLRCount<-0  
#   }
#   
#   
#   if("Marine Protected Area (OSPAR)" %in% colnames(reshaped))
#   {
#     
#     reshaped$OSPARCount<-reshaped$"Marine Protected Area (OSPAR)"
#   } else 
#   {
#     reshaped$OSPARCount<-0  
#   }
#   
#   
#   if("Site of Community Importance (Habitats Directive)" %in% colnames(reshaped))
#   {
#      
#      reshaped$habdirCount<-reshaped$"Site of Community Importance (Habitats Directive)"
#   } else 
#   {
#     reshaped$habdirCount<-0  
#   }
# 
# 
#   if("Special Protection Area (Birds Directive)" %in% colnames(reshaped))
#   {
#     reshaped$spabdCount<-reshaped$"Special Protection Area (Birds Directive)"
#   } else 
#   {
#     reshaped$spabdCount<-0  
#   }
# 
# 
#   if("Specially Protected Area (Cartagena Convention)" %in% colnames(reshaped))
#   {
#     
#     reshaped$spaccCount<-reshaped$"Specially Protected Area (Cartagena Convention)"
#   } else 
#   {
#     reshaped$spaccCount<-0  
#   }
#   if("Specially Protected Areas of Mediterranean Importance (Barcelona Convention)" %in% colnames(reshaped))
#   {
#     reshaped$spabcCount<-reshaped$"Specially Protected Areas of Mediterranean Importance (Barcelona Convention)"
#   } else 
#   {
#     reshaped$spabcCount<-0  
#   }
#   
# ##### regional end ######
#   colNum<-which( colnames(reshaped)=="countSum" )
#   reshaped$nat <- (reshaped$countSum) - (rowSums(reshaped[,(colNum+1):length(names(reshaped))]))
#   reshaped$reg <- (rowSums(reshaped[,(colNum+4):(length(names(reshaped))-1)]))
#   reshaped$int <- (rowSums(reshaped[,(colNum+1):(colNum+3)]))
#   
#   reshapedType2<-reshaped[,-c(6:(colNum-1))]
# 
# 
#   reshapedType$countSum <- rowSums( reshapedType[,6:length(names(reshapedType))])
#   
# #getting rid of small polys fro alternative version
# reshapedTypeSR<-subset(reshapedType,reshapedType$AREA_GEO>= 0.001)
# reshapedSR<-subset(reshaped,reshaped$AREA_GEO>= 0.001)
# #finding max overlap in a grid cell
# #if only one row then skip aggregating
# if (length(reshaped$GID)>1){
#   reshapedMax<-aggregate(reshaped,by=list(reshaped$GID),FUN=max)
# } else {
#   reshapedMax<-reshaped
# }
# 
# reshapedMax<-reshapedMax[,c("GID","countSum")]
# #if only one row then skip aggregating
# if (length(reshapedSR$GID)>1){
#   reshapedMaxSR<-aggregate(reshapedSR,by=list(reshapedSR$GID),FUN=max)
# } else {
#     reshapedMaxSR<-reshapedSR
#   }
#   reshapedMaxSR<-reshapedMaxSR[,c("GID","countSum")]
#   #if only one row then skip aggregating
#   if (length(reshapedSR$GID)>1){
#     reshapedTypeSR_AGG<-aggregate(reshapedTypeSR[c(1,5:9)] ,by=list(reshapedTypeSR$int,reshapedTypeSR$reg,reshapedTypeSR$nat,reshapedTypeSR$countSum),FUN=sum)
#     reshapedTypeSR_AGG$int<-NULL
#     reshapedTypeSR_AGG$reg<-NULL
#     reshapedTypeSR_AGG$nat<-NULL
#     reshapedTypeSR_AGG$countSum<-NULL
#     reshapedTypeSR_AGG$GID<-NULL
#   
#   colnames(reshapedTypeSR_AGG)<-c("int","reg","nat","countSum","AREA_GEO")
#   } else {
#     reshapedTypeSR_AGG<-reshapedTypeSR[c(1,5:9)]
#   }
#   head(reshapedTypeSR_AGG)
#   reshapedTypeSR_AGG$ISO3batch<-substr(filenames[i], 0, 3)
#   if (exists("reshapedTypeSR_AGG$Na")){
#     reshapedTypeSR_AGG$Na<-NULL
#   }
#   #reshapedTypeSR_AGG$percent<-reshapedTypeSR_AGG$AREA_GEO/sum(reshapedTypeSR_AGG$AREA_GEO))*100
#   ###saving
#   paste0(out.folder,"/",filenames[i])
#   fileInt<-gsub(".dbf",".csv",paste0("int_",filenames[i]))
#   fileInt<-paste0(out.folder,"/",fileInt)
#   write.csv(reshaped,fileInt,na="0",row.names=FALSE)
#   fileSum<-gsub(".dbf",".csv",paste0("sum_",filenames[i]))
#   fileSum<-paste0(out.folder,"/",fileSum)
#   write.csv(reshapedMax,fileSum,na="0",row.names=FALSE )
#   fileType<-gsub(".dbf",".csv",paste0("type_",filenames[i]))
#   fileType<-paste0(out.folder,"/",fileType)
#   write.csv(reshapedType,fileType,na="0",row.names=FALSE )
#   ##saving versions with small polygons (slithers) removed
#   #paste0(out.folder2,"/",filenames[i])
#   fileIntSR<-gsub(".dbf",".csv",paste0("int_",filenames[i]))
#   fileIntSR<-paste0(out.folder2,"/",fileIntSR)
#   write.csv(reshapedSR,fileIntSR,na="0",row.names=FALSE)
#   fileSumSR<-gsub(".dbf",".csv",paste0("sum_",filenames[i]))
#   fileSumSR<-paste0(out.folder2,"/",fileSumSR)
#   write.csv(reshapedMaxSR,fileSumSR,na="0",row.names=FALSE )
#   fileTypeSR<-gsub(".dbf",".csv",paste0("type_",filenames[i]))
#   fileTypeSR<-paste0(out.folder2,"/",fileTypeSR)
#   write.csv(reshapedTypeSR,fileTypeSR,na="0",row.names=FALSE )
#   fileTypeSR_AGG<-gsub(".dbf",".csv",paste0("agg_type_",filenames[i]))
#   fileTypeSR_AGG<-paste0(out.folder2,"/",fileTypeSR_AGG)
#   write.csv(reshapedTypeSR_AGG,fileTypeSR_AGG,na="0",row.names=FALSE )
#   print(i)
#   print(fileInt)
# }
#   
# 
# 
# 
# 
