#
# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.
#
# In RStudio 1.1 or older, see the Plumber documentation for details
# on running the API.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

# Load required libraries
library(plumber)


source_segments<- readr::read_rds("audience_source_segments.rds")
summary(source_segments)

input_segment <- readr::read_rds("audience_test_segment.rds")
summary(input_segment)


#* @apiTitle Semantic Audience Matching: Finding the Best Fit

#* @apiDescription This API servers check the semantic matching between audience segments and identify the best semantic match. It uses cosine similarity for this task. 

#* @param input_segment Represents a single segment, typically a categorical description or label, against which similarity is measured with other segments, aiming to find the most similar segment(s) from a set of source segments.
#* @param source_segments Refer to a collection of segments used for comparison against the input segment, with the aim of identifying the most similar segment(s) based on cosine similarity scores. Must be a vector, better to be separated by pipe (|) operator.
#* @threshold Allows the user to control the sensitivity of the matching process. A higher threshold requires closer matches, while a lower threshold may allow for looser matches. Adjusting the threshold can help balance between precision and recall in the matching algorithm.

#* @get /Segment_API
calculate_and_match <- function(input_segment, source_segments, threshold = 0.5) {
  
  # Convert input_segments to a single string separated by "><\\|"
  # input_segment <- paste(input_segments, collapse = "><\\|")
  
  # Error handling
  # if (!is.character(source_segments) || !file.exists(source_segments)) {
  #      stop("Invalid source_segments. Please provide a valid file path.")
  #    }
  #    
  #    # Convert input_segments to a single string separated by "><\\|"
  #    if (!is.list(input_segments)) {
  #      stop("Input segments must be provided as a list.")
  #    }
     
  
  # Convert input_segment and source_segments to character vectors
  input_segment <- as.character(input_segment)
  source_segments <- lapply(source_segments, as.character)
  
  # Initialize variables to store best match and similarity score
  best_similarity <- -Inf
  best_match <- ""
  
  # Loop through each source segment
  for (source_segment in source_segments) {
    # Split the input segment into a vector
    input_vector <- unlist(strsplit(input_segment, "><\\|"))
    source_vector <- unlist(strsplit(source_segment, "><\\|"))
    
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
    
    # Update best similarity and best match if similarity exceeds threshold and is the highest so far
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
