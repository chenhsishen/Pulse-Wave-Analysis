##Waveform Normalization
- 這裡在做的事情，算是資料專案中「粗活」。因為不同病人的脈波週期不同，若要一起訓練，就得在資料中做一些取捨，最後們決定，去除週期較大的尾端的部分；週期較小的，就利用內插法補齊。
- 而這裡說的內插法，只是補上前後兩個值的平均這麼簡單而已；先計算出週期間的差異，再等比例內插至週期較小的波中。
- 至於哪樣叫週期大、哪樣叫週期小，是我經過嘗試後，以內插的比例不會破壞波形原本的形狀為主。

###Normalization with Interpolation
- 我將整個流程，即標準化後再儲存各個波，寫成一個函數```Normalized()```，之後能一次套用到所有的資料。
```R
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

```
