print('Importing modules')

import sys
import arcpy
import time
from arcpy import env
#from arcpy.sa import *


# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

arcpy.env.overwriteOutput = True

beginTime = time.clock()



wkspce1=r"C:\Data\test\wdpa_intersect.gdb"
arcpy.env.workspace = wkspce1
listFCs=arcpy.ListFeatureClasses("*grid*")

startNum=0
print listFCs
for FC in listFCs[startNum:]:
    #FC= "gridLSO"
    field=FC[-3:]
    print field
    beginTime2 = time.clock()
    tempObjectID="OBJECTID"
    grid_national=FC
    print grid_national
    beginTime2 = time.clock()
    print "Adding area to grid"
    #arcpy.AddGeometryAttributes_management(Input_Features=grid_national,Geometry_Properties="AREA_GEODESIC",Length_Unit="#",Area_Unit="SQUARE_KILOMETERS",Coordinate_System="#")
    print "Adding field and creating a unique id from iso3 code and fishnet id"
    #arcpy.AddField_management(in_table=grid_national,field_name="fnet_iso",field_type="TEXT",field_length="30")
    #arcpy.CalculateField_management(in_table=grid_national,field="fnet_iso", expression="'{0}' +str(!OBJECTID!)".format(field),expression_type="PYTHON_9.3",code_block="#")
    print("Elapsed time (minutes): " + str((time.clock() - beginTime2)/60))
