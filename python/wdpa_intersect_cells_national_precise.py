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
##
wkspce1=r"C:\Data\wdpa_desig\raw\wdpa_desig_inputs.gdb"
wkspce2=r"C:\Data\wdpa_desig\scratch\national\precise_int_dbfs"
wkspce3=r"C:\Data\wdpa_desig\scratch\national\fnets\fnets.gdb"
wkspce4=r"C:\Data\wdpa_desig\scratch\national\precise_temp_fcs\temp.gdb"
####featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
inFC_zone="Fishnet_1km_clip_to_Land_Moll"
inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed"
inFC_iso3="EEZv8_WVS7_Dis_copy_Land_Mollweide_NEW_UPDATED"
#fieldList = arcpy.ListFields(inFC_zone) ### simply pointer to location

##change to field name
flds = ("ISO3")

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
with arcpy.da.SearchCursor(inFC_main,flds) as cur:
    for row in cur:
        listVals.append((row[0]))

del cur
#removing duplicates
listVals=list(set(listVals))
print "list vals: " + str(listVals)

arcpy.env.workspace = wkspce3
#listVals2=[]
listVals2=arcpy.ListFeatureClasses(wild_card='fnet_*')
print "list vals2: " + str(listVals2)
arcpy.env.workspace = wkspce1

listValsTemp=[]
for s in listVals2:
    listValsTemp.append(s.replace('fnet_', ''))
print "testing:" + str(listValsTemp)
listVals2=listValsTemp
del(listValsTemp)

##listVals2=[]
##
##with arcpy.da.SearchCursor(inFC_iso3,flds) as cur2:
##    for row in cur2:
##        listVals2.append((row[0]))
##
##
##
######seeing which countries are not in both the wdpa and the admin layer
##        
##del cur2

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
listExcept=['BRA','CAN','CHN','AUS']#missed out - 'USA' 'RUS' 'IND'- rerun!!!!
listExcept=['USA', 'RUS', 'IND']

#removing those on exception list from list of those to run
listValsBth = list(set(listValsBth) - set(listExcept))

print listValsBth
print "listValsBth: " + str(len(listValsBth))

################################################################################
inMem = True #temp

for val in listExcept[startNum:]:
        beginTime1 = time.clock()
        i += 1
        env.workspace = wkspce1 ## path to feature class
        #val='ARE'
        print "\nLoop counter: "+ str(i)
        in_memory_feature = "in_memory\\"+ str(i)
        selectString=""" {0} = '{1}' """.format(flds,(val))
        print "Selection string:" +selectString
        print "Selecting PAs using iso3 code"
        arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
        result = arcpy.GetCount_management(in_memory_feature)
        count = int(result.getOutput(0))
        print "Number of rows selected: " +str(count)
##        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
##        selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val))
##        print "Selecting admin outline using iso3 - currently land only"
##        print "Selection string:" +selectString
##        arcpy.MakeFeatureLayer_management(inFC_iso3, in_memory_feature2,selectString)
        valClean=arcpy.ValidateTableName(val)
##        outFC = wkspce3+"/"+prefix+"_"+"_"+str(valClean[0:15])+".shp"
##        result = arcpy.GetCount_management(in_memory_feature2)
##        count = int(result.getOutput(0))
##        print "FeatureClass stored: "+ str(outFC)
##        arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
##        arcpy.env.extent = outFC
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##        print "Number of rows selected: " +str(count)
        grid_national=wkspce3+"/"+prefix2+"_"+str(valClean[0:15])
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
            arcpy.CalculateField_management(grid_national,field=gridCellID,expression="""!OBJECTID!""",expression_type="PYTHON_9.3")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            
        
##        if arcpy.Exists(grid_national):
##            print "Skipping selecting and clipping grid by admin boundary, as clipped feature class exists: " + str(grid_national)
##            inMem = True
##            pass
##        else:
##            try:
##                inMem = True
##                print "Selecting grid cells using admin boundary"
##                arcpy.MakeFeatureLayer_management(inFC_zone, in_memory_feature3)
##                arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature2)
##                result = arcpy.GetCount_management(in_memory_feature3)
##                count = int(result.getOutput(0))
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                print "Clipping grid cells using admin boundary"
##                arcpy.Clip_analysis(in_memory_feature3,in_memory_feature2,grid_national)
##                print "Clipped grid cells stored here: "+grid_national
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                arcpy.Delete_management(in_memory_feature3)
##            except:
##                inMem = False
##                print "WARNING: error when selecting cells by admin boundary - likely too big for memory (RAM)., so now attempting clip on main grid using hard disk"
##                print "Clipping grid cells using admin boundary"
##                arcpy.Clip_analysis(inFC_zone,in_memory_feature2,grid_national)
##                print "Clipped grid cells stored here: "+grid_national
##                print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##                arcpy.Delete_management(in_memory_feature3)
##                pass
        if inMem == True:
            print "Putting clipped grid into memory (RAM)"
            arcpy.MakeFeatureLayer_management(grid_national, in_memory_feature3)
            result = arcpy.GetCount_management(in_memory_feature3)
            count = int(result.getOutput(0))
            print "Number of rows selected: " +str(count)
            print "Selecting clipped grid cells overlapping PAs for this iso3 code"
            arcpy.SelectLayerByLocation_management(in_memory_feature3,"INTERSECT",in_memory_feature)
            grid_national_sel=wkspce3+"/"+prefix3+"_"+str(valClean[0:15])
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Copying selected cells (those that overlap with PAs) to: " + str(grid_national_sel)
            arcpy.CopyFeatures_management(in_memory_feature3,grid_national_sel)
            result = arcpy.GetCount_management(in_memory_feature3)
            count = int(result.getOutput(0))
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
        else:
            in_memory_feature3=grid_national
            pass
        flds2="WDPAID;ISO3;DESIG_ENG"
        #tprint "Tabulating intersection between cells and pas using: "+flds2
        if count > 0:
