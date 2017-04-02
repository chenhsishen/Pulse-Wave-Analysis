## Waveform Normalization
- 這裡在做的事情，算是資料專案中「粗活」。因為不同病人的脈波週期不同，若要一起訓練，就得在資料中做一些取捨，最後們決定，去除週期較大的尾端的部分；週期較小的，就利用內插法補齊。
- 而這裡說的內插法，只是補上前後兩個值的平均這麼簡單而已；先計算出週期間的差異，再等比例內插至週期較小的波中；除了週期長度以外，振幅高度也要乘上同樣內插前後相差的比例。
- 至於哪樣叫週期大、哪樣叫週期小，是我經過嘗試後，以內插的比例不會破壞波形原本的形狀為主。

### Normalization with Interpolation
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
    ifelse(length(x) > 400,seq <- round(seq(1,ncol(a_1),by=c((ncol(a_1)-1)/(800-ncol(a_1))))),   #這邊的seq，是按比例內插所需要的「位置」向量
           seq <- round(seq(1,ncol(a_1),by=c((ncol(a_1)-1)/(450-ncol(a_1))))))  #至於為什麼要用400和800，就如同上面所說的，是嘗試之後的結果
    a_1_new <- a_1
    for(i in 1:length(seq)){
      a_1_new <- cbind(a_1_new[,1:seq[i]],mean(c(a_1_new[,seq[i]],a_1_new[,seq[i]+1]))  #接著就按照位置向量，將其後兩個值的平均插入
                      ,a_1_new[,c(seq[i]+1):ncol(a_1_new)])
    }
    a_1_new_r <- a_1_new*c(length(a_1_new)/ncol(a_1)) #將波的振幅高度按比例提高
    a_list[[j]] <- a_1_new_r
  }
  a_data <- ldply(a_list)   #將資料合併為一個資料集，並回傳這個資料集
  a_data
}

```

### Comparison between Un-normalized and Normalized
 - 標準化後和標準化前的波，我們來用下面兩張圖比較：
 - 標準化前：
 ![Imgur](http://i.imgur.com/fXo4QTC.jpg)
 - 標準化後：
 ![Imgur](http://i.imgur.com/6xtjoya.jpg)
 - 有沒有發現，其實看不太出來差異呢！這就是我要的！！！

### Final Result
 - 最後把各個病人和在不同狀態的波形整理出來，我們總共得到下面18個波：(由此可見，我們得到的樣本真的很有限吧！)
 ![Imgur](http://i.imgur.com/yjXYn3x.jpg)
 
### 透過這些處理後，我們就能把資料做後續的建模和視覺化囉！之後和組員討論，有機會再把後續的程式放上來；至於把這些程式接起來後的程式碼，我放在[這邊](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Complete-Solution.R)。
### 裡面有一部分沒有做到標準化，只有進行切波，是因為後續某項處理要保留時間維度(即每0.02秒為一筆資料的維度)
