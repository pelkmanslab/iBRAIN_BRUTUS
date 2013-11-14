%%load sample set
strProjectPath = npc('Z:\Data\Users\Gabriele\20121029_2012-011_CellCycle\Plates\20121229_2012-011_CellCycle_HelaMZ');
% strProjectPath = npc('Z:\Data\Users\Gabriele\20121029_2012-011_CellCycle\Plates\20121229_2012-011_CellCycle_a431');
% strBATCHPath = npc('X:\Data\Users\Prisca\endocytome\090928_A431_w2LAMP1_w3ChtxAW1\090309_A431_Chtx_Lamp1_CP392-1ba\BATCH');
% strGRPMDPath = npc('Z:\Data\Users\Gabriele\20121029_2012-011_CellCycle\Plates\20121229_2012-011_CellCycle_HelaMZ\GRPMD\GRPMD_Setting_Nuclei_Cellcycle_Prisca.txt');

GRPMDSettings = 'GRPMD_Setting_Nuclei_CellcycleBinary.txt';
strBATCHPath = npc(fullfile(strProjectPath, 'BATCH'));
strGRPMDPath = npc(fullfile(strProjectPath, 'GRPMD',GRPMDSettings));
[matCompleteData,strColumns,matCompleteMetaData] = getRawProbModelData2(strBATCHPath, strGRPMDPath);

for ix = [2,3,4]
tmpIX = matCompleteMetaData(:,1) == ix;
iCells(:,ix) = tmpIX; 
end
iCells = logical(sum(iCells,2));

for ix = [1:14 16:size(strColumns,2)]
    clear XAxses
    XAxses = nanzscore(matCompleteData(iCells,ix)./matCompleteData(iCells,15));
    
    figure
    title(sprintf('%s',strColumns{ix}))
    hold on
    %%Intensities
%     plotquant(XAxses,nanzscore(matCompleteData(iCells,3)),500,'k',.5)%S
    plotquant(XAxses,nanzscore(matCompleteData(iCells,1)),500,'k',.5)%G2
%     plotquant(XAxses,nanzscore(matCompleteData(iCells,2)),500,'k',.5)%M
    
%%SVM
%     plotquant(XAxses,double(matCellCycleStage(:,1)).*1,500,'y',.5)%G1
%     plotquant(XAxses,double(matCellCycleStage(:,2)).*2,200,'r',.5)%S
    plotquant(XAxses,double(matCellCycleStage(:,3)).*3,500,'g',.5)%G2
%     plotquant(XAxses,double(matCellCycleStage(:,4)).*4,500,'b',.5)%M
    hold off
    ix
%         plotquant(nanzscore(matCompleteData(iCells,ix)),nanzscore(matCompleteData(iCells,22)./matCompleteData(iCells,15)),500,'r',.5)

end


matData = matCompleteData(iCells,:);
%%get the S non log10 transformed
inxS = matData(:,3) > (350/10000);
%%get the G2  log10 transformed
inxG2 = matData(:,1) > -3,1;
%%get the M non log10 transformed
inxM = matData(:,2) > 0.0006;
%%get the G1 non log10 transformed
inxG1 = all([inxS inxG2 inxM] == 0,2);

matCellCycleStage = [inxG1 inxS inxG2 inxM];

%%Clearing overlap between S and G2
inxOverlap = inxS == 1 & inxG2 == 1;
matCellCycleStage(inxOverlap,2) = 0;
%%Clearing overlap between S and G2
inxOverlap = inxG2 == 1 & inxM == 1;
matCellCycleStage(inxOverlap,3) = 0;
%%Clearing overlap between S and M
inxOverlap = inxS == 1 & inxM == 1;
matCellCycleStage(inxOverlap,2) = 0;


matPercentageCellCycle = sum(matCellCycleStage)./sum(sum(matCellCycleStage)).*100;
matCellCycleSCPrediction = NaN(size(matCellCycleStage,1),size(matCellCycleStage,2));
for ix = 1:size(matCellCycleStage,2)
matCellCycleSCPrediction(:,ix) = matCellCycleStage(:,ix).*ix;
end
matCellCycleSCPrediction = sum(matCellCycleSCPrediction,2);


XData = matCompleteData(iCells,4:end);
yfit = NaN(size(XData,1),size(matCellCycleStage,2));
matCCSPModel = NaN(size(XData,1),size(matCellCycleStage,2));
for ix = 1:size(matCellCycleStage,2)
clear b 
fprintf('%s: processing %d. phase.\n',mfilename,ix)
b = glmfit(XData,matCellCycleStage(:,ix),'binomial','link','probit');
yfit(:,ix) = glmval(b, XData,'probit','size', 1000);
[intHillCoefficient{ix}, intMaxRMSE{ix}, yMinOUT{ix}, yMaxOUT{ix}, xHalfOUT{ix}, matMaxYFit{ix}, matAllMaxRMSEs{ix}] = fitAdjustedHill(yfit(:,ix),double(matCellCycleStage(:,ix)));
matCCSPModel(:,ix) = yfit(:,ix)>xHalfOUT{ix};
matCCSPMPercentage = (sum(matCCSPModel(:,ix))/size(XData,1))*100;
fprintf('%s: %d percent of the cells were predicted to be in %d.Phase\n',mfilename,matCCSPMPercentage,ix)
end




%% Binning Data
intNumOfBins = 20;%5000 for 414636  floor(size(matXData,1)/80)
matBinEdges = linspace(quantile(matCompleteData(:,15),0.001),quantile(matCompleteData(:,15),0.999),intNumOfBins); %linspace(quantile(matXData,0.001),quantile(matXData,0.999),intNumOfBins)
[~,matBinDataIX] = histc(matData(:,15),matBinEdges);

% set x-data to the middle value of each bin.
matBinEdges = matBinEdges + median(diff(matBinEdges));
matBinEdges(end) = [];

numOfBins = numel(matBinEdges);
matDataBounds = NaN(numOfBins,4);

parfor iBin = 1:numOfBins
    matIX = matBinDataIX==iBin;
    for jx = 1:4
    matDataBounds(iBin,jx) = (sum(matCellCycleSCPrediction(matIX)==jx)/sum(matIX))*100;
    end
end

% matNonNanIX = any(~isnan(matDataBounds),2);
matCellCycleLCD = NaN(numOfBins,6);
matCellCycleLCD(:,1) = matBinEdges; %X
matCellCycleLCD(:,2:5) =  matDataBounds;% Y

figure()
bar(matCellCycleLCD(:,2:5),'stacked')




