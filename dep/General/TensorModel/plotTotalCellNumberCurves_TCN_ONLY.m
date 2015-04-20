% function plotTotalCellNumberCurves(strRootPath)

%%% NEW FIGURE    

hFigure = [];
hFigure(1) = figure();
hold on

    strRootPaths = {'\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';...
                    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';...
%                     '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\VV_KY\';...
                    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\SV40_MZ\';...
                    '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\DV_KY\';...
%                     '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\AD3_MZ\'
                    };
for iProject = 1:length(strRootPaths)

    strRootPath = strRootPaths{iProject};


    % if nargin == 0
%         strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
    %     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\060118_EV1_Kyo_CB\BATCH\';
    %     strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\50K_checkers\061120_SV40_GM1_MZ_checker\';
    % end
    strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];





    cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
    cellstrTargetFolderList = getbasedir(cellstrTargetFolderList);
    intNumOfFolders = length(cellstrTargetFolderList);
    
%     intNumOfFolders = 1
    
    PlateTensor = cell(intNumOfFolders,1);

    MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
    MasterTensor = MasterTensor.Tensor;


    %%% WHAT TO DO IF TCN COUNT IS A MODEL VARIABLE???
    % % % matTCNIndex = find(~cellfun('isempty',strfind(MasterTensor.Model.Features,'Edges')));
    % % % matOtherIndices = find(cellfun('isempty',strfind(MasterTensor.Model.Features,'Edges')));
    % % % 
    % % % if matTCNIndex
    % % %     disp(sprintf('  REMOVING TCN FIELD %s FROM TENSOR',MasterTensor.Model.Features{matTCNIndex}))
    % % %     MasterTensor.Model.Features = MasterTensor.Model.Features(matOtherIndices)
    % % %     MasterTensor.Model.X = MasterTensor.Model.X
    % % % else
    % % %     
    % % % end

    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

    matRawIIs = nan(intNumOfFolders,50);
    matRawTotalCells = nan(intNumOfFolders,50);
    matRawInfectedCells = nan(intNumOfFolders,50);
    matModelExpectedInfectedCells = nan(intNumOfFolders,50);
    matCorrectedTCNs = nan(intNumOfFolders,50);

    cellMeanModelParameterValue = {};

    cellstrDataLabels = cell(intNumOfFolders,50);

    for i = 1:intNumOfFolders

        disp(sprintf('PROCESSING %s',getlastdir(cellstrTargetFolderList{i})))

        PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
        PlateTensor{i} = PlateTensor{i}.Tensor;



        if length(cellMeanModelParameterValue) < (size(PlateTensor{i}.TrainingData,2)-1)
            cellMeanModelParameterValue = cell(1,1);
        end

        if isempty(PlateTensor{i}.TrainingData)
            disp(sprintf('  EMPTY TRAININGDATA IN %s',getlastdir(cellstrTargetFolderList{i})))
            continue
        end    

        handles = struct();
        handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_CorrectedTotalCellNumberPerWell.mat'));    
        handles = LoadMeasurements(handles, fullfile(cellstrTargetFolderList{i},'Measurements_Image_FileNames.mat'));        

        intNumberOfImages = length(handles.Measurements.Image.FileNames);

        cellFileNames = cell(1,intNumberOfImages);
        %convert ImageNames to something we can index
        for l = 1:length(handles.Measurements.Image.FileNames)
            cellFileNames{1,l} = char(handles.Measurements.Image.FileNames{l}(1));
        end    
        wellcounter = 0;

        for iRows = 3:7
            for iCols = 2:11
                if iRows == 4 && iCols == 3
                    disp(['skipping PLK1: ',[matRows{iRows},matCols{iCols}]])
                    continue
                end
                wellcounter = wellcounter + 1;

                matCurWellCellIndices = find(PlateTensor{i}.MetaData(:,1) == iRows & PlateTensor{i}.MetaData(:,2) == iCols);

                %%% LOOK FOR WHICH IMAGES MATCH THIS WELL AND GET THE TOTAL
                %%% WELL CELL NUMBER FROM CORRECTEDTOTALCELLNUMBERPERWELL
                %%% CHECK IMAGE INDICES FROM FILENAMES
                str2match = strcat('_',matRows(iRows), matCols(iCols));
                matImageIndices = find(~cellfun('isempty',strfind(cellFileNames, char(str2match))));

                if not(isempty(matImageIndices))
                    matTCNs = cell2mat(handles.Measurements.Image.CorrectedTotalCellNumberPerWell(matImageIndices));
                    if length(unique(matTCNs)) == 1
                        matCorrectedTCNs(i,wellcounter) = matTCNs(1);
                    else
                        warning('MATLAB:programmo','  predictTotalCellNumberCurves: the images of this well have more then one CorrectedTCN values')
                        matCorrectedTCNs(i,wellcounter) = matTCNs(1);
                    end
                end

                %%% DATA LABELS: OLIGO NUMBER AND WELL NAME
                cellstrDataLabels{i,wellcounter} = [num2str(PlateTensor{i}.Oligo),'_',matRows{iRows},matCols{iCols}];

                if ~isempty(matCurWellCellIndices)
                    %%% ORIGINAL INFECTION INDEX                
                    intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurWellCellIndices,1)-1);
                    intTotalCells = length(matCurWellCellIndices);
                    matRawInfectedCells(i,wellcounter) = intInfectedCells;
                    matRawTotalCells(i,wellcounter) = intTotalCells;
                    matRawIIs(i,wellcounter) = intInfectedCells./intTotalCells;

                    %%% MODEL EXPECTED INFECTION INDEX            
                    X = PlateTensor{i}.TrainingData(matCurWellCellIndices,2:end);
                    X = X - 1;
                    X = [ones(size(X,1),1),X];
                    Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                    matModelExpectedInfectedCells(i,wellcounter) = sum(Y(:));


    %                 for iDim = 2:size(PlateTensor{i}.TrainingData,2)
                    for iDim = find(strcmpi(PlateTensor{i}.Features,'Image_CorrectedTotalCellNumberPerWell_1'))
                        if isempty(cellMeanModelParameterValue{1})
                            cellMeanModelParameterValue{1} = nan(intNumOfFolders,50);
                        end
                        cellMeanModelParameterValue{1}(i,wellcounter) = mean(PlateTensor{i}.TrainingData(matCurWellCellIndices,iDim));
                    end
                end
            end
        end
    end

