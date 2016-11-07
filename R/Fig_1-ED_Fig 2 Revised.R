wants <- c("rgeos", "rgdal", "maptools","RColorBrewer","raster","spdep")
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])
has <- wants %in% .packages()
for(p in wants[!has]) library(p,character.only = T)

add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}


normalise_ogm_set_b <- function(v,b, labels)
{
  #na.v.i = which(v == -1.0)
  #v = log(v)
  v[is.infinite(v)] = NA
  # v[v < 0] = NA

  v.norm = as.integer(cut(v,breaks=b))
  
  v.norm[is.na(v.norm)] = 0.0
  #   v.norm = (v.norm/max(v.norm))
  #   v.norm = v.norm * 10
  return(list(v.norm,labels))
}

normalise_ogm_mines_set_b <- function(v,b, labels)
{
  #na.v.i = which(v == -1.0)
  #v = log(v)
  v[is.infinite(v)] = NA
  
  v.norm = as.integer(cut(v,breaks=b))
  
  v.norm[is.na(v.norm)] = 0.0
  v.norm = v.norm-1.0
  
  return(list(v.norm,labels))
}


normalise_ogm <- function(v,b,density,log)
{
  #na.v.i = which(v == -1.0)
  #v = log(v)
  v[is.infinite(v)] = NA
  # v[v < 0] = NA
  brks.v = quantile(v,probs = b,na.rm = T)
  brks.v = unique(brks.v)
  print(brks.v)
  if(log)
  {
    label.brks = exp(brks.v)
  }
  else
  {
    label.brks = (brks.v)
  }
  if(density)
  {
    #temp = format(label.brks/cell.area,big.mark=",",trim=T,digits= 1,scientific=F)
    labels = rep("",length(label.brks)-1)
    for(i in 1:length(label.brks)-1)
    {
      labels[i] = paste(format(label.brks[i]/cell.area,big.mark=",",trim=T,digits= 2,scientific=F)
                        ,"\n to \n",
                        format(label.brks[i+1]/cell.area,big.mark=",",trim=T,digits= 2,scientific=F))
    }
  }
  else
  {
    #temp = format(label.brks,big.mark=",",trim=T, digits = 1,scientific=F)
    labels = rep("",length(label.brks)-1)
    for(i in 1:length(label.brks)-1)
    {
      labels[i] = paste(format(label.brks[i],big.mark=",",trim=T, digits = 2,scientific=F)
                        ,"\n to \n",
                        format(label.brks[i+1],big.mark=",",trim=T, digits = 2,scientific=F))
    }
  }
  
  #v.norm = as.integer(cut(v,breaks=brks.v))
  v.norm = as.integer(cut(v,breaks=brks.v))
  
  v.norm[is.na(v.norm)] = 0.0
  #   v.norm = (v.norm/max(v.norm))
  #   v.norm = v.norm * 10
  return(list(v.norm,labels))
}

normalise_ogm_mines <- function(v,b,density,log)
{
  #na.v.i = which(v == -1.0)
  #v = log(v)
  v[is.infinite(v)] = NA
  # v[v < 0] = NA
  brks.v = quantile(v,probs = b,na.rm = T)
  brks.v = unique(brks.v)
  print(brks.v)
  if(log)
  {
    label.brks = exp(brks.v)
    v = v + 1
  }
  else
  {
    label.brks = (brks.v)
  }
  if(density)
  {
    #temp = format(label.brks/cell.area,big.mark=",",trim=T,digits= 1,scientific=F)
    labels = rep("",length(label.brks)-1)
    for(i in 1:length(label.brks)-1)
    {
      labels[i] = paste(format(label.brks[i]/cell.area,big.mark=",",trim=T,digits= 2,scientific=F)
                        ,"\n to \n",
                        format(label.brks[i+1]/cell.area,big.mark=",",trim=T,digits= 2,scientific=F))
    }
  }
  else
  {
    #temp = format(label.brks,big.mark=",",trim=T, digits = 1,scientific=F)
    labels = rep("",length(label.brks)-1)
    for(i in 1:length(label.brks)-1)
    {
      labels[i] = paste(format(label.brks[i],big.mark=",",trim=T, digits = 2,scientific=F)
                        ,"\n to \n",
                        format(label.brks[i+1],big.mark=",",trim=T, digits = 2,scientific=F))
    }
  }
  
  #v.norm = as.integer(cut(v,breaks=brks.v))
  v.norm = as.integer(cut(v,breaks=brks.v))
  
  v.norm[is.na(v.norm)] = 0.0
  v.norm = v.norm-1.0
  #   v.norm = (v.norm/max(v.norm))
  #   v.norm = v.norm * 10
  return(list(v.norm,labels))
}

w.wout.infrastructure.boxplot<-function(inds, o, b, add,x1,x2,xlims,ylims,ticks,add.signif)
{
  no.infr.i <- which((master[inds,ogm.cols[[o]]]) == 0 & master[inds,bd.cols[[b]]] > 0)
  no.infr.quants <- quantile(master[inds[no.infr.i],bd.cols[[b]]],probs = c(0.025,0.975),na.rm=T)
  
  bp = boxplot(master[inds[no.infr.i],bd.cols[[b]]],
               range=0,log="y",add=add, at = x1,
               ylims = ylims, xlims = xlims,yaxt=ticks,
               col = "#e3d7b6",cex.axis=0.7,lwd=1, plot=F)
  bp$stats[c(1,5),1] = no.infr.quants
  bxp(bp,
               range=0,log="y",add=add, at = x1,
               ylims = ylims, xlims = xlims,axes=F,
               boxfill = "#e3d7b6",cex.axis=0.7,lwd=1, show.names=T)
  
  
  w.infr.i<-which(master[inds,ogm.cols[[o]]] > 0 & master[inds,bd.cols[[b]]] > 0)
  w.infr.quants <- quantile(master[inds[w.infr.i],bd.cols[[b]]],probs = c(0.025,0.975),na.rm=T)
  
  median.1 = median(master[inds[no.infr.i],bd.cols[[b]]])
  median.2 = median(master[inds[w.infr.i],bd.cols[[b]]])
  
  col = ifelse(median.2 < median.1,"dark red","black")
  
  bp<-boxplot(master[inds[w.infr.i],bd.cols[[b]]],
              range = 0,log="y",add=T, at = x2,
              ylims = ylims,xlims = xlims,yaxt=ticks,border = col,
              col="#968b69",cex.axis=0.7,lwd=1, plot=F)
  bp$stats[c(1,5),1] = w.infr.quants
  bxp(bp,range = 0,log="y",add=T, at = x2,
      ylims = ylims,xlims = xlims,axes=F,boxcol = col,
      boxfill="#968b69",border=col,cex.axis=0.7,lwd=1, show.names=T)
  ret<-NA
  if(add.signif && length(no.infr.i) > 0 && length(w.infr.i) > 0 &&
       sum(is.na(master[inds[no.infr.i],bd.cols[[b]]]) < length(no.infr.i)) &&
       sum(is.na(master[inds[w.infr.i],bd.cols[[b]]]) < length(w.infr.i)))
  {
  #   ret<-wilcox.test(master[inds[no.infr.i],bd.cols[[b]]],master[inds[w.infr.i],bd.cols[[b]]])$p.value
  
  
    
    df.mod = data.frame(c(master[inds[no.infr.i],bd.cols[[b]]],
                          master[inds[w.infr.i],bd.cols[[b]]]))
    names(df.mod) = "bd"
    df.mod$label = c(rep(1,length(no.infr.i)),rep(2,length(w.infr.i)))
    df.mod$Longitude = c(master$Longitude[inds[no.infr.i]],master$Longitude[inds[w.infr.i]])
    df.mod$Latitude = c(master$Latitude[inds[no.infr.i]],master$Latitude[inds[w.infr.i]])
    
    n.zeroes = 1
    n = 0
    
    while(n.zeroes > 0 && n < 1E6)
    {
      n = n + 2000
      print(paste("Finding min distance: ",n))
      neighbourhood = dnearneigh(cbind(df.mod$Longitude,df.mod$Latitude),0,n,longlat = T)
      n.zeroes = sum(unlist(lapply(neighbourhood,function (x) x[1])) == 0)
    }
    n.min = n
    
    n2 = nb2listw(neighbourhood,glist = NULL, style = "W",zero.policy = T)
    
    m1= lm(bd ~ label, df.mod)
    m2 = errorsarlm(bd ~ label, data = df.mod, zero.policy = T, n2)
    
    moran1 = moran.test(residuals(m1),n2)
    moran2 = moran.test(residuals(m2),n2)
    
    ret = list(m1 = m1,
               m2 = m2,
               moran1 = moran1,
               moran2 = moran2)
    
  }
  if(b == 1) sig.scalar = 1.2
  if(b == 3) sig.scalar = 1.3
  
  if(add.signif && !is.na(ret))
  {
    signif.val = summary(ret$m2)[[46]][2,4]
    
    text(x1+0.5,ylims[2]*sig.scalar,as.character(symnum(signif.val, corr=FALSE,
                                                      cutpoints = c(0,  .001,.01,.05, .1, 1),
                                                      symbols = c("***","**","*","."," "))),
                                       cex=1.2,
                                       col = col)
  }
    
  return(ret)
}

