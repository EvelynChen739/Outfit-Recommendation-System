---
title: "Outfit Recommendation Project"
author: "Evelyn Chen"
output: html_document
---

# Project Title and Description

**Project Name**: Outfit Recommendation System

**Description**: This project uses weather data to recommend a suitable outfit for the day. Based on the current temperature and weather conditions, the system selects random clothing items (shoes, bottoms, tops, accessories, and coats) from a personal closet database. The recommendations are made available through an API endpoint.

# Table of Contents

1.  [Prerequisites and Dependencies](#prerequisites-and-dependencies)
2.  [Installation and Setup Instructions](#installation-and-setup-instructions)
3.  [Project Structure Overview](#project-structure-overview)
4.  [Usage Instructions](#usage-instructions)
5.  [Recommendation Logic Explanation](#recommendation-logic-explanation)
6.  [Output Description](#output-description)
7.  [Troubleshooting and FAQs](#troubleshooting-and-faqs)
8.  [Dependencies and Package Installation](#dependencies-and-package-installation)

# Prerequisites and Dependencies {#prerequisites-and-dependencies}

Before you start using this project, make sure you have the following software and tools installed:

### Software Requirements

-   **R** (version 4.0 or higher) – A programming language for statistical computing and graphics.
-   **SQLite** (for database management) – A lightweight database used to store the closet data.

### R Packages

The project requires several R packages to function properly. You can install them with the following command:

```{r}
install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "dplyr", "jpeg", "grid"))
```

# Installation and Setup Instructions {#installation-and-setup-instructions}

### Step 1: Cloning or Downloading the Project Repository

To begin setting up the project, clone or download the repository from GitHub. You can use the following command to clone the repository:

```{bash}
git clone https://github.com/EvelynChen739/Outfit-Recommendation-System
```

### Step 2: Setting Up Directories and Files

Once the repository is cloned, navigate to the project directory:

```{bash}
cd "D:/LBS/Data Management/win-4292317" 
```

### Step 3: Obtaining and Setting Up the Weatherstack API Key

This project requires a Weatherstack API key to fetch weather data.

1.  Go to the Weatherstack website and sign up for an account.

2.  After logging in, obtain your personal API key.

### Step 4: Installing Dependencies

This project requires several R packages to function correctly. Install the necessary dependencies by running the following command in R:

```{r}
install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "dplyr", "magick"))
```

# Project Structure Overview {#project-structure-overview}

Here is an overview of the project structure:

-   **`product_scraping.R`**:
    -   Scrapes product data and images from online stores.
-   **`weatherstack_api.R`**:
    -   Fetches current weather data using the Weatherstack API.
-   **`etl.R`**:
    -   Cleans and processes the scraped data, and populates the `closet.db` SQLite database.
-   **`ootd_api.R`**:
    -   Defines the API endpoints using Plumber, including `/ootd` and `/rawdata`.
-   **`run_pipeline.sh`**:
    -   Automates the entire data pipeline, from scraping data to setting up the API.
-   **`images/`**:
    -   Directory containing product images for the recommendations.
-   **`closet.db`**:
    -   SQLite database containing the product data (e.g., clothing items).

# Usage Instructions {#usage-instructions}

### Running the Entire Pipeline

To run the entire pipeline, including product scraping, weather data fetching, data processing, and starting the API server, use the following Bash script:

1.  Open a terminal or command prompt.

2.  Navigate to the project directory:

    ``` bash
    cd "D:/LBS/Data Management/win-4292317"
    ```

3.  Run the `run_pipeline.sh` script with your Weatherstack API key:

    ``` bash
    ./run_pipeline.sh YOUR_ACCESS_KEY
    ```

    Replace `YOUR_ACCESS_KEY` with your actual Weatherstack API key. This will initiate the full pipeline from scraping products to setting up the Plumber API.

### Running the API Server Independently

If you prefer to run the API server separately, you can use the `ootd_api.R` script.

1.  Navigate to the project directory:

    ``` bash
    cd "D:/LBS/Data Management/win-4292317"
    ```

2.  Run the `ootd_api.R` script to start the API server:

    ``` bash
    Rscript ootd_api.R
    ```

    This will start the Plumber API server on port 8000 (or the specified port). You can adjust the port by modifying the script if needed.

### Accessing the API Endpoints

Once the API server is running, you can access the following endpoints:

#### Accessing `/ootd`

This endpoint returns the "Outfit of the Day" plot, which includes the selected clothing items and weather information.

You can access it via your web browser or using `curl`:

-   In your browser, visit: <http://localhost:8000/ootd>

-   Or, use `curl` to download the plot image:

    ``` bash
    curl "http://localhost:8000/ootd" --output ootd_plot.png
    ```

    This will save the "Outfit of the Day" plot as `ootd_plot.png` in the current directory.

#### Accessing `/rawdata`

This endpoint returns the raw product data from the `closet.db` SQLite database.

You can access it via your web browser or using `curl`:

-   In your browser, visit: <http://localhost:8000/rawdata>

-   Or, use `curl` to retrieve the data in JSON format:

    ``` bash
    curl "http://localhost:8000/rawdata" --output rawdata.json
    ```

    This will save the raw product data as `rawdata.json`.

### Additional Steps for Generating Outputs

If you want to generate new "Outfit of the Day" recommendations, you can re-run the `run_pipeline.sh` script or manually trigger specific steps (e.g., scraping or weather fetching). The generated outputs, such as `ootd_plot.png` or `rawdata.json`, will be saved in the project directory.

# Recommendation Logic Explanation {#recommendation-logic-explanation}

The outfit recommendation logic is based on the current weather data (such as temperature and weather description) and a set of predefined rules. The system selects clothing items (shoes, bottoms, tops, accessories, and coats) from the database based on these conditions. Here's a detailed breakdown of how the recommendation logic works:

### Weather Data Influence

**Temperature**: - The primary factor for outfit selection is the temperature fetched from the Weatherstack API. - If the temperature is **greater than 25°C**, the system assumes it is hot weather and recommends lighter clothing such as shorts, t-shirts, and no coats. - If the temperature is **less than or equal to 25°C**, the system assumes cooler weather and may recommend additional layers like coats or jackets.

### Temperature Thresholds and Corresponding Clothing Choices

The system follows a set of rules to decide which clothing items to select based on temperature:

-   **Hot Weather (Temperature \> 25°C)**:
    -   **Shoes**: Select a random shoe from the "shoes" category.
    -   **Bottoms**: Select a random item from the "bottoms" category (e.g., shorts, skirts).
    -   **Tops**: Select a random item from the "tops" category (e.g., t-shirts, tank tops).
    -   **Coats**: No coat is recommended for hot weather.
    -   **Accessories**: Select a random accessory, such as sunglasses or light jewelry.
-   **Cool Weather (Temperature ≤ 25°C)**:
    -   **Shoes**: Select a random shoe from the "shoes" category.
    -   **Bottoms**: Select a random item from the "bottoms" category (e.g., pants, jeans).
    -   **Tops**: Select a random item from the "tops" category (e.g., shirts, sweaters).
    -   **Coats**: A coat is selected from the "coats" category for cooler weather.
    -   **Accessories**: Select a random accessory, such as scarves or gloves.

### Example Logic Implementation

Here’s a simplified example of how the logic is implemented in the R code:

``` r
if (temperature > 25) {
  # Hot weather logic: Do not include coats
  outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' ORDER BY RANDOM() LIMIT 1")
  outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'bottoms' ORDER BY RANDOM() LIMIT 1")
  outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' ORDER BY RANDOM() LIMIT 1")
  outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' ORDER BY RANDOM() LIMIT 1")
} else {
  # Cool weather logic: Include coats
  outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' ORDER BY RANDOM() LIMIT 1")
  outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'bottoms' ORDER BY RANDOM() LIMIT 1")
  outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' ORDER BY RANDOM() LIMIT 1")
  outfit$coat <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'coats' ORDER BY RANDOM() LIMIT 1")
  outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' ORDER BY RANDOM() LIMIT 1")
}
```

# Output Description {#output-description}

The project generates several outputs during its execution. These outputs provide visual and data-based insights into the outfit recommendation process. Below is a detailed description of the key outputs.

### 1. Outfit Plot Image (`ootd_plot.png`)

#### Description:

The `ootd_plot.png` file is the primary visual output of this project. It is an image that displays the recommended outfit for the day, along with relevant weather information.

#### Contents:

-   **Date**: The current date is displayed at the top of the image, providing context for the recommendation.
-   **Weather Forecast**: The weather description (e.g., "Sunny", "Rainy") is prominently shown to explain why the specific outfit was selected.
-   **Outfit Items**:
    -   Shoes
    -   Bottoms (e.g., pants, skirts)
    -   Tops (e.g., t-shirts, blouses)
    -   Accessories (e.g., hats, sunglasses, scarves)
    -   Coats (only included if the temperature is cool or rainy conditions are detected)

Each item is represented as an image arranged in a grid format.

#### Format:

-   **File Name**: `ootd_plot.png`
-   **Image Type**: PNG
-   **Location**: The image is saved in the project directory by default.

#### Example Content:

The following is an example layout of the `ootd_plot.png`:

-   **Header**: Includes the current date and weather description.
-   **Grid Layout**: A 2x3 grid displaying images of the outfit items, with each grid cell representing one clothing category.

# Troubleshooting and FAQs {#troubleshooting-and-faqs}

This section covers common issues you might encounter while running the project, along with solutions and tips for resolving them.

### 1. API Key Errors

#### Issue:

When accessing the `/ootd` or `/rawdata` endpoints, you might encounter errors related to the API key, such as "Invalid API key" or "Missing API key".

#### Solution:

-   Ensure that your Weatherstack API key is valid and properly set up.

-   If you're using an environment variable for the API key, make sure it is correctly exported. For example, on Linux or macOS, you can set the environment variable as follows:

    ``` bash
    export WEATHER_API_KEY="your_api_key_here"
    ```

### 2. Missing Dependencies

#### Issue:

You might encounter errors related to missing R packages or system dependencies, such as:

-   `Error: could not find function 'plumb'`
-   `Error: Package 'httr' not found`

#### Solution:

Ensure that all required R packages are installed. Run the following command in R to install the necessary packages:

``` r
install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "dplyr", "magick"))
```

### 3. Port Conflicts (API Server Doesn't Start)

#### Issue:

When trying to start the Plumber API server, you may encounter an error indicating that the desired port (e.g., port 8000) is already in use. This can happen if another process is already running on that port. You may see an error message like this: Error: Port 8000 is already in use \#### Solution: To resolve this, you have a few options:

1.  **Identify the Process Using the Port:** First, find out which process is using the port and stop it. Depending on your operating system, you can use the following commands:

    -   **Linux/macOS**: Run the following command in your terminal to check which process is using port 8000:

        ``` bash
        lsof -i :8000
        ```

        This will return a list of processes using port 8000. If you see any, you can stop them using the `kill` command, specifying the process ID (PID):

        ``` bash
        kill <PID>
        ```

    -   **Windows**: Run the following command in Command Prompt to find the process ID using port 8000:

        ``` bash
        netstat -ano | findstr :8000
        ```

        Once you have the PID, you can terminate the process using:

        ``` bash
        taskkill /PID <PID> /F
        ```

2.  **Change the Port Used by the Plumber API Server:** If you cannot stop the existing process or prefer to use a different port, you can modify the port number in your Plumber API script. For example, change the following line in your `ootd_api.R` script:

    ``` r
    pr$run(port = 8000)
    ```

### 4. Tips for Ensuring the Scripts Run Smoothly

#### Issue:

Sometimes, scripts may not run as expected due to various issues like missing dependencies, incorrect configurations, or environmental problems. Below are some tips to ensure your scripts run smoothly:

#### Solution:

**Ensure All Dependencies are Installed**: Before running any of the scripts, make sure that all the necessary R packages and system dependencies are installed. Use the following R command to install any missing packages: `r    install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "dplyr", "magick"))`

# Dependencies and Package Installation {#dependencies-and-package-installation}

In order to successfully run the project, several R packages and system-level dependencies are required. This section provides instructions for installing both R packages and any system-level dependencies needed for the project.

### 1. R Packages

The project relies on several R packages that need to be installed before running the scripts. To install these R packages, run the following command in your R console:

``` r
install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "dplyr", "magick"))
```

### 2. Instructions for Installing System-Level Dependencies

In addition to the R packages, there are some system-level dependencies that you may need to install depending on your operating system. These dependencies are required for certain functionalities like web requests, image manipulation, and database handling. Below are the instructions for installing each of these dependencies.

**curl** (for HTTP requests)

`curl` is a command-line tool used for transferring data with URLs. It is used by the `httr` R package to make HTTP requests to APIs. Most operating systems have `curl` pre-installed, but if it's missing, follow the instructions below to install it:

-   **Linux**: Open a terminal and run the following command:

    ``` bash
    sudo apt-get install curl
    ```

-   **Mac**: curl is usually pre-installed on macOS. If for any reason it's missing, you can install it via Homebrew:

    ``` bash
    brew install curl
    ```

-   **Windows**: You can download the latest version of curl from the official website curl.se. Follow the installation instructions provided on the site.
