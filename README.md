# Linguas Analytics Dashboard

This repository contains the source code for the Linguas Analytics Dashboard, a Shiny application designed to provide insights into language and country participation over time. The application is built using R and Shiny, with database connectivity to MySQL for live data retrieval and analysis.

## Overview

The dashboard provides multiple views of the data, including:
- Total counts from each language over time
- Total counts from each country over time
- Cumulative total count over the selected date range
- A detailed breakdown and tally by country
- Interactive data tables with detailed event data

## Features

- **Database Connection**: Connect to a MySQL database to fetch real-time data.
- **Interactive Plots**: Dynamic plots created using `ggplot2` that update based on the selected date range.
- **Data Tables**: Interactive tables using the `DT` package, allowing for detailed examination of the data.

## Dependencies

To run this application, you will need to install the following R packages:

```R
install.packages("shiny")
install.packages("DBI")
install.packages("RMySQL")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("DT")
install.packages("lubridate")
```
To run the application locally, you can clone this repository and run the application from your R environment:
```R
library(shiny)
runApp('path_to_app_directory')
