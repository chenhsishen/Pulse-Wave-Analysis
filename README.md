##Pulse-Wave-Analysis
 - 這是一個和新光醫院的麻醉科醫師，林佑霆醫師合作的專案，旨在分析麻醉病患的臨床生理訊號；由於現代醫學對於脈波辨識並沒有太多著墨，因此要借助資料科學的工具，來發展出一套可能的方法。
 - 由於這個專案是和其他三位同學共同完成，在徵求他們同意前，我只會放上我貢獻的[部分程式](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Complete-Solution.R)，也就是從原始資料中自動辨識、擷取並標準化不同種類的波形。
 - 專案完成後我們認為利用機器學習的方式進行脈波辨識，進而判斷麻醉中病人的生理狀況是可行的，但完整的研究需要更多臨床上的協助。
 - 由於整個組都是「統計」相關背景的學生，我們自然選用R作為我們的工具。
 
 ---
  
###Raw Data
 - 林醫師給我們的資料是麻醉病人的臨床生理脈搏，是橈動脈的脈波；每0.02秒紀錄一次脈搏的壓力，一次測量大約10000-30000毫秒不等。
 - 如果畫出來，擷取其中一段，會像這個樣子:
 
 ![Imgur](http://i.imgur.com/EPgNbiP.jpg)
 - 很明顯的，這是一筆二維的資料。
 
###Data Preprocess - From 2-Dimensional to Multi-Dimensional 
 - 二維的資料我們通常不是太喜歡，在和林醫師討論後，他的建議是把每一個「脈波」，即每一次脈搏所產稱的「那個波」，當作一筆觀測值，這樣每一個raw data，200-300秒的時間，就會有足夠的資料。(幾百筆，依病人的脈搏週期而定)
 - 同時，一個波通常由400-600個點組成(即儀器記錄的脈搏壓力)，把幾百個記錄點，作為資料的Varibles，就成功將二維的資料轉成多維了。
 - 所以資料前處理的需求是，能夠自動判別不同波段的週期，進而從波段中擷取各個脈波的，擷取出來的脈波會長這個樣子：
 
 ![Imgur](http://i.imgur.com/fXo4QTC.jpg)
 
###Challenge for Data Preprocess 
 - 稍微觀察上面的兩張圖片，應該不難推測出，不管是不是同一個病人，擷取出的各個脈波，所包含的記錄點數目都不會一樣；即每一次脈搏的週期並不是固定的。
 - 特別是這次的資料，又分成各種手術前後，病人的脈波更是會出現劇烈的變化，週期也比較難直觀地掌握。
 - 自動偵測週期以及正規化每一個波段，是這次專案的前處理中，比較有難度的地方。
 
###[Solution - Fast Fourier Transform/ Local Minimum Discovery/ Normalization](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Complete-Solution.R)
 - [Step1: Fast Fourier Transform](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Fast%20Fourier%20Transform.md) 能協助我們逼近一段波段(raw data)的主要週期
 - [Step2: Local Minimum Discovery](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Local%20Minimum%20Discovery.md) 將第一階段的結果代入，搜尋週期中的區域最小值，最為波和波之間的分割點，並擷取出一個一個波
 - [Step3: Waveform Normalization](https://github.com/chenhsishen/Pulse-Wave-Analysis/blob/master/Waveform%20Normalization.md) 選擇補上前後兩個點的平均值，利用內插法進行正規化
