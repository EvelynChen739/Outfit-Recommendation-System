# ootd_api.R

library(plumber)
library(DBI)
library(RSQLite)
library(jsonlite)
library(dplyr)
library(jpeg)
library(grid)
library(httr)

# Load weather data
weather_data <- readRDS("weather_data.rds")
temperature <- weather_data$current$temperature
weather_desc <- weather_data$current$weather_descriptions

# Connect to database
conn <- dbConnect(SQLite(), dbname = "closet.db")

#* @apiTitle Outfit Recommendation API
#* Get Outfit of the Day
#* @get /ootd
function() {
    # Initialize outfit list
    outfit <- list()
    
    # Apply rules to select outfit based on weather
    if (temperature > 25) {
        # Hot weather: Do not include coats
        outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' ORDER BY RANDOM() LIMIT 1")
        outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'bottoms' ORDER BY RANDOM() LIMIT 1")
        outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' ORDER BY RANDOM() LIMIT 1")
        outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' ORDER BY RANDOM() LIMIT 1")
    } else {
        # Cool weather: Select random item from all categories including coats
        outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' ORDER BY RANDOM() LIMIT 1")
        outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'bottoms' ORDER BY RANDOM() LIMIT 1")
        outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' ORDER BY RANDOM() LIMIT 1")
        outfit$coat <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'coats' ORDER BY RANDOM() LIMIT 1")
        outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' ORDER BY RANDOM() LIMIT 1")
    }
    
    # Disconnect from the database
    dbDisconnect(conn)
    
    # Set the output to a JPEG file
    jpeg("outfit_recommendation.jpg", width = 800, height = 600)  # Set the size of the output image
    
    # Create an empty plot
    plot.new()
    plot.window(xlim = c(0, 1), ylim = c(0, 1))
    
    # Add weather and date information
    text(0.5, 0.9, paste("Date:", Sys.Date()), cex = 1.5)
    text(0.5, 0.8, paste("Weather:", weather_desc), cex = 1.2)
    
    # Combine all the images into a grid layout
    grid.newpage()  # Create a new page for the grid
    pushViewport(viewport(layout = grid.layout(2, 3)))
    
    # Function to plot images in the grid layout
    plot_image <- function(image_path, row, col) {
        if (file.exists(image_path)) {
            img <- tryCatch({
                readJPEG(image_path)  # Read the image file (JPEG format)
            }, error = function(e) {
                message("Error reading image: ", image_path)
                return(NULL)
            })
            
            if (!is.null(img)) {
                rasterImage(img, 
                            unit(0.1, "npc") + (col - 1) * unit(0.3, "npc"), 
                            unit(0.7, "npc") - (row - 1) * unit(0.4, "npc"), 
                            unit(0.4, "npc") + (col - 1) * unit(0.3, "npc"), 
                            unit(0.9, "npc") - (row - 1) * unit(0.4, "npc"))
            }
        } else {
            message("Image file not found: ", image_path)
        }
    }
    
    # Plot images for each category (shoes, bottoms, tops, coat, accessories)
    if (!is.null(outfit$shoes)) {
        plot_image(outfit$shoes$image_path, 1, 1)
    }
    if (!is.null(outfit$bottom)) {
        plot_image(outfit$bottom$image_path, 1, 2)
    }
    if (!is.null(outfit$top)) {
        plot_image(outfit$top$image_path, 1, 3)
    }
    if (!is.null(outfit$coat)) {
        plot_image(outfit$coat$image_path, 2, 1)
    }
    if (!is.null(outfit$accessory)) {
        plot_image(outfit$accessory$image_path, 2, 2)
    }
    
    # Close the JPEG device to save the image
    dev.off()
    
    # Return success message
    return("Outfit image saved as 'outfit_recommendation.jpg'!")
}

#* Get Raw Product Data from Closet
#* @get /rawdata
function() {
    conn <- dbConnect(SQLite(), dbname = "closet.db")
    data <- dbGetQuery(conn, "SELECT * FROM closet")
    dbDisconnect(conn)
    return(toJSON(data))
}

# Start the Plumber API
pr <- plumb("ootd_api.R")
pr$run(port = 8000)  
