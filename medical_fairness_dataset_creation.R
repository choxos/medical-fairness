is_open_general = dplyr::filter(unique_transparency, grepl("general-purpose repository", open_data_category))
open_data = unique_transparency %>% filter(is_open_data == T)


library(metareadr)
library(here)


opendata = read.csv("medical_fairness_general_repo.csv")
categories = as.data.frame(table(opendata$category))


### Next, we download xmls in format accessible with metareadr.
### To skip errors (i.e., The metadata format 'pmc' is not supported by the
### item or by the repository.), first define a new function:

# Next, we download xmls in format accessible with rtransparent:

skipping_errors <- function(x) tryCatch(mt_read_pmcoa(x), error = function(e) e)


# Function to download and save XML files
download_xml <- function(pmcid) {
        # Remove "PMC" prefix
        pmcid_without_prefix <- gsub("PMC", "", as.character(pmcid))
        
        # Attempt to download XML using skipping_errors function
        xml_file <- skipping_errors(pmcid_without_prefix)
        
}


categories = as.data.frame(table(opendata$category))


# Iterate through each element in the filtered_list
for (element_name in categories$Var1) {
        print(element_name)
        
        setwd("xmls")
        # Create a folder for the current element
        dir.create(element_name)
        setwd(element_name)
        
        # Get the tibble for the current element
        current_tibble = opendata[opendata$category == element_name,]
        
        # Iterate through each pmcid in the tibble
        for (pmcid in current_tibble$pmcid) {
                download_xml(pmcid)
        }
        
        setwd("../..")
}



## Extracting URLs
library(xml2)
library(stringr)

filter_words = c("figshare|dryad|zenodo|dataverse|dvn|osf|dataversenl|34894|mendeley|17632|gigadb|5524|openneuro|github")

urls = data.frame(matrix(ncol = 3, nrow = 0))
names(urls) = c("pmcid", "category", "url")

for(i in categories$Var1){
        setwd(i)
        filepath = dir(pattern=glob2rx("PMC*.xml"))
        for (j in filepath){
                xml_file = read_xml(j)
                ext_links = xml_find_all(xml_file, "//ext-link")
                hrefs = xml_attr(ext_links, "href")
                hrefs = tolower(hrefs)
                output = hrefs[grepl(filter_words, hrefs)]
                if(length(output) == 0){
                        ext_links = xml_find_all(xml_file, "//p")
                        ext_links = xml_text(ext_links)
                        ext_links = tolower(ext_links)
                        output = ext_links[grepl(filter_words, ext_links)]
                        pattern = paste0("(https?://|10\\.[^ ]*\\b)(", paste(keywords, collapse = "|"), ")[^ ]*")
                        links = regmatches(output, regexpr(pattern, output, perl = TRUE))
                        links = sub("\\).*$", "", links)
                        links = sub("[.:;,]$", "", links)
                        urls[j,1] = j
                        urls[j,1] = sub("\\.xml$", "", urls[j,1])
                        urls[j,1] = sub("\\s+", "", urls[j,1])
                        urls[j,2] = i
                        if(grepl(".*\\.(com|org|io|nl|edu)$", links[1])==F){
                                urls[j,3] = links[1]
                        } else {
                                urls[j,3] = links[2]
                        }
                        rownames(urls) = NULL
                } else {
                output = as.data.frame(output)
                output = rbind(i, output)
                urls[j,1] = j
                urls[j,1] = sub("\\.xml$", "", urls[j,1])
                urls[j,1] = sub("\\s+", "", urls[j,1])
                urls[j,2] = output[1,1]
                if(grepl(".*\\.(com|org|io|nl|edu)$", output[2,1])==F){
                        urls[j,3] = output[2,1]
                } else {
                        urls[j,3] = output[3,1]
                }
                rownames(urls) = NULL
                }
        }
        setwd("..")
}


write.csv(urls, "../data/medical_fairness_urls.csv")