w.any.realm.wout.infrastructure.boxplot<-function(inds, o, b, add,x1,x2,xlims,ylims,ticks,add.signif)
{
  no.infr.i <- which((master[inds,ogm.cols[[o]]]) == 0 & master[inds,bd.cols[[b]]] > 0)
  no.infr.quants <- quantile(master[inds[no.infr.i],bd.cols[[b]]],probs = c(0.025,0.975),na.rm=T)
  
  bp = boxplot(master[inds[no.infr.i],bd.cols[[b]]],
               range=0,log="y",add=add, at = x1,
               ylims = ylims, xlims = xlims,yaxt=ticks,
               col = "#e3d7b6",cex.axis=0.7,lwd=1, plot=F)
  bp$stats[c(1,5),1] = no.infr.quants
  bxp(bp,
      range=0,log="y",add=add, at = x1,
      ylims = ylims, xlims = xlims,axes=F,
      boxfill = "#e3d7b6",cex.axis=0.7,lwd=1, show.names=T)
  
  
  w.infr.i<-which(master[,ogm.cols[[o]]] > 0 & master[,bd.cols[[b]]] > 0)
  w.infr.quants <- quantile(master[w.infr.i,bd.cols[[b]]],probs = c(0.025,0.975),na.rm=T)
  
  median.1 = median(master[inds[no.infr.i],bd.cols[[b]]])
  median.2 = median(master[w.infr.i,bd.cols[[b]]])
  
  col = ifelse(median.2 < median.1,"dark red","black")
  
  bp<-boxplot(master[w.infr.i,bd.cols[[b]]],
              range = 0,log="y",add=T, at = x2,
              ylims = ylims,xlims = xlims,yaxt=ticks,border = col,
              col="#968b69",cex.axis=0.7,lwd=1, plot=F)
  bp$stats[c(1,5),1] = w.infr.quants
  bxp(bp,range = 0,log="y",add=T, at = x2,
      ylims = ylims,xlims = xlims,axes=F,boxcol = col,
      boxfill="#968b69",border=col,cex.axis=0.7,lwd=1, show.names=T)
  ret<-NA
  if(length(no.infr.i) > 0 && length(w.infr.i) > 0 &&
       sum(is.na(master[inds[no.infr.i],bd.cols[[b]]]) < length(no.infr.i)) &&
       sum(is.na(master[w.infr.i,bd.cols[[b]]]) < length(w.infr.i)))
  {
    ret<-wilcox.test(master[inds[no.infr.i],bd.cols[[b]]],master[w.infr.i,bd.cols[[b]]])$p.value
  }
  
  if(b == 1) sig.scalar = 1.2
  if(b == 3) sig.scalar = 1.3
  
  
  if(add.signif && !is.na(ret)) text(x1+0.5,ylims[2]*sig.scalar,as.character(symnum(ret, corr=FALSE,
                                                                                    cutpoints = c(0,  .001,.01,.05, .1, 1),
                                                                                    symbols = c("***","**","*","."," "))),
                                     cex=1.2,
                                     col = col)
  
  return(ret)
}



#Specify the input directory
indsn="C:/Users/mikeha/Work/Fossil Fuels and biodiversity/"
wgs1984.proj <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
moll.proj <- CRS("+proj=moll +datum=WGS84")


WL <- readShapePoly("C:/Users/mikeha/Work/Spatial data/natural-earth-vector-master/natural-earth-vector-master/10m_physical/ne_10m_land.shp")#download from 'naturalearth.com'
proj4string(WL) <- wgs1984.proj  
WL.moll <- spTransform(WL, moll.proj)

world<-readShapeSpatial("C:/Users/mikeha/Dropbox/World countries/outline_clip")
proj4string(world) = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"


#comb.shp.name = "BD_Realm_OGM_Realm_Continent_no_dup"
comb.shp.name = "BD_Realm_OGM_Realm_Continent_no_dup_all_well_count_conc_1"

comb = readShapeSpatial(paste(indsn,"Combined/",comb.shp.name,sep=""),
                        repair=T,delete_null_obj=T, force_ring = F)

proj4string(comb) = "+proj=moll +datum=WGS84"

# Don't transform plot as equal area projection
# comb = spTransform(comb,CRS(proj4string(world)))
# proj4string(comb) = proj4string(world)
# Transform the world outline
world = spTransform(world,CRS(proj4string(comb)))
proj4string(world) = proj4string(comb)

shp.un.regions = readShapeSpatial("c:/Users/mikeha/Work/Fossil Fuels and Biodiversity/UNEP regions/UNEP_regions_multi.shp",
                                  repair=T,delete_null_obj=T, force_ring = F)
proj4string(shp.un.regions) = CRS("+init=epsg:4326")
shp.un.regions = spTransform(shp.un.regions,CRS("+proj=moll +ellps=WGS84"))

shp.un.countries = readShapeSpatial("c:/Users/mikeha/Work/Fossil Fuels and Biodiversity/UNEP regions/EEZv8_UNEP_Countries.shp",
                                  repair=T,delete_null_obj=T, force_ring = F)
proj4string(shp.un.countries) = CRS("+init=epsg:4326")
shp.un.countries = spTransform(shp.un.countries,CRS("+proj=moll +ellps=WGS84"))

outdir = "C:/Users/mikeha/Google Drive/Fossil Fuels and biodiversity/Figures/"

wgs1984.proj <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

comb.wgs = spTransform(comb,wgs1984.proj)

comb.wgs.pts = gCentroid(comb.wgs,byid=T)

comb$Latitude = coordinates(comb.wgs.pts)[,2]
comb$Longitude = coordinates(comb.wgs.pts)[,1]



#master<-read.csv(paste(indsn,"Combined/",comb.shp.name,".csv",sep=""))
master<-comb@data

master$InvArea[which(master$InvArea < 0.0)] = 0.0
#Convert from per m2 to per 1000 km2
master$InvArea = master$InvArea * 1E9

hs.inds = which(master$Realm_1 == 0)
terr.inds = which(master$Realm_1 == 1)
eez.inds = which(master$Realm_1 == 2)
ant.inds = which(master$Realm_1 == 3)
mar.inds<-c(hs.inds,eez.inds)

continents = as.character(unique(master$CONTINENT))
continents = continents[!(continents == " ") & !(continents == "Antarctica")]

continents.inds = sapply(continents,function(x) which(master$CONTINENT == x & master$Realm_1 == 1))


#Realm labels
realm.labels = c("Terrestrial","High Seas","EEZ","Antarctica","Global")

#Find the columns corresponding to each category of ogm data
ogm.colnames = c("Count_","Count_1","Count_2","sum_counts","sum_length")
ogm.labels= c("Wells","Coal mines","Refineries","Wells,mines & refineries",
              "Pipeline length","Field area ","Fut. field area")



