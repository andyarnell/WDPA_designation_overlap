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
wkspce2=r"C:\Data\wdpa_desig\scratch\national\tab_int_dbfs"
wkspce3=r"C:\Data\wdpa_desig\scratch\national\fnets\fnets.gdb"
wkspce4=r"C:\Data\wdpa_desig\scratch\national\fnets\fnets.gdb"
env.workspace = wkspce1 ## path to feature class
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
listExcept=['CHN','BRA','CAN','AUS','IND','RUS']#missed out - 'USA' - rerun!!!!



#removing those on exception list from list of those to run
listValsBth = list(set(listValsBth) - set(listExcept))
listValsBth.sort(reverse=False)

print listValsBth
print "listValsBth: " + str(len(listValsBth))

################################################################################
inMem = True #temp

for val in listValsBth[startNum:6]:
        beginTime1 = time.clock()
        i += 1
        #val='ARE'
        print "\nLoop counter: "+ str(i)
        in_memory_feature = "in_memory\\"+ str(i)
        selectString=""" {0} = '{1}' """.format(flds,(val))
        print "Selection string:" +selectString
        print "Selecting PAs using iso3 code"
        arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
        result = arcpy.GetCount_management(in_memory_feature)
        count = int(result.getOutput(0))
        print "Number of rows selected: " +str(count)
##        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
##        selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val))
##        print "Selecting admin outline using iso3 - currently land only"
##        print "Selection string:" +selectString
##        arcpy.MakeFeatureLayer_management(inFC_iso3, in_memory_feature2,selectString)
        valClean=arcpy.ValidateTableName(val)
##        outFC = wkspce3+"/"+prefix+"_"+"_"+str(valClean[0:15])+".shp"
##        result = arcpy.GetCount_management(in_memory_feature2)
##        count = int(result.getOutput(0))
##        print "FeatureClass stored: "+ str(outFC)
##        arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
##        arcpy.env.extent = outFC
##        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##        print "Number of rows selected: " +str(count)
        grid_national=wkspce3+"/"+prefix2+"_"+str(valClean[0:15])
        print grid_national
        gridCellID="GID"
        print "adding field :"+ gridCellID+ "- for feature class: " +str(grid_national)
        arcpy.AddField_management(grid_national,gridCellID,"LONG")
        print "calculating field for: " +str(grid_national)
        arcpy.CalculateField_management(grid_national,field=gridCellID,expression="""!OBJECTID!""",expression_type="PYTHON_9.3")
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
        in_memory_feature3 = "in_memory\\"+ str(i)+"3"
##        if arcpy.Exists(grid_national):
##            print "Skipping selecting and clipping grid by admin boundary, as clipped feature class exists: " + str(grid_national)
##            inMem = True
##            pass
##        else:
##            try:
##                inMem = True
##                print "Selecting grid cells using admin boundary"
##                arcpy.MakeFeatureLayer_management(inFC_zone, in_memory_feature3)
##                arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature2)
##                result = arcpy.GetCount_management(in_memory_feature3)
##                count = int(result.getOutput(0))
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                print "Clipping grid cells using admin boundary"
##                arcpy.Clip_analysis(in_memory_feature3,in_memory_feature2,grid_national)
##                print "Clipped grid cells stored here: "+grid_national
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                arcpy.Delete_management(in_memory_feature3)
##            except:
##                inMem = False
##                print "WARNING: error when selecting cells by admin boundary - likely too big for memory (RAM)., so now attempting clip on main grid using hard disk"
##                print "Clipping grid cells using admin boundary"
##                arcpy.Clip_analysis(inFC_zone,in_memory_feature2,grid_national)
##                print "Clipped grid cells stored here: "+grid_national
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                arcpy.Delete_management(in_memory_feature3)
##                pass
        if inMem == True:
            print "Putting clipped grid into memory (RAM)"
            arcpy.MakeFeatureLayer_management(grid_national, in_memory_feature3)
            result = arcpy.GetCount_management(in_memory_feature3)
            count = int(result.getOutput(0))
            print "Number of rows selected: " +str(count)
            print "Selecting clipped grid cells overlapping PAs for this iso3 code"
            arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature)
            grid_national_sel=wkspce3+"/"+prefix3+"_"+str(valClean[0:15])
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Copying selected cells (those that overlap with PAs) to: " + str(grid_national_sel)
            arcpy.CopyFeatures_management(in_memory_feature3,grid_national_sel)
            result = arcpy.GetCount_management(in_memory_feature3)
            count = int(result.getOutput(0))
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
        else:
            in_memory_feature3=grid_national
            pass
        flds2="WDPAID;ISO3;DESIG_ENG"
        print "Tabulating intersection between cells and pas using: "+flds2
        if count > 0:
            arcpy.TabulateIntersection_analysis(in_zone_features=in_memory_feature3,zone_fields=gridCellID,
                                            in_class_features=in_memory_feature,out_table=wkspce1+"/"+"Temp_Tab",class_fields=flds2,sum_fields="#",xy_tolerance="#",out_units="SQUARE_KILOMETERS")
            outFile="tabInt_split_{0}.dbf".format(val)
            arcpy.TableToTable_conversion (wkspce1+"/"+"Temp_Tab",wkspce2,outFile)
            print "Copying dbf output to: " + wkspce2 +"/" + outFile
        else:
            print "Skipping intersection as no cells intersect PAs"
            pass
        #print "Number of rows selected: " +str(count)
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
        arcpy.Delete_management(in_memory_feature)
        #arcpy.Delete_management(in_memory_feature2)
        arcpy.Delete_management(in_memory_feature3)
        del (in_memory_feature)
        #del (in_memory_feature2)
        del (in_memory_feature3)
        
       # except:
        #    print "\n ###################ERROR with selection string:" +selectString+"\n"
        print("For iso3 - elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
