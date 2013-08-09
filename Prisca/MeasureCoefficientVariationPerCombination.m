

function [FtestNonTargeting,Ftest]=MeasureCoefficientVariationPerCombination(strBASIC,strFeatureName)


if nargin==0
 strBASIC = '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\100215_A431_Actin_LDL\100215_A431_Actin_LDL_CP393-1bi\BATCH';   
 strFeatureName = '_RescaledRed';
end

strBASIC = npc(strBASIC);



textFileName = strcat('COMB_Mean',strFeatureName,'.txt');
strSettingFile = fullfile(getbasedir(getbasedir(strBASIC)),textFileName);




    cellstrPlateBasicData = SearchTargetFolders(strBASIC,'BASICDATA_*.mat','rootonly');
    if ~isempty(cellstrPlateBasicData)
        load(cellstrPlateBasicData{1});
    else
        error('%s: could not find BASICDATA_*.mat in %s',mfilename,strBASIC)
    end    
     
    
    
    % Load data
     [matCompleteData, strFinalFieldName, matCompleteMetaData] = getRawProbModelData2(strBASIC,strSettingFile);

    
   %get data from Non-targeting
     matNonTargetingImageIX = BASICDATA.ImageIndices(strcmpi(BASICDATA.GeneData,'Non-targeting'));
     matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
     matNonTargetingCellIX = ismember(matCompleteMetaData(:,6),matNonTargetingImageIX);
     
     NonTargetingData = matCompleteData(matNonTargetingCellIX,:);
     
    NumberofPredictors = size(strFinalFieldName,2)-1; 
    CombinationMatrix = all_possible_combinations2(ones(1,NumberofPredictors)+1)-1;
    strFinalPredictors=cell(size(CombinationMatrix,1),2);
     
     for iCombination=1:size(CombinationMatrix,1)
      
         
      disp(sprintf('measuring F-test for combination %d over %d',iCombination,size(CombinationMatrix,1))) 
      PredictorMatrix=matCompleteData(:,2:end); 
      PredictorMatrixNT=NonTargetingData(:,2:end); 
      strFinalFieldNamePredictors=strFinalFieldName(:,2:end);
      
      CombinationIndex=(CombinationMatrix(iCombination,:))==1;
      
      PredictorMatrix=PredictorMatrix(:,CombinationIndex);
      PredictorMatrixNT=PredictorMatrixNT(:,CombinationIndex);
      strFinalFieldNamePredictors=strFinalFieldNamePredictors(:,CombinationIndex);
      
      
      
      matCompleteDataForCombination=[];
      matCompleteDataForCombinationNT=[];
      
      if ~sum(CombinationIndex)==0
      
      matCompleteDataForCombination= [matCompleteData(:,1),PredictorMatrix];
      matCompleteDataForCombinationNT= [NonTargetingData(:,1),PredictorMatrixNT];
    
      strFinalPredictors{iCombination}=strFinalFieldNamePredictors;
 
    % do bin correction, first column is readout, others are used for binning.
    [matCompleteDataBinReadout,matBinEdges,matBinDimensions,matTensorII,matTensorTCN, matCompleteDataBinIndex, matIIPerBin, matTCNPerBin] = doBinCorrectionPrisca(matCompleteDataForCombination, strFinalFieldNamePredictors);%
    
     % do bin correction, first column is readout, others are used for binning.
    [matCompleteDataBinReadoutNonTargeting,matBinEdgesNonTargeting,matBinDimensionsNonTargeting,matTensorIINonTargeting,matTensorTCNNonTargeting, matCompleteDataBinIndexNonTargeting, matIIPerBinNonTargeting, matTCNPerBinNonTargeting] = doBinCorrectionPrisca(matCompleteDataForCombinationNT, strFinalFieldNamePredictors);%
   
   
    

    %Get Data Per Bin for non targeting
  
     matBinDataNonTargeting=cell(1,1);
      for i=1:max(matCompleteDataBinIndexNonTargeting)
         matBinDataNonTargeting{i}= matCompleteDataForCombinationNT(matCompleteDataBinIndexNonTargeting==i,1);
         if size(matBinDataNonTargeting{i},1)<50
             matBinDataNonTargeting{i}=[]; 
         end
      end
      indexEmptyNonTargeting=cellfun(@isempty,matBinDataNonTargeting);
      matBinDataNonTargeting(indexEmptyNonTargeting)=[];
      
     
     
     %Get Data Per Bin for full data
     matBinData=cell(1,1);
      for i=1:max(matCompleteDataBinIndex)
         matBinData{i}= matCompleteDataForCombination(matCompleteDataBinIndex==i,1);
         if size(matBinData{i},1)<50
             matBinData{i}=[]; 
         end
      end
      indexEmpty=cellfun(@isempty,matBinData);
      matBinData(indexEmpty)=[];
      
   
    varWithin = median(cellfun(@var,matBinData));
    varBetween = var(matIIPerBin);
    Ftest(iCombination,:) = 100*(varBetween / (varBetween + varWithin));

    varWithinNonTargeting = median(cellfun(@var,matBinDataNonTargeting));
    varBetweenNonTargeting = var(matIIPerBinNonTargeting);
    FtestNonTargeting(iCombination,:) = 100*(varBetweenNonTargeting / (varBetweenNonTargeting + varWithinNonTargeting));

    
      else
      end
     end

    strOutputFileNameVariance = fullfile(strBASIC,['VarianceAnalysis',strFeatureName,'.mat']);
%     strOutputFileNameFtestNT = fullfile(strBASIC,['FtestNT',strFeatureName,'.mat']);
%     strOutputFileNamePredictors = fullfile(strBASIC,['strCombination',strFeatureName,'.mat']);

    
    save(strOutputFileNameVariance,'Ftest','FtestNonTargeting','strFinalPredictors')
%     save(strOutputFileNameFtest,'Ftest')
%     save(strOutputFileNamePredictors,'strFinalPredictors')
%     
     
     
end