#add colume for well, refineries and pipelines
master$w_r_p_m = rowSums(master[,c("Count_","Count_2", "sum_length","prdcoalcnt")])
ogm.colnames = c(ogm.colnames,"w_r_p_m")
ogm.cols = sapply(ogm.colnames, function(x) which(colnames(master) == x))

master$w_r_p = rowSums(master[,c("Count_","Count_2", "sum_length")])
ogm.colnames = c(ogm.colnames,"w_r_p")
ogm.cols = sapply(ogm.colnames, function(x) which(colnames(master) == x))

ogm.colnames = c(ogm.colnames,"prdcoalcnt")
ogm.cols = sapply(ogm.colnames, function(x) which(colnames(master) == x))

ogm.colnames = c(ogm.colnames,"validblkar")
ogm.cols = sapply(ogm.colnames, function(x) which(colnames(master) == x))



bd.colnames = c("SpCount","SumInvArea","InvArea","MaxInvArea","MinInvArea")
bd.labels = c("Assessed Spp. richness", "Sum RR","Assessed Spp. mean range rarity", "Max RR", "Min RR")
bd.cols = sapply(bd.colnames, function(x) which(colnames(master) == x))

wilcox.test.outputs<-array(NA, dim=c(length(ogm.colnames),length(bd.colnames),12))





# Construct map of the bd in question -------------------------------------


cell.area = 50*50 #km2
def.breaks <- seq(0,1,length.out = 10)
def.breaks <-c(0,0.5,0.75,0.9,0.95,0.96,0.97,0.98,0.99,1.0)

wells = comb@data$Count_
wells.breaks = c(0.99,30,1000,3000,8000,68000)
wells.labels = c("1\n to \n<30","30\n to \n<1,000","1,000\n to \n<3,000","3,000\n to \n<8,000",">8,000")
wells.norm = normalise_ogm_set_b(wells,wells.breaks, wells.labels)

#def.breaks <- seq(0,1,length.out = 20)
refineries = log(comb@data$Count_2)
refineries.norm = normalise_ogm(refineries,def.breaks,F,T)

pipes = (comb@data$sum_length)
pipes.breaks = c(1E-3,200,700,1000,2000,8500)
pipes.labels = c(">0\n to \n<200","200\n to \n<700","700\n to \n<1,000","1,000\n to \n<2,000",">2,000")
pipes.norm = normalise_ogm_set_b(pipes, pipes.breaks, pipes.labels)

exploited.fields = comb@data$Sum_Area
exploited.fields[which(exploited.fields > 2500.0)] = 2500.0
# exploited.fields = log(exploited.fields)
fields.breaks = c(1E-3,50,250,700,1500,2600)
fields.labels = c(">0\n to \n<50","50\n to \n<250","250\n to \n<700","700\n to \n<1,500",">1,500")
exploited.fields.norm = normalise_ogm_set_b(exploited.fields, fields.breaks,fields.labels)

unexploited.fields = comb@data$Sum_Area_1
unexploited.fields[which(unexploited.fields > 2500.0)] = 2500.0
# unexploited.fields = log(unexploited.fields)
unexploited.fields.norm = normalise_ogm_set_b(unexploited.fields, fields.breaks, fields.labels)

valid.blocks = comb@data$validblkar
# valid.blocks = log(valid.blocks)
blocks.breaks = c(1E-3,500,1000,1500,2000,2500)
blocks.labels = c(">0\n to \n<500","500\n to \n<1,000","1,000\n to \n<1,500","1,500\n to \n<2,000",">2,000")
valid.blocks.norm = normalise_ogm_set_b(valid.blocks, blocks.breaks,blocks.labels)

bid.blocks = comb@data$bidblkarea
#bid.blocks[which(bid.blocks > 2500.0)] = 2500.0
# bid.blocks = log(bid.blocks)
bid.blocks.norm = normalise_ogm_set_b(bid.blocks, blocks.breaks,blocks.labels)

prd.mines = comb@data$prdcoalcnt 
# prd.mines = log(prd.mines)
mines.breaks = c(0,1,2,4,6,8,18)
mines.labels = c("1\n to \n<2","2\n to \n<4","4\n to \n<6","6\n to \n<8",">8")
prd.mines.norm = normalise_ogm_set_b(prd.mines,mines.breaks,mines.labels) 

exp.mines = comb@data$explcoalcn
# exp.mines = log(exp.mines)
exp.mines.norm = normalise_ogm_set_b(exp.mines, mines.breaks,mines.labels)


sr.breaks <-c(0,1,25,50,100,350,600,850,1100,1350,1600)
sr.labels<-c("1\n to \n<25","25\n to \n<50","50\n to \n<100","100\n to \n<350","350\n to \n<600","600\n to \n<850","850\n to \n<1,100","1,100","1,100\n to \n<1,350",">1,350")


sr.breaks <-c(0.9,10,20,30,45,
              60,100,250,500,
              750,1000,2000)
sr.labels<-c("1\n to \n<10",
             "10\n to \n<20",
             "20\n to \n<30",
             "30\n to \n<45",
             "45\n to \n<60",
             "60\n to \n<100",
             "100\n to \n<250",
             "250\n to \n<500",
             "500\n to \n<750",
             "750\n to \n<1,000",
             ">1,000")

n.breaks = 100


sr = (comb@data$SpCount)
sr.breaks = c(seq(0,1100,length.out = n.breaks-1),range(sr)[2])
sr.norm = normalise_ogm_set_b(sr, sr.breaks,sr.labels)

rr.breaks<-c(0,1E-9,1E-5,1E-4,2.5E-4,5E-4,7.5E-4,1E-3,1E-2,1E-1,1E9)
rr.labels<-c(">0\n to \n<0.00001",
             "0.00001\n to \n<0.0001",
             "0.0001\n to \n<0.00025",
             "0.00025\n to \n<0.0005",
             "0.0005\n to \n<0.00075",
             "0.00075\n to \n<0.001",
             "0.001\n to \n<0.01",
             "0.01\n to \n<0.1",
             ">0.1")
rr = 1E9*comb@data$InvArea
rr = log(rr)
rr[is.infinite(rr)] = NA
rr.up.val = -2.5
rr.breaks = c((seq(range(rr,na.rm = T)[1],rr.up.val, length.out = n.breaks-1)),
              range(rr,na.rm = T)[2])

# rr.breaks = c(head(seq(range(rr,na.rm = T)[1],0,length.out = n.breaks-20),n.breaks-21),
#               seq(0,range(rr,na.rm=T)[2], length.out = 20))
#rr.breaks = quantile(rr, na.rm=T,probs = seq(0,1,length.out = n.breaks))
rr.norm = normalise_ogm_mines_set_b(rr,rr.breaks,rr.labels)

# Read in map of oceans - for background
bound.shp.name = 'cntry_eez_merge_iso3_moll_mar_bgeom.shp'
bound = readShapeSpatial(paste(indsn,"GIS/",bound.shp.name,sep=""),
                        repair=T,delete_null_obj=T, force_ring = F)

proj4string(bound) = "+proj=moll +datum=WGS84"


#Read in map of EEZs
eez.shp.name = "World_EEZ_Moll_DS.shp"
eez = readShapeSpatial(paste(indsn,"GIS/",eez.shp.name,sep=""),
                       repair=T,delete_null_obj=T, force_ring = F)

proj4string(eez) = "+proj=moll +ellps=WGS84"


legend.x.scale = 0.35


# Plot Species Richness and Range rarity as two panel plot------------------------------- ------------------------------
#plot.bg.colours = c('#2c6223','#045580','#04806d')
height.cm = 18
width.cm = 14
#png(paste(outdir,"WellsPipes_moll_bg_eez_grey.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)
pdf(file = paste(outdir,"SR_meanRR_moll_grey-fine.pdf",sep=""),width=width.cm/2.54,height=height.cm/2.54)

par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
par(xpd=NA)
par(cex=1)

layout(matrix(c(1,2,3,4),nrow = 4), heights = c(0.45,0.05,0.45,0.05))

plot.norm = sr.norm

