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
####comment out dependiong on land or marine regions
wkspce1=r"C:\Data\wdpa_desig\raw\wdpa_desig_inputs_postdec2016.gdb"
wkspce2=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\textfiles"
wkspce4=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\featureclasses"
wkspce5=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\marine\admin_boundaries"

##wkspce1=r"C:\Data\wdpa_desig\raw\wdpa_desig_inputs_postdec2016.gdb"
##wkspce2=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\textfiles"
##wkspce4=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\featureclasses"
##wkspce5=r"C:\Data\wdpa_desig\scratch\both_scales_dt_erase\land\admin_boundaries"

arcpy.env.workspace = wkspce4

fcs = 'fcs.gdb'

if not arcpy.Exists(fcs):
    arcpy.CreateFileGDB_management(wkspce4, fcs)
    print "fcs FileGDB created"
else:
    print "fcs gdb exists"

wkspce4=wkspce4+"/"+fcs

print wkspce4
