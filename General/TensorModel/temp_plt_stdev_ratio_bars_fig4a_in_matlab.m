cellLabels = {'DV','MHV','RV','SV40','ChTxb','Tfn'};

matMeans = [7.1283,0.8423,1.7581,3.916,0.4575,0.5473];
matRndMeans = [0.155735,0.18343,0.183105,0.17212,0.00151,0.00702];
matRndStdevs = [0.009933636,0.01124615,0.012043364,0.012376914,0.000825897,0.000461944];
matStdevs = zeros(size(matMeans));




subplot(2,3,1:2)
barweb([matMeans(1:4)',matRndMeans(1:4)'], [matStdevs(1:4)',matRndStdevs(1:4)'], [], cellLabels(1:4), [], [], [], [], [], [])
subplot(2,3,3)
barweb([matMeans(5:6)',matRndMeans(5:6)'], [matStdevs(5:6)',matRndStdevs(5:6)'], [], cellLabels(5:6), [], [], [], [], [], [])