%     matModelIIs = matModelExpectedInfectedCells./matRawTotalCells;
% 
%     %%% lowess sorting and trendline settings
%     intLowessSpanValue = 0.5;
%     intLowessOrderValue = 1;      
%     [foo,sortix] = sort(matCorrectedTCNs(:));
% 
%     sortix(matCorrectedTCNs(sortix)<500 | isnan(matCorrectedTCNs(sortix))) = [];
% 
%     clear foo;
% 
% 
%     %%% MAKE FIRST PLOT/AXIS AS BASIS
% 
%     subplot(2,3,iProject)
%     hold on
%     scatter(matCorrectedTCNs(:),matRawIIs(:),'.r')
%     YSmooth = malowess(matCorrectedTCNs(sortix), matRawIIs(sortix), 'Robust', 'true', 'span', intLowessSpanValue, 'Order',intLowessOrderValue);    
%     plot(matCorrectedTCNs(sortix), YSmooth,'-r','LineWidth',3)           
%     title(strFigureTitle)
%     hold off
%     drawnow

%%% POLYFIT EXAMPLE
% % %     matRawRIIs = matRawIIs ./ repmat(nanmedian(matRawIIs,2),1,size(matRawIIs,2));
% % %     matRawRIIs = log2(matRawRIIs);
% % % 
% % %     cdate = matCorrectedTCNs(:);
% % %     pop = matRawRIIs(:);
% % %     matBadIndices = (isnan(cdate) | isnan(pop) | cdate < 1000);
% % %     cdate(matBadIndices) = [];
% % %     pop(matBadIndices) = [];
% % %     [cdate,sortindex]=sort(cdate);
% % %     pop=pop(sortindex)
% % %     
% % %     % Calculate fit parameters
% % %     [p,ErrorEst] = polyfit(cdate,pop,2);
% % %     % Evaluate the fit and the prediction error estimate (delta)
% % %     [pop_fit,delta] = polyval(p,cdate,ErrorEst);
% % %     % Plot the data, the fit, and the confidence bounds
% % % %     plot(cdate,pop,'+',...
% % %     plot(cdate,pop_fit,[cellColor{iProject},'-'],...
% % %          cdate,pop_fit+2*delta,[cellColor{iProject},':'],...
% % %          cdate,pop_fit-2*delta,[cellColor{iProject},':']); 
% % %     % Annotate the plot
% % %     drawnow

    matRawRIIs = matRawIIs ./ repmat(nanmedian(matRawIIs,2),1,size(matRawIIs,2));
    matRawRIIs = log2(matRawRIIs);

    % matCorrectedTCNs(:),matRawIIs(:)
    cellColor = {'g','b','m','c','k','y','g','b','y','m','c','k'};
    matBinEdges = 1:100:25000;
    [foo, binNumber] = histc(matCorrectedTCNs(:),matBinEdges);
    matBinMean = nan(size(matBinEdges));
    matBinStd = nan(size(matBinEdges));
    matBinCount = nan(size(matBinEdges));    
    for iBin = unique(binNumber)'
        if iBin > 0
            matBinMean(iBin) = nanmean(matRawRIIs(binNumber == iBin));
            matBinStd(iBin) = nanstd(matRawRIIs(binNumber == iBin));
            matBinCount(iBin) = length(find(binNumber == iBin));
        end
    end
    
    indices2show = find(matBinCount > 2);
%     errorbar(indices2show,matBinMean(indices2show),matBinStd(indices2show),'LineWidth',2,'Color',cellColor{iProject})
    scatter(indices2show,matBinMean(indices2show),['o',cellColor{iProject}],'filled')
    drawnow
    
end

legend(getlastdir(strRootPaths))

hold off
drawnow