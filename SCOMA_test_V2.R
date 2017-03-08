rm(list=ls())
graphics.off() 
wd<- setwd("C:/Users/W0038460/ownCloud/SCOMA/APSIM_modelling/R/results")
library(xml2)


in.dir = "C:/Users/W0038460/ownCloud/SCOMA/APSIM_modelling/scoma_wheat/"

# STEP 1.create 3 new files for variable 1 viz "init water" using a default APSIM file (called base_file)

# read the base apsim file
base_file = read_xml(paste0(in.dir,'wheat_template.apsim'))
# change the initial water
initial_water <- xml_find_first(base_file, '//InitialWater')
fraction_water <- xml_find_all(initial_water, '//FractionFull')

int_water_run <- c(1.0, 0.50, 0.25)
# run a loop so that it will replaces base value with the new value
for(a in int_water_run){
  for (i in fraction_water) {
    old <- xml_double(fraction_water) 
    new <- a
    xml_text(fraction_water) <- as.character(new)  # Assign new value back into xml document
  }
  
  file_path <- "ini_wat"
  if (!file.exists(file_path)) {
    dir.create(paste0(file_path)) #create a new directory, to store the outputs
  }
  write_xml(base_file, file = paste0(file_path, '/ini.wat=', a, '.apsim'))
  }

# STEP B create 3 new files for variable 2 viz "XF", for all the 3 output files from STEP A

# read the 3 ini water files created from STEP A
init_wat_files = list.files("ini_wat", pattern = ".apsim", full.names =  TRUE)

# read the 3 int water files and replace the XF variable values for each of 3 files

for (e in init_wat_files) {
  read_init_wat_files <- read_xml(e)
  water <- xml_find_first(read_init_wat_files, '//Water')
  SoilCrop <- xml_children(xml_find_first(water, '//SoilCrop'))
  XF <- xml_children(xml_find_first(water, '//XF'))
  
  XF_run <- c(1.0, 0.75, 0.50) # replace with 3 XF values viz 0.85, 0.35 and 0.15
  # replace the value of XF
  for (d in XF_run) {
    for (j in XF) {
      old <- xml_double(XF)
      new <- d
      # Assign new value back into xml document
      xml_text(XF) <- as.character(new)
      file_path <- "XF/"
      if (!file.exists(file_path)) {
        dir.create(paste0(file_path)) #create a new directory called XF to store the XF output files
      }
write_xml(read_init_wat_files,file = paste0(file_path, basename(substr(e, 1, nchar(e) - 6)), '_XF=', d, '.apsim'))
    }
  }
}


## STEP C: add Nitrogen (both NO3 and NH4) variables

N_files = list.files("XF", pattern = ".apsim", full.names =  TRUE)

for (e in N_files) {
  read_N_files <- read_xml(e)
 
# change the Nitrogen Values
nitrogen <- xml_find_first(read_N_files, '//Sample[@name="InitialNitrogen"]')
no3 <- xml_children(xml_find_first(nitrogen, '//NO3'))
nh4<- xml_children(xml_find_first(nitrogen, '//NH4'))
  
# Change the value of both no3 and NH4 
  no3_run <- c(1.0, 0.8, 0.6) # replace original no3 with these values
  nh4_run <- c(1.0, 0.8, 0.6) # replace original no3 with these values
  
# I need to combine two loop fuction in one.. i.e. both NO3 and NH4 values should be replaced 
# simultaneously as a fraction of original values, but I cant do it!!!!
  
# till here everything fine.. Dont know how to proceed further!!!
  
for (d in no3_run) {
for (j in no3) {
old <- xml_double(no3) 
new <- old * d # new value should be the fraction of old value
# Assign new value back into xml document
xml_text(no3) <- as.character(new)
    }
  }
  
for (f in nh4_run) {
for (g in nh4) {
old <- xml_double(nh4) 
new <- old * f 
# Assign new value back into xml document
xml_text(nh4) <- as.character(new)    
}   
}
  
file_path <- "N/"
if (!file.exists(file_path)) {
   dir.create(paste0(file_path))
  write_xml(read_N_files, file = paste0(file_path, basename(substr(e, 1, nchar(e) - 6)), '_N=', d, '.apsim'))      
  }
}
  
# STEP 4 begins here onwards..  
  


  
  
  
# the below code works fine when I run indepently. But, I need a for loop function that can handle an "AND" function
# so that I can combine no3 and NH4 into one..

# note, there are 6 rows of NO3 values to be replaced. 

# Question 1: WHAT TO DO IF I WANT TO REPLACE ONLY THE BOTTOM 3 LINES out of 6 values of NO3? Currently, all the values are replaced
# as a fraction of base file.

# Question 2: I GET THE FOLLOWING WARNING MESSAGE: In dir.create(paste0(file_path)) : 'XF' or 'N' already exists
  
# here is some old code that replaces values seperately for NO3 and NH4
for (i in seq(along = no3)) {
    # i <- 1
    old <- xml_double(no3[[i]]) 
    new <- old * 0.5
    # Assign new value back into xml document
    xml_text(no3[[i]]) <- as.character(new)
}
  
for (i in seq(along = nh4)) {
    # i <- 1
    old <- xml_double(nh4[[i]]) 
    new <- old * 0.5
    # Assign new value back into xml document
    xml_text(nh4[[i]]) <- as.character(new)
  }
  























