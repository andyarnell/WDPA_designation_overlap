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

#choose if land or marine (type True for land or False for marine)
land=False


####featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
#inFC_zone="Fishnet_1km_clip_to_Land_Moll"
#inFC_main="WDPA_DTmarineAndterrestrial_erase"

# for national
#inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed_copy"

# for regional
inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed_unepregion"

# for national
inFC_iso3="eezv8_v7_raw_mol_no_dt"

#for regional
#inFC_iso3="eezv8_v7_raw_mol_no_dt_diss_region"


##change to field name of iso3 for the different layers
# for national
fldsMain = ("ISO3")
fldsZone = ("ISO3_edt")

#for regional
#fldsMain = ("GEOandUNEP")
#fldsZone = ("GEOandUNEP")

##prefix for output filename
prefix="country"
prefix2="fnet"
prefix3="fnetwdpa"

#where to start iterating through - default should be 0
startNum = 0


tempObjectID="FISHNET_ID"


######################################################
#setting workspace
arcpy.env.workspace = wkspce1
listVals=[]

##print "Input FeatureClass: {}".format(inFC_main)
##    making list of attributes                         
with arcpy.da.SearchCursor(inFC_main,fldsMain) as cur:
    for row in cur:
        listVals.append((row[0]))

del cur
#removing duplicates
listVals=list(set(listVals))
print "list vals: " + str(listVals)


arcpy.env.workspace = wkspce1

##listValsTemp=[]
##for s in listVals2:
##    listValsTemp.append(s.replace('fnet_', ''))
##print "testing:" + str(listValsTemp)
##listVals2=listValsTemp
##del(listValsTemp)

listVals2=[]

with arcpy.da.SearchCursor(inFC_iso3,fldsZone) as cur2:
    for row in cur2:
        listVals2.append((row[0]))



####seeing which countries are not in both the wdpa and the admin layer
        
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

i = startNum
#######################################################################


#############################################################################
###list to run seperateley for those that seem to crash due to their size
#listExcept=['BRA','CAN','CHN','AUS']#missed out - 'USA' 'RUS' 'IND'- rerun!!!!
#listExcept=['RUS','IND','BRA','USA','CAN','AUS','DEU','FRA','CHL','SXM','CIV','GRL']
listExcept=[]

#removing those on exception list from list of those to run
listValsBth = list(set(listValsBth) - set(listExcept))

#listValsBth=listExcept

print listValsBth
listValsBth.sort()
print "listValsBth: " + str(len(listValsBth))

################################################################################
inMem = True #temp

#[u'Europe', u'Polar', u'West Asia', u'ABNJ', u'Asia + Pacific', u'Africa', u'Latin America + Caribbean', u'North America']
#listValsBth=['Polar', 'Asia + Pacific', 'Africa', 'Latin America + Caribbean']
#listValsBth = ['GBR' , 'DEU', 'DNK', 'ESP']
print listValsBth

in_memory_feature = "in_memory\\"+ str(i)
arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature)

