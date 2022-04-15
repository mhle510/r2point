##############################
# Objectives
# - Extract time series from points with WGS coordinates


##############################


# step 1- path setup
mainPath = "D:/r2point"
setwd(mainPath)

# step 2 - package calling 
source(file.path(mainPath,'ras_2_points_in_timeseries.r'))
library(rgdal)
library(readxl)
library(tictoc)

# step 3 - path load
# path to points 
excelPath = file.path(mainPath, 'input','points','raingauge_coords.xls')
excel_sheets(excelPath)

# path to raw raster folder
rawrasPath = file.path(mainPath, 'input','rawras')

# step 4 - run
tic()
ras_2_points_in_timeseries(mainPath = mainPath, # main folder path
                           excelPath = excelPath, # path to excel files
                           excelSheet = 'mekongdelta', # name of point coordinates
                           rawrasPath = rawrasPath, # path to raw raster folder
                           noCores = 10,# number of cores to run parallel
                           outputName = 'banyen') # name of output
toc()

