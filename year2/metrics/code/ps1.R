################################################################################
# Applied Microeconometrics - Problem Set 1
# Zachary Kuloszewski
################################################################################

library(tidyverse)
library(ggplot2)
library(reshape2)
library(data.table)
library(dplyr)

## set user paths
user_path <- function() {
  user <- Sys.info()["user"]
  
  if (user == "zachkuloszewski"){
    path = "/Users/zachkuloszewski/Library/CloudStorage/Dropbox/My Mac (Zachs-MBP.lan)/Documents/GitHub/phd_psets/year2/metrics/"
  } 
  else if (user == ""){
    path = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  stopifnot(file.exists(path))
  return(path)
}