for val in listValsBth[startNum:]:
        beginTime1 = time.clock()
        i += 1
        env.workspace = wkspce1 ## path to feature class
        #val='Latin America + Caribbean'##uncomment to run on a specific value (ISO3/region). To stop looping change [startNum:] to [startNum:1].
        #val="GBR"
        print "\nLoop counter: "+ str(i)
        #in_memory_feature = "in_memory\\"+ str(i)
        #selectString=""" {0} = '{1}' """.format(fldsMain,(val))
        #print "Selection string:" +selectString
        print "Selecting PAs using iso3 code"
        #arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature)
        result0 = arcpy.GetCount_management(in_memory_feature)
        count0 = int(result0.getOutput(0))
        print "Number of rows selected: " +str(count0)
        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
        if land:
            selectString=""" {0} = '{1}' AND type = 'Land'""".format(fldsZone,(val))
            #selectString="""type = 'Land'"""
        else:
            selectString=""" {0} = '{1}' AND (type = 'EEZ' or type = 'ABNJ')""".format(fldsZone,(val))
            #selectString="""type = 'EEZ' or type = 'ABNJ'"""
        print "Selecting admin outline using iso3 - currently land only"
        print "Selection string:" +selectString
        valClean=arcpy.ValidateTableName(val)
        val=valClean
        #valClean=val
        outFC = wkspce5+"/"+prefix+"_"+str(valClean)+".shp"
        arcpy.Select_analysis(inFC_iso3,outFC,selectString)
        arcpy.MakeFeatureLayer_management(inFC_iso3, in_memory_feature2,selectString)
        
        result = arcpy.GetCount_management(in_memory_feature2)
        count = int(result.getOutput(0))
        print "FeatureClass stored: "+ str(outFC)
        #arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
        #arcpy.env.extent = outFC
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##        print "Number of rows selected: " +str(count)
        grid_national=outFC#wkspce3+"/"+prefix2+"_"+str(valClean[0:15])
        print grid_national
        in_memory_feature3 = "in_memory\\"+ str(i)+"3"
        def findField(fc, fi):
            fieldnames = [field.name for field in arcpy.ListFields(fc)]
            if fi in fieldnames:
              return True
            else:
              return False
        if findField(grid_national,"GID")==False:
            gridCellID="GID"
            print "no GID field so adding field :"+ gridCellID+ "- for feature class: " +str(grid_national)
            arcpy.AddField_management(grid_national,gridCellID,"LONG")
            print "calculating field for: " +str(grid_national)
            arcpy.CalculateField_management(grid_national,field=gridCellID,expression="""!FID!""",expression_type="PYTHON_9.3")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            
        
        #flds2="WDPAID;ISO3;DESIG_ENG"
        in_memory_feature3=grid_national
        if count > 0:
            env.workspace = wkspce4 
            print "Intersecting grid and wdpa"
            intFC=val+"_preciseInt"
            inFCs=""" " """ + in_memory_feature3+ ";"+in_memory_feature+""" " """
            print inFCs
            arcpy.env.XYTolerance = "0.1 Meters"
            arcpy.Intersect_analysis(in_features=inFCs,out_feature_class=intFC,join_attributes="ALL",cluster_tolerance="#",output_type="INPUT")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            #arcpy.TableToTable_conversion(intFC,wkspce2,intFC+".dbf")
            #print "dissolving WDPA by designation"
            #intDissFC=val+"precise_int_diss"
            #dissField="FID_fnet_{0}".format(val)
            #dissExpr="FID_fnet_{0};DESIG_ENG".format(val)
            inMemIntFC="in_memory\\"+ str(i)+"4"
            print "putting fc in memory"
            arcpy.MakeFeatureLayer_management(intFC, inMemIntFC)
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            #inMemIntDissFC="in_memory\\" str(i)+"5"
            #arcpy.Dissolve_management(in_features=inMemIntFC,out_feature_class=intDissFC,dissolve_field=dissExpr,statistics_fields="#",multi_part="SINGLE_PART",unsplit_lines="DISSOLVE_LINES")
            inMemIntUnionFC="in_memory\\inmem"+ str(i)+"5"
            print "union between wdpa and grid"
            arcpy.Union_analysis(in_features= inMemIntFC,out_feature_class=inMemIntUnionFC,join_attributes="ALL",cluster_tolerance="#",gaps="GAPS")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            #splitting to singlepart so that slithers can be removed more effectively as areas are for smallest part
            inMemIntUnionFCsinglepart=("in_memory\\inmem"+ str(i)+"6")
            try:
                arcpy.MultipartToSinglepart_management(inMemIntUnionFC,inMemIntUnionFCsinglepart)
                inMemIntUnionFC=inMemIntUnionFCsinglepart
            except:        
                print "repairing geometry due to errors"
                arcpy.RepairGeometry_management (inMemIntUnionFC)
                #arcpy.MultipartToSinglepart_management(inMemIntUnionFC,inMemIntUnionFCsinglepart)
            #recoding so that code afterwards doesn't need changing
            #del(inMemIntUnionFCsinglepart)
            print "adding geodesic area column for filtering out small polygons later"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
            print "adding centroid column for aggregating by in r code"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "CENTROID_INSIDE")            
            arcpy.AddField_management(inMemIntUnionFC,"xy_join","TEXT",field_length="30")
        
            arcpy.CalculateField_management(in_table=inMemIntUnionFC, field="xy_join", expression="str(round(!INSIDE_X!,0))+'_'+str(round(!INSIDE_Y!,0))", expression_type="PYTHON_9.3", code_block="")
                
            intUnionFC=val+"_preciseAdminIntUnionFC"
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Saving vector and dbfs for analysis in R"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionFC)
            try:
                arcpy.TableToTable_conversion(inMemIntUnionFC,wkspce2,intUnionFC+".csv")
                #arcpy.ConvertTableToCsvFile_roads (in_table, out_csv_file, {in_delimiter})
            except:
                print "Skipping table copying as causing errors"
            arcpy.DeleteIdentical_management(inMemIntUnionFC, ["INSIDE_X", "INSIDE_Y","AREA_GEO"])
            print "removing identical features using centroid and area fields - allows joins at later date"
            intUnionUniqFC=val+"_preciseAdminIntUnionUniqFC"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionUniqFC)
            #arcpy.Delete_management(intFC)
            #arcpy.Delete_management(in_memory_feature)
            arcpy.Delete_management(in_memory_feature2)
            del in_memory_feature2
            del result
            del count
            del grid_national
            del inMemIntUnionFC
            env.workspace = wkspce1
        else:
            
            print "Skipping intersection as no cells intersect PAs"
            #arcpy.Delete_management(intFC)
            #arcpy.Delete_management(in_memory_feature)
            arcpy.Delete_management(in_memory_feature2)
            del in_memory_feature2
            del result
            del count
            del grid_national

        
        #print "Number of rows selected: " +str(count)
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))

        
       # except:
        #    print "\n ###################ERROR with selection string:" +selectString+"\n"
        print("For iso3 - elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
#arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
