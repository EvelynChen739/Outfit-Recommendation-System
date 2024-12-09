# product_scraping.R

library(rvest)
library(httr)
library(stringr)

# Create a directory to save images
if (!dir.exists("images")) {
    dir.create("images")
}

# Define the URLs for each category 
categories <- list(
    shoes = "https://www.boohoo.com/womens/black-friday?prefn1=category&prefv1=Shoes%20%26%20Boots",    
    bottoms = "https://www.boohoo.com/womens/black-friday?prefn1=category&prefv1=Jeans",    
    tops = "https://www.boohoo.com/womens/black-friday?prefn1=category&prefv1=Tops",         
    coats = "https://www.boohoo.com/womens/black-friday?prefn1=category&prefv1=Coats%20%26%20Jackets",       
    accessories = "https://www.boohoo.com/womens/black-friday?prefn1=category&prefv1=Accessories" 
)

# Function to scrape data from a single category
scrape_category <- function(url, category_name, num_items = 5) {
    # Read the webpage
    webpage <- read_html(url)
    
    # Extract product sections
    product_sections <- webpage %>% html_nodes("section.b-product_tile")
    
    # Extract product names from `data-product-name` attribute
    product_names <- product_sections %>% html_attr("data-product-name")
    
    # Extract image URLs by navigating to the <img> tag
    image_urls <- product_sections %>%
        html_nodes("div > div > div > a > picture > img") %>% # Traverse three <div> levels
        html_attr("src") # Extract the `src` attribute
    
    # Handle relative URLs if needed
    image_urls <- ifelse(
        grepl("^//", image_urls),
        paste0("https:", image_urls),
        image_urls
    )
    
    # Remove any NA or invalid entries
    product_names <- product_names[!is.na(product_names)]
    image_urls <- image_urls[!is.na(image_urls)]
    
    # Limit to the first `num_items`
    data <- data.frame(
        name = head(product_names, num_items),
        category = category_name,
        image_url = head(image_urls, num_items),
        stringsAsFactors = FALSE
    )
    
    return(data)
}

# Initialize an empty data frame to store results
all_data <- data.frame()

# Loop through each category and scrape data
for (category_name in names(categories)) {
    message("Scraping category: ", category_name)
    category_data <- scrape_category(categories[[category_name]], category_name, num_items = 5)
    
    # Append data to the master data frame
    all_data <- rbind(all_data, category_data)
}

# Download images and update image paths in the data frame
all_data$image_path <- paste0("images/", gsub("[^a-zA-Z0-9]", "_", all_data$name), ".jpg")

for (i in 1:nrow(all_data)) {
    tryCatch({
        download.file(all_data$image_url[i], destfile = all_data$image_path[i], mode = "wb")
        message("Downloaded: ", all_data$image_path[i])
    }, error = function(e) {
        message("Failed to download: ", all_data$image_url[i])
    })
}

# Save the data frame for the ETL process
write.csv(all_data[, c("name", "category", "image_path")], "products_raw.csv", row.names = FALSE)

message("Scraping and image download completed successfully!")