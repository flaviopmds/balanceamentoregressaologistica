#Carregando pacotes
library(tidyverse)
library(ROSE)
library(corrplot)
library(readr)
#Carregando os dados

creditcard <- read_csv("creditcard.csv")

#Dimensão dos dados
dim(creditcard)

#Sumário das variáveis
summary(creditcard)

# Apesar de não saber o que as variáveis iniciadas com V representam, é importante saber como essas variáveis estão relacionadas com a variável resposta (fraude ou não fraude)
#A matriz de correlação ajuda a compreender como essas variáveis estão relacionadas entre si.
# No entanto, vale lembrar que vamos analisar as correlações dos dados que foi utilizado o undersampling.
correlations <- cor(creditcard,method="pearson")
corrplot(correlations, number.cex = .9, method = "circle", type = "full", tl.cex=0.8,tl.col = "black")

#Gráfico densidade da variável Time
# 1 hora = 60 minutos e 1 minuto = 60 segundos, logo pra gente saber quantos segundos corresponde a 1 hora
# temos que multiplicar 60*60

segundos_por_horas = 60*60

creditcard$horas=trunc(creditcard$Time/segundos_por_horas)


ggplot(creditcard, aes(x = horas, fill = as.factor(Class))) +
  geom_density(alpha = 0.5) +
  labs(x = "Horas",
       y = "Densidade",
       col = "Class") +
  scale_fill_discrete(labels = c("Normal", "Fraude")) + theme(legend.title = element_blank())


#Boxplot da variável Amount
creditcard %>% mutate(Classe=ifelse(Class==1,"Fraude","Normal")) %>% ggplot() + aes(x=Classe,y=Amount) + geom_boxplot()

# Distribção das classes
creditcard %>% mutate(classe=if_else(Class==1,"Fraude","Não Fraude")) %>% group_by(classe) %>% summarise(Freq=n()) %>%
  ggplot(aes(x=classe,y=Freq,fill=classe)) + geom_bar(stat = "identity",fill=c("red","blue"),color="black") +
  geom_text(aes(label = Freq),vjust=0, color="black",size=4.5)  +xlab("Classe") +
  theme_minimal()  +ylab("Frequência absoluta") + scale_y_continuous(breaks = seq(from = 0,to = 300000,by = 60000))

# Observe que o nosso conjunto de dados original está desbalanceado. Note que 99,83% das transações não são fraude.
#Se ele for utilizado dessa forma para os modelos e analises preditivas podemos obter muitos erros, pois os algoritmos irão
#assumir que a maioria das transações não são fraudes. Porém, o objetivo do trabalho é encontrar padrões das transações que são fraudes.


#MODELAGEM DOS DADOS

set.seed(123)

#Modelo dados desbalaceado
#Dividindo o banco de dados em treinamento e teste
set=sample(nrow(creditcard),round(nrow(creditcard)*0.70),replace = FALSE)
d_train=creditcard[set,]
d_test=creditcard[-set,]

glm.model = glm(Class ~ ., data = d_train, family = "binomial")
summary(glm.model)
glm.predict <- predict(glm.model, d_test[-31], type = "response")

matriz_confusao=table(d_test$Class, glm.predict > 0.5)
ac=(matriz_confusao[1,1]+matriz_confusao[2,2])/(matriz_confusao[1,1]+matriz_confusao[2,2]+matriz_confusao[1,2]+matriz_confusao[2,1])
sens=matriz_confusao[2,2]/(matriz_confusao[2,1]+matriz_confusao[2,2])
prec=matriz_confusao[2,2]/(matriz_confusao[1,2]+matriz_confusao[2,2])


#Balanceando com o método oversampling e modelando os dados
creditcard_d=ovun.sample(Class~.,data = creditcard, method = "over",p = 0.5,seed = 1)$data


set=sample(nrow(creditcard_d),round(nrow(creditcard_d)*0.70),replace = FALSE)
d_train=creditcard_d[set,]
d_test=creditcard_d[-set,]
glm.model = glm(Class ~ ., data = d_train, family = "binomial")
summary(glm.model)
glm.predict <- predict(glm.model, d_test[-31], type = "response")
matriz_confusao=table(d_test$Class, glm.predict > 0.5)
ac=(matriz_confusao[1,1]+matriz_confusao[2,2])/(matriz_confusao[1,1]+matriz_confusao[2,2]+matriz_confusao[1,2]+matriz_confusao[2,1])
sens=matriz_confusao[2,2]/(matriz_confusao[2,1]+matriz_confusao[2,2])
prec=matriz_confusao[2,2]/(matriz_confusao[1,2]+matriz_confusao[2,2])
(2*sens*prec)/(sens+prec)


#Para evitar overfitting no modelo, vamos usar o método de undersampling, que consiste
#em remover os dados da maior classe para ter um conjunto de dados mais balanceado.

#Balanceando com o método undersampling e modelando os dados

creditcard_under=ovun.sample(Class~.,data = creditcard, method = "under",p = 0.5,seed = 1)$data

dim(creditcard_under)



set=sample(nrow(creditcard_under),round(nrow(creditcard_under)*0.70),replace = FALSE)
d_train=creditcard_under[set,]
d_test=creditcard_under[-set,]
glm.model = glm(Class ~ ., data = d_train, family = "binomial")
summary(glm.model)
glm.predict <- predict(glm.model, d_test[-31], type = "response")
matriz_confusao=table(d_test$Class, glm.predict > 0.5)
ac=(matriz_confusao[1,1]+matriz_confusao[2,2])/(matriz_confusao[1,1]+matriz_confusao[2,2]+matriz_confusao[1,2]+matriz_confusao[2,1])
sens=matriz_confusao[2,2]/(matriz_confusao[2,1]+matriz_confusao[2,2])
prec=matriz_confusao[2,2]/(matriz_confusao[1,2]+matriz_confusao[2,2])
(2*sens*prec)/(sens+prec)




