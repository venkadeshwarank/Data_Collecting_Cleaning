---
title: "Codebook: Messy Data to Tidy Data Conversion"
author: "Venkadeshwaran K"
date: "April 16, 2016"
output: html_document
---


**Tidy_output.txt** Tidy Dataset has been derived from combining Label, Subject, Test, Train and feature datasets.  

## Fields and its description with unit

Column Name |  Data Type |  Unit | Description 
------------|------------|-------|-------------
Subject     | Num        | NA    | Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30
Activity    | Factor     | NA    | Activity performed by each person. (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
Scale 	    | Factor     | NA    | Scale in which the measure ment is done. (Time, Frequency)
Variable    | Factor     | NA    | Different variables of measurement in acceleration or Angular velocity
Formula     | Factor     | NA    | Calculation performed on the measured data (Mean, StandardDeviation)
Axis 	    | Factor     | NA    | Directional axis in which the data is recorded. (X, Y, Z)
Values      | (Num)	     |Hertz(Hz)| Values calculated from the variable with the given formula on the given axis.