features.to.plot = which(plot.norm[[1]] > 0)
#features.to.plot = which(sr > 1100)
#plot(eez,border = "black", add = T)
plot(WL.moll,lwd=0.05,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")

cols <- c(colorRampPalette(rev(brewer.pal(8,"RdYlBu")))(n.breaks-1),"#7a0177")

palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot]+1, border = NA, add=T)
plot(WL.moll, add=T, col = NA, border= "black",lwd=0.05)


mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

# t=legend(bbox(bound)[1,1]*0.8,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
#          title="Assessed species richness",
#          xpd=T,horiz=T,
#          fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
#          x.intersp = 0.02,
#          adj=c(-2,2))
# 
# text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
#      plot.norm[[2]],
#      pos=1,
#      cex=0.5)

par(mar=c(2,3,0,3))

x.lim = c(0,1300)#
y.lim = c(0,1)

width <- (1300)/(n.breaks-1)
x_step <- seq(0, 1300, width)


plot(NA, axes=F, xlab="",ylab="",xlim = x.lim, ylim = y.lim)

sapply(seq_len(n.breaks-1),
       function(i) {
         rect(x_step[i], 0, x_step[i]+width, 1, col=i, border=NA)
       })
rect(x_step[n.breaks-1], 0, x_step[n.breaks-1]+100, 1, col=n.breaks, border=NA)

axis(1,at=seq(0,1400,200),labels = c(seq(0,1200,200),'>1100'), tick = F, line=-1,cex.axis=0.7)
mtext(side = 1, "Assessed species richness", line = 1, cex = 0.8)

par(mar=c(0,0,0,0))

plot.norm = rr.norm
features.to.plot = which(plot.norm[[1]] > 0)
#features.to.plot = which(rr > rr.up.val)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")

cols <- c(colorRampPalette(rev(brewer.pal(8,"RdYlBu")))(n.breaks-1),"#7a0177")

palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot]+2, border = NA, add=T)
plot(WL.moll, add=T, col = NA, border= "black",lwd=0.1)

mtext("b",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)
# 
# t=legend(bbox(bound)[1,1]*0.65,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
#          title="Assessed range rarity",
#          xpd=T,horiz=T,
#          fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
#          x.intersp = 0.08,
#          adj=c(-2,2))
# 
# text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
#      plot.norm[[2]],
#      pos=1,
#      cex=0.5)
par(mar=c(2,3,0,3))

x.lim = c(min(rr.breaks, na.rm = T),rr.up.val + 1)
y.lim = c(0,1)

width <- (rr.up.val - min(rr.breaks, na.rm = T))/(n.breaks-2)
x_step <- seq(min(rr.breaks, na.rm = T), rr.up.val, width)


plot(NA, axes=F, xlab="",ylab="",xlim = x.lim, ylim = y.lim)

sapply(seq_len(n.breaks-1),
       function(i) {
         rect(x_step[i], 0, x_step[i]+width, 1, col=i, border=NA)
       })
rect(x_step[n.breaks-1], 0, x_step[n.breaks-1]+1, 1, col=n.breaks, border=NA)

axis(1,at=seq(-12,x.lim[2],1),labels = c(seq(-12,rr.up.val,1),paste0('>',rr.up.val)),tick = F, line=-1,cex.axis=0.7)#
mtext(side = 1, "Assessed range rarity", line = 1, cex = 0.8)

#axis(1,at=rr.breaks,tick = F, line=-1,cex.axis=0.8)
dev.off()


# Plot wells and pipelines as two panel plot------------------------------- ------------------------------
#plot.bg.colours = c('#2c6223','#045580','#04806d')
height.cm = 18
width.cm = 14
#png(paste(outdir,"WellsPipes_moll_bg_eez_grey.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)
pdf(file = paste(outdir,"WellsPipes_moll_bg_eez_grey.pdf",sep=""),width=width.cm/2.54,height=height.cm/2.54)

par(oma=c(0,0,0,0))
par(mar=c(4,0,0,0))
par(xpd=NA)
par(cex=1)

layout(matrix(c(1,2),nrow = 2))

plot.norm = wells.norm

# comb@data$wells.norm = wells.norm[[1]]
# 
# comb.wgs84 = spTransform(comb,wgs1984.proj)
# world.wgs84 = spTransform(world,wgs1984.proj)
# 
# r <- raster(ncol=360, nrow=160)
# extent(r) <- extent(comb.wgs84)
# wells.raster = rasterize(x = comb.wgs84,y = r,field = "wells.norm", fun = 'mean')

features.to.plot = which(plot.norm[[1]] > 0  & comb$Realm_1 > 0)

#plot(eez,border = "black", add = T)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)



mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

t=legend(bbox(bound)[1,1]*legend.x.scale,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Wells (2500 km"^{-2},")",sep="")),
         xpd=T,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.5)


plot.norm = pipes.norm
features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)


mtext("b",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

t=legend(bbox(bound)[1,1]*legend.x.scale,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Pipeline length (km 2500 km"^{-2},")",sep="")),
         xpd=T,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.5)

dev.off()


# Plot exploited and unexploited field areas as two panel plot ------------------------------
plot.bg.colours = c('#2c6223','#045580')
height.cm = 18
width.cm = 15
#png(paste(outdir,"Ex_Unexp_fields_moll_bg_eez_grey.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)
pdf(file = paste(outdir,"Ex_Unexp_fields_moll_bg_eez_grey.pdf",sep=""),width=width.cm/2.54,height=height.cm/2.54)

par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
par(xpd=NA)
par(cex=1)

layout(matrix(c(1,2,3),nrow = 3), heights = c(0.45,0.45,0.1))

plot.norm = exploited.fields.norm

features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)



mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

# t=legend(bbox(bound)[1,1]*0.6,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
#          title=expression(paste("Exploited fields (km"^{-2}," 250 km"^{-2},")",sep="")),
#          xpd=T,horiz=T,
#          fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
#          x.intersp = 0.08,
#          adj=c(-2,2))
# 
# text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
#      plot.norm[[2]],
#      pos=1,
#      cex=0.5)


plot.norm = unexploited.fields.norm
features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)




mtext("b",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

t=legend(bbox(bound)[1,1]*legend.x.scale,bbox(bound)[2,1]*1.05,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Fields (km"^{-2}," 2500 km"^{-2},")",sep="")),
         xpd=NA,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1.5,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(700000),t$text$y-(0.06*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.8)

dev.off()


# Plot valid and bidding block areas as two panel plot ------------------------------
plot.bg.colours = c('#2c6223','#045580')
height.cm = 18
width.cm = 15
#png(paste(outdir,"Val_bid_blocks_moll_bg_no_data_eez_grey.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)
pdf(file = paste(outdir,"Val_bid_blocks_moll_bg_no_data_eez_grey.pdf",sep=""),width=width.cm/2.54,height=height.cm/2.54)

par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
par(xpd=NA)
par(cex=1)

layout(matrix(c(1,2,3),nrow = 3), heights = c(0.45,0.45,0.1))

plot.norm = valid.blocks.norm

features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)
plot(shp.un.countries,col="white",add=T,border=NA)
#plot(shp.un.countries,border = NA,density = 20, add=T)


mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

# t=legend(bbox(bound)[1,1]*0.5,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
#          title=expression(paste("Valid blocks (km"^{-2}," 2500 km"^{-2},")",sep="")),
#          xpd=T,horiz=T,
#          fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
#          x.intersp = 0.08,
#          adj=c(-2,2))
# 
# text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
#      plot.norm[[2]],
#      pos=1,
#      cex=0.5)


plot.norm = bid.blocks.norm
features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.5,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)
plot(shp.un.countries,col="white",add=T,border=NA)
#plot(shp.un.countries,border = NA,density = 20, add=T)



mtext("b",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)


