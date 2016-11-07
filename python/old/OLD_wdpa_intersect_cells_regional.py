print('Importing modules')
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
import time

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

#enabling overwrite
env.overwriteOutput = True

beginTime = time.clock()

##defining workspaces
wkspce1=r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb"
wkspce2=r"C:\Users\marined\Desktop\OVERLAP_APR2016\scratch\regional\tables"
wkspce3=r"C:\Users\marined\Desktop\OVERLAP_APR2016\scratch\regional\admin"
wkspce4=r"C:\Users\marined\Desktop\OVERLAP_APR2016\scratch\regional\fnets\fnets.gdb"

env.workspace = wkspce1 ## path to feature class
inFC_zone="Fishnet_1km_clip_to_Land_Moll"
inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed"
inFC_iso3=r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\EEZv8_WVS7_Dis_copy_Land_Mollweide_NEW_UPDATED"
inFC_region=r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\EEZv8_v7_copy_Land_regional_dissolve_Mollweide"
inFC_LUT=r"C:\Users\marined\Desktop\OVERLAP_APR2016\ISO_regions.dbf"

##change to field name
flds = ("ISO3")
flds2 = ("GEOandUNEP")

##prefix for output filename
prefix="country"
prefix2="fnet"
prefix3="fnetwdpa"

#where to start iterating through - default should be 0
#these can be changed to allow starting from a specific regoin and country depending on where theye are in the lists
countryStartNum = 0
regionStartNum = 0

#which fiel to use as an ID for the grids (there is some repetition but the tabular outputs can be joined to the fishnet grids for their country
tempObjectID="OBJECTID"

######################################################
#setting workspace
arcpy.env.workspace = wkspce1


print "Input FeatureClass: {}".format(inFC_main)
    
#making list of attributes
listVals=[]
with arcpy.da.SearchCursor(inFC_main,flds) as cur:
    for row in cur:
        listVals.append((row[0]))


#list of regions
listRegions=[]
with arcpy.da.SearchCursor(inFC_region,flds2) as cur:
    for row in cur:
        listRegions.append((row[0]))

#removing duplicates
listRegions=list(set(listRegions))
print listRegions
print "listRegions: " + str(len(listRegions))

del cur
#removing duplicates
listVals=list(set(listVals))

listVals2=[]

with arcpy.da.SearchCursor(inFC_iso3,flds) as cur2:
    for row in cur2:
        listVals2.append((row[0]))

del cur2
listVals2=list(set(listVals2))

listValsBth = list(set(listVals).intersection(listVals2))
print listValsBth
print "listValsBth: " + str(len(listValsBth))



listValsExtr = [item for item in listVals if item not in listVals2]
listVals2Extr = [item for item in listVals2 if item not in listVals]

listValsExtr = [item for item in listVals if item not in listVals2]
print "listValsExtr: \n" + str(len(listValsExtr))
print "listValsExtr: \n" + str(listValsExtr)

                              
listVals2Extr = [item for item in listVals2 if item not in listVals]
print "listVals2Extr: \n" + str(len(listVals2Extr))
print "listVals2Extr: \n" + str(listVals2Extr)

                               
print "Number of distinct attributes in chosen field: "+ str(len (listVals))


j=regionStartNum
listExcept=['CHN','BRA','CAN','AUS','IND','RUS']#missed out - 'USA' - rerun!!!!

listValsBth = list(set(listValsBth) - set(listExcept))


print listValsBth
print "listValsBth: " + str(len(listValsBth))

def buildWhereClauseFromList(table, field, valueList):
    """Takes a list of values and constructs a SQL WHERE
    clause to select those values within a given field and table."""

    # Add DBMS-specific field delimiters
    fieldDelimited = arcpy.AddFieldDelimiters(arcpy.Describe(table).path, field)

    # Determine field type
    fieldType = arcpy.ListFields(table, field)[0].type

    # Add single-quotes for string field values
    if str(fieldType) == 'String':
        valueList = ["'%s'" % value for value in valueList]

    # Format WHERE clause in the form of an IN statement
    whereClause = "%s IN(%s)" % (fieldDelimited, ', '.join(map(str, valueList)))
    return whereClause


