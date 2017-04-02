## Local Minimum Discovery
 - 擷取脈波所需要的，是要找出去切割脈波的「點」。藉由[上一篇](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Fast%20Fourier%20Transform.md)得到的資訊，我們能找出每個週期裡的區域最小值。
 - 善用R提供的套件，再加上我們自己運算出的週期，就能完美切割出週期不同的波。

---

### Find Local Minimum/ Maximum in R
 - 安裝R的```quantmod```套件，並利用其中的```findValleys()```找出區域最小(或```findPeaks()```找出區域最大)；背後的邏輯很簡單，只要發生「正負號」轉換的地方，就會被視為出現一個極值。
 - 可以設定threshold，調整它的靈敏程度，在閾值內的變動會被忽略。
 - 這個函數回傳的值，是極值在一個向量中的「位置」(即這麼多的值中，第幾個會是極值)，用下面這段程式碼說明：
```R
v <- findValleys(raw[,2],thresh = 0)
```
 - 回傳的v，即是一個數值向量，裡面包含了各個區域最小值出現的位置；為了方便接下來的處理，我們把這個向量v的長度補到和原始資料一樣，空缺的地方就補上0。
```R
v <- findValleys(raw[,2],thresh = 0)
raw_v <- ifelse(n %in% v, raw_v[n] <- raw[,2][n],raw_v[n]<-0) 
```

### Apply Time information into Local Minimum Finding
 - 引入```fft()```計算出來的週期後，我們要確定我們找出的波谷，是「前後半個週期」間的最小值。
```R
for(i in 1:length(raw_v)){
    tryCatch({
      if(raw[,2][i-1] %in% min(raw[,2][c(i-round(index_1/2)):c(i+round(index_1/2))])){  #是否符合前後半個週期的最小，有個話就保留，沒有就補0
        raw_v[i] <- raw_v[i]
      }
      else {
        raw_v[i] <- 0
      }
    },error=function(y) y <- NULL)
  } 
```
 - 這樣一來，我們就得到了真實的區域最小值的「位置向量」，接下來就可以用這結論去切割脈波了。
 ![Imgur](http://i.imgur.com/cbEpPIN.png)
 
### To Extract each wave from the data
 - 雖然我們已經很逼近結果了，但還是有些細節要注意，主因是原始資料中，因為在資料搜集時的睏談，開頭和結尾的波段不會是完整的，要扣除這兩個波。
 - 再來是如果中間突然出現異常的跳動(即並非正常的週期和震幅變化)，我們也選擇不將其納入我們準備訓練的資料中。
```R
cut_1 <- which(!raw_v %in% 0)    #僅取出位置向量中不等於0的真實位置
  a <- list();length(a) <- length(cut_1)  #將各個波的資料，存入一個叫a的list
  a[[1]] <- raw[,2][1:cut_1[1]]
  for(i in 2:length(cut_1)){
    tryCatch({
      a[[i]] <- raw[,2][c(cut_1[i]+1):c(cut_1[i+1]-1)]   #取出單個波
    },error= function(y) y <- NULL)
  }
  l <- c()      
  for(i in 1:c(length(a)-1)){
    l[i] <- length(a[[i]])   #為了去除剛剛說的頭尾不完整的波形，所以要先獲得各個波的長度
  }
  }
  l <- l[-1]  #去除第一個波
  for(i in 1:c(length(a)-1)){
    a[[i]] <- a[[i]][1:min(l[!l%in%min(l)])]  #在剩下的長度中，選出倒數第三小的，作為這些波統一的長度。
  }
  aa <- ldply(a)  #將list中的個元素合併成一個資料集。
  aa <- aa[-1,]
  aa <- na.omit(aa)
```
### 最後的這個資料集，裡面就有多筆觀測值，每筆觀測值就是一個波在各個時間點記錄到的脈搏。下一篇會說明如何將不同人的脈波資料正規化，在不更動形狀的情況下，幫助我們訓練辨識脈波的模型。
