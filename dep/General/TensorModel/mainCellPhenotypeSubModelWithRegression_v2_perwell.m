
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\061117_Ad5_50K_MZ_2_1\';
% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad3_MZ\070313_Ad3_MZ_P1_1\';

strRootPath = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\BATCH\';
strSettingsFile = '\\nas-biol-imsb-1\share-3-$\Data\Users\Berend\EvaBerend\081117_MCF10A_SV40_ChTxBup_pFAK\ProbModel_Settings_all_cells_included.txt';


% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\RV_KY_2\';
% strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\RV_KY_2\ProbModel_Settings.txt';        

% strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\SV40_MZ\';
% strSettingsFile = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\SV40_MZ\ProbModel_Settings.txt';

[structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);

cellstrDataPaths = getbasedir(SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat'));

intNumOfDirs = size(cellstrDataPaths,1);

matCompleteDataPerCell = [];
matCompleteDataPerWell = [];

strFinalFieldName = {};
for iDir = 1:intNumOfDirs
    
    matFinalDataPerWell = [];
    matFinalDataPerCell = [];    
    
    strDataPath = cellstrDataPaths{iDir};    
    disp(sprintf('  analyzing %s',strDataPath))


    %%% INITIALIZE PLATEDATAHANDLES
    PlateDataHandles = struct();
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_FileNames.mat'));    
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,'Measurements_Image_ObjectCount.mat'));

    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ObjectsToExclude.MeasurementsFileName));
    PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structMiscSettings.ImagesToExclude.MeasurementsFileName));        

    matImageOutOfFocus = PlateDataHandles.Measurements.(structMiscSettings.ImagesToExclude.ObjectName).(structMiscSettings.ImagesToExclude.MeasurementName);
    cellObjectsToExclude = PlateDataHandles.Measurements.(structMiscSettings.ObjectsToExclude.ObjectName).(structMiscSettings.ObjectsToExclude.MeasurementName);    
    matObjectsToExcludeColumn = structMiscSettings.ObjectsToExclude.Column;       

    %%% GET A LIST OF WHICH IMAGES TO INCLUDE FROM
    %%% structMiscSettings.RegExpImageNamesToInclude
    cellImageNames = cell(size(PlateDataHandles.Measurements.Image.FileNames));
    for k = 1:length(PlateDataHandles.Measurements.Image.FileNames)
        cellImageNames{k} = PlateDataHandles.Measurements.Image.FileNames{k}{1,1};
    end
    
    strRegexp = structMiscSettings.RegExpImageNamesToInclude;
%     strRegexp = '_H\d\d';%%% OVERWRITE
    disp(sprintf('*** NOTE, strRegExp = %s',strRegexp))
    
    %%% ALSO SKIP WELL THE FOLLOWING WELLS BECAUSE THEY ARE CELLKILLERS
