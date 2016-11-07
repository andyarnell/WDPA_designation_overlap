print('Importing modules')
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
import time

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

#env.overwriteOutput = True

beginTime = time.clock()
##
wkspce1=r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb"
wkspce2=r"C:\Users\marined\Desktop\OVERLAP_APR2016\outputs"
env.workspace = wkspce1 ## path to feature class
featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
fieldList = arcpy.ListFields(featureClass) ### simply pointer to location
inFC_Zone="Fishnet_1km_clip_to_Land_Moll"
inFC_main="WDPApoly_all_PPR2016_Mollweide"

##
##
##wkspce1=r"C:\Data\test\wdpa_intersect.gdb"
##wkspce2=r"C:\Data\test\output"
##env.workspace = wkspce1 ## path to feature class
##featureClass = r"C:\Data\test\wdpa_intersect.gdb\Fishnet1km_test2" ## path to feature class
##fieldList = arcpy.ListFields(featureClass) ### simply pointer to location
##inFC_Zone="Fishnet1km_test2"
##inFC_main="WDPA_June2015_shapefile_polygons"

splitNum=125

lyrfile=inFC_Zone
result = arcpy.GetCount_management(lyrfile)
count = int(result.getOutput(0))
print(count)


temp="in_memory\\"+"Temp"


arcpy.Delete_management(in_data="{0}/Out_Temp".format(wkspce1),data_type="#")
##arcpy.Delete_management(in_data="{0}/Temp".format(wkspce1),data_type="#")
arcpy.Delete_management(in_data="{0}".format(temp),data_type="#")
arcpy.Delete_management(in_data="{0}/Temp_Tab".format(wkspce1),data_type="#")

temp="in_memory\\"+"Temp"
temp2="in_memory\\"+"Temp2"
tempBBox="in_memory\\"+"TempBBOX"
iterNum = count/splitNum

tempObjectID="OBJECTID"
i=211


row = 57322155 ## initiate
#row=iterNum * i+1



beginTime1a = time.clock()

#arcpy.MakeFeatureLayer_management (in_features=inFC_main, out_layer=temp2)

print "Uploaded WDPA"
print("Processing time (minutes): " + str((time.clock() - beginTime1a)/60))

#inFC_main=temp2

print inFC_main

print "Number of zonal polygons per iteration number: {0}".format(str(iterNum))
while row < count+iterNum:
    beginTime2 = time.clock()
    i+=1
    print "\nIteration: {0} of {1}".format(str(i),splitNum)
    print "Row number: {0}".format(str(row))
    ####arcpy.FeatureClassToFeatureClass_conversion(in_features=inFC_Zone,out_path=wkspce1,out_name="Temp",where_clause=("OBJECTID >= " + str(row) + " AND OBJECTID < " + str(row + iterNum) ))
    whereClause=("{0} >= {1} AND {0} < {2}".format( tempObjectID, str(row),str(row + iterNum) ))
    myExtent=arcpy.Describe(inFC_Zone).extent
    arcpy.MakeFeatureLayer_management (in_features=inFC_Zone, out_layer=temp, where_clause=whereClause)
    print "Processed copy feature class in:" + str(((time.clock() - beginTime2)/60))
    #arcpy.MinimumBoundingGeometry_management(in_features=temp,out_feature_class=tempBBox,geometry_type="ENVELOPE",group_option="ALL",group_field="#",mbg_fields_option="NO_MBG_FIELDS")
    #arcpy.SelectLayerByLocation_management(temp2,'intersect',tempBBox)
    arcpy.SelectLayerByLocation_management(temp,'intersect',inFC_main)
    print "Processed selectbylocation feature class:" + str(((time.clock() - beginTime2)/60))
    arcpy.TabulateIntersection_analysis(in_zone_features=temp,zone_fields=tempObjectID,
                                        in_class_features=inFC_main,out_table=wkspce1+"/"+"Temp_Tab",class_fields="WDPAID;DESIG_ENG",sum_fields="#",xy_tolerance="#",out_units="SQUARE_KILOMETERS")
    outFile="tabInt_split_{0}.dbf".format(i)
    arcpy.TableToTable_conversion (wkspce1+"/"+"Temp_Tab",wkspce2,outFile)
    if row == 1:
        arcpy.Rename_management(in_data=wkspce1+"/"+"Temp_Tab",out_data=wkspce1+"/"+"Out_Temp",data_type="Table")
    elif row > 1:
        inString="{0}/Out2;{0}/Temp_Tab".format(wkspce1)
        outString="{0}/Out_Temp".format(wkspce1)
        arcpy.Merge_management(inputs=inString,output=outString)
    arcpy.Delete_management(in_data="{0}/Out2".format(wkspce1),data_type="#")
    arcpy.Rename_management(in_data="{0}/Out_Temp".format(wkspce1),out_data="{0}/Out2".format(wkspce1))
    arcpy.Delete_management(in_data="{0}".format(temp),data_type="#")
    arcpy.Delete_management(in_data="{0}/Temp_Tab".format(wkspce1),data_type="#")
    row = row + iterNum
    print "Processed tabulate intersection. Output for iteration: {0}".format(outFile)
    print("Processing time (minutes): " + str((time.clock() - beginTime2)/60))

print("Elapsed time (minutes): " + str((time.clock() - beginTime)/60))
