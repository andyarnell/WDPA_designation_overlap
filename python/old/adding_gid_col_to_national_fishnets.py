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

#in_folder=("C:/Data/wdpa_desig/scratch/reshape")
in_folder2=("C:/Data/wdpa_desig/scratch/grids/grids.gdb")


arcpy.env.workspace = in_folder2 +"/"
gridCellID="GID"
listFC=arcpy.ListFeatureClasses()
for fc in listFC[3:]:
    print "adding field to: " +str(fc)
    beginTime1 = time.clock()
    arcpy.AddField_management(fc,gridCellID,"LONG")
    print "calculating field for: " +str(fc)
    arcpy.CalculateField_management(fc,field=gridCellID,
                                    expression="""!OBJECTID!""",
                                    expression_type="PYTHON_9.3")

    print  "Finished processing for :"   + str(fc)
    print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
