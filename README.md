---
title: "Converting Messy Data into Tidy data"
author: "Venkadeshwaran K"
date: "April 15, 2016"
output: html_document

Dataset: Human Activity Recognition Using Smartphones Dataset
Credits: Smartlab
---

```{r, include=TRUE}
knitr::opts_chunk$set(echo = TRUE)
```

## Process

To convert the given messy data into Tidy data, ready to analysis format. Below actions are to performed.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Data Collection

Fist step is to collect data from this [link]  (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) .

```{r}
file_url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(file_url, destfile = 'HAR.zip')
unzip('HAR.ZIP', exdir = '.')
#dir() - to check the downloaded file
setwd('UCI HAR Dataset')

```
Now we have the needed data and the working directory has been set to downloaded directory

## Loading Data and needed Libraries

```{r}
library(dplyr)
library(tidyr)
```
All the files has been splitted into train dataset (70%) and test dataset (30%). We will combine both the data set into a single file 

#### Reading Activity Label data
Links the class labels with their activity name.

```{r}
test_labels <- read.table('./test/y_test.txt')
train_labels <- read.table('./train/y_train.txt')
## Combining data set
total_labels <- rbind(test_labels, train_labels)
```

#### Reading Subject data
Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
```{r}
subject_train <- read.table('./train/subject_train.txt') 
subject_test <- read.table('./test/subject_test.txt')
total_subjects <- rbind(subject_test,subject_train)
names(total_subjects) <- 'subject
```
#### Reading the variable dataset 

```{r}
test <- read.table('./test/X_test.txt')
train <- read.table('./train/X_train.txt')
total_dataset <- rbind(test,train)
```
All the needed datasets has been loaded and combined the test and train into a single file.

## Extracting Mean & Std related columns
In this part of exercise we were only interested in Mean and std related columns alone. All the columns details are stored in the _feature.txt_ file.

####Reading the feature file to extract column names
This contains the list of 561 variable names

``` {r}
features <- read.table('features.txt', col.names = c('SNo', 'Column_name'))
features_name <- features$column_name
print('Entire columns numbers', length(features_name))

## Filtering columns names with mean | std alone
mean_std_columns <- grep('(mean|std)\\(', features_name)
mean_std_column_names <- grep('(mean|std)\\(', features_name, value = T)
print('Mean & std related columns alone', length(mean_std_column_names))
```

#### Formatting column names to increase readability
Removing (), expanding abbrevations to improve readablity
```{r}
mean_std_column_names <- gsub('mean\\(\\)', 'Mean', mean_std_column_names)
mean_std_column_names <- gsub('std\\(\\)', 'StandardDeviation', mean_std_column_names)
mean_std_column_names <- gsub('BodyBody', 'Body', mean_std_column_names)
mean_std_column_names <- gsub('Mag', 'Magnititude', mean_std_column_names)
```
#### Filtering non mean|std columns
```{r}
total <- select(total_dataset, mean_std_columns)
names(total) <- mean_std_column_names
```
Now the _total_ has only the needed columns

## Labeling the Activites
The _labels_ dataset has numeric representation of the activities. This need to be mapped to right activity
```{r}
activities <- c('WALKING', 'WALKING_UPSTAIRS', 'WALKING_DOWNSTAIRS', 'SITTING', 
                'STANDING', 'LAYING')
activity <- sapply(total_labels, function(x) activities[x])
colnames(activity) <- 'activity'
```

## Combining datasets
Labels, Subject, Test_train datasets can be combined into single dataset.
```{r}
full_data <- cbind(total_subjects, activity, total)
##converting to plyr table
full_data <- tbl_df(full_data)
full_data
```

## Tidy dataset
The above data is not tidy. The below mentioned tidy rule is not valid in this dataset.

* Each column needs to be single variable
* Values should not be a vairable

Eg: tBodyAcc-Mean-X column has four variable combined. 

* Domain -- Time/Frequency
* Variable -- Form of measurement acceleration/Angular velocity
* Formula -- Mean/Std/Min/Max/..
* Axis -- X/Y/Z

```{r}
tidy <- full_data %>%
        gather('variable', 'value', -1,-2) %>%
        separate(variable, c('variable', 'formula', 'axis')) %>%
        separate(variable, c('scale', 'variable'), 1) %>%
        mutate(scale= gsub('t', 'Time', scale), 
               scale= gsub('f', 'Frequency', scale))

tidy
```
Now the data is tidy.

## Summarising Tidy Data with Mean
Creating an independent tidy data set with the average of each variable for each activity and each subject. The output value is in **Hertz(Hz)**

```{r}
grouped_tidy <- tidy %>% group_by(subject, activity, scale, variable, formula, axis)

output <- summarise(grouped_tidy, mean(value))
```
## Saving Output file

Summarized output file has been stored with in .txt format with write.table().
```{r}
write.table(output, 'tidy_output.txt', col.names =FALSE)
```


