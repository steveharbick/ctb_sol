#####################################################################
#####################################################################
# Hardware required
#####################################################################
#####################################################################

# at least 4GBb of RAM
# at least 6GBb of memory space
# MacOs or Linux
# 16 Gb of RAM and 11 cores for optimal performance

#####################################################################
#####################################################################
# Software required
#####################################################################
#####################################################################

# R version 3.0.1 (2013-05-16) -- "Good Sport" or later

#####################################################################
#####################################################################
# Packages required
#####################################################################
#####################################################################

# #install the following packages if necessary
#install.packages("SOAR")
#install.packages("Matrix")
#install.packages("MASS")
#install.packages("RTextTools")
#install.packages("tau")
#install.packages("glmnet")
#install.packages("nnls")
#install.packages("e1071")
#install.packages("gbm")
#install.packages("randomForest")
#install.packages("foreach")
#install.packages("doMC")

#####################################################################
#####################################################################
# How to Run the Code
#####################################################################
#####################################################################

1. Paste solution folder 
2. TODO : how to produce tsp files? 
3. Put “tsv" files into the “Input/frompems” folder
4. Ensure the working dir path in “_RUN_ME.R” (line 19) and in “_TEST_ME.R” (line 19) are correct.
5. Ensure the item lists in “_RUN_ME.R” (line 34) and in “_TEST_ME.R” (line 41) are correct 
6. Open a R session and ensure that all packages listed above are installed.
7. Run the R script files in the following order:
	1.	_RUN_ME.R
	2.	_TEST_ME.R
8. The working RData.files will be saved in the folder “Working_files”
9. The predictions will be saved in the folder “Output”
