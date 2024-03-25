library(httr)
library(jsonlite)

# run the API in a background job for API wrapper development

 
 b_url <- "http://127.0.0.1:5022/Segment_API"
   
 # Define parameters
 params <- list(input_segment = input_segment, source_segments = source_segments, threshold = 0.5)
   
 # Modify URL with parameters
 query_url <- modify_url(url = b_url, query = params)
   
 # Send GET request
 resp <- GET(query_url)
   
 # Extract raw content
 resp_raw <- content(resp, as = "text", encoding = "utf-8")
   
 # Parse JSON response
 jsonlite::fromJSON(resp_raw)
 
 calculate_and_match <- function(input_segment, source_segments, threshold = 0.5) {

   #input_segment <- paste(input_segments, collapse = "|")
    
   b_url <- "http://127.0.0.1:5022/Segment_API"
   
   # Define parameters
   params <- list(input_segment = input_segment, source_segments = source_segments, threshold = 0.5)
   
   # Modify URL with parameters
   query_url <- modify_url(url = b_url, query = params)
   
   # Send GET request
   resp <- GET(query_url)
   
   # Extract raw content
   resp_raw <- content(resp, as = "text", encoding = "utf-8")
   
   # Parse JSON response
   jsonlite::fromJSON(resp_raw)
   
 }
 
 result <- calculate_and_match(input_segment, source_segments, threshold = 0.5)
#print(result)
