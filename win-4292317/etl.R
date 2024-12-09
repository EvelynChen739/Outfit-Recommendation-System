# etl.R

library(RSQLite)
library(dplyr)

# Step 1: Read the raw product data from CSV
products <- read.csv("products_raw.csv", stringsAsFactors = FALSE)

# Step 2: Data Cleaning
products_clean <- products %>%
    filter(!is.na(name), !is.na(category), !is.na(image_path)) %>% # Remove rows with missing values
    distinct() # Remove duplicate rows

# Step 3: Connect to SQLite Database
conn <- dbConnect(SQLite(), dbname = "closet.db")

# Step 4: Define the Schema for the `closet` Table
dbExecute(conn, "
CREATE TABLE IF NOT EXISTS closet (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  category TEXT,
  image_path TEXT
);
")

# Step 5: Load the Cleaned Data into the Database
dbWriteTable(conn, "closet", products_clean, overwrite = TRUE, row.names = FALSE)

dbDisconnect(conn)

cat("ETL process completed successfully. Cleaned data has been inserted into the 'closet' table in 'closet.db'.\n")