##            arcpy.TabulateIntersection_analysis(in_zone_features=in_memory_feature3,zone_fields=tempObjectID,
##                                            in_class_features=in_memory_feature,out_table=wkspce1+"/"+"Temp_Tab",class_fields=flds2,sum_fields="#",xy_tolerance="#",out_units="SQUARE_KILOMETERS")
##            outFile="tabInt_split_{0}.dbf".format(val)
##            arcpy.TableToTable_conversion (wkspce1+"/"+"Temp_Tab",wkspce2,outFile)
            ####print "Copying dbf output to: " + wkspce2 +"/" + outFile
            env.workspace = wkspce4 
            print "Intersecting grid and wdpa"
            intFC=val+"_preciseInt"
            inFCs=""" " """ + in_memory_feature3+ ";"+in_memory_feature+""" " """
            print inFCs
            arcpy.env.XYTolerance = "0.1 Meters"
            arcpy.Intersect_analysis(in_features=inFCs,out_feature_class=intFC,join_attributes="ALL",cluster_tolerance="#",output_type="INPUT")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            #arcpy.TableToTable_conversion(intFC,wkspce2,intFC+".dbf")
            print "dissolving WDPA by designation"
            #intDissFC=val+"precise_int_diss"
            #dissField="FID_fnet_{0}".format(val)
            dissExpr="FID_fnet_{0};DESIG_ENG".format(val)
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
            print "adding geodesic area column for filtering out small polygons later"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
            print "adding centroid column for aggregating by in r code"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "CENTROID_INSIDE")            
            intUnionFC=val+"_preciseIntUnionFC"
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Saving vector and dbfs for analysis in R"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionFC)
            try:
                arcpy.TableToTable_conversion(inMemIntUnionFC,wkspce2,intUnionFC+".dbf")
            except:
                print "Skipping table copying as causing errors"
            arcpy.DeleteIdentical_management(inMemIntUnionFC, ["GID", "INSIDE_X", "INSIDE_Y", "AREA_GEO"])
            print "removing identical features using centroid and area fields - allows joins at later date"
            intUnionUniqFC=val+"_preciseIntUnionUniqFC"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionUniqFC)
            #inMemIntDissFC="in_memory\\"+ str(i)+"5"
            #arcpy.MakeFeatureLayer_management(intDissFC, inMemIntDissFC)
##            ##arcpy.env.XYTolerance = "0.1 Meters"
##            ##print "importing toolbox"
##            arcpy.ImportToolbox(r'C:\Data\wdpa_desig\Count Overlapping Polygons_faster.tbx')
##            print "counting overlapping polygons"
##            intDissCntFC=val+"precise_int_diss_cnt"
##            arcpy.CountOverlappingPolygons_overlap(Input_Features=InMemIntDissFC,Output_Feature_Class=intDissCntFC)
##            print "adding geodesic area column for filtering out small polygons later"
##            arcpy.AddGeometryAttributes_management (intDissCntFC, "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
##            intDissCntStatFC=val+"precise_int_diss_cnt_stat"
##            arcpy.Statistics_analysis(in_table=intDissCntFC,out_table=intDissCntStatFC,statistics_fields="Join_Count MAX",case_field=dissField)
##            print "getting stats from each cell"
##            arcpy.CopyFeatures_management(in_memory_feature3,"fnet_count_"+val)
##            print "joining max stats to grid"
##            arcpy.JoinField_management("fnet_count_"+val, "OBJECTID", intDissCntStatFC,dissField, "MAX_Join_Count")
##            print "make feature layer with polygons over a certain size"
##            intDissCntFCSmlrem=val+"precise_int_diss_cnt_smlrem"
##            arcpy.MakeFeatureLayer_management (intDissCntFC, intDissCntFCSmlrem, "AREA_GEO>= 0.001")
##            print "save temp layer"
##            arcpy.CopyFeatures_management("aut_precise_int_diss_cnt_smlrem","aut_precise_int_diss_cnt_smlrem1")
            #arcpy.SelectLayerByAttribute_management ("aut_precise_int_diss_cnt_smlrem", {selection_type}, {where_clause})
            #intDissCntFCSmlremStat=val+"precise_int_diss_cnt_smlrem_stat"
            #arcpy.Statistics_analysis(in_table=intDissCntFCSmlrem,out_table=intDissCntFCSmlremStat,statistics_fields="Join_Count MAX",case_field=dissField)
            #print "getting stats from each cell"
            #arcpy.CopyFeatures_management(in_memory_feature3,"fnet_count_smlrem"+val)
            #print "joining max stats to grid"
            #arcpy.JoinField_management("fnet_count_"+val, "OBJECTID",intDissCntStatFC,dissField, "MAX_Join_Count")
            #print "deleting temp file"
            #arcpy.Delete_management("intDissCntFCSmlrem")
            arcpy.Delete_management(in_memory_feature)
            #arcpy.Delete_management(in_memory_feature2)
            arcpy.Delete_management(inMemIntFC)
            arcpy.Delete_management(in_memory_feature3)
            del (in_memory_feature)
            #del (in_memory_feature2)
            del (in_memory_feature3)
            del (inMemIntUnionFC)
            del (inMemIntFC)
        else:
            print "Skipping intersection as no cells intersect PAs"
            
            pass
        #print "Number of rows selected: " +str(count)
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))

        
       # except:
        #    print "\n ###################ERROR with selection string:" +selectString+"\n"
        print("For iso3 - elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
