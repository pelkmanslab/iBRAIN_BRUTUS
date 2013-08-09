% function compareNoVirusToInfectedDimensions(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\David\Pictures\David_iBRAIN\080312Davidtestplaterescan3\BATCH\';         

%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_final\SV40_MZ_NEW\20080506202703_M2_080429_50k_SV40_GM1rmed_MZ_p1_1_2\';         
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\David\080220davidvirus\';
%     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_final\SV40_MZ_NEW_2\';

    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';

% end

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

% calculate the most common dimension-indices from all trainingdata (single
% cells)
matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);

% you can also use the median pop-props of the no virus control
% matDimensionMedians = nanmedian(MasterTensor.TrainingData((MasterTensor.MetaData(:,1)==8),:),1);

% we need to kick out total cell number!
intNumDims = length(matDimensionMedians);

intNumIndices = size(MasterTensor.Model.X,1);

matAllDims = 1:intNumDims;

% MasterTensor.Features'
matDimensionMedians(2)=3
% matDimensionMedians(end)=6

figure

for iDim = 2:intNumDims % skipping first dimension, constant
    
    itnCurrentDimBins = MasterTensor.BinSizes(iDim);

    matCurrentClassDimensions = 2:intNumDims;
    matCurrentClassDimensions(matCurrentClassDimensions==iDim) = [];

    disp(sprintf('finding cells matching current tensor-slice for dimension %d',iDim))
    matCurrentClassCellIndices = ones(size(MasterTensor.TrainingData,1),1);
    for iDim2 = matCurrentClassDimensions % skipping first dimension, constant
        matCurrentClassCellIndices = (MasterTensor.TrainingData(:,iDim2)==matDimensionMedians(iDim2) & matCurrentClassCellIndices);
    end
    
% % %     matCurrentClassCellIndices = ismember(MasterTensor.TrainingData(:,2:end),matDimensionMedians(1,2:end),'rows');
   

    
%     MasterTensor.MetaDataFeatures
 
    %%% HARD CODED NO VIRUS CONTROL DATA: 50
    matNoVirusCtrlCellIndices = (MasterTensor.MetaData(:,1)==8) & matCurrentClassCellIndices;% 50K
    matInfectedCellIndices = (MasterTensor.MetaData(:,1)<8) & matCurrentClassCellIndices;
    matReallyInfectedCellIndices = (MasterTensor.TrainingData(:,1)==2) & (MasterTensor.MetaData(:,1)<8) & matCurrentClassCellIndices;    

%%% DAVID'S TEST PLATE LAYOUT
%     matNoVirusCtrlCellIndices = (MasterTensor.MetaData(:,2)==1) & matCurrentClassCellIndices;% 50K
%     matInfectedCellIndices = (MasterTensor.MetaData(:,2)>1) & (MasterTensor.MetaData(:,2)<16) & matCurrentClassCellIndices;
%     matReallyInfectedCellIndices = (MasterTensor.TrainingData(:,1)==2) & (MasterTensor.MetaData(:,2)>1) & (MasterTensor.MetaData(:,2)<16) & matCurrentClassCellIndices;    

%%% DAVID'S TEST PLATE LAYOUT, ATTEMPT 2
%     intNVCColumn = 1;
%     intAssayRow = 12;
%     matNoVirusCtrlCellIndices = (MasterTensor.MetaData(:,2)==intNVCColumn) & matCurrentClassCellIndices;% 50K
%     matInfectedCellIndices = (MasterTensor.MetaData(:,2)>intNVCColumn) & (MasterTensor.MetaData(:,1)==intAssayRow) & matCurrentClassCellIndices;
%     matReallyInfectedCellIndices = (MasterTensor.MetaData(:,2)>intNVCColumn) & (MasterTensor.TrainingData(:,1)==2) & (MasterTensor.MetaData(:,1)==intAssayRow) & matCurrentClassCellIndices;    


