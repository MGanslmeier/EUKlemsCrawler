# Scrape and Extrace EU Klems Data

The EU Klems database is a widely used dataset within the economic disciplin. Unfortunately, the single country files make it very time consuming to use this dataset. To save time for researchers, two functions are provided to download and extract the data from the excel sheets.

    source('src/EUKlemsCrawler.R')
    DownloadFiles()
    klems_df <- ExtractValues()