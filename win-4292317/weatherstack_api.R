# weatherstack_api.R

library(httr)
library(jsonlite)

# Retrieve API key from environment variable
api_key <- Sys.getenv("2099ccae689ae320ffd9900725541a0f")

# Construct API request
response <- GET(
    url = "http://api.weatherstack.com/current",
    query = list(
        access_key = api_key,
        query = "London"
    )
)

# Make the GET request
response <- GET(url)

# Parse response
weather_data <- content(response, as = "text") %>% fromJSON(flatten = TRUE)
    
# Extract relevant information
current_temperature <- weather_data$current$temperature
weather_descriptions <- weather_data$current$weather_descriptions
    
    
# Save weather data for use in recommendation logic
saveRDS(weather_data, "weather_data.rds")