%     matImageIndicesToInclude = (~cellfun(@isempty,regexp(cellImageNames,strRegexp)) & ...
%         cellfun(@isempty,strfind(cellImageNames,'_B08')) & ...
%         cellfun(@isempty,strfind(cellImageNames,'_B09')) & ...        
%         cellfun(@isempty,strfind(cellImageNames,'_D03')) & ...
%         cellfun(@isempty,strfind(cellImageNames,'_D04')) & ...
%         cellfun(@isempty,strfind(cellImageNames,'_D06')) & ...
%         cellfun(@isempty,strfind(cellImageNames,'_G04')) & ...        
%         cellfun(@isempty,strfind(cellImageNames,'_G05')) );

    matImageIndicesToInclude = ~cellfun(@isempty,regexp(cellImageNames,strRegexp));
    disp(sprintf('  analyzing %d images, structMiscSettings.RegExpImageNamesToInclude = "%s"',sum(matImageIndicesToInclude(:)),strRegexp))

    %%% GET PER IMAGE INFORMATION ON PLATE WELL LOCATION
    [matImageNamePlateRows,matImageNamePlateColumns]=cellfun(@filterimagenamedata,cellImageNames','UniformOutput',1);
    
    %%% LOOP OVER ALL FIELDNAMES IN STRUCTDATACOLUMNSTOUSE
    cellstrNucleiFieldnames = fieldnames(structDataColumnsToUse);
%     for i = 2:length(cellstrNucleiFieldnames)%%% ORIGINAL
    for i = 1:size(cellstrNucleiFieldnames,1)%%% SKIP THE READOUT, INFECTION
        
        strCurrentFieldName = char(cellstrNucleiFieldnames{i});
        strObjectName = structDataColumnsToUse.(strCurrentFieldName).ObjectName;

        for ii = 1:size(structDataColumnsToUse.(strCurrentFieldName).Column,2)

            strFinalFieldName = [strFinalFieldName; [strObjectName,'_',strCurrentFieldName,'_',num2str(structDataColumnsToUse.(strCurrentFieldName).Column(ii))]];
            intCurrentColumn = structDataColumnsToUse.(strCurrentFieldName).Column(ii);
            intNumberOfBins = structDataColumnsToUse.(strCurrentFieldName).NumberOfBins;
            
            %%% IF THE CURRENT REQUIRED DATA IS NOT PRESENT, THEN LOAD
            %%% THE CORRESPONDING RAW DATA FILE 
            if ~isfield(PlateDataHandles.Measurements,strObjectName) || ~isfield(PlateDataHandles.Measurements.(strObjectName),strCurrentFieldName)
                PlateDataHandles = LoadMeasurements(PlateDataHandles, fullfile(strDataPath,structDataColumnsToUse.(strCurrentFieldName).MeasurementsFileName));
            end

            
            matPlateDataPerCell = [];                        
            matPlateDataPerWell = cell(8,12);

            for k = find(~matImageOutOfFocus & matImageIndicesToInclude)
%                     disp(sprintf('PROCESSING %s',PlateDataHandles.Measurements.Image.FileNames{k}{1,1}))
                matTempData = [];
                if not(isempty(PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}))
                    % intObjectCount = PlateDataHandles.Measurements.Image.ObjectCount{k}(1,1);
                    intObjectCount = length(find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn)));

                    %%% ONLY TAKE OBJECTS FROM NON-OTHER CLASSIFIED
                    %%% NUCLEI
                    if strcmpi(strObjectName,'Nuclei') || strcmpi(strObjectName,'Cells')
                        % exclude other-classified cells
                        matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                            
                    elseif strcmpi(strObjectName,'Image')
                        matOKCells = 1;
                    else
                        %assume default is objects
                        matOKCells = find(~cellObjectsToExclude{k}(:,matObjectsToExcludeColumn));                                                        
                    end

                    if intObjectCount > 1

                        %%% TRANSPOSE IF THE DATA REQUIRES IT
                        if structDataColumnsToUse.(strCurrentFieldName).Transpose
                            matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(intCurrentColumn,matOKCells)';
                        else
                            matTempData = PlateDataHandles.Measurements.(strObjectName).(strCurrentFieldName){k}(matOKCells,intCurrentColumn);          
                        end

                        %%% REPEAT MEASUREMENT IF IT IS A 1xN SIZE MATRIX &&
                        %%% OBJECTCOUNT > 1
                        %%% ADDED strcmpi(strObjectName,'Image') &&
                        %%% SINCE THIS SHOULD ONLY HAPPEN FOR IMAGE
                        %%% MEASUREMENTS...
                        if strcmpi(strObjectName,'Image') && size(matTempData,1) == 1 && size(matTempData,2) == 1 && intObjectCount > 1
                            matTempData = repmat(matTempData,intObjectCount,1);
                        end

                        %%% LOG10 TRANSFORM DATA IF SETTINGS SAY TO DO SO                            
                        if isfield(structDataColumnsToUse.(strCurrentFieldName),'Log10Transform')
                           if structDataColumnsToUse.(strCurrentFieldName).Log10Transform
                                matTempData = log10(matTempData);
                                matTempData(isinf(matTempData) | isnan(matTempData)) = NaN;
                           end
                        end

                        matPlateDataPerWell{matImageNamePlateRows(k),matImageNamePlateColumns(k)} = [matPlateDataPerWell{matImageNamePlateRows(k),matImageNamePlateColumns(k)};matTempData];
                        matPlateDataPerCell = [matPlateDataPerCell;matTempData];                        

                    end % if objectcount > 1 check

                end
            end
    
            %%% take mean value per well
            matMeanValuesPerWell = cellfun(@nanmean,matPlateDataPerWell);
            matMeanValuesPerWell(isnan(matMeanValuesPerWell)) = [];
            matFinalDataPerWell = [matFinalDataPerWell, single(matMeanValuesPerWell(:))];
            
            %%% all data per single cell
            matFinalDataPerCell = [matFinalDataPerCell, single(matPlateDataPerCell(:))];
            
        end
    end
    
    matCompleteDataPerCell = [matCompleteDataPerCell;matFinalDataPerCell];
    matCompleteDataPerWell = [matCompleteDataPerWell;matFinalDataPerWell];    

end
size(matCompleteDataPerWell)
size(matCompleteDataPerCell)

% load(fullfile(strRootPath,'matCompleteData.mat'),'matCompleteDataPerWell','matCompleteDataPerCell','cellstrNucleiFieldnames')

% matZScoredCopmleteDataPerCell = nanzscore(matCompleteDataPerWell);


