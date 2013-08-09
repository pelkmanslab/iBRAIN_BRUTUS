% function plotDataPerWell_2(strRootPath,str50KPath,strOutputPath)

%     if nargin < 3
%         strOutputPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\50K_results\080620_poprops_per_well\';
%     end
%     if nargin < 2
%         str50KPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';
%     end
%     if nargin < 1
%         strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';
%     end
%     
    
%     if nargin==0
        strRootPath = 'Y:\Data\Users\Frank\iBRAIN\081205-timedose-VSV-DYRK3INH-20x\';
        strSettingsFile = 'Y:\Data\Users\Frank\iBRAIN\081205-timedose-VSV-DYRK3INH-20x\ProbModel_Settings_all_cells_included.txt';
%     end
    
    strRootPath = npc(strRootPath);
    strOutputPath = npc(strRootPath);
        

    %%% IF PRESENT LOAD THE TRAININGDATA STRUCT. FROM THE CURRENT FOLDER
    [boolTrainingDataFileExists] =  fileattrib(fullfile(strRootPath,'ProbModel_TensorDataPerWell.mat'));
    if boolTrainingDataFileExists
        oldTensorDataPerWell = load(fullfile(strRootPath,'ProbModel_TensorDataPerWell.mat'));
        oldTensorDataPerWell = oldTensorDataPerWell.TensorDataPerWell;
    else
        disp(sprintf('quiting plotDataPerWell: no model data in %s',strRootPath))
        return
    end

    [structDataColumnsToUse, structMiscSettings] = initStructDataColumnsToUse(strSettingsFile);    
    
    MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
    MasterTensor = MasterTensor.Tensor;

    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');


    intNumOfParams = length(MasterTensor.Model.Features);
    iWell = 0;
    iOligo = 1;
    
    intNumOfWells = 96;

    matRawInfectedCells = cell(intNumOfParams,intNumOfWells);
    matRawTotalCells = cell(intNumOfParams,intNumOfWells);
    matRawIIs = cell(intNumOfParams,intNumOfWells);
    matModelExpectedInfectedCells = cell(intNumOfParams,intNumOfWells);
    cellstrWellNames = cell(1,intNumOfWells);

    intOligoIndex = find(strcmpi(MasterTensor.MetaDataFeatures,'OligoNumber'));

    for iRows = 1:8

        %MasterTensor.MetaDataFeatures(:,1) == 'PlateRow'
        intCurRowIndices = find(MasterTensor.MetaData(:,1)==iRows);

        matCurRowMetaData = MasterTensor.MetaData(intCurRowIndices ,:);
        matCurRowTrainingData = MasterTensor.TrainingData(intCurRowIndices ,:);


        for iCols = 1:12

            intCurColIndices = find(matCurRowMetaData(:,2)==iCols);        
            matCurTrainingData = matCurRowTrainingData(intCurColIndices ,:);
            matCurMetaData = matCurRowMetaData(intCurColIndices ,:);        

            iWell = iWell + 1;
            strLabelsPerGene = strcat(matRows{iRows}, matCols{iCols});
            cellstrWellNames{1,iWell} = strLabelsPerGene;
%             disp(sprintf('processing %s dim %d / %d',strLabelsPerGene,iDim,intNumOfParams))
                disp(sprintf('processing %s',strLabelsPerGene))
            for iDim = 2:intNumOfParams

                for iBin = 1:MasterTensor.BinSizes(iDim)

                    if not(isempty(MasterTensor.TrainingData))

                        %%% FIND ALL THE CELL INDICES THAT MATCH THE CURRENT
                        %%% DIMENSION BIN...
                        matCurWellBinCellIndices = find(matCurTrainingData(:,iDim) == iBin);

                        %%% ORIGINAL INFECTION INDEX                
                        intInfectedCells = sum(matCurTrainingData(matCurWellBinCellIndices,1)-1);
                        intTotalCells = length(matCurWellBinCellIndices);

                        % SET TOTALCELLS=0 TOT NaN
                        if intTotalCells==0
                            intTotalCells = NaN;
                            intInfectedCells = NaN; 
                        end                

                        matRawInfectedCells{iDim,iWell}(iOligo,iBin) = intInfectedCells;
                        matRawTotalCells{iDim,iWell}(iOligo,iBin) = intTotalCells;
                        matRawIIs{iDim,iWell}(iOligo,iBin) = intInfectedCells./intTotalCells;

    %                     %%% MODEL EXPECTED INFECTION INDEX            
    %                     X = MasterTensor.TrainingData(matCurWellBinCellIndices,2:end);
    %                     X = X - 1;
    % 
    %                     X = [ones(size(X,1),1),X];
    %                     Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
    %                     Y = sum(Y,2);
    % 
    %                     %%% only clamp predicted output to 0/1 if it is a binary
    %                     %%% readout
    %                     if MasterTensor.BinSizes(1,1) == 2
    %                         Y(Y<0)=0;
    %                         Y(Y>1)=1;
    %                     end
    % 
    %                     matModelExpectedInfectedCells{iDim,iWell}(1,iBin) = round(sum(Y(:)));
                    end
                end % iBin
            end % iDim 
        end % iCols
    end % iRows

    cellstrDimNames = MasterTensor.Features;
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_VirusScreen_ClassicalInfection_1','INFECTION');
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_GridNucleiCountCorrected_1','LCD');
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_AreaShape_1','SIZE');
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_GridNucleiEdges_1','EDGE');
    cellstrDimNames = strrep(cellstrDimNames,'Image_CorrectedTotalCellNumberPerWell_1','TCN');
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_CellTypeClassificationPerColumn_2','MIT');
    cellstrDimNames = strrep(cellstrDimNames,'Nuclei_CellTypeClassificationPerColumn_3','APOP');

    for iDim = 2:intNumOfParams
        for iOligo = 1
            hFig = figure();%'WindowStyle','docked'
            for iWell = 1:intNumOfWells

                matPresentDatapoints = find(matRawTotalCells{iDim,iWell}(iOligo,:)>10);
                
                if ~isempty(matPresentDatapoints)
                    subplot(8,12,iWell)
                    hold on
                    bar(matRawTotalCells{iDim,iWell}(iOligo,matPresentDatapoints),'FaceColor',[.92 .92 .92],'EdgeColor',[.92 .92 .92])
                    axis tight
                    drawnow
                    plot(matRawIIs{iDim,iWell}(iOligo,matPresentDatapoints)' * max(get(gca,'YLim')),'linewidth',2)
                    title(cellstrWellNames{1,iWell},'FontSize',8,'FontWeight','bold')
                    hold off 
                    drawnow
                    set(gca,'FontSize',6)
                end
            end



            % add page title
            hold on
            axes('Color','none','Position',[0,0,1,.95])
            axis off
            title(strrep(sprintf('%s %s Oligo %d',getlastdir(strRootPath),cellstrDimNames{iDim},iOligo),'_','\_'),'FontSize',14,'FontWeight','bold')
            hold off
            drawnow        

            drawnow           
            pause(.1)
            
            %datestr(now, 'yyddmmHHMMSS')
            strFigureName = sprintf('plotDataPerWell_%s_%s_oligo%d',getlastdir(strRootPath),cellstrDimNames{iDim},iOligo);
            gcf2pdf(strOutputPath,strFigureName)
            close(hFig)
        end
    end

% end