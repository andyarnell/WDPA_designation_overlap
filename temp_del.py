        arcpy.Delete_management(in_memory_feature)
        arcpy.Delete_management(in_memory_feature2)
        arcpy.Delete_management(in_memory_feature3)
        arcpy.Delete_management(wkspce1+"/"+"Temp_Tab")
        del (in_memory_feature)
        del (in_memory_feature2)
        del (in_memory_feature3)
        del result
        del count
        del grid_national
        del grid_national_sel
        del inMem
        del selectString
        del valClean
        del FC