#check if file is already unzipped
if (!file.exists("UCI HAR Dataset")) {
    if (!file.exists("getdata_projectfiles_UCI HAR Dataset.zip")) {
        stop("was expecting HAR Dataset folder or zip file")
    } else {
        unzip("getdata_projectfiles_UCI HAR Dataset.zip")
    }
}

#read activity labels
activityLabels <- read.delim("UCI HAR Dataset/activity_labels.txt", 
                             header=FALSE, sep=" ")
colnames(activityLabels) <- c("activity.number", "activity.label")

#read and merge data from X_ files
X.test <- read.delim("UCI HAR Dataset/test/X_test.txt", header=FALSE, sep="")
X.train <- read.delim("UCI HAR Dataset/train/X_train.txt", header=FALSE, sep="")
X <- rbind(X.test, X.train)

#read file with the names of features
features <- read.delim("UCI HAR Dataset/features.txt", header=FALSE, sep=" ")

#name columns in data frame
colnames(X) <- as.character(features[, 2])

#select only feautures with mean and std in name
X <- X[, grepl("mean\\(\\)|std\\(\\)", names(X))]

#read and merger y_ files - activity data
y.test <- read.delim("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep="")
y.train <- read.delim("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep="")
y <- rbind(y.test, y.train)

#merge activity data to data frame
X <- cbind(X, y)
colnames(X)[length(colnames(X))] <- "activity"

#read and merge data about subjects
subject.test <- read.delim("UCI HAR Dataset/test/subject_test.txt", 
                           header=FALSE, sep=" ")
subject.train <- read.delim("UCI HAR Dataset/train/subject_train.txt", 
                            header=FALSE, sep=" ")
subject <- rbind(subject.test, subject.train)
colnames(subject) <- "subject"

#merge data about subjects into main data frame
X <- cbind(X, subject)

#replace activity numbers with descriptive names
X <- merge(x = X, y = activityLabels, by.x = "activity", 
           by.y = "activity.number", all.x=TRUE)

#clean up column names
colnames(X) <- gsub("\\-std\\(\\)", ".std", colnames(X))
colnames(X) <- gsub("\\-mean\\(\\)", ".mean", colnames(X))
colnames(X) <- gsub("\\-", ".", colnames(X))

#prepare tidy data set - find average by subject and activity
aggregated <- NULL
for (name in colnames(X)[grepl("mean|std", colnames(X))]) {
    oneVarAggregated <- aggregate(X[, name] ~ subject + activity.label, 
                                  data = X, FUN= "mean")
    colnames(oneVarAggregated)[3] <- name
    if (is.null(aggregated)) {
        aggregated <- oneVarAggregated
    }
    else {
        aggregated <- cbind(aggregated, oneVarAggregated[, name])
        colnames(aggregated)[length(colnames(aggregated))] <- name
    }
}

write.csv(aggregated, file="tidy_data.csv")