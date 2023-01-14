install.packages("XML")
install.packages("curl")
install.packages("stringr")
install.packages("plyr")
install.packages("dplyr")
install.packages("car")
                 
library(XML)
library(curl)
library(stringr)
library(plyr)
library(dplyr)
library(stringi)
library(ggplot2) 


getData<-function(objects){
  data<-data.frame()
  index = 1
  
  for (i in 1:length(objects)) 
  { 
    object_i<-objects[[i]]
    
    xpath_title <- ".//div[contains(@class, 'iva-item-titleStep-pdebR')]"
    x<-xpathSApply(object_i, xpath_title, xmlValue)
    if (!is.null(x))
    {
      s <- strsplit(x, ",")
      data[index, 'auto_name'] <- s[[1]][1]
      data[index, 'year'] <- s[[1]][2]
      print(index)
      print(data[index, 'auto_name'])
      print(data[index, 'year'])
    }
    
    xpath_price <- ".//span[contains(@class, 'price-price-JP7qe')]"
    x<-xpathSApply(object_i, xpath_price, xmlValue)
    if (!is.null(x))
    {
      data[index, 'price'] <- gsub("₽", "", x)
      data[index, 'price'] <- stri_replace_all_charclass(data[index, 'price'], "\\p{WHITE_SPACE}", "")
      #data[index, 'price'] <- as.numeric(data[index, 'price'])
      print(data[index, 'price'])
    }
    
    xpath_model <- ".//div[contains(@class, 'iva-item-autoParamsStep-WzfS8')]" 
    x<-xpathSApply(object_i, xpath_model, xmlValue)
    if (!is.null(x))
    {
      s <- strsplit(x, ",")
      up_index = 0
      if (length(s[[1]]) > 5) {
        up_index <- up_index + 1
        print(s[[1]][up_index])
      }

      data[index, 'km'] <- s[[1]][1 + up_index]
      data[index, 'km'] <- gsub("км", "", data[index, 'km'])
      data[index, 'km'] <- stri_replace_all_charclass(data[index, 'km'], "\\p{WHITE_SPACE}", "")
      print(data[index, 'km'])
      
      data[index, 'engine'] <- str_trim(s[[1]][2 + up_index], "left")
      data[index, 'engine'] <- gsub('[()]', '', data[index, 'engine'])
      data[index, 'engine'] <- gsub('[ATCVTMT]', '', data[index, 'engine'])
      data[index, 'engine'] <- gsub('л.с.', '', data[index, 'engine'])
      data[index, 'engine'] <- gsub('[0-9]{2,3}', '', data[index, 'engine'])
      data[index, 'engine'] <- stri_replace_all_charclass(data[index, 'engine'], "\\p{WHITE_SPACE}", "")
      print(data[index, 'engine'])
      
      data[index, 'form'] <- str_trim(s[[1]][3 + up_index], "left")
      print(data[index, 'form'])
      
      data[index, 'wd'] <- str_trim(s[[1]][4 + up_index], "left")
      print(data[index, 'wd'])
      
      data[index, 'fuel'] <- str_trim(s[[1]][5 + up_index], "left")
      print(data[index, 'fuel'])
    }
    
    index <- index + 1
    Sys.sleep(2)
    
  }
  return(data)
}


max_url <- 2
data<-data.frame()
for (u in 1:max_url)
{
  print(u)
  if (u==1) {
    url_file <- str_c("https://www.avito.ru/kazan/avtomobili/s_probegom/subaru-ASgBAgICAkSGFMjmAeC2DaaZKA?cd=1&f=ASgBAQICA0SGFMjmAeC2DaaZKPrwD~i79wIBQOa2DSTQtyjKtyg&radius=200")
  }
  
  if (u==2) {
    url_file <- str_c("https://www.avito.ru/kazan/avtomobili/s_probegom/subaru-ASgBAgICAkSGFMjmAeC2DaaZKA?cd=1&f=ASgBAQICA0SGFMjmAeC2DaaZKPrwD~i79wIBQOa2DSTQtyjKtyg&radius=200&p=2")
  }
  
  con<-curl(url_file)
  
  result<-readLines(con, warn=FALSE)
  close(con)
  
  html_file<-htmlParse(result, encoding = "UTF-8")
  xpath<- "//div[contains(@class, 'iva-item-body-KLUuy')]"
  objects<-xpathSApply(html_file, xpath)
  newData<-getData(objects)
  
  newData$auto_name <- as.factor(newData$auto_name)
  newData$year <- as.numeric(newData$year)
  newData$price <-as.numeric(newData$price)
  newData$km <-as.numeric(newData$km)
  newData$engine <-as.double(newData$engine)
  newData$form <-as.factor(newData$form)
  newData$wd <- as.factor(newData$wd)
  newData$fuel <- as.factor(newData$fuel)
  data<-rbind(data, newData)
}


data = data[!duplicated(data),]

data

model1<-lm(data$year~ data$price, data = data)
plot(data$year, data$price,col="black", type="p", pch=16, xlab="Year", ylab="Price",
     main="зависимость между годом производства и ценой")
lines(predict(model1), data$price, col="red")


model2<-lm(data$km~ data$price, data = data)
plot(data$km, data$price, col="black", type="p", pch=16, xlab="KM", ylab="Price",
     main="зависимость цены от пробега")
lines(predict(model2), data$price, col="red")
grid(lty = 3, lwd = 1)


model3<-lm(data$engine~ data$price, data = data)
plot(data$engine, data$price, col="black", type="p", pch=16, las=2, xlab="Engine", ylab="Price",
     main="зависимость цены от типа двигателя")
lines(predict(model3), data$price, col="red")
grid(lty = 3, lwd = 1)

model4<-lm(data$form~ data$price, data = data)
plot(data$form, data$price, col="black", type="p", pch=16, las=2, xlab="Form", ylab="Price",
     main="Зависимость цены от типа  кузова")
lines(predict(model4), data$price, col="red")
grid(lty = 3, lwd = 1)


total<-lm(data$price~ data$year + data$km + data$engine + data$form)

total

summary(total)

model <-lm(data$price~ data$year + data$km + data$engine + data$form, data = data)
data$pred <- predict(model)

data$pred

data$pred_2 <- data$price - data$pred

data$pred_2

hist.price <- ggplot(data, aes(price))+
  geom_histogram(aes (y = ..density..))+theme_bw()+
  labs(x = 'Цена', y = 'плотность')
hist.price + stat_function(fun = dnorm, args = list(mean = mean(data$price, na.rm = TRUE),
                                                    sd = sd(data$price, na.rm = TRUE)), color  = 'red')

num_data <- as.data.frame(data[,c("price","km", "engine", "form")])
X <- as.data.frame(data[,c("km", "engine", "form")])

library(car)
scatterplotMatrix(num_data, main ='Соотношение переменных')