intNumOfCells = size(matCompleteDataPerCell,1);
disp('*** reducing data size 10 fold')
% matCompleteDataPerCell = single(nanzscore(matCompleteDataPerCell(1:10:intNumOfCells,:)));
matCompleteDataPerCell = single(nanzscore(matCompleteDataPerCell));

intNumOfDims = size(matCompleteDataPerCell,2);

%%% PER WELL
matRndIndices = randperm(size(matCompleteDataPerWell,1));
matRndIndices = matRndIndices(1:end);
[vif,r2,bs,cellstats] = testVIF(matCompleteDataPerWell(matRndIndices,:));
matWellBs = bs(:,2:end);

% bs(:,2:end)
% strFinalFieldName(1:6)

%%% PER CELL
matBootStrapBS=nan(intNumOfDims,intNumOfDims,100);
for i = 1:100
    i
    matRndIndices = randperm(size(matCompleteDataPerCell,1));
    matRndIndices = matRndIndices(1:20000);
    [vif,r2,bs,cellstats] = testVIF(matCompleteDataPerCell(matRndIndices,:));

%     [vif,r2,bs,cellstats] = testVIF_glmfit(zscore(matCompleteDataPerCell(matRndIndices,1:6)));
    
    matBootStrapBS(:,:,i) = bs(:,2:end);
end

matBootStapBStds=nan(intNumOfDims,intNumOfDims);
matBootStapBMeans=nan(intNumOfDims,intNumOfDims);
for i = 1:intNumOfDims
    for ii = 1:intNumOfDims
        matBootStapBStds(i,ii)=nanstd([matBootStrapBS(i,ii,:)]);
        matBootStapBMeans(i,ii)=nanmean([matBootStrapBS(i,ii,:)]);        
    end
end

% matCellBs = bs(:,2:end);

bs(:,2:end)
strFinalFieldName(:)

% boxplot(matCompleteDataPerCell(matRndIndices,3),matCompleteDataPerCell(matRndIndices,6))
% scatterhist(matCompleteDataPerCell(matRndIndices,3),matCompleteDataPerCell(matRndIndices,6))
% xlabel(strFinalFieldName{3})
% ylabel(strFinalFieldName{6})

% strFinalFieldName2 = {'LCD','SIZE','EDGE','POP.SIZE','MIT','APOP'};
strFinalFieldName2 = strrep(strFinalFieldName,'_','\_')

figure()
hold on
icount = 0;

for i = 1:intNumOfDims
    for ii = 1:intNumOfDims
        icount = icount + 1;
        if ii < i
            [matCorrcoef, matP] = corrcoef(matCompleteDataPerCell(:,i),matCompleteDataPerCell(:,ii), 'rows', 'pairwise');
            subplot(intNumOfDims-1,intNumOfDims-1,i-1+((ii-1)*(intNumOfDims-1)))
%             subplot(5,5,i-1+((ii-1)*5))
%             subplot(3,3,i-1+((ii-1)*3))
            scatter(matCompleteDataPerWell(:,i),matCompleteDataPerWell(:,ii),repmat(3,size(matCompleteDataPerWell(:,ii))),'b','filled')
            set(gca,'fontsize',6)
            xlabel(strFinalFieldName2{i},'fontsize',4)
            ylabel(strFinalFieldName2{ii},'fontsize',4)
            title(sprintf('reg.coef = %.3f \\pm %.3f \n cor.coef = %.2f (p = %g)',matBootStapBMeans(i,ii),matBootStapBStds(i,ii),matCorrcoef(1,2),matP(1,2)),'fontsize',8)
            drawnow
        end
    end
end
hold off
drawnow
gcf2pdf
return

%%% SHOW SCATTERPLOT PER SINGLE CELL
matRndIndices = randperm(size(matCompleteDataPerCell,1));
matRndIndices = matRndIndices(1:100);

strFinalFieldName2 = {'LCD','SIZE','EDGE','TCN','MIT','APOP'};
figure()
hold on
icount = 0;
for i = 1:6
    for ii = 1:6
        icount = icount + 1;
        if ii < i
            subplot(5,5,i-1+((ii-1)*5))
            scatter(matCompleteDataPerCell(matRndIndices,i),matCompleteDataPerCell(matRndIndices,ii),repmat(3,size(matCompleteDataPerCell(matRndIndices,ii))),'b','filled')
            xlabel(strFinalFieldName2{i})
            ylabel(strFinalFieldName2{ii})
            title(sprintf('beta = %g +/- %.2f (std)',matBootStapBMeans(i,ii),matBootStapBStds(i,ii)),'fontsize',8)
            drawnow
        end
    end
end
hold off
drawnow
