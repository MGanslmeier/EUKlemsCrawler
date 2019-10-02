pacman::p_load(rvest, RCurl, readxl, plyr, dplyr, tidyr)

# function to download files
DownloadFiles <- function(){
  
  # sracpe all links to files
  links <-
    read_html('http://www.euklems.net/index_TCB_201807.shtml') %>% 
    html_nodes('body > table:nth-child(18) > tr > td:nth-child(3) > a') %>% 
    html_attr('href') %>% 
    paste('http://www.euklems.net',.,sep='/')
  
  # download all files
  dir.create('data/files')
  for(i in links){
    fileName_short <- gsub('http://www.euklems.net/TCB/2017/', '', i)
    fileName <- paste("data/files/", fileName_short, sep = '')
    download.file(i, destfile = fileName, method = "libcurl")
  }
  
}

##################

# function to extract values
ExtractValues <- function(){
  
  # define objects
  file_vector <- list.files('data/files', full.names = T)
  sheet_vector <- excel_sheets(file_vector[2])
  res <- list()
  
  # extract values
  for(j in 1:length(file_vector)){
    for(i in 1:length(sheet_vector)){
      tryCatch({
        
        # initialize country_name and df
        iso2 <- basename(file_vector[j]) %>% substr(., 1, 2)
        df <- read_excel(file_vector[j], sheet = sheet_vector[i])[,c(1:2)] %>% mutate(iso2 = iso2)
        
        # merge sheets to df
        for(i in sheet_vector){
          temp <- read_excel(file_vector[j], sheet = i)
          temp$desc <- NULL
          df <- merge(df,temp,by='code')
        }
        
        # store df in results list
        res[[j]] <- df
        
      }, error = function(e){})
    }
  }
  
  # reshape dataframe
  final <- 
    ldply(res, rbind) %>% 
    gather(., key = "variable_year", value = "value", -c(code, desc, iso2)) %>%
    mutate(year = sub("^.*([0-9]{4}).*", "\\1", variable_year), indicator = gsub('[0-9]','',variable_year)) %>% 
    select(-variable_year) %>% spread(.,indicator,value) %>% select(iso2 , year, code, desc, everything()) %>%
    arrange(iso2, year, code)
  return(final)
}
