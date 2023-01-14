install.packages("openxlsx")
install.packages("ggplot2") 

library(openxlsx) 
library(ggplot2) 
df <- read.xlsx("C:/Users/nikit/Downloads/wild2ver.xlsx") 
df$Price <- as.numeric(df$Price)
df
g15 <- ggplot(df, aes(x=Price)) + 
  geom_histogram(fill = "pink", colour = "brown") + 
  theme(text = element_text(size = 50),element_line(size =1)) 
options(repr.plot.width = 50, repr.plot.height =20) 
g15