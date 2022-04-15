################################################################################
# Author : Manh-Hung Le, Hong Xuan Do                                      #
################################################################################                                                       #
# Updates: 14-Apr-2022                                                        #
#                                                                  #
################################################################################

ras_2_points_in_timeseries = function(mainPath, excelPath, excelSheet, rawrasPath, noCores, outputName){
  
  # packages
  library(readxl)
  library(raster)
  library(tidyverse)
  library(doParallel)
  
  
  # create processing folder
  dir.create(file.path(mainPath,'proccesed'), showWarnings = F)
  processedPath = file.path(mainPath,'proccesed')
  
  # read point coordinates from excel file
  pointDat = read_xls(excelPath, sheet = excelSheet)
  # convert to data.frame
  pointDat = data.frame(pointDat)
  # convert point coordinates to spatial information
  pointsp =  pointDat[,c("NAME","LONG","LAT")]
  coordinates(pointsp) <- c("LONG", "LAT") # chuyen thanh dang khong gian
  proj4string(pointsp) <- "+proj=longlat +datum=WGS84 +ellps=WGS84" # gan toa do
  
  # read raster files (raster)
  listrawRas = list.files(rawrasPath, pattern = '.tif', 
                          recursive = T, full.names = T)
  n = length(listrawRas)
  # obtain date informaiton
  dates = substr(basename(listrawRas),8,15)
  
  cl = makeCluster(noCores)
  clusterEvalQ(cl, library("raster"))
  # export library raster to all cores
  clusterEvalQ(cl, library("raster"))
  clusterEvalQ(cl, library("tidyverse"))
  
  t = parLapply(cl = cl, 1:n,
                function(ll,listrawRas, pointsp){
                  Ras = raster(listrawRas[ll]) 
                  raster::extract(Ras,pointsp) %>% 
                    round(3) %>% t
                }, listrawRas, pointsp # you need to pass these variables into the clusters
  )
  r2point = do.call(rbind,t) # each subcatchment is a column
  stopCluster(cl)
  
  
  # format lai so lieu chiet xuat
  colnames(r2point) = pointDat$NAME
  r2pointFinal = data.frame(dates = dates,
                            r2point)
  
  opPath = paste(processedPath, '/',outputName,'_points.csv', sep = '')
  write.csv(r2pointFinal, opPath,row.names = F)
}