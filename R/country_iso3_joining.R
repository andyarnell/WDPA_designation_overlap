in.iso3<-read.csv("C:/Data/wdpa_desig/land_iso3.csv")
in.iso3<-read.csv("C:/Data/wdpa_desig/marine_iso3.csv")

in.iso3<-data.frame(in.iso3)

head(in.iso3)

iso3.lut<-unique(stat[,c("Name","ISO3_edt")])

iso3.out<-merge(in.iso3,iso3.lut,by.x="iso3",by.y="ISO3_edt",all.x=TRUE)
names(iso3.lut)

head(iso3.out)




iso3.out.sort<-iso3.out[order(iso3.out$region,iso3.out$iso3),]

write.csv(iso3.out.sort,"C:/Data/wdpa_desig/land_iso3_out.csv")
write.csv(iso3.out.sort,"C:/Data/wdpa_desig/marine_iso3_out.csv")
