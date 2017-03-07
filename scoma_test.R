rm(list = ls())
graphics.off()

library(xml2)

# STEP A.create 3 new files for variable 1 viz "init water" using a default APSIM file (called base_file)

# read the base apsim file
base_file <-
  read_xml("wheat_test.apsim")
# change the initial water
initial_water <- xml_find_first(base_file, '//InitialWater')
fraction_water <- xml_find_all(initial_water, '//FractionFull')

# create 3 initial water i.e. 1, 0.5 and 0.25.
# created as characters so that all have same length for filenames, see
# second loop when writing files using `substr()` for reason
int_water_run <- c(1, 0.5, 0.25)
# run a loop so that it will replaces base value with the new value
for (c in int_water_run) {
  for (i in fraction_water) {
    old <- xml_double(fraction_water)
    new <- c
    xml_text(fraction_water) <-
      as.character(new)  # Assign new value back into xml document
  }
  # You only need to create the directory 1X, check to see if the directory exists,
  # if not create it, otherwise go on
  # since you use "ini_wat" 2X, create a new object and use it in your code.
  file_path <- "ini_wat"
  if (!file.exists(file_path)) {
    # use paste0, shortcut for paste(sep = ""), you should not have any
    # messages creating this directory if all goes well
    dir.create(paste0(file_path)) #create a new directory, to store the outputs
  }
  write_xml(base_file, file = paste0(file_path, '/initwat_', c, '.apsim'))
}


# STEP B create 3 new files for variable 2 viz "XF", for all the 3 output files from STEP A

# read the 3 ini water files created from STEP A

init_wat_files <-
  list.files("ini_wat", pattern = ".apsim", full.names =  TRUE)

# read the 3 int water files and replace the XF variable values for each of 3 files

for (m in init_wat_files) {
  read_init_wat_files <- read_xml(m)
  # locate the XF values and replace the 3 XF values viz 0.85, 0.35, 0.15 for each of 3 init water files
  # the below 3 steps should locate the XF value
  water <- xml_find_first(read_init_wat_files, '//Water')
  SoilCrop <- xml_children(xml_find_first(water, '//SoilCrop'))
  XF <- xml_children(xml_find_first(water, '//XF'))

  XF_run <-
    c(0.85, 0.35, 0.15) # replace with 3 XF values viz 0.85, 0.35 and 0.15
  # replace the value of XF
  for (d in XF_run) {
    for (j in XF) {
      old <- xml_double(XF)
      new <- d
      # Assign new value back into xml document
      xml_text(XF) <- as.character(new)
      # only create directory 1X in first loop through
      # since you use "XF" 2X, create a new object and use it in your code.
      file_path <- "ini_wat/XF/"
      if (!file.exists(file_path)) {
        dir.create(paste0(file_path)) #create a new directory called XF to store the XF output files
      }
      # use paste0, shortcut for paste(sep = "")
      # You used "c" from the first for loop, this won't work, you only end up with the last value of "c".
      # instead use the value from the filename to specify the init_wat value, see `?substr` and ?basename
      write_xml(read_init_wat_files,
                # substring removing the ".apsim" for the new filename output
                file = paste0(file_path, basename(
                  substr(m, 1, nchar(m) - 6)
                  ), '_XF_', d, '.apsim'))
    }
  }
}


# STEP C: read the 9 outputs (3 init water x 3 XF)

# change the Nitrogen Values
