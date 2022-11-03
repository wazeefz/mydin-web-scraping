library(rvest)
library(RSelenium)

url = "https://mydinexpress.my/hypermart/"

driver = rsDriver(port = as.integer(sample(1000:10000, 1)), browser = "chrome", chromever = "106.0.5249.61")

remDr = driver[["client"]]

remDr$navigate(url)

Sys.sleep(0.5)

#Function1 : Check for Agree Button

checkagree = function(){
              clickagree = read_html(remDr$getPageSource()[[1]]) %>%
                html_nodes("a.btn.btn-color-primary.wd-age-verify-allowed") %>% html_text()
              
              if(length(clickagree)!=0){
                Sys.sleep(0.5)
                agreebutton = remDr$findElement(using = "css selector",
                                          value = "a.btn.btn-color-primary.wd-age-verify-allowed")
                agreebutton$clickElement()
              }

}

#Function2 : Getting All Product Links

getprodlink = function(){
  
              clickloadmore = read_html(remDr$getPageSource()[[1]]) %>%
              html_nodes("span.load-more-loading") %>% html_text()
              
              k = 1
            
              while(length(read_html(remDr$getPageSource()[[1]]) %>%
                           html_nodes("span.load-more-loading") %>% html_text())!=0){

              
                Sys.sleep(0.8)
                
                loadmorebutton = remDr$findElement(using = "css selector",
                                          value = "span.load-more-loading")
                loadmorebutton$clickElement()
                
                
                cat(k,"\n")
                k = k + 1
                
                
              }
                
                
              product_links = read_html(remDr$getPageSource()[[1]]) %>%
                  html_nodes("a.open-quick-view.quick-view-button") %>% html_attr("href") 
              
              cat("Length of product_links =", length(product_links))
              
              return(as.data.frame(product_links))
  
  

} 

Sys.sleep(0.5)

#Function3 : Getting All Product Details


getproddetails = function(){



              prod_details = data.frame()
              
              for(i in 1:length(product_links)){
                remDr$navigate(product_links[i])
                
                Sys.sleep(.8)
                
                name = read_html(remDr$getPageSource()[[1]]) %>%
                  html_nodes("h1.product_title.entry-title") %>% html_text() 
                # cat("NAME = ",name,"\n")
                
                allcategory = read_html(remDr$getPageSource()[[1]]) %>%
                  html_nodes("a.breadcrumb-link  ") %>% html_text()
                category = allcategory[2]
                # cat("CATEGORY = ",category,"\n")
                
                subcategory = allcategory[3]
                # cat("SUBCATEGORY = ",subcategory,"\n")
                
                price = read_html(remDr$getPageSource()[[1]]) %>%
                  html_nodes("span.amount") %>% html_text()
                price = price[length(price)]
                # cat("PRICE = ",price,"\n")
                
                sku = read_html(remDr$getPageSource()[[1]]) %>%
                  html_nodes("span.sku_wrapper") %>% html_text()
                # cat("SKU = ",sku,"\n")
                
                cat("iteration =",i,"\n")
               
                df = data.frame(Name = name, 
                                Category = category,
                                SubCategory = subcategory,
                                Price = price,
                                SKU = sku)
                
                prod_details = rbind(prod_details, df)
                
                
              }
  return(prod_details)
}

############################################################################

#Function Compilation

Sys.sleep(0.5)

checkagree()

Sys.sleep(0.5)

product_links = getprodlink()

product_links = tryCatch(getprodlink(), error = function(e){e})

# while(inherits(x,"error")){
#   x = tryCatch(getprodlink(), error = function(e){e})
# }

Sys.sleep(0.5)

getproddetails()

nrow(productdetails)


############################################################################

#Saving dataframe into csv file

date = gsub("-", "_", Sys.Date())


data.table::fwrite(productdetails, paste0("//10.13.10.22/dataSandbox/scraping/misc/mydin/mydindata_", date, ".csv"))






