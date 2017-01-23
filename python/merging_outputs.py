import arcpy, os

arcpy.env.workspace = r'C:\Data\wdpa_desig\scratch\national_dt_erase\marine\precise_temp_fcs\temp.gdb'

arcpy.env.overwriteOutput=True


fcs = arcpy.ListFeatureClasses(wild_card='*Uniq*')
print fcs
mergePath=r"C:\Data\wdpa_desig\scratch\national_dt_erase\marine\output_fcs\merged_fcs.gdb"
mergeFile= "merged_fcs" 
mergeOutput = mergePath + "/" mergeFile

print mergeOutput

#sortOutput = r"W:\S&P\s&p techs\Emily\TownshipsDissolved\FinalDissolved.gdb\OSRS_ORN_NER_new"

#arcpy.CopyFeatures_management(fcs[0],mergeOutput)
arcpy.FeatureClassToFeatureClass_conversion(fcs[0], mergePath, mergeFile, {field_mapping}, {config_keyword})

arcpy.Append_management (fcs[1:], mergeOutput, schema_type="NO_TEST")

#arcpy.Merge_management(fcs, mergeOutput)
#arcpy.Sort_management(mergeOutput, sortOutput, [["HWY_NUM_PR", "ASCENDING"]])
