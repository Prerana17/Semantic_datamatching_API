#input segment = list of the description of audience segment 

#Step 1: Required package installation
#install.packages("textTinyR")
#install.packages("Matrix")
#install.packages("rjson")

#Loading required libraries
library(jsonlite)
library(textTinyR)
library(tidyverse)
library(stringr)

#Step 2: Data Processing

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


#Step 3: Function to check similarity and score

# # Merged function for calculating cosine similarity and performing semantic matching
 calculate_and_match <- function(input_segment, source_segments, threshold = 0.5) {
      
   # Convert input_segments to a single string separated by "><\\|"
   #input_segment <- paste(input_segments, collapse = "><\\|")
   
   # Convert input_segment and source_segments to character vectors
   input_segment <- as.character(input_segment)
   source_segments <- lapply(source_segments, as.character)

   # Initialize variables to store best match and similarity score
   best_similarity <- -Inf
   best_match <- ""

   # Loop through each source segment
   for (source_segment in source_segments) {
     # Split the input segment into a vector
     input_vector <- unlist(strsplit(input_segment, "\\|"))
     source_vector <- unlist(strsplit(source_segment, "\\|"))

     # Combine input and source vectors to create a bag of words
     bag_of_words <- unique(c(input_vector, source_vector))

     # Create vectors representing term frequency for input and source segments
     input_tf <- rep(0, length(bag_of_words))
     source_tf <- rep(0, length(bag_of_words))

     for (term in input_vector) {
       input_tf[bag_of_words == term] <- sum(input_vector == term)
     }

     for (term in source_vector) {
       source_tf[bag_of_words == term] <- sum(source_vector == term)
     }

     # Calculate cosine similarity
     dot_product <- sum(input_tf * source_tf)
     input_norm <- sqrt(sum(input_tf^2))
     source_norm <- sqrt(sum(source_tf^2))

     if (input_norm == 0 || source_norm == 0) {
       similarity <- 0  # To avoid division by zero
     } else {
       similarity <- dot_product / (input_norm * source_norm)
     }

     # Update the best similarity and best match if similarity exceeds the threshold and is the highest so far
     if (similarity >= threshold && similarity > best_similarity) {
       best_similarity <- similarity
       best_match <- source_segment
     }
   }

   # Construct API response
   response <- list(
     best_match = ifelse(best_similarity > -Inf, best_match, "No suitable match found."),
     similarity_score = best_similarity
   )

   return(response)
 }

# Perform semantic matching
result <- calculate_and_match(input_segment, source_segments, threshold = 0.5)
#print(result)
