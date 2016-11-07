print('Importing modules')
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
import time

print "Running against: {}".format(sys.version)

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

##for val in listValsBth[startNum:]:
##        beginTime1 = time.clock()
##        i += 1

##print "Intersecting grid and wdpa"
##arcpy.Intersect_analysis(in_features="fnet_AUT #;WDPA_June2015_shapefile_polygons #",out_feature_class="aut_precise_int",join_attributes="ALL",cluster_tolerance="#",output_type="INPUT")
##print "dissolving WDPA by designation"
##arcpy.Dissolve_management(in_features="aut_precise_int",out_feature_class="aut_precise_int_diss",dissolve_field="FID_fnet_aut;DESIG_ENG",statistics_fields="#",multi_part="MULTI_PART",unsplit_lines="DISSOLVE_LINES")
##print "union between dissolved wdpa"
##arcpy.CopyFeatures_management("aut_precise_int_diss","aut_precise_int_diss_uni")
######arcpy.Union_analysis(in_features="aut_precise_int_diss #",out_feature_class="aut_precise_int_diss_uni",join_attributes="ALL",cluster_tolerance="#",gaps="GAPS")
##arcpy.env.XYTolerance = "0.1 Meters"
####print "importing toolbox"
##arcpy.ImportToolbox(r'C:\Data\wdpa_desig\Count Overlapping Polygons_faster.tbx')
##print "counting overlapping polygons"
##arcpy.CountOverlappingPolygons_overlap(Input_Features="aut_precise_int_diss_uni",Output_Feature_Class="aut_precise_int_diss_uni_cnt")
##print "adding geodesic area column for filtering out small polygons later"
##arcpy.AddGeometryAttributes_management ("aut_precise_int_diss_uni_cnt", "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
##arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt",out_table="aut_precise_int_diss_uni_cnt_stat",statistics_fields="Join_Count MAX",case_field="FID_fnet_AUT")
##print "getting stats from each cell"
##arcpy.CopyFeatures_management("fnet_AUT","fnet_AUT_count")
##print "joining max stats to grid"
##arcpy.JoinField_management("fnet_AUT_count", "OBJECTID", "aut_precise_int_diss_uni_cnt_stat","FID_fnet_AUT", "MAX_Join_Count")
print "make feature layer with polygons over a certain size"
arcpy.MakeFeatureLayer_management ("aut_precise_int_diss_uni_cnt", "aut_precise_int_diss_uni_cnt_smlrem", "AREA_GEO>= 0.001")
print "save temp layer"
arcpy.CopyFeatures_management("aut_precise_int_diss_uni_cnt_smlrem","aut_precise_int_diss_uni_cnt_smlrem1")
#arcpy.SelectLayerByAttribute_management ("aut_precise_int_diss_uni_cnt_smlrem", {selection_type}, {where_clause})
arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt_smlrem",out_table="aut_precise_int_diss_uni_cnt_smlrem_stat",statistics_fields="Join_Count MAX",case_field="FID_fnet_AUT")
print "getting stats from each cell"
arcpy.CopyFeatures_management("fnet_AUT","fnet_AUT_count_smlrem")
print "joining max stats to grid"
arcpy.JoinField_management("fnet_AUT_count_smlrem", "OBJECTID", "aut_precise_int_diss_uni_cnt_smlrem_stat","FID_fnet_AUT", "MAX_Join_Count")
print "deleting temp file"
arcpy.Delete_management("aut_precise_int_diss_uni_cnt_smlrem")
print("Elapsed time (minutes): " + str((time.clock() - beginTime)/60))
