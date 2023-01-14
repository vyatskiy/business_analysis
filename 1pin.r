mydata <- read.table("C:/Users/nikit/Downloads/access.log", header = FALSE, sep = "")
mydata

install.packages("stringr")
library(stringr)

dataframe <- subset(mydata, select = -c(V1, V2, V3, V5, V7,V8))
colnames(dataframe) <- c("date", "request", "id_bask")

id_bask = gsub("ID", "", dataframe$id_bask)
date_n = gsub("Apr", "04", dataframe$date)
date_n = gsub("[[]", "", date_n)
date_n = gsub("/", "-", date_n)
date_n = gsub("2015:", "2015 ", date_n)

request_n = gsub("1.1", "", dataframe$request)
request_n = gsub("[[:upper:][:space:][/]", "", request_n)
request_n = gsub("addbasket.phtml?", "addbasket.phtml ", request_n)
request_n = gsub("[?]", "", request_n)
id_book = str_extract(request_n, "id_book=.*")
id_book = gsub("id_book=", "", id_book)

request_n = gsub("?id_book=..", "", request_n)

newData <- data.frame(id_bask = id_bask, query_date = date_n, 
                       request = request_n, id_book = id_book )
newData
write.csv2(newData, "example1.csv")

newDataWithoutNull = subset(newData, id_book != 'NA')
newDataWithoutNull

write.csv2(newDataWithoutNull, "newDataWithoutNull.csv")

install.packages("arules")
library(arules)
library(datasets)

mydata2 <- read.csv("D:\\python scripts\\newDataWithoutNull_2.csv", sep=',', head=TRUE)
head(mydata2)

data <- as(split(mydata2[, 'id_book'], mydata2[, 'id_bask']), 'transactions')
data

inspect(data)

summary(data)

itemFrequencyPlot(data,topN=15, type="absolute")

rules=apriori(data = data,
              parameter = list(support=0.01, confidence=0.1,
                               minlen=1))

inspect(rules[1:10])

