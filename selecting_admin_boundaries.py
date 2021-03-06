print('Importing modules')
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
import time

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

env.overwriteOutput = True

beginTime = time.clock()
##
wkspce1=r"C:\Data\wdpa_desig\raw\wdpa_desig_inputs.gdb"
wkspce2=r"C:\Data\wdpa_desig\scratch\national\precise_int_dbfs"
wkspce3=r"C:\Data\wdpa_desig\scratch\national\fnets\fnets.gdb"
wkspce4=r"C:\Data\wdpa_desig\scratch\national\precise_temp_fcs\temp.gdb"
wkspce5=r"C:\Data\wdpa_desig\scratch\national\admin"

####featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
inFC_zone="Fishnet_1km_clip_to_Land_Moll"
inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed"
inFC_iso3="EEZv8_WVS7_Dis_copy_Land_Mollweide_NEW_UPDATED"
#fieldList = arcpy.ListFields(inFC_zone) ### simply pointer to location

##change to field name
flds = ("ISO3")

##prefix for output filename
prefix="country"
prefix2="fnet"
prefix3="fnetwdpa"
#where to start iterating through - default should be 0
startNum = 0


tempObjectID="FISHNET_ID"


######################################################
#setting workspace
arcpy.env.workspace = wkspce1
listVals=[]

##print "Input FeatureClass: {}".format(inFC_main)
##    making list of attributes                         
with arcpy.da.SearchCursor(inFC_main,flds) as cur:
    for row in cur:
        listVals.append((row[0]))

del cur
#removing duplicates
listVals=list(set(listVals))
print "list vals: " + str(listVals)

arcpy.env.workspace = wkspce3
#listVals2=[]
listVals2=arcpy.ListFeatureClasses(wild_card='fnet_*')
print "list vals2: " + str(listVals2)
arcpy.env.workspace = wkspce1

listValsTemp=[]
for s in listVals2:
    listValsTemp.append(s.replace('fnet_', ''))
print "testing:" + str(listValsTemp)
listVals2=listValsTemp
del(listValsTemp)

##listVals2=[]
##
##with arcpy.da.SearchCursor(inFC_iso3,flds) as cur2:
##    for row in cur2:
##        listVals2.append((row[0]))
##
##
##
######seeing which countries are not in both the wdpa and the admin layer
##        
##del cur2

listVals2=list(set(listVals2))

listValsBth = list(set(listVals).intersection(listVals2))
print listValsBth
print "listValsBth: " + str(len(listValsBth))



listValsExtr = [item for item in listVals if item not in listVals2]
listVals2Extr = [item for item in listVals2 if item not in listVals]

listValsExtr = [item for item in listVals if item not in listVals2]
print "listValsExtr: \n" + str(len(listValsExtr))
print "listValsExtr: \n" + str(listValsExtr)

                              
listVals2Extr = [item for item in listVals2 if item not in listVals]
print "listVals2Extr: \n" + str(len(listVals2Extr))
print "listVals2Extr: \n" + str(listVals2Extr)

                               
print "Number of distinct attributes in chosen field: "+ str(len (listVals))

i = startNum
#######################################################################


#############################################################################
###list to run seperateley for those that seem to crash due to their size
#listExcept=['BRA','CAN','CHN','AUS']#missed out - 'USA' 'RUS' 'IND'- rerun!!!!
listExcept=['RUS', 'IND','BRA','USA','CAN','AUS','DEU','FRA','CHL','SXM','CIV','GRL']

#removing those on exception list from list of those to run
listValsBth = list(set(listValsBth) - set(listExcept))

print listValsBth
print "listValsBth: " + str(len(listValsBth))

################################################################################
inMem = True #temp

for val in listValsBth[startNum:]:
        beginTime1 = time.clock()
        i += 1
        env.workspace = wkspce1 ## path to feature class
        #val='ARG'
        print "\nLoop counter: "+ str(i)
        in_memory_feature = "in_memory\\"+ str(i)
        selectString=""" {0} = '{1}' """.format(flds,(val))
        print "Selection string:" +selectString
        print "Selecting PAs using iso3 code"
        arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
        result = arcpy.GetCount_management(in_memory_feature)
        count = int(result.getOutput(0))
        print "Number of rows selected: " +str(count)
        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
        selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val))
        print "Selecting admin outline using iso3 - currently land only"
        print "Selection string:" +selectString
        #valClean=arcpy.ValidateTableName(val)
        valClean=val
        outFC = wkspce5+"/"+prefix+"_"+str(valClean[0:15])+".shp"
        arcpy.Select_analysis(inFC_iso3,outFC,selectString)
