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
arcpy.env.XYTolerance = "1 Meters"
print "Intersecting grid and wdpa"
arcpy.Intersect_analysis(in_features="fnet_AUT_sel #;WDPA_June2015_shapefile_polygons #",out_feature_class="aut_precise_int",join_attributes="ALL",cluster_tolerance="#",output_type="INPUT")
print "dissolving WDPA by designation"
arcpy.Dissolve_management(in_features="aut_precise_int",out_feature_class="aut_precise_int_diss",dissolve_field="FID_fnet_aut_sel;DESIG_ENG",statistics_fields="#",multi_part="MULTI_PART",unsplit_lines="DISSOLVE_LINES")
print "union between dissolved wdpa"
arcpy.CopyFeatures_management("aut_precise_int_diss","aut_precise_int_diss_uni")
####arcpy.Union_analysis(in_features="aut_precise_int_diss #",out_feature_class="aut_precise_int_diss_uni",join_attributes="ALL",cluster_tolerance="#",gaps="GAPS")
print "importing toolbox"
arcpy.ImportToolbox(r'C:\Data\wdpa_desig\Count Overlapping Polygons_faster.tbx')
print "counting overlapping polygons"

arcpy.CountOverlappingPolygons_overlap(Input_Features="aut_precise_int_diss_uni",Output_Feature_Class="aut_precise_int_diss_uni_cnt")
print "joining layer with counts to original grid"
####arcpy.SpatialJoin_analysis(target_features="fnet_AUT_sel",join_features="aut_precise_int_diss_uni_cnt",out_feature_class="aut_precise_int_diss_uni_cnt_join",join_operation="JOIN_ONE_TO_MANY",join_type="KEEP_ALL",
####                           field_mapping="""Join_Count "Join_Count" true true false 4 Long 0 0 ,First,#,aut_precise_int_diss_uni_cnt,Join_Count,-1,-1""",match_option="INTERSECT",search_radius="#",distance_field_name="#")
arcpy.AddGeometryAttributes_management ("aut_precise_int_diss_uni_cnt", "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt",out_table="aut_precise_int_diss_uni_cnt_stat",statistics_fields="Join_Count MAX",case_field="FID_fnet_AUT_sel")
print "getting stats from each cell"
##arcpy.Eliminate_management(in_features="aut_precise_int_diss_uni_cnt", out_feature_class="aut_precise_int_diss_uni_cnt_elim", selection="AREA", ex_where_clause="AREA_GEO > 300", ex_features="")
###arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt_join",out_table="aut_precise_int_diss_uni_cnt_join_stat",statistics_fields="Join_Count MAX",case_field="OBJECTID")
arcpy.CopyFeatures_management("fnet_AUT_sel","fnet_AUT_sel_count")
print "joining max stats to grid"
arcpy.JoinField_management("fnet_AUT_sel_count", "OBJECTID", "aut_precise_int_diss_uni_cnt_stat","FID_fnet_AUT_sel", "MAX_Join_Count")

arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt_smlrem",out_table="aut_precise_int_diss_uni_cnt_smlrem_stat",statistics_fields="Join_Count MAX",case_field="FID_fnet_AUT_sel")
print "getting stats from each cell"
##arcpy.Eliminate_management(in_features="aut_precise_int_diss_uni_cnt", out_feature_class="aut_precise_int_diss_uni_cnt_elim", selection="AREA", ex_where_clause="AREA_GEO > 300", ex_features="")
###arcpy.Statistics_analysis(in_table="aut_precise_int_diss_uni_cnt_join",out_table="aut_precise_int_diss_uni_cnt_join_stat",statistics_fields="Join_Count MAX",case_field="OBJECTID")
arcpy.CopyFeatures_management("fnet_AUT_sel","fnet_AUT_sel_count_smlrem")
print "joining max stats to grid"
arcpy.JoinField_management("fnet_AUT_sel_count_smlrem", "OBJECTID", "aut_precise_int_diss_uni_cnt_smlrem_stat","FID_fnet_AUT_sel", "MAX_Join_Count")

#print "saving grid"
#arcpy.CopyFeatures_management("fnet_AUT_sel_copy", "fnet_AUT_sel_count")
#print "deleting temp file"
#arcpy.Delete_management("fnet_AUT_sel_copy")
print("Elapsed time (minutes): " + str((time.clock() - beginTime)/60))
