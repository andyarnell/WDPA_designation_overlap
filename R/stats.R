stat<-read.csv("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/marine/output_fcs/merged_textfiles/merged_fcs_non_unique.csv")
stat<-read.csv("C:/Data/wdpa_desig/scratch/both_scales_dt_erase/land/output_fcs/merged_textfiles/merged_fcs_non_unique.csv")
names(stat)
stat.uniq<-unique(stat[,c("WDPAID","GEOandUNEP")])
head(stat.uniq)
head(stat)
aggregate(stat.uniq$WDPAID~stat.uniq$GEOandUNEP,data=stat.uniq,FUN=count)

aggregate(stat.uniq$WDPAID, by=stat.uniq$GEOandUNEP,FUN=count)

count.region<-summary(stat.uniq$GEOandUNEP)
count.region

