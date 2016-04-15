## Converting Messy data into Tidy Data

library(dplyr)
library(tidyr)

## Downloading the input files

file_url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(file_url, destfile = 'HAR.zip')
unzip('HAR.ZIP', exdir = '.')
#dir() - to check the downloaded file
setwd('UCI HAR Dataset')

## Reading the Labels input files
test_labels <- read.table('./test/y_test.txt')
train_labels <- read.table('./train/y_train.txt')
total_labels <- rbind(test_labels, train_labels)

## Reading the test and train Subject data and combining both
subject_train <- read.table('./train/subject_train.txt')
subject_test <- read.table('./test/subject_test.txt')
total_subjects <- rbind(subject_test,subject_train)
names(total_subjects) <- 'subject'

## Reading the feature file to extract column names

features <- read.table('features.txt', col.names = c('SNo', 'column_name'))
features_name <- features$column_name

## Filtering columns names with mean | std alone
mean_std_columns <- grep('(mean|std)\\(', features_name)
mean_std_column_names <- grep('(mean|std)\\(', features_name, value = T)
mean_std_column_names <- gsub('mean\\(\\)', 'Mean', mean_std_column_names)
mean_std_column_names <- gsub('std\\(\\)', 'StandardDeviation', mean_std_column_names)
mean_std_column_names <- gsub('BodyBody', 'Body', mean_std_column_names)
mean_std_column_names <- gsub('Mag', 'Magnititude', mean_std_column_names)


## Forming Activity Labels
activities <- c('WALKING', 'WALKING_UPSTAIRS', 'WALKING_DOWNSTAIRS', 'SITTING', 
                'STANDING', 'LAYING')
activity <- sapply(total_labels, function(x) activities[x])
colnames(activity) <- 'activity'


## Reading the test and train input files and combaining both
test <- read.table('./test/X_test.txt')
train <- read.table('./train/X_train.txt')
total_dataset <- rbind(test,train)

## Extracting Mean and StdDev related columns alone 
total <- select(total_dataset, mean_std_columns)
names(total) <- mean_std_column_names

## Merging Subject, Activity, Measurement datasets
full_data <- cbind(total_subjects, activity, total)
full_data <- tbl_df(full_data)

## formating the data to Tidy data

tidy <- full_data %>%
        gather('variable', 'value', -1,-2) %>%
        separate(variable, c('variable', 'formula', 'axis')) %>%
        separate(variable, c('scale', 'variable'), 1) %>%
        mutate(scale= gsub('t', 'Time', scale), scale= gsub('f', 'Frequency', scale))

## grouping tidy data based on variable, subject, activity
grouped_tidy <- tidy %>% group_by(subject, activity, scale, variable, formula, axis)

output <- summarise(grouped_tidy, mean(value))

## writing the output to local file
write.table(output, 'tidy_output.txt', col.names =FALSE)