listValsBth=listExcept
for region in listRegions[regionStartNum:]:
    j += 1
    #sql="""{0}=='{1}'""".format(flds2,region)
    #print sql
    in_memory_feature0 = "in_memory\\reg"+ str(j)
    sql = arcpy.AddFieldDelimiters(inFC_region,flds2) +"""='{0}'""".format(region)
    arcpy.MakeFeatureLayer_management(inFC_region, in_memory_feature0,sql)#may need to swap slection string for seperate select by attributes step
    sql = arcpy.AddFieldDelimiters(inFC_LUT,flds2) +"""='{0}'""".format(region)
    print sql
    listVals3 = []
    with arcpy.da.SearchCursor(inFC_LUT,flds,sql) as cur2:
        for row in cur2:
            listVals3.append((row[0]))
    listVals3=list(set(listVals3))
    whereClause=buildWhereClauseFromList(inFC_main, flds, listVals3)
    in_memory_feature1 = "in_memory\\wdpa"+ str(j)
    
    print "Selection string:" +whereClause
    print "Selecting PAs using iso3 code"
    #arcpy.SelectByAttributes(inFC_main, whereClause)
    arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature1,whereClause)#may need to swap slection string for seperate select by attributes step
    result = arcpy.GetCount_management(in_memory_feature1)
    count = int(result.getOutput(0))
    print "Number of rows selected: " +str(count)
    listValsBth2=list(set(listValsBth).intersection(listVals3))
    print listValsBth2
    #Make feature layer for that region
    i=0
    for val in listValsBth2[countryStartNum:]:
            #selectString=""" {0} = '{1}' """.format(flds,(val))
            beginTime1 = time.clock()
            i += 1
            #try:
            #val='COD'
            #in_memory_feature4=
            print "\nLoop counter: "+ str(i)
            #in_memory_feature = "in_memory\\"+ str(i)
            #selectString=""" {0} = '{1}' """.format(flds,(val))
            #print "Selection string:" +selectString
            #print "Selecting PAs using iso3 code"
            #arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
            #result = arcpy.GetCount_management(in_memory_feature)
            #count = int(result.getOutput(0))
            #print "Number of rows selected: " +str(count)
            in_memory_feature2 = "in_memory\\cntry"+ str(i)+"2"
            selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val))
            
            print "Selecting admin outline using iso3 - currently land only"
            print "Selection string:" +selectString
            arcpy.MakeFeatureLayer_management(inFC_iso3, in_memory_feature2,selectString)
            
            valClean=arcpy.ValidateTableName(val)
            outFC = wkspce3+"/"+prefix+"_"+"_"+str(valClean[0:15])+".shp"
            result = arcpy.GetCount_management(in_memory_feature2)
            count = int(result.getOutput(0))
            
            print "FeatureClass stored: "+ str(outFC)
            arcpy.Select_analysis(inFC_iso3, outFC,selectString)
#            arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
            arcpy.env.extent = outFC
            ext=arcpy.Describe(outFC)
            print ext.extent
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Number of rows selected: " +str(count)
            grid_national=wkspce4+"/"+prefix2+"_"+str(valClean[0:15])
            in_memory_feature3 = "in_memory\\"+ str(i)+"3"
            if arcpy.Exists(grid_national):
                print "Skipping selecting and clipping grid by admin boundary, as clipped feature class exists: " + str(grid_national)
                inMem = True
                pass
            else:
                try:
                    inMem = True
                    print "Selecting grid cells using admin boundary"
                    arcpy.MakeFeatureLayer_management(inFC_zone, in_memory_feature3)
                    arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature2)
                    result = arcpy.GetCount_management(in_memory_feature3)
                    count = int(result.getOutput(0))
                    print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
                    print "Clipping grid cells using admin boundary"
                    arcpy.Clip_analysis(in_memory_feature3,in_memory_feature0,grid_national)
                    print "Clipped grid cells stored here: "+grid_national
                    print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
                    arcpy.Delete_management(in_memory_feature3)
                except:
                    inMem = False
                    print "WARNING: error when selecting cells by admin boundary - likely too big for memory (RAM)., so now attempting clip on main grid using hard disk"
                    print "Clipping grid cells using admin boundary"
                    arcpy.Clip_analysis(inFC_zone,in_memory_feature0,grid_national)
                    print "Clipped grid cells stored here: "+grid_national
                    print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
                    arcpy.Delete_management(in_memory_feature3)
                    pass
            if inMem == True:
                print "Putting clipped grid into memory (RAM)"
                arcpy.MakeFeatureLayer_management(grid_national, in_memory_feature3)
                result = arcpy.GetCount_management(in_memory_feature3)
                count = int(result.getOutput(0))
                print "Number of rows selected: " +str(count)
                print "Selecting clipped grid cells overlapping PAs for this iso3 code"
                arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature1)
                grid_national_sel=wkspce4+"/"+prefix3+"_"+str(valClean[0:15])
                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
                print "Copying selected cells (those that overlap with PAs) to: " + str(grid_national_sel)
                arcpy.CopyFeatures_management(in_memory_feature3,grid_national_sel)
                result = arcpy.GetCount_management(in_memory_feature3)
                count = int(result.getOutput(0))
                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            else:
                in_memory_feature3=grid_national
                pass
            flds3="WDPAID;ISO3;DESIG_ENG"
            print "Tabulating intersection between cells and pas using: "+flds3
            if count > 0:
                arcpy.TabulateIntersection_analysis(in_zone_features=in_memory_feature3,zone_fields=tempObjectID,
                                                in_class_features=in_memory_feature1,out_table=wkspce1+"/"+"Temp_Tab",class_fields=flds3,sum_fields="#",xy_tolerance="#",out_units="SQUARE_KILOMETERS")
                outFile="tabInt_split_{0}.dbf".format(val)
                print "copying output table from temp folder to: " + wkspce2
                arcpy.TableToTable_conversion (wkspce1+"/"+"Temp_Tab",wkspce2,outFile)
            else:
                print "Skipping intersection as no cells intersect PAs"
                pass
            #print "Number of rows selected: " +str(count)
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            
            arcpy.Delete_management(in_memory_feature2)
            arcpy.Delete_management(in_memory_feature3)
            
            del (in_memory_feature2)
            del (in_memory_feature3)
            arcpy.Delete_management(wkspce1+"/"+"Temp_Tab")
            
           # except:
            #    print "\n ###################ERROR with selection string:" +selectString+"\n"
            print("For iso3 - elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
    arcpy.Delete_management(in_memory_feature1)
    del (in_memory_feature1)
        
arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