%%% comparison between the highly infected SV40_MZ_GM1RMED (oligo 1) and the low
%%% infected SV40_MZ data (oligo 3) data
%     matNoVirusCtrlCellIndices = (MasterTensor.MetaData(:,5)==3) & matCurrentClassCellIndices;% 50K
%     matInfectedCellIndices = (MasterTensor.MetaData(:,5)==1) & matCurrentClassCellIndices;
%     matReallyInfectedCellIndices = (MasterTensor.TrainingData(:,1)==2) & (MasterTensor.MetaData(:,5)==1) & matCurrentClassCellIndices;    

%     unique(MasterTensor.MetaData(:,end-1))
    
    disp(sprintf('found %d cells: %d no-virus-ctrl, %d assay, %d infected',sum(matCurrentClassCellIndices), sum(matNoVirusCtrlCellIndices), sum(matInfectedCellIndices), sum(matReallyInfectedCellIndices) ))    
    

    [xNoVirus]=histc(MasterTensor.TrainingData(matNoVirusCtrlCellIndices,iDim),1:MasterTensor.BinSizes(iDim));
    [xInfected]=histc(MasterTensor.TrainingData(matInfectedCellIndices,iDim),1:MasterTensor.BinSizes(iDim));
    [xReallyInfected]=histc(MasterTensor.TrainingData(matReallyInfectedCellIndices,iDim),1:MasterTensor.BinSizes(iDim));
    
    subplot(2,3,(iDim-1))
    hold on
    plot(xInfected/sum(xInfected),'g','LineWidth',2)
    plot(xReallyInfected/sum(xInfected),'--g','LineWidth',2)
    plot(xNoVirus/sum(xNoVirus),'b','LineWidth',2)    
    vline(matDimensionMedians(iDim),'k:')        
    legend({sprintf('assay (%d)',sum(xInfected)),sprintf('infected (%d)',sum(xReallyInfected)),sprintf('no-virus (%d)',sum(xNoVirus))},'FontSize',8)
    
    
    if ~MasterTensor.Model.DiscardParamBasedOnCIs(iDim)
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10)
    else
        title(strrep(MasterTensor.Features{iDim},'_','\_'),'fontsize',10,'color','r')        
    end    
    
    hold off
    drawnow
    
end
        
        
% add axis w/color none that overlaps entire figure as title placeholder
strFigureTitle = strrep(sprintf('%s',char(getlastdir(strRootPath))),'_','\_');
hold on
axes('Color','none','Position',[0,0,1,.95])
axis off
title(['comparing distributions of no-virus cells and infected cells (keeping all other dims the same): ',strFigureTitle],'FontSize',14,'FontWeight','bold')
hold off
drawnow



    
%     for iBin = 1:intCurrentDimBins
        
        
        
%         matCurrentClass = zeros(size(matAllDims));
%         matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
%         matCurrentClass(iDim) = iBin;
%         matCurrentClass = matCurrentClass - 1;
%         matCurrentClass(1) = 1;
%         
%         intCurrentRowIndex = find(sum(MasterTensor.Model.X == repmat(matCurrentClass,intNumIndices,1),2) == size(matCurrentClass,2));
% 
%         cellMeasuredII{iDim}(1,iBin) = MasterTensor.Model.Y(intCurrentRowIndex);
% 
%         [yhat,dylo,dyhi] = glmval(MasterTensor.Model.Params, matCurrentClass(1,2:end),'identity',MasterTensor.Model.Stats);
%         yhat(yhat<0) = 0;
%         yhat(yhat>1) = 1;
%         
%         cellModelExpectedII{iDim}(1,iBin) = yhat;%sum(MasterTensor.Model.Params' .* matCurrentClass);
% %         cellModelExpectedIILowerBound{iDim}(1,iBin) = yhat-dylo;
% %         cellModelExpectedIIUpperBound{iDim}(1,iBin) = yhat+dyhi;
%         
%         cellTotalCells{iDim}(1,iBin) = MasterTensor.TotalCells(intCurrentRowIndex);        
%         cellWeights{iDim}(1,iBin) = MasterTensor.Model.W(intCurrentRowIndex,intCurrentRowIndex);
        
%         MasterTensor
% 
%     end
% end

gcf2pdf