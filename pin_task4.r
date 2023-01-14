install.packages("tm")
install.packages("RTextTools")
install.packages("wordcloud")
install.packages("geniusr")
install.packages("stringr")
install.packages("dplyr")
install.packages("stopwords")
install.packages("csv")
install.packages("SnowballC")

library(SnowballC)
library(tm)
library(csv)
library(RTextTools)
library(wordcloud)
library(geniusr)
library(stringr)
library(dplyr)
library(stopwords)


mayak <- read.csv("C:/Users/nikit/Downloads/mayak.csv", sep=";")
esenin <- read.csv("C:/Users/nikit/Downloads/esenin.csv", sep=";")
borodino <- read.csv("C:/Users/nikit/Downloads/borodino.csv", sep=";")


pos <- readLines("C:/Users/nikit/Downloads/positive-words.txt")
neg <- readLines("C:/Users/nikit/Downloads/negative-words.txt")

pos <- pos[!str_detect(pos, ";")]  
pos <- pos[2:length(pos)] 

neg <- neg[!str_detect(neg, ";")] 
neg <- neg[2:length(neg)]  

pos[1:50]

pos <- stemDocument(pos, language = "english") 
pos <- pos[!duplicated(pos)] 
neg <- stemDocument(neg, language = "english") 
neg <- neg[!duplicated(neg)] 

pos2 <- pos
neg2 <- neg


words = ""
words2 = ""

for (ind in 1:nrow(mayak)) {
  words = paste(words, mayak[ind, 1])
}
for (ind in 1:nrow(borodino)) {
  words2 = paste(words2, borodino[ind, 1])
}

words
words2


reviews <- Corpus(VectorSource(words)) 
reviews[[1]]$content

reviews2 <- Corpus(VectorSource(words2)) 
reviews2[[1]]$content


reviews <- tm_map(reviews, content_transformer(removeNumbers)) 
reviews[[1]]$content 

reviews2 <- tm_map(reviews2, content_transformer(removeNumbers)) 
reviews2[[1]]$content 


reviews <- tm_map(reviews, content_transformer(str_replace_all), pattern = "[[:punct:]]", replacement = " ") 
reviews[[1]]$content 

reviews2 <- tm_map(reviews2, content_transformer(str_replace_all), pattern = "[[:punct:]]", replacement = " ") 
reviews2[[1]]$content


reviews <- tm_map(reviews, content_transformer(tolower)) 
reviews[[1]]$content 

reviews2 <- tm_map(reviews2, content_transformer(tolower)) 
reviews2[[1]]$content 

reviews <- tm_map(reviews, content_transformer(removeWords), words = stopwords("en")) 
reviews[[1]]$content

reviews2 <- tm_map(reviews2, content_transformer(removeWords), words = stopwords("en")) 
reviews2[[1]]$content

reviews <- tm_map(reviews, stemDocument, language = "english") 
reviews[[1]]$content

reviews2 <- tm_map(reviews2, stemDocument, language = "english") 
reviews2[[1]]$content


tdm <- TermDocumentMatrix(reviews, control = list(weighting = weightBin)) 

tdm2 <- TermDocumentMatrix(reviews2, control = list(weighting = weightBin))

pos.mat <- tdm[rownames(tdm) %in% pos, ] 
neg.mat <- tdm[rownames(tdm) %in% neg, ] 
pos.out <- apply(pos.mat, 2, sum) 
neg.out <- apply(neg.mat, 2, sum) 
senti.diff <- pos.out - neg.out 
senti.diff[senti.diff == 0] <- NA 

print("разница м/у + и - терминами")
senti.diff 
print("кол-во (+) терминов")
sum(pos.out)
print("кол-во (-) терминов")
sum(neg.out)

pos2.mat <- tdm2[rownames(tdm2) %in% pos2, ] 
neg2.mat <- tdm2[rownames(tdm2) %in% neg2, ] 
pos2.out <- apply(pos2.mat, 2, sum) 
neg2.out <- apply(neg2.mat, 2, sum) 
senti.diff <- pos2.out - neg2.out 
senti.diff[senti.diff == 0] <- NA 

print("разница м/у + и - терминами")
senti.diff 
print("кол-во (+) терминов")
sum(pos2.out)
print("кол-во (-) терминов")
sum(neg2.out)


wordcloud(reviews, scale =  c(5, 2), random.order = F,  max.words = 100, colors = brewer.pal(9,"Blues"))
wordcloud(reviews2, scale =  c(5, 2), random.order = F,  max.words = 100, colors = brewer.pal(9,"Reds"))