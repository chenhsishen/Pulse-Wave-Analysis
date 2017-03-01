library(plyr)  
library(data.table)
library(quantmod)

setwd("~/Desktop/PulseWaveData")
list <- list.files('.')

#cut the waves
Without_Time <- function(x){
  raw <- as.data.frame(fread(x))
  v <- findValleys(raw[,2],thresh = 0.00000000000000001)
  n <- 1:length(raw[,2])
  raw_v <- c()
  raw_v <- ifelse(n %in% v, raw_v[n] <- raw[,2][n],raw_v[n]<-0)
  f_1 <- fft(raw[,2])
  ff_1 <- Re(f_1)^2
  index_1 <- c()
  index_1 <- ifelse(length(raw[,2])<=20000, index_1 <-length(raw[,2])/c(which(ff_1 %in% max(ff_1[2:50]))+1),
                    index_1 <-length(raw[,2])/c(which(ff_1 %in% max(ff_1[2:100]))+1))
  for(i in 1:length(raw_v)){
    tryCatch({
      if(raw[,2][i-1] %in% min(raw[,2][c(i-round(index_1/3)):c(i+round(index_1/3))])){
        raw_v[i] <- raw_v[i]
      }
      else {
        raw_v[i] <- 0
      }
    },error=function(y) y <- NULL)
  }  
  cut_1 <- which(!raw_v %in% 0)
  a <- list();length(a) <- length(cut_1)
  a[[1]] <- raw[,2][1:cut_1[1]]
  for(i in 2:length(cut_1)){
    tryCatch({
      a[[i]] <- raw[,2][c(cut_1[i]+1):c(cut_1[i+1]-1)] 
    },error= function(y) y <- NULL)
  }
  l <- c()
  for(i in 1:c(length(a)-1)){
    l[i] <- length(a[[i]])
  }
  l <- l[-1]
  for(i in 1:c(length(a)-1)){
    a[[i]] <- a[[i]][1:min(l[!l%in%min(l)])]
  }
  aa <- ldply(a)
  aa <- aa[-1,]
  na.omit(aa)
} 

Wave_normalized <- lapply(list,FUN = Without_Time)

ll <- c()
for(i in 1:18){
  ll[i] <- length(Wave_normalized[[i]])
}
for(i in 1:18){
  if(ll[i] > 500){
    Wave_normalized[[i]] <- Wave_normalized[[i]][,1:500]
  }
}


##############################################
####        create the function           ####
##          calculating all the             ## 
#   normalized wave (with time dimension)    #
#              and put each                  #
####      list into another list          ####   
##############################################
With_Time <- function(x){
  raw <- as.data.frame(fread(x))
  v <- findValleys(raw[,2],thresh = 0.00000000000000001)
  n <- 1:length(raw[,2])
  raw_v <- c()
  raw_v <- ifelse(n %in% v, raw_v[n] <- raw[,2][n],raw_v[n]<-0)
  f_1 <- fft(raw[,2])
  ff_1 <- Re(f_1)^2
  index_1 <- c()
  index_1 <- ifelse(length(raw[,2])<=20000, index_1 <-length(raw[,2])/c(which(ff_1 %in% max(ff_1[2:50]))+1),
                    index_1 <-length(raw[,2])/c(which(ff_1 %in% max(ff_1[2:100]))+1))
  for(i in 1:length(raw_v)){
    tryCatch({
      if(raw[,2][i-1] %in% min(raw[,2][c(i-round(index_1/3)):c(i+round(index_1/3))])){
        raw_v[i] <- raw_v[i]
      }
      else {
        raw_v[i] <- 0
      }
    },error=function(y) y <- NULL)
  }  
  cut_1 <- which(!raw_v %in% 0)
  a <- list();length(a) <- length(cut_1)
  a[[1]] <- raw[1:cut_1[1],]
  for(i in 2:length(cut_1)){
    tryCatch({
      a[[i]] <- raw[c(cut_1[i]+1):c(cut_1[i+1]-1),] 
    },error= function(y) y <- 0)
  }
  l <- c()
  for(i in 1:c(length(a)-1)){
    l[i] <- nrow(a[[i]])
  }
  l <- l[-1]
  for(i in 1:c(length(a)-1)){
    a[[i]] <- a[[i]][1:min(l[!l%in%min(l)]),]
  }
  a <- a[-1]
  for(i in 1:length(a)){
    a[[i]] <- na.omit(a[[i]])
  }
  for(i in 1:(length(a))){
    if(nrow(a[[i]]) < min(l[!l%in%min(l)])){
      a[[i]] <- NA 
    }
  }
  b <- a[!is.na(a)]
  b
}


Wave_with_time <- lapply(list,FUN=With_Time)


### The list with normalized wave
Wave_normalized <- lapply(list,FUN = Without_Time)

Normalized <- function(x){
  a_list <- list();length(a_list) <- nrow(x)
  a_1 <- c()
  seq <- c()
  a_1_new <- c()
  a_1_new_r <- c()
  for(j in 1:length(a_list)){
    a_1 <- x[j,]
    ifelse(length(x) > 400,seq <- round(seq(1,ncol(a_1),by=c((ncol(a_1)-1)/(800-ncol(a_1))))),
           seq <- round(seq(1,ncol(a_1),by=c((ncol(a_1)-1)/(450-ncol(a_1))))))
    a_1_new <- a_1
    for(i in 1:length(seq)){
      a_1_new <- cbind(a_1_new[,1:seq[i]],mean(c(a_1_new[,seq[i]],a_1_new[,seq[i]+1]))
                       ,a_1_new[,c(seq[i]+1):ncol(a_1_new)])
    }
    a_1_new_r <- a_1_new*c(length(a_1_new)/ncol(a_1))
    a_list[[j]] <- a_1_new_r
  }
  a_data <- ldply(a_list)
  a_data
}
N <- lapply(Wave_normalized,Normalized)

