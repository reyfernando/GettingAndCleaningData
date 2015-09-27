library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
getwd()
#Sets working directory
setwd("/Users/reyfernando/Documents/Coursera_Data_Science/03 Data Gathering/Project Assigment")
#shows files downloaded and unzip
dir()
#reads source
Act_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Act_Labels
#changes 2nd column to character
Act_Labels[,2] <-as.character(Act_Labels[,2])
# reads and changes info to character for features as well
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
#displays content
features



# Extract only the data on mean and standard deviation
# Its like bit of text minning to fixed the name of features
?grep  #similar to like
?gsub #gsub perform replacement of the first and all matches respectively.
# we basically search for mean and std

Our_features <- grep(".*mean.*|.*std.*", features[,2]) 

Our_features  # basically includes rows where 
#now we take the rows with the features we only want
Our_features.names <- features[Our_features,2]  
Our_features.names
# and we overwrite the name to make it more legible
Our_features.names = gsub('-mean', 'Mean', Our_features.names)
Our_features.names
Our_features.names = gsub('-std', 'Std', Our_features.names)
Our_features.names <- gsub('[-()]', '', Our_features.names)
#now column names are clean and more elegible
Our_features.names





# Load the datasets

Our_features
Our_features.names

train <- read.table("UCI HAR Dataset/train/X_train.txt")[Our_features]

dim(train)   # 79 columns 7352 rows
summary(train)
head(train) ## missing column name
plot(train[,3])

train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_activities  ## information related to activity, sitting, waiting etc.
train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_Subjects  ## information from each participant i.e. participant id

#  join different vectors
train <- cbind(train_Subjects, train_activities, train)
train

test <- read.table("UCI HAR Dataset/test/X_test.txt")[Our_features]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# we now merge datasets and add names to the columns i.e. labels
#merges to data sets
Final_Data <- rbind(train, test)
#adds column name to data set
colnames(Final_Data) <- c("subject_id", "activity_event", Our_features.names)
Final_Data
head(Final_Data)
## a deeper look at the data highlights that for every subject id there are multiple activities events. 
# hence we take the average of each activity event in order to not have any duplicates.
# we do this by pivoting the variables with melt() function and later by casting it


# turn activities & subjects into factors
Final_Data$activity_event <- factor(Final_Data$activity_event, levels = Act_Labels[,1], labels = Act_Labels[,2])
Final_Data$subject_id <- as.factor(Final_Data$subject_id)

# Convers object into a molten data frame by including primary key index
## its a sort of pivot function where from 78 columns one goes to 4
?melt
??melt
Final_Data.melted <- melt(Final_Data, id = c("subject_id", "activity_event"))

# cast a molten data frame into a data frame
## this function allows us to get the mean of each attribute and then 
#to pivot back all variables after subject and activity
?dcast
Final_Data.mean <- dcast(Final_Data.melted, subject_id + activity_event ~ variable, mean)
Final_Data.mean

write.table(Final_Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
