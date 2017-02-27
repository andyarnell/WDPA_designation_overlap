import arcpy, os

####input workspace

#national
#arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\national_dt_erase\marine\precise_temp_fcs\temp.gdb'
arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\national_dt_erase\land\precise_temp_fcs\temp.gdb'

#regional

#arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\regional_dt_erase\marine\precise_temp_fcs\temp.gdb'
#arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\regional_dt_erase\land\precise_temp_fcs\temp.gdb'

arcpy.env.overwriteOutput=True


fcs = arcpy.ListFeatureClasses(wild_card='*Uniq*')
print fcs

####output workspace

#national
#mergePath=r"C:\Data\wdpa_desig\scratch\national_dt_erase\marine\output_fcs\merged_fcs.gdb"
mergePath=r"C:\Data\wdpa_desig\scratch\national_dt_erase\land\output_fcs\merged_fcs.gdb"

#regional
#mergePath=r"C:\Data\wdpa_desig\scratch\regional_dt_erase\marine\output_fcs\merged_fcs.gdb"
#mergePath=r"C:\Data\wdpa_desig\scratch\regional_dt_erase\land\output_fcs\merged_fcs.gdb"



###file name for output
mergeFile= "merged_fcs" 
mergeOutput = mergePath + "/" +mergeFile

print mergeOutput

#arcpy.CopyFeatures_management(fcs[0],mergeOutput)
#copying first FC to the mergeOutput
arcpy.FeatureClassToFeatureClass_conversion(fcs[0], mergePath, mergeFile)

#appending to mergeOutput all subsequent FCs in the list (and using NO_TEST for schema so they match the first FC output)
arcpy.Append_management (fcs[1:], mergeOutput, schema_type="NO_TEST")
