#input segment = list of the description of audience segment 

#Required package installation
#install.packages("textTinyR")
#install.packages("Matrix")
#install.packages("rjson")

#Loading required libraries
library(jsonlite)
library(textTinyR)
library(tidyverse)
library(stringr)


# Read the CSV file
s_audience_segments <- read.csv("source_segments.csv", sep = ";", header = TRUE, stringsAsFactors = FALSE)

# Rename the columns names for better readability
colnames(s_audience_segments) <- c("label_id_long", "label_id", "parent_id", "segment_description", "label_name")

head(s_audience_segments)

#Check is there any missing values in Data
colSums(is.na(s_audience_segments))


# Read the JSON file
json_text <- readLines("test_audiences.json")

# Join the lines into a single string
json_string <- paste(json_text, collapse = "\n")

# Parse the JSON string
json_data <- fromJSON(json_string)

# Extract the test audiences data
test_audiences <- json_data$test_audiences

# Convert to data frame
t_audience_segment <- data.frame(
  segment_id = sapply(test_audiences, function(x) x$segment_id),
  segment_description = sapply(test_audiences, function(x) x$description)
)

#Saving our processed data for future use
write_rds(s_audience_segments, "audience_source_segments.rds")
write_rds(t_audience_segment, "audience_test_segment.rds")


source_segments <- readr::read_rds("audience_source_segments.rds")
summary(source_segments)

input_segment <- readr::read_rds("audience_test_segment.rds")
summary(input_segment)