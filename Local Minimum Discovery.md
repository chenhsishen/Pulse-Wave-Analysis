##Local Minimum Discovery
 - 擷取脈波所需要的，是要找出去切割脈波的「點」。藉由[上一篇](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Fast%20Fourier%20Transform.md)得到的資訊，我們能找出每個週期裡的區域最小值。
 - 善用R提供的套件，再加上我們自己運算出的週期，就能完美切割出週期不同的波。

---

###Find Local Minimum/ Maximum in R
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

###Apply Time information into Local Minimum Finding
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

