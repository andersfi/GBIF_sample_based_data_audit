# load packages 
library(rgbif)
library(jsonlite)
library(magrittr)

# get list of all sample-based datasets (limit = 300 to be checked against portal before running)
datasets <- datasets(data = "all", type = "sampling_event", limit = 300, start = NULL, curlopts = list())

datasets <- data.frame(
  title=datasets$data$title,
  key=datasets$data$key,
  description=datasets$data$description)

for(i in 1:length(datasets$key)){
  datasets$occurences[i] <- occ_count(datasetKey = datasets$key[i])
}

# number of occurrences in GBIF sample-based datasets
sum(datasets$occurences)

#-----------------
# download
#----------------

# set GBIF credentials
options(gbif_user=rstudioapi::askForPassword("my gbif username"))
options(gbif_email=rstudioapi::askForPassword("my registred gbif e-mail"))
options(gbif_pwd=rstudioapi::askForPassword("my gbif password"))


# the query is to large to be passed as one (GBIF has 12,000 characters as limit to quiery).
# Therefore, split the quiery into two arguments and run download request multiple-times.
# Current volume of sample-based datasets require a split into 3 prediciates.
d_keys <- as.character(datasets$key)
n_chuncs <- round(length(d_keys)/3,digits=0)
chunc1 <- 1:n_chuncs
chunc2 <- (n_chuncs+1):(n_chuncs*2)
chunc3 <- (n_chuncs*2+1):(n_chuncs*3)

VectorList <- splitIndices(d_keys, 3)

q2_start <- q1_end + 1
q2_end <- length(datasets$key)
datasets_to_download1 <- paste("datasetKey = ",paste(datasets$key[chunc1], collapse =","))
datasets_to_download2 <- paste("datasetKey = ",paste(datasets$key[chunc2], collapse =","))
datasets_to_download3 <- paste("datasetKey = ",paste(datasets$key[chunc3], collapse =","))

# create download key

download_key1 <- occ_download(
  datasets_to_download1,
  type = "and"
) %>% 
  occ_download_meta

download_key2 <- occ_download(
  datasets_to_download2,
  type = "and"
) %>% 
  occ_download_meta

download_key3 <- occ_download(
  datasets_to_download3,
  type = "and"
) %>% 
  occ_download_meta

downlaod_key1 <- "0045528-181108115102211" #download_key1[1]
downlaod_key2 <- "0045532-181108115102211" #download_key2[1]
downlaod_key3 <- "0045533-181108115102211" #download_key2[1]

# download dataset (NB: large file)

download.file(url=paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key1[1],sep=""),
              destfile="download1.zip",
              quiet=TRUE, mode="wb")
download.file(url=paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key2[1],sep=""),
              destfile="download2.zip",
              quiet=TRUE, mode="wb")
download.file(url=paste("http://api.gbif.org/v1/occurrence/download/request/",
                        download_key3[1],sep=""),
              destfile="download3.zip",
              quiet=TRUE, mode="wb")



