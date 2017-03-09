import arcpy, os

####input workspace

#arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\featureclasses\fcs.gdb'
arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\featureclasses\fcs.gdb'


arcpy.env.overwriteOutput=True


fcs = arcpy.ListFeatureClasses(wild_card='*UnionFC*')

print fcs

####output workspace

#both scales

#mergePath=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\output_fcs\merged_fcs.gdb"
mergePath=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\output_fcs\merged_fcs.gdb"



###file name for output
mergeFile= "merged_fcs_noon_unique" 
mergeOutput = mergePath + "/" +mergeFile

print mergeOutput

#arcpy.CopyFeatures_management(fcs[0],mergeOutput)
#copying first FC to the mergeOutput
arcpy.FeatureClassToFeatureClass_conversion(fcs[0], mergePath, mergeFile)

#appending to mergeOutput all subsequent FCs in the list (and using NO_TEST for schema so they match the first FC output)
arcpy.Append_management (fcs[1:], mergeOutput, schema_type="NO_TEST")


##########################
#import arcpy, os

####input workspace

arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\featureclasses\fcs.gdb'
#arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\featureclasses\fcs.gdb'


arcpy.env.overwriteOutput=True

fcs = arcpy.ListFeatureClasses(wild_card='*UnionFC*')

print fcs

####output workspace



mergePath=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\output_fcs\merged_fcs.gdb"
#mergePath=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\output_fcs\merged_fcs.gdb"



###file name for output
mergeFile= "merged_fcs_non_unique" 
mergeOutput = mergePath + "/" +mergeFile

print mergeOutput

#arcpy.CopyFeatures_management(fcs[0],mergeOutput)
#copying first FC to the mergeOutput
arcpy.FeatureClassToFeatureClass_conversion(fcs[0], mergePath, mergeFile)

#appending to mergeOutput all subsequent FCs in the list (and using NO_TEST for schema so they match the first FC output)
arcpy.Append_management (fcs[1:], mergeOutput, schema_type="NO_TEST")
