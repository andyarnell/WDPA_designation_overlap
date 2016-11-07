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
##wkspce1=r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb"
##wkspce2=r"C:\Users\marined\Desktop\OVERLAP_APR2016\outputs"
##env.workspace = wkspce1 ## path to feature class
##featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
##fieldList = arcpy.ListFields(featureClass) ### simply pointer to location
##inFC_Zone="Fishnet_1km_clip_to_Land_Moll"
##inFC_main="WDPApoly_all_PPR2016_Mollweide"
##

wkspce1=r"C:\Data\test\wdpa_intersect.gdb"
wkspce2=r"C:\Data\test\output"
env.workspace = wkspce1 ## path to feature class
featureClass = r"C:\Data\test\wdpa_intersect.gdb\Fishnet1km_test2" ## path to feature class
fieldList = arcpy.ListFields(featureClass) ### simply pointer to location
inFC_zone="Fishnet1km_test2"
inFC_zone=r"C:\Data\testPaz\threats.gdb\cerrado_fnet"
inFC_main="WDPA_June2015_shapefile_polygons"
inFC_iso3 = r"C:\Data\geo6\raw\admin\EEZv8_WVS_DIS_V3_ALL_final_v3.shp"
#featureclass within inwkspce
#FC = "WDPA_June2015_shapefile_polygons"

##change to field name
flds = ("ISO3")

##prefix for output filename
prefix="country"

#where to start iterating through - default should be 0
startNum = 0


tempObjectID="OBJECTID"

######################################################
#setting workspace
arcpy.env.workspace = wkspce1

listVals=[]

print "Input FeatureClass: {}".format(inFC_main)
    
#making list of attributes                         
with arcpy.da.SearchCursor(inFC_main,flds) as cur:
    for row in cur:
        listVals.append((row[0]))

del cur
#removing duplicates
listVals=list(set(listVals))

listVals2=[]

with arcpy.da.SearchCursor(inFC_iso3,flds) as cur2:
    for row in cur2:
        listVals2.append((row[0]))

del cur2
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

#listExcept=['CHN','BRA','USA','CAN','AUS','RUS']

#listValsBth = list(set(listValsBth) - set(listExcept))
print listValsBth
print "listValsBth: " + str(len(listValsBth))


for val in listValsBth[startNum:]:
        beginTime1 = time.clock()
        i += 1
        #try:
        val='BRA'
        in_memory_feature = "in_memory\\"+ str(i)
        selectString=""" {0} = '{1}' """.format(flds,(val))
        print "\nSelection string:" +selectString
        arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
        result = arcpy.GetCount_management(in_memory_feature)
        count = int(result.getOutput(0))
        print "Number of rows selected: " +str(count)
        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
        selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val))
        print "\nSelection string:" +selectString
        arcpy.MakeFeatureLayer_management(inFC_iso3, in_memory_feature2,selectString)
        valClean=arcpy.ValidateTableName(val)
        outFC = wkspce1+"/"+prefix+"_"+str(i)+"_"+str(valClean[0:15])
        result = arcpy.GetCount_management(in_memory_feature2)
        count = int(result.getOutput(0))
        print "FeatureClass stored: "+ str(outFC)
        arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
        arcpy.env.extent = outFC
        #arcpy.CreateFishnet_management(inFC_zone,
        print "Number of rows selected: " +str(count)
        print "Loop counter: "+ str(i)
        in_memory_feature3 = "in_memory\\"+ str(i)+"3"
        arcpy.MakeFeatureLayer_management(inFC_zone, in_memory_feature3)
        arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature2)
        result = arcpy.GetCount_management(in_memory_feature3)
        count = int(result.getOutput(0))
        grid_national="grid"+val
        arcpy.Clip_analysis(in_memory_feature3,in_memory_feature2,grid_national)
##        beginTime2 = time.clock()
##        print "Adding area to grid"
##        arcpy.AddGeometryAttributes_management(Input_Features=grid_national,Geometry_Properties="AREA_GEODESIC",Length_Unit="#",Area_Unit="SQUARE_KILOMETERS",Coordinate_System="#")
##        print "Adding field and creating a unique id from iso3 code and fishnet id"
##        arcpy.AddField_management(in_table=grid_national,field_name="fnet_iso",field_type="TEXT",field_length="30")
##        arcpy.CalculateField_management(in_table=grid_national,field="fnet_iso", expression="val +str(!OBJECTID!)",expression_type="PYTHON_9.3",code_block="#")
##        print("Elapsed time (minutes): " + str((time.clock() - beginTime2)/60))
        arcpy.Delete_management(in_memory_feature3)
        arcpy.MakeFeatureLayer_management(grid_national, in_memory_feature3)
        result = arcpy.GetCount_management(in_memory_feature3)
        count = int(result.getOutput(0))
        print "Number of rows selected: " +str(count)
        arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature)
        result = arcpy.GetCount_management(in_memory_feature3)
        count = int(result.getOutput(0))
        if count > 0:
            arcpy.TabulateIntersection_analysis(in_zone_features=in_memory_feature3,zone_fields=tempObjectID,
                                            in_class_features=in_memory_feature,out_table=wkspce1+"/"+"Temp_Tab",class_fields="WDPAID;ISO3;DESIG_ENG",sum_fields="#",xy_tolerance="#",out_units="SQUARE_KILOMETERS")
            outFile="tabInt_split_{0}.dbf".format(val)
            arcpy.TableToTable_conversion (wkspce1+"/"+"Temp_Tab",wkspce2,outFile)
        else:
            pass
        print "Number of rows selected: " +str(count)
        arcpy.Delete_management(in_memory_feature)
        arcpy.Delete_management(in_memory_feature2)
        arcpy.Delete_management(in_memory_feature3)
       # except:
        #    print "\n ###################ERROR with selection string:" +selectString+"\n"
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
