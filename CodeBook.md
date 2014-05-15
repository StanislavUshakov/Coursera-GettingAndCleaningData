CodeBook
========================================================

##Introduction

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist.

## Raw data

Data consists of 2 data chunks: test data and training data. File contains the following features:
These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

- tBodyAcc-XYZ
- tGravityAcc-XYZ
- tBodyAccJerk-XYZ
- tBodyGyro-XYZ
- tBodyGyroJerk-XYZ
- tBodyAccMag
- tGravityAccMag
- tBodyAccJerkMag
- tBodyGyroMag
- tBodyGyroJerkMag
- fBodyAcc-XYZ
- fBodyAccJerk-XYZ
- fBodyGyro-XYZ
- fBodyAccMag
- fBodyAccJerkMag
- fBodyGyroMag
- fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

- mean(): Mean value
- std(): Standard deviation
- mad(): Median absolute deviation 
- max(): Largest value in array
- min(): Smallest value in array
- sma(): Signal magnitude area
- energy(): Energy measure. Sum of the squares divided by the number of values. 
- iqr(): Interquartile range 
- entropy(): Signal entropy
- arCoeff(): Autorregresion coefficients with Burg order equal to 4
- correlation(): correlation coefficient between two signals
- maxInds(): index of the frequency component with largest magnitude
- meanFreq(): Weighted average of the frequency components to obtain a mean frequency
- skewness(): skewness of the frequency domain signal 
- kurtosis(): kurtosis of the frequency domain signal 
- bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
- angle(): Angle between to vectors.

Files with prefix "y" contain number of activity taken.
Files with prefix "subject" contain id of subject.

## Tidy data

Tidy data set contains only average values of the mean and standard deviation for each measurement:
- tBodyAcc.mean.XYZ, tBodyAcc.std.XYZ - real value
- tGravityAcc.mean.XYZ, tGravityAcc.mean.XYZ - real value
- tBodyAccJerk.mean.XYZ, tBodyAccJerk.std.XYZ - real value
- tBodyGyro.mean.XYZ, tBodyGyro.std.XYZ - real value
- tBodyGyroJerk.mean.XYZ, tBodyGyroJerk.std.XYZ - real value
- tBodyAccMag.mean, tBodyAccMag.std - real value
- tGravityAccMag.mean, tGravityAccMag.std - real value
- tBodyAccJerkMag.mean, tBodyAccJerkMag.std - real value
- tBodyGyroMag.mean, tBodyGyroMag.std - real value
- tBodyGyroJerkMag.mean, tBodyGyroJerkMag.std - real value
- fBodyAcc.mean.XYZ, fBodyAcc.std.XYZ - real value
- fBodyAccJerk.mean.XYZ, fBodyAccJerk.std.XYZ - real value
- fBodyGyro.mean.XYZ, fBodyGyro.std.XYZ - real value
- fBodyAccMag.mean, fBodyAccMag.std - real value
- fBodyAccJerkMag.mean, fBodyAccJerkMag.std - real value
- fBodyGyroMag.mean, fBodyGyroMag.std - real value
- fBodyGyroJerkMag.mean, fBodyGyroJerkMag.std - real value
- subject - integer, id of the subject
- activity.label - one of the following values: 
    * WALKING 
    * WALKING_UPSTAIRS
    * WALKING_DOWNSTAIRS
    * SITTING
    * STANDING
    * LAYING

## Data processing

Place zip file with data and processing script into one folder. Run the script.

Script will check if there's needed data:

```r
if (!file.exists("UCI HAR Dataset")) {
    if (!file.exists("getdata_projectfiles_UCI HAR Dataset.zip")) {
        stop("was expecting HAR Dataset folder or zip file")
    } else {
        unzip("getdata_projectfiles_UCI HAR Dataset.zip")
    }
}
```


Read activity labels:

```r
activityLabels <- read.delim("UCI HAR Dataset/activity_labels.txt", header = FALSE, 
    sep = " ")
colnames(activityLabels) <- c("activity.number", "activity.label")
```


Read and merge data from X_ files:

```r
X.test <- read.delim("UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "")
X.train <- read.delim("UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "")
X <- rbind(X.test, X.train)
```


Read file with the names of features:

```r
features <- read.delim("UCI HAR Dataset/features.txt", header = FALSE, sep = " ")
```


Name columns in data frame

```r
colnames(X) <- as.character(features[, 2])
```


Select only feautures with mean and std in name:

```r
X <- X[, grepl("mean\\(\\)|std\\(\\)", names(X))]
```


Read and merger y_ files - activity data:

```r
y.test <- read.delim("UCI HAR Dataset/test/y_test.txt", header = FALSE, sep = "")
y.train <- read.delim("UCI HAR Dataset/train/y_train.txt", header = FALSE, sep = "")
y <- rbind(y.test, y.train)
```


Merge activity data to data frame:

```r
X <- cbind(X, y)
colnames(X)[length(colnames(X))] <- "activity"
```


Read and merge data about subjects:

```r
subject.test <- read.delim("UCI HAR Dataset/test/subject_test.txt", header = FALSE, 
    sep = " ")
subject.train <- read.delim("UCI HAR Dataset/train/subject_train.txt", header = FALSE, 
    sep = " ")
subject <- rbind(subject.test, subject.train)
colnames(subject) <- "subject"
```


Merge data about subjects into main data frame:

```r
X <- cbind(X, subject)
```


Replace activity numbers with descriptive names:

```r
X <- merge(x = X, y = activityLabels, by.x = "activity", by.y = "activity.number", 
    all.x = TRUE)
```


Clean up column names:

```r
colnames(X) <- gsub("\\-std\\(\\)", ".std", colnames(X))
colnames(X) <- gsub("\\-mean\\(\\)", ".mean", colnames(X))
colnames(X) <- gsub("\\-", ".", colnames(X))
```


Prepare tidy data set - find average by subject and activity:

```r
aggregated <- NULL
for (name in colnames(X)[grepl("mean|std", colnames(X))]) {
    oneVarAggregated <- aggregate(X[, name] ~ subject + activity.label, data = X, 
        FUN = "mean")
    colnames(oneVarAggregated)[3] <- name
    if (is.null(aggregated)) {
        aggregated <- oneVarAggregated
    } else {
        aggregated <- cbind(aggregated, oneVarAggregated[, name])
        colnames(aggregated)[length(colnames(aggregated))] <- name
    }
}
```


Write to file:

```r
write.csv(aggregated, file = "tidy_data.txt")
```

