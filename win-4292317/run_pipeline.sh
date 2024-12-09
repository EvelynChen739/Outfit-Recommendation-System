#!/bin/bash
# Usage: ./run_pipeline.sh YOUR_ACCESS_KEY
YOUR_ACCESS_KEY= "2099ccae689ae320ffd9900725541a0f"
export YOUR_ACCESS_KEY
# Run R scripts
Rscript product_scraping.R
Rscript weatherstack_api.R
Rscript etl.R
Rscript run_ootd_api.R &
# Wait for API to start
sleep 5
# Call the /ootd endpoint
curl "<http://localhost:8000/ootd>" --output ootd_plot.png
echo "Outfit of the Day plot saved as ootd_plot.png"

# run_ootd_api.R
library(plumber)
# Load the API
r <- plumb("ootd_api.R")

# Run the API on port 8000
r$run(port = 8000)