t=legend(bbox(bound)[1,1]*legend.x.scale,bbox(bound)[2,1]*1.05,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Blocks (km"^{-2}," 2500 km"^{-2},")",sep="")),
         xpd=NA,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1.5,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(700000),t$text$y-(0.06*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.8)


dev.off()


# Plot producing and exploration mines as two panel plot------------------------------- ------------------------------
plot.bg.colours = c('#2c6223','#045580')
height.cm = 18
width.cm = 15
#png(paste(outdir,"Prod_expl_mines_moll_bg_pts_eez.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)
pdf(file = paste(outdir,"Prod_expl_mines_moll_bg_pts_eez.pdf",sep=""),width=width.cm/2.54,height=height.cm/2.54)

par(oma=c(0,0,0,0))
par(mar=c(0,0,0,0))
par(xpd=NA)
par(cex=1)

layout(matrix(c(1,2,3),nrow = 3), heights=c(0.45,0.45,0.1))

plot.norm = prd.mines.norm

features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.1,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
cols = add.alpha(cols,0.6)
palette(cols)
pts.to.plot = gCentroid(comb[features.to.plot,],byid = T)
plot(pts.to.plot,col = plot.norm[[1]][features.to.plot], border = NA, add=T,pch=16,cex=0.8)
#plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)


# mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)
# 
# t=legend(bbox(bound)[1,1]*0.7,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
#          title=expression(paste("Producing mines (2500 km"^{-2},")",sep="")),
#          xpd=T,horiz=T,
#          fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
#          x.intersp = 0.08,
#          adj=c(-2,2))
# 
# text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
#      plot.norm[[2]],
#      pos=1,
#      cex=0.5)


plot.norm = exp.mines.norm
features.to.plot = which(plot.norm[[1]] > 0)
plot(WL.moll,lwd=0.1,col = "lightgrey", border = "black")#add=T
plot(bound,lwd=0.5,col = NA,border = "black", add=T)
cols = col2rgb(rev(brewer.pal(length(plot.norm[[2]]),"RdYlBu")))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
cols = add.alpha(cols,0.6)
palette(cols)
pts.to.plot = gCentroid(comb[features.to.plot,],byid = T)
plot(pts.to.plot,col = plot.norm[[1]][features.to.plot], border = NA, add=T,pch=16,cex=0.8)
# plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)




mtext("b",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

t=legend(bbox(bound)[1,1]*legend.x.scale,bbox(bound)[2,1]*1.05,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Mines (2500 km"^{-2},")",sep="")),
         xpd=NA,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1.5,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(700000),t$text$y-(0.06*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.8)


dev.off()



# Plot map of refineries --------------------------------------------------

height.cm = 9
width.cm = 14
png(paste(outdir,"Refineries.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)


par(oma=c(0,0,0,0))
par(mar=c(4,0,0,0))
par(xpd=NA)
par(cex=1)

plot.norm = refineries.norm

features.to.plot = which(plot.norm[[1]] > 0)
plot(bound,lwd=0.5)
cols = col2rgb(brewer.pal(length(plot.norm[[2]]),"PuRd"))
#Make the colours darker
cols = round(cols*0.8)
cols = apply(cols,2,function(x) paste(as.hexmode(x),collapse =""))
cols = paste("#",cols,sep="")
palette(cols)
plot(comb[features.to.plot,],col = plot.norm[[1]][features.to.plot], border = NA, add=T)
plot(world, add=T,lwd=0.5)



#mtext("a",at=bbox(bound)[1,1],line=-2,cex=1.2,font=2)

t=legend(bbox(bound)[1,1]*0.5,bbox(bound)[2,1]*1.0,rep("   ",length(plot.norm[[2]])),
         title=expression(paste("Refineries (250 km"^{-2},")",sep="")),
         xpd=T,horiz=T,
         fill=seq(1:length(plot.norm[[2]])),bty="n", cex=1,
         x.intersp = 0.08,
         adj=c(-2,2))

text(t$text$x-(400000),t$text$y-(0.01*abs(t$text$y)),
     plot.norm[[2]],
     pos=1,
     cex=0.5)

dev.off()


#Calculate NH vs SH plus terrestrial vs marine --------
grid.pts = readShapeSpatial("c:/Users/mikeha/Work/Fossil Fuels and Biodiversity/Combined/BD_Realm_OGM_Realm_Continent_no_dup_all_well_count_pt.shp",
                            repair=T,delete_null_obj=T, force_ring = F)

proj4string(grid.pts) = "+proj=moll +datum=WGS84"

grid.pts = spTransform(grid.pts,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

grid.coords = coordinates(grid.pts)

#indices of wells, pipelines, refineries and mines
inf.inds = which((master[,ogm.cols$w_r_p_m]) > 0)
pNH = length(which(grid.coords[inf.inds,2] >= 0))/length(inf.inds)
pSH = length(which(grid.coords[inf.inds,2] <= 0))/length(inf.inds)

#indices of exploited fields
exp.fields.inds = which((master$Sum_Area) > 0)
pTerr = length(which(master$Realm_1[exp.fields.inds] == 1))/length(exp.fields.inds)
pMar = length(which(master$Realm_1[exp.fields.inds] %in% c(0,2)))/length(exp.fields.inds)

# Plot relationships for all infrastructure----------
l.inds = c(list(hs.inds),list(terr.inds))

height.cm = 20
width.cm = 14
png(paste(outdir,"Inf_BD_Relationships_boxplots_coast.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)

bd.inds = c(1,3)
ogm.inds = c(6)

xlims=c(0,6)
mar.xlims = c(-1,3)
terr.xlims = c(3,7)





q1 = list()
q2 = list()
for(i in 1:length(l.inds))
{
  c = bd.cols[[bd.inds[1]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q1[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
  c = bd.cols[[bd.inds[2]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q2[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
}
ls.ylims = c(list(c(min(unlist(q1)),max(unlist(q1)))),
             list(c(min(unlist(q2)),max(unlist(q2))*1.5)))
y.labs = c(list(c(1,2,5,10,20,50,100,200,500,1000)),
           list(c(5E-6,5E-4,5E-2,5)))

lab.y = c(ls.ylims[[1]][1]*0.8,ls.ylims[[2]][1]*0.7)
text.y = c(ls.ylims[[1]][1]*0.6,ls.ylims[[2]][1]*0.45)

text.cex =0.6

layout(matrix(c(1:6),
              nrow=2,ncol=3,byrow = T),widths=c(0.1,0.45,0.45))


par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

# par(oma=c(0,0,0,0))
 
par(xpd=F)


o = ogm.inds
for(b.i in 1:length(bd.inds))
{
  b = bd.inds[b.i]
#   par(mar=c(0,0,0.5,0))
#   if(b.i == 1){ #== bd.inds[1]) par(mar=c(0,0,1,0))
#     plot(1, type="n", axes=F, xlab="", ylab="")
#     mtext(bd.labels[b],side=4,line = -4, las=0,cex=0.6)
#   }
#   par(mar=c(0,0,0.5,2))
#   if(b == bd.inds[1]) par(mar=c(0,0,1,2))
  

  if(b == 1){
    par(mar=c(3,0.5,1.5,2.0))
  }
  else
  {
    par(mar=c(3,2.0,1.5,0.5))
  }
    
    

    yaxt = "s"
    
    plot(1, type="n", xlim = xlims, ylim = ls.ylims[[b.i]], xlab="", 
         ylab="",xaxt="n",yaxt= "n",log="y",lwd=0.5,mgp=c(2.5,1,0))
    par(xpd=NA)
    mtext(text = bd.labels[b],side=2,line = 2.5)
    par(xpd=F)
    axis(side = 2, at = y.labs[[b.i]])
    mar.poly.x = c(mar.xlims,tail(mar.xlims,1),rev(mar.xlims),mar.xlims[1])
    terr.poly.x = c(terr.xlims,tail(terr.xlims,1),rev(terr.xlims),terr.xlims[1])
    poly.y = c(rep(ls.ylims[[b.i]][1]*0.01,2),rep(ls.ylims[[b.i]][2]*100,3),ls.ylims[[b.i]][1])
    polygon(x = mar.poly.x,y = poly.y,border = NA,col="#afeeee")
    polygon(x = terr.poly.x,y = poly.y,border = NA,col="#d3ffce")
    
    
    
    mtext(LETTERS[b.i],side = 3, adj = 0,cex=1.2, font = 2)       
    
    par(xpd=NA)
    
    #Write the labels for marine and terresrial regions
#     if(b == 3)
#     {
#       text(x=sum(mar.xlims)/2,y=text.y/20,"Marine", pos=1,cex=1.1)
#       text(x=sum(terr.xlims)/2,y=text.y/20,"Terrestrial", pos=1,cex=1.1)
#     } 
    
    x = 1    
    add = T
    
    w.wout.infrastructure.boxplot(inds = mar.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,T)
#     mtext("No Infr.",side = 1, line = -8,adj = 1/6,cex = text.cex)
#     mtext("With",side = 1, line = -8,adj = 2/6,cex = text.cex)
#     mtext("Marine",side=1,line = 2,adj = 1.5/6,cex = 0.8)
    text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
    text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)
    text(x=x+0.5,y=text.y[b.i],"Marine", pos= 1,cex=0.8)
  
    x = x + 3
    add = T
    
    w.wout.infrastructure.boxplot(inds = terr.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,T)
#     mtext("No Infr.",side = 1, line = -8,adj = 4/6,cex = text.cex)
#     mtext("With",side = 1, line = -8,adj = 5/6,cex = text.cex)
#     mtext("Terrestrial",side=1,line = 2,adj = 10/12,cex = 0.8)    

    text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
    text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
    text(x=x+0.5,y=text.y[b.i],"Terrestrial", pos= 1,cex=0.8) 
    

  par(xpd=F)
}


hs.inds = which(grid.pts$Realm_1 == 0 & rowSums(grid.pts@data[,c("Count_","Count_2","sum_length")]) > 0 & grid.pts$NEAR_DIST > -1)
terr.inds = which(grid.pts$Realm_1 == 1 & rowSums(grid.pts@data[,c("Count_","Count_2","sum_length")]) > 0 & grid.pts$NEAR_DIST > -1)
eez.inds = which(grid.pts$Realm_1 == 2 & rowSums(grid.pts@data[,c("Count_","Count_2","sum_length")]) > 0 & grid.pts$NEAR_DIST > -1)
ant.inds = which(grid.pts$Realm_1 == 3 & rowSums(grid.pts@data[,c("Count_","Count_2","sum_length")]) > 0 & grid.pts$NEAR_DIST > -1)
mar.inds<-c(hs.inds,eez.inds)

par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

par(mar=c(5,0.25,1.0,0.25))
plot(ecdf(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1 %in% c(0,2))]/1000),
     ylab="",
     xlab = "",
     main = "")
plot(ecdf(grid.pts@data$NEAR_DIST[mar.inds]/1000),col="red",add=T,yaxt="n")
abline(v=(100),lty=2)
par(xpd=NA)
text(x = 3250, y = -0.2, labels="Distance from coast (km)",cex=1.1)#,side=1,line = 2.5,cex=0.8,adj=1.5
mtext(text="Empirical cumulative distribution function",side=2,line = 2.5,cex=0.8)
text(-80,1,LETTERS[3],cex=1.8,font=2)
par(xpd=F)

legend(x = 250,y = 0.2,legend=c("All","Exploitation"),
       col = c("black","red"),lwd=1,cex=1.0, bty="n")

par(mar=c(5,0.25,1.0,0.25))
plot(ecdf(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1  == 1)]/1000),yaxt="n",ylab="",
     xlab = "",
     main = "")
plot(ecdf(grid.pts@data$NEAR_DIST[terr.inds]/1000),col="red",add=T,yaxt="n",ylab="")
#abline(v=(100),lty=2)
text(-80,1,LETTERS[4],cex=1.8,font=2)



dev.off()


# Plot with/without oil & gas infrastructure for realms ------------------

l.inds = c(list(hs.inds),list(eez.inds),list(terr.inds))

height.cm = 20
width.cm = 17
png(paste(outdir,"Oil_gas_Inf_BD_Relationships_boxplots_realms.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)

bd.inds = c(1,3)
ogm.inds = c(7)

xlims=c(0,9)
r.xlims = list(c(-1,3),c(3,6),c(6,10))
r.cols=c("#afcfee","#afeeee","#d3ffce")

q1 = list()
q2 = list()
for(i in 1:length(l.inds))
{
  c = bd.cols[[bd.inds[1]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q1[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
  c = bd.cols[[bd.inds[2]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q2[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
}
ls.ylims = c(list(c(min(unlist(q1)),max(unlist(q1)))),
             list(c(min(unlist(q2)),max(unlist(q2))*1.5)))
y.labs = c(list(c(1,2,5,10,20,50,100,200,500,1000)),
           list(c(5E-6,5E-4,5E-2,5)))

lab.y = c(ls.ylims[[1]][1]*0.8,ls.ylims[[2]][1]*0.7)
text.y = c(ls.ylims[[1]][1]*0.62,ls.ylims[[2]][1]*0.45)

text.cex =0.8

layout(matrix(c(1:3),
              nrow=1,ncol=3,byrow = T),widths=c(0.1,0.45,0.45))


par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

# par(oma=c(0,0,0,0))

par(xpd=F)


o = ogm.inds
for(b.i in 1:length(bd.inds))
{
  b = bd.inds[b.i]
  #   par(mar=c(0,0,0.5,0))
  #   if(b.i == 1){ #== bd.inds[1]) par(mar=c(0,0,1,0))
  #     plot(1, type="n", axes=F, xlab="", ylab="")
  #     mtext(bd.labels[b],side=4,line = -4, las=0,cex=0.6)
  #   }
  #   par(mar=c(0,0,0.5,2))
  #   if(b == bd.inds[1]) par(mar=c(0,0,1,2))
  
  
  if(b == 1){
    par(mar=c(3,0.5,1.5,2.0))
  }
  else
  {
    par(mar=c(3,2.0,1.5,0.5))
  }
  
  
  
  yaxt = "s"
  
  plot(1, type="n", xlim = xlims, ylim = ls.ylims[[b.i]], xlab="", 
       ylab="",xaxt="n",yaxt= "n",log="y",lwd=0.5,mgp=c(2.5,1,0))
  par(xpd=NA)
  mtext(text = bd.labels[b],side=2,line = 2.5)
  par(xpd=F)
  axis(side = 2, at = y.labs[[b.i]])
  for(i in 1:length(r.xlims))
  {
    poly.x = c(r.xlims[[i]],r.xlims[[i]][2],rev(r.xlims[[i]]),r.xlims[[i]][1])
    poly.y = c(rep(ls.ylims[[b.i]][1]*0.01,2),rep(ls.ylims[[b.i]][2]*100,3),ls.ylims[[b.i]][1])
    polygon(x = poly.x,y = poly.y,border = NA,col=r.cols[i])
  }
  
  
  
  
  mtext(letters[b.i],side = 3, adj = 0,cex=1.2, font = 2)       
  
  par(xpd=NA)
  
  #Write the labels for marine and terresrial regions
  #     if(b == 3)
  #     {
  #       text(x=sum(mar.xlims)/2,y=text.y/20,"Marine", pos=1,cex=1.1)
  #       text(x=sum(terr.xlims)/2,y=text.y/20,"Terrestrial", pos=1,cex=1.1)
  #     } 
  
  x = 1    
  add = T
  
  w.wout.infrastructure.boxplot(inds = hs.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  #w.wout.infrastructure.boxplot<-function(inds, o, b, add,x1,x2,xlims,ylims,ticks,add.signif)
    
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)
  text(x=x+0.5,y=text.y[b.i],"High Seas", pos= 1,cex=1.0)
  
  x = x + 3
  add = T
  
  w.wout.infrastructure.boxplot(inds = eez.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"EEZ", pos= 1,cex=1.0) 
  
  x = x + 3
  add = T
  
  w.wout.infrastructure.boxplot(inds = terr.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"Terrestrial", pos= 1,cex=1.0) 
  
  par(xpd=F)
}

dev.off()



# Plot with/without coal mines for realms ------------------

l.inds = c(list(hs.inds),list(eez.inds),list(terr.inds))

height.cm = 20
width.cm = 17
png(paste(outdir,"Coal_BD_Relationships_boxplots_realms.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)

bd.inds = c(1,3)
ogm.inds = c(8)

xlims=c(0,9)
r.xlims = list(c(-1,3),c(3,6),c(6,10))
r.cols=c("#afcfee","#afeeee","#d3ffce")

q1 = list()
q2 = list()
for(i in 1:length(l.inds))
{
  c = bd.cols[[bd.inds[1]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q1[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
  c = bd.cols[[bd.inds[2]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q2[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
}
ls.ylims = c(list(c(min(unlist(q1)),max(unlist(q1)))),
             list(c(min(unlist(q2)),max(unlist(q2))*1.5)))
y.labs = c(list(c(1,2,5,10,20,50,100,200,500,1000)),
           list(c(5E-6,5E-4,5E-2,5)))

lab.y = c(ls.ylims[[1]][1]*0.8,ls.ylims[[2]][1]*0.7)
text.y = c(ls.ylims[[1]][1]*0.62,ls.ylims[[2]][1]*0.45)

text.cex =0.8

layout(matrix(c(1:3),
              nrow=1,ncol=3,byrow = T),widths=c(0.1,0.45,0.45))


par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

# par(oma=c(0,0,0,0))

par(xpd=F)


o = ogm.inds
for(b.i in 1:length(bd.inds))
{
  b = bd.inds[b.i]
  #   par(mar=c(0,0,0.5,0))
  #   if(b.i == 1){ #== bd.inds[1]) par(mar=c(0,0,1,0))
  #     plot(1, type="n", axes=F, xlab="", ylab="")
  #     mtext(bd.labels[b],side=4,line = -4, las=0,cex=0.6)
  #   }
  #   par(mar=c(0,0,0.5,2))
  #   if(b == bd.inds[1]) par(mar=c(0,0,1,2))
  
  
  if(b == 1){
    par(mar=c(3,0.5,1.5,2.0))
  }
  else
  {
    par(mar=c(3,2.0,1.5,0.5))
  }
  
  
  
  yaxt = "s"
  
  plot(1, type="n", xlim = xlims, ylim = ls.ylims[[b.i]], xlab="", 
       ylab="",xaxt="n",yaxt= "n",log="y",lwd=0.5,mgp=c(2.5,1,0))
  par(xpd=NA)
  mtext(text = bd.labels[b],side=2,line = 2.5)
  par(xpd=F)
  axis(side = 2, at = y.labs[[b.i]])
  for(i in 1:length(r.xlims))
  {
    poly.x = c(r.xlims[[i]],r.xlims[[i]][2],rev(r.xlims[[i]]),r.xlims[[i]][1])
    poly.y = c(rep(ls.ylims[[b.i]][1]*0.01,2),rep(ls.ylims[[b.i]][2]*100,3),ls.ylims[[b.i]][1])
    polygon(x = poly.x,y = poly.y,border = NA,col=r.cols[i])
  }
  
  
  
  
  mtext(letters[b.i],side = 3, adj = 0,cex=1.2, font = 2)       
  
  par(xpd=NA)
  
  #Write the labels for marine and terresrial regions
  #     if(b == 3)
  #     {
  #       text(x=sum(mar.xlims)/2,y=text.y/20,"Marine", pos=1,cex=1.1)
  #       text(x=sum(terr.xlims)/2,y=text.y/20,"Terrestrial", pos=1,cex=1.1)
  #     } 
  
  x = 1    
  add = T
  
  #w.wout.infrastructure.boxplot(inds = hs.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,T)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)
  text(x=x+0.5,y=text.y[b.i],"High Seas", pos= 1,cex=1.0)
  
  x = x + 3
  add = T
  
  #w.wout.infrastructure.boxplot(inds = eez.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,T)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"EEZ", pos= 1,cex=1.0) 
  
  x = x + 3
  add = T
  
  w.any.realm.wout.infrastructure.boxplot(inds = terr.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"Terrestrial", pos= 1,cex=1.0) 
  
  par(xpd=F)
}

dev.off()


# Plot with/without valid contract blocks for realms ------------------

l.inds = c(list(hs.inds),list(eez.inds),list(terr.inds))

height.cm = 20
width.cm = 17
png(paste(outdir,"Valid_Block_BD_Relationships_boxplots_realms.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)

bd.inds = c(1,3)
ogm.inds = c(9)

xlims=c(0,9)
r.xlims = list(c(-1,3),c(3,6),c(6,10))
r.cols=c("#afcfee","#afeeee","#d3ffce")

q1 = list()
q2 = list()
for(i in 1:length(l.inds))
{
  c = bd.cols[[bd.inds[1]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q1[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
  c = bd.cols[[bd.inds[2]]]
  r = l.inds[[i]][which(master[l.inds[[i]],c] > 0)]
  q2[[i]] = quantile(master[r,c],probs = c(0.005,0.995))
}
ls.ylims = c(list(c(min(unlist(q1)),max(unlist(q1)))),
             list(c(min(unlist(q2)),max(unlist(q2))*1.5)))
y.labs = c(list(c(1,2,5,10,20,50,100,200,500,1000)),
           list(c(5E-6,5E-4,5E-2,5)))

lab.y = c(ls.ylims[[1]][1]*0.8,ls.ylims[[2]][1]*0.7)
text.y = c(ls.ylims[[1]][1]*0.62,ls.ylims[[2]][1]*0.45)

text.cex =0.8

layout(matrix(c(1:3),
              nrow=1,ncol=3,byrow = T),widths=c(0.1,0.45,0.45))


par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

# par(oma=c(0,0,0,0))

par(xpd=F)


o = ogm.inds
for(b.i in 1:length(bd.inds))
{
  b = bd.inds[b.i]
  #   par(mar=c(0,0,0.5,0))
  #   if(b.i == 1){ #== bd.inds[1]) par(mar=c(0,0,1,0))
  #     plot(1, type="n", axes=F, xlab="", ylab="")
  #     mtext(bd.labels[b],side=4,line = -4, las=0,cex=0.6)
  #   }
  #   par(mar=c(0,0,0.5,2))
  #   if(b == bd.inds[1]) par(mar=c(0,0,1,2))
  
  
  if(b == 1){
    par(mar=c(3,0.5,1.5,2.0))
  }
  else
  {
    par(mar=c(3,2.0,1.5,0.5))
  }
  
  
  
  yaxt = "s"
  
  plot(1, type="n", xlim = xlims, ylim = ls.ylims[[b.i]], xlab="", 
       ylab="",xaxt="n",yaxt= "n",log="y",lwd=0.5,mgp=c(2.5,1,0))
  par(xpd=NA)
  mtext(text = bd.labels[b],side=2,line = 2.5)
  par(xpd=F)
  axis(side = 2, at = y.labs[[b.i]])
  for(i in 1:length(r.xlims))
  {
    poly.x = c(r.xlims[[i]],r.xlims[[i]][2],rev(r.xlims[[i]]),r.xlims[[i]][1])
    poly.y = c(rep(ls.ylims[[b.i]][1]*0.01,2),rep(ls.ylims[[b.i]][2]*100,3),ls.ylims[[b.i]][1])
    polygon(x = poly.x,y = poly.y,border = NA,col=r.cols[i])
  }
  
  
  
  
  mtext(letters[b.i],side = 3, adj = 0,cex=1.2, font = 2)       
  
  par(xpd=NA)
  
  #Write the labels for marine and terresrial regions
  #     if(b == 3)
  #     {
  #       text(x=sum(mar.xlims)/2,y=text.y/20,"Marine", pos=1,cex=1.1)
  #       text(x=sum(terr.xlims)/2,y=text.y/20,"Terrestrial", pos=1,cex=1.1)
  #     } 
  
  x = 1    
  add = T
  
  w.wout.infrastructure.boxplot(inds = hs.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)
  text(x=x+0.5,y=text.y[b.i],"High Seas", pos= 1,cex=1.0)
  
  x = x + 3
  add = T
  
  w.wout.infrastructure.boxplot(inds = eez.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"EEZ", pos= 1,cex=1.0) 
  
  x = x + 3
  add = T
  
  w.wout.infrastructure.boxplot(inds = terr.inds,o,b,add,x,x+1,xlims,ls.ylims[[b.i]],yaxt,F)
  
  text(x=x,y=lab.y[b.i],"Without", pos= 1,cex=text.cex)
  text(x=x+1.25,y=lab.y[b.i],"With", pos= 1,cex=text.cex)    
  text(x=x+0.5,y=text.y[b.i],"Terrestrial", pos= 1,cex=1.0) 
  
  par(xpd=F)
}

dev.off()



# Plot distances from coasts ------------------------


height.cm = 10
width.cm = 17
png(paste(outdir,"Inf_Dist_Coasts_realms.png",sep=""),width=width.cm,height=height.cm,units="cm",res=600)

layout(matrix(1:4,byrow = T, nrow = 1),widths = c(1,5,5,5))

hs.inds = which(grid.pts$Realm_1 == 0 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) > 0 & grid.pts$NEAR_DIST > -1)
terr.inds = which(grid.pts$Realm_1 == 1 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) > 0 & grid.pts$NEAR_DIST > -1)
eez.inds = which(grid.pts$Realm_1 == 2 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) > 0 & grid.pts$NEAR_DIST > -1)
ant.inds = which(grid.pts$Realm_1 == 3 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) > 0 & grid.pts$NEAR_DIST > -1)

par(mar=c(0,0,0,0))
plot(1, type="n", axes=F, xlab="", ylab="")

par(mar=c(5,4,1.0,0.25))
plot(ecdf(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1 %in% c(0) & grid.pts$NEAR_DIST > -1)]/1000),
     ylab="",
     xlab = "",
     main = "",lwd=2)
plot(ecdf(grid.pts@data$NEAR_DIST[hs.inds]/1000),col="red",add=T,yaxt="n",lwd=2,pch=NA)

par(xpd=NA)
mtext(text="Empirical cumulative distribution function",side=2,line = 2.5,cex=0.8)
text(-80,1,letters[1],cex=1.0,font=2)
par(xpd=F)

legend(x = 500,y = 0.2,legend=c("All","Exploitation"),
       col = c("black","red"),lwd=2,cex=1.0, bty="n")

par(mar=c(5,0.25,1.0,0.25))
plot(ecdf(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1  == 2)]/1000),yaxt="n",ylab="",
     xlab = "",
     main = "",lwd=2)
plot(ecdf(grid.pts@data$NEAR_DIST[eez.inds]/1000),col="red",add=T,yaxt="n",ylab="",lwd=2,pch=NA)
#abline(v=(100),lty=2)
text(-80,1,letters[2],cex=1.0,font=2)
abline(v=(100),lty=2)
mtext(text="Distance from coast (km)",side=1,line = 2.5,cex=0.8)

par(mar=c(5,0.25,1.0,0.25))
plot(ecdf(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1  == 1)]/1000),yaxt="n",ylab="",
     xlab = "",
     main = "",lwd=2)
plot(ecdf(grid.pts@data$NEAR_DIST[terr.inds]/1000),col="red",add=T,yaxt="n",ylab="",lwd=2,pch=NA)
#abline(v=(100),lty=2)
text(-80,1,letters[3],cex=1.0,font=2)



dev.off()


length(which(grid.pts@data$NEAR_DIST[eez.inds]/1000 < 100))/length(eez.inds)
length(which(grid.pts@data$NEAR_DIST[which(grid.pts$Realm_1  == 2)]/1000 < 100))/length(which(grid.pts$Realm_1  == 2))


terr.w.inds = which(grid.pts$Realm_1 == 1 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) > 0)
terr.wo.inds = which(grid.pts$Realm_1 == 1 & rowSums(master[,c("Count_","Count_2","sum_length","prdcoalcnt")]) == 0)
hist(grid.coords[terr.w.inds,2])
hist(grid.coords[terr.wo.inds,2])

plot(ecdf(master$SpCount[terr.wo.inds]),xlab="",ylab="",main="",lwd=2)
plot(ecdf(master$SpCount[terr.w.inds]),col="red",add=T,ylab="",lwd=2,pch=NA)


png(paste0(outdir,"Hist_SR_RR_terr_with_without.png"),width = 12,height = 12,units = "cm",res=600)

layout(matrix(1:2,ncol=2))
par(mar=c(3,3,0,0))

hist(master$SpCount[terr.wo.inds],col = rgb(0,0,0,0.5),freq = F,breaks=20,ylim = c(0,0.005),
     xlab="",ylab="",main="",yaxt="n",cex.axis=0.8)
hist(master$SpCount[terr.w.inds],add=T, col=rgb(1,0,0,0.5),freq = F,breaks=20)
axis(side = 2,at = seq(0,0.005,0.001),labels = seq(0,0.5,0.1),las=1,cex.axis=0.8)
mtext(side = 1,text="Assessed spp. richness",line =2,cex=0.8)
mtext(side = 2,text="Proportion of grid cells (%)",line = 2.25,cex=0.8)
segments(x0 = median(master$SpCount[terr.wo.inds]),
         x1 = median(master$SpCount[terr.wo.inds]),
         y0 = 0, y1 = -1,col = rgb(0,0,0),lwd=2,)
segments(x0 = median(master$SpCount[terr.w.inds]),
         x1 = median(master$SpCount[terr.w.inds]),
         y0 = 0, y1 = -1,col = rgb(1,0,0),lwd=2)

x.vec = c(800,1000,1000,800,800)-200
y.vec = c(0.4,0.4,0.43,0.43,0.4)/100

polygon(x = x.vec,
        y = y.vec,
        col = rgb(0,0,0,0.5))
text(max(x.vec),0.00415,"Without",pos = 4,cex=0.6)
polygon(x = x.vec,
        y = y.vec-(0.04/100),
        col = rgb(1,0,0,0.5))
text(max(x.vec),0.00415-0.0004,"With",pos=4,cex=0.6)
polygon(x = x.vec,
        y = y.vec-(0.08/100),
        col = rgb(0,0,0,0.5))
polygon(x = x.vec,
        y = y.vec-(0.08/100),
        col = rgb(1,0,0,0.5))
text(max(x.vec),0.00415-0.0008,"Distributions\noverlap",pos=4,cex=0.6)

segments(x0 = min(x.vec),
         x1 = max(x.vec),
         y0 = 0.0025, y1 = 0.0025,col = rgb(0,0,0),lwd=2,)
text(900,0.0025,"Median without",pos=4,cex=0.6)
segments(x0 = min(x.vec),
         x1 = max(x.vec),
         y0 = 0.0021, y1 = 0.0021,col = rgb(1,0,0),lwd=2)
text(900,0.0021,"Median with",pos=4,cex=0.6)
mtext(letters[1],side = 3, adj = 0.02,padj=2,cex=1, font = 2)

h1 = hist(log(master$InvArea[terr.wo.inds]),plot=F)
h2 = hist(log(master$InvArea[terr.w.inds]),plot=F)
hist(log(master$InvArea[terr.wo.inds]),col = rgb(0,0,0,0.5),freq = F,breaks=20,ylim=c(0,0.5),
     xlab="",ylab="",main="",yaxt="n",cex.axis=0.8)
hist(log(master$InvArea[terr.w.inds]),add=T, col=rgb(1,0,0,0.5),freq = F,breaks=10)
axis(side = 2,at = seq(0,0.5,0.1),labels = seq(0,50,10),las=1,cex.axis=0.8)
mtext(side = 1,text="Log(Assessed spp. mean range rarity)",line =2,cex=0.6)
#mtext(side = 2,text="Proportion of grid cell area (%)",line = 3)
segments(x0 = median(log(master$InvArea[terr.wo.inds])),
         x1 = median(log(master$InvArea[terr.wo.inds])),
         y0 = 0, y1 = -1,col = rgb(0,0,0),lwd=2,)
segments(x0 = median(log(master$InvArea[terr.w.inds])),
         x1 = median(log(master$InvArea[terr.w.inds])),
         y0 = 0, y1 = -1,col = rgb(1,0,0),lwd=2)
mtext(letters[2],side = 3, adj = 0.02,padj=2,cex=1, font = 2)

dev.off()