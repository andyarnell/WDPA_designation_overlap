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
wkspce2=r"C:\Data\wdpa_desig\scratch\regional\precise_int_dbfs"
wkspce3=r"C:\Data\wdpa_desig\scratch\regional\fnets\fnets.gdb"
wkspce4=r"C:\Data\wdpa_desig\scratch\regional\precise_temp_fcs\temp.gdb"
wkspce5=r"C:\Data\wdpa_desig\scratch\regional\admin"

####featureClass = r"C:\Users\marined\Desktop\OVERLAP_APR2016\OVERLAP_1km.gdb\Fishnet_1km_clip_to_Land_Moll" ## path to feature class
#inFC_zone="Fishnet_1km_clip_to_Land_Moll"
inFC_main="WDPApoly_all_PPR2016_Mollweide_with_tbry_fixed_w_regions"
inFC_subgroups="EEZv8_v7_copy_Land_regional_dissolve_Mollweide"
#fieldList = arcpy.ListFields(inFC_zone) ### simply pointer to location

##change to field name
flds = ("GEOandUNEP")

##prefix for output filename
prefix="country"
prefix2="fnet"
prefix3="fnetwdpa"
#where to start iterating through - default should be 0
startNum = 3


#tempObjectID="FISHNET_ID"


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


#comparing to other values in other layer
arcpy.env.workspace = wkspce3
listVals2=[]
listVals2=arcpy.ListFeatureClasses(wild_card='fnet_*')
print "list vals2: " + str(listVals2)
arcpy.env.workspace = wkspce1

##listValsTemp=[]
##for s in listVals2:
##    listValsTemp.append(s.replace('fnet_', ''))
##print "testing:" + str(listValsTemp)
##listVals2=listValsTemp
##del(listValsTemp)

listVals2=[]

with arcpy.da.SearchCursor(inFC_subgroups,flds) as cur2:
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
listExcept=[None]

#removing those on exception list from list of those to run
listValsBth = list(set(listValsBth) - set(listExcept))

print listValsBth
print "listValsBth: " + str(len(listValsBth))

################################################################################
inMem = True #temp

for val in listValsBth[startNum:]:
        beginTime1 = time.clock()
        i += 1
        env.workspace = wkspce1 ## path to feature class
        #val='USA'
        print "\nLoop counter: "+ str(i)
        in_memory_feature = "in_memory\\"+ str(i)
        selectString=""" {0} = '{1}' """.format(flds,(val))
        print "Selection string:" +selectString
        print "Selecting PAs using subgroups code"
        arcpy.MakeFeatureLayer_management(inFC_main, in_memory_feature,selectString)
        result0 = arcpy.GetCount_management(in_memory_feature)
        count0 = int(result0.getOutput(0))
        print "Number of rows selected: " +str(count0)
        in_memory_feature2 = "in_memory\\"+ str(i)+"2"
        #selectString=""" {0} = '{1}' AND type = 'Land' """.format(flds,(val)) #deprecated for regional as land is implied
        selectString=""" {0} = '{1}'""".format(flds,(val))
        print "Selecting admin outline using subgroups - currently land only"
        print "Selection string:" +selectString
        valClean=arcpy.ValidateTableName(val)
        val=valClean
        outFC = wkspce5+"/"+prefix+"_"+str(valClean)+".shp"
        arcpy.Select_analysis(inFC_subgroups,outFC,selectString)
        arcpy.MakeFeatureLayer_management(inFC_subgroups, in_memory_feature2,selectString)
        
        result = arcpy.GetCount_management(in_memory_feature2)
        count = int(result.getOutput(0))
        print "FeatureClass stored: "+ str(outFC)
        #arcpy.CopyFeatures_management(in_memory_feature2,outFC) 
        #arcpy.env.extent = outFC
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
##        print "Number of rows selected: " +str(count)
        grid_regional=outFC#wkspce3+"/"+prefix2+"_"+str(valClean[0:15])
        print grid_regional
        in_memory_feature3 = "in_memory\\"+ str(i)+"3"
        def findField(fc, fi):
            fieldnames = [field.name for field in arcpy.ListFields(fc)]
            if fi in fieldnames:
              return True
            else:
              return False
        if findField(grid_regional,"GID")==False:
            gridCellID="GID"
            print "no GID field so adding field :"+ gridCellID+ "- for feature class: " +str(grid_regional)
            arcpy.AddField_management(grid_regional,gridCellID,"LONG")
            print "calculating field for: " +str(grid_regional)
            arcpy.CalculateField_management(grid_regional,field=gridCellID,expression="""!FID!""",expression_type="PYTHON_9.3")
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            
        
        flds2="WDPAID;subgroups;DESIG_ENG"
        in_memory_feature3=grid_regional
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
            print "adding geodesic area column for filtering out small polygons later"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "AREA_GEODESIC", Area_Unit="SQUARE_KILOMETERS")
            print "adding centroid column for aggregating by in r code"
            arcpy.AddGeometryAttributes_management (inMemIntUnionFC, "CENTROID_INSIDE")            
            intUnionFC=val+"_preciseAdminIntUnionFC"
            print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
            print "Saving vector and dbfs for analysis in R"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionFC)
            ##try:
            arcpy.TableToTable_conversion(inMemIntUnionFC,wkspce2,intUnionFC+".dbf")
            ##except:
            ##    print "Skipping table copying as causing errors"
            arcpy.DeleteIdentical_management(inMemIntUnionFC, ["GID", "INSIDE_X", "INSIDE_Y", "AREA_GEO"])
            print "removing identical features using centroid and area fields - allows joins at later date"
            intUnionUniqFC=val+"_preciseAdminIntUnionUniqFC"
            arcpy.CopyFeatures_management(inMemIntUnionFC,intUnionUniqFC)
            arcpy.Delete_management(intFC)
            arcpy.Delete_management(in_memory_feature)
            arcpy.Delete_management(in_memory_feature2)
            del in_memory_feature2
            del result
            del count
            del grid_regional
            del inMemIntUnionFC
            env.workspace = wkspce1
        else:
            
            print "Skipping intersection as no cells intersect PAs"
            arcpy.Delete_management(intFC)
            arcpy.Delete_management(in_memory_feature)
            arcpy.Delete_management(in_memory_feature2)
            del in_memory_feature2
            del result
            del count
            del grid_regional

        
        #print "Number of rows selected: " +str(count)
        print("Elapsed time (minutes): " + str((time.clock() - beginTime1)/60))

        
       # except:
        #    print "\n ###################ERROR with selection string:" +selectString+"\n"
        print("For subgroups - elapsed time (minutes): " + str((time.clock() - beginTime1)/60))
#arcpy.Delete_management("in_memory")


print "Finished processing"
print("Total elapsed time (minutes): " + str((time.clock() - beginTime)/60))
