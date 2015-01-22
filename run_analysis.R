## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")


# Loading data for activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Loading data for data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extracting only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Loading and processing data for X_test & Y_test
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features

# Extracting only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Loading activity labels
Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Binding data
test_data <- cbind(as.data.table(subject_test), Y_test, X_test)

# Loading and processing data for X_train & Y_train.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extracting only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Loading activity data
Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Binding data
train_data <- cbind(as.data.table(subject_train), Y_train, X_train)

# Merging test and train data
data_new = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data_new), id_labels)
melt_data      = melt(data_new, id = id_labels, measure.vars = data_labels)

# Applying mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "data/tidy_data.txt")
