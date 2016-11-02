print('Importing modules')
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
import time

arcpy.env.workspace = r"C:\Data\wdpa_desig\scratch\national\precise_temp_fcs\temp.gdb" ## path to feature class

listVals=arcpy.ListFeatureClasses(wild_card='*_preciseAdminIntUnionUniqFC')
outFolder = r"C:\Data\wdpa_desig\scratch\national\precise_temp_fcs\maps1.gdb" ## path to feature class

print listVals
for val in listVals:
    #arcpy.Delete_management(val)
    arcpy.Copy_management(val,outFolder+"/"+val)
    print val
