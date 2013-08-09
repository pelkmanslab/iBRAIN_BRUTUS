function getModelParamsPerWell(strRootPath)

if nargin == 0
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\HPV16_MZ_2\';
end


cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
intNumOfFolders = length(cellstrTargetFolderList);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;


%%% INIT DATA CONTAINERS
tempDataPerOligo = [];
matSigmaPerOligo = [];
matRSquarePerOligo = [];
matAdjustedRSquaredPerOligo = [];

tempDataPerGene = [];
matSigmaPerGene = [];
matRSquarePerGene = [];
matAdjustedRSquaredPerGene = [];


%%% FIND AND REMOVE TOTALCELLNUMBER PARAMETER FROM
intAllOtherThenTCNIndices = 1:length(MasterTensor.Features);%find(cellfun(@isempty,strfind(MasterTensor.Features,'TotalCellNumber')));
intTCNIndex = find(~cellfun(@isempty,strfind(MasterTensor.Features,'TotalCellNumber')));
% intTCNIndex = [intTCNIndex,find(~cellfun(@isempty,strfind(MasterTensor.Features,'CellTypeClassification')))];
intAllOtherThenTCNIndices(intTCNIndex) = [];

disp('removing all references to TotalCellNumber from trainingdata, features and binsizes')
MasterTensor.Features = {MasterTensor.Features{intAllOtherThenTCNIndices}};
MasterTensor.TrainingData(:,intTCNIndex) = [];
MasterTensor.BinSizes(:,intTCNIndex) = [];
MasterTensor.Model.Features = {MasterTensor.Model.Features{intAllOtherThenTCNIndices}};

matAllPossibleCombinations = uint8(all_possible_combinations2(MasterTensor.BinSizes(2:end)));


matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');

cellstrLabelsPerGene = {};
cellstrLabelsPerOligo = {};
matTCNPerGene = [];
matTCNPerOligo = [];
% iOligo=1;

intMetaDataOligoNumberIndex = find(strcmpi(MasterTensor.MetaDataFeatures,'OligoNumber'));

for iRows = 3:7
    for iCols = 2:11
        for iSwitch = 1:2

            if iSwitch == 1
                iOligoCount = 1:3;
            elseif iSwitch == 2
                iOligoCount = 1;
            end

            for iOligo = iOligoCount


                matClassInfectedCells = zeros(size(matAllPossibleCombinations,1),1);
                matClassTotalCells = zeros(size(matAllPossibleCombinations,1),1);


                if iSwitch == 1
                    matCurWellCellIndices = find(MasterTensor.MetaData(:,1) == iRows & MasterTensor.MetaData(:,2) == iCols & MasterTensor.MetaData(:,intMetaDataOligoNumberIndex) == iOligo);
                    cellstrLabelsPerOligo = [cellstrLabelsPerOligo, strcat(matRows(iRows), matCols(iCols),'_',num2str(iOligo))];                                    
                    matTCNPerOligo = [matTCNPerOligo, length(matCurWellCellIndices)];
                    disp(sprintf('analyzing row %d, col %d, oligo %d',iRows,iCols,iOligo))                    
                elseif iSwitch == 2
                    matCurWellCellIndices = find(MasterTensor.MetaData(:,1) == iRows & MasterTensor.MetaData(:,2) == iCols);
                    cellstrLabelsPerGene = [cellstrLabelsPerGene, strcat(matRows(iRows), matCols(iCols))];                    
                    disp(sprintf('analyzing row %d, col %d, combined oligos (%d)',iRows,iCols,iOligo))                    
                    matTCNPerGene = [matTCNPerGene, length(matCurWellCellIndices)];                    
                end
                
                if length(matCurWellCellIndices) > 50

                    matTrainingData = uint8(MasterTensor.TrainingData(matCurWellCellIndices,:));
                    matAllPresentCombinations = uint8(unique(matTrainingData(:,2:end),'rows'));

                    for ii = 1:size(matAllPresentCombinations,1)
                        matCurrentClassInfected = repmat([2,matAllPresentCombinations(ii,:)],size(matTrainingData,1),1);
                        matCurrentClassUninfected = repmat([1,matAllPresentCombinations(ii,:)],size(matTrainingData,1),1);

                        [matInfectedRowIndices, foo] = find(sum(matTrainingData == matCurrentClassInfected,2) == size(matCurrentClassInfected,2));
                        [matUninfectedRowIndices, foo] = find(sum(matTrainingData == matCurrentClassUninfected,2) == size(matCurrentClassInfected,2));

                        intInfected = length(matInfectedRowIndices);
                        intUninfected = length(matUninfectedRowIndices);

                        %%% LOOK FOR CELLS THAT MATCH ALL CRITERIA (DIMENSIONS)
                        [intCurRow, foo] = find(sum(matAllPossibleCombinations == repmat(matAllPresentCombinations(ii,:),size(matAllPossibleCombinations,1),1),2) == size(matAllPresentCombinations,2));

                        matTrainingData([matInfectedRowIndices;matUninfectedRowIndices],:) = [];

                        matClassInfectedCells(intCurRow,1) = matClassInfectedCells(intCurRow,1) + intInfected;
                        matClassTotalCells(intCurRow,1) = matClassTotalCells(intCurRow,1) + intInfected + intUninfected;
                    end

                    matClassInfectionIndex = matClassInfectedCells ./ matClassTotalCells;

                    [rowInd,colInd]=find(matAllPossibleCombinations(:,end)+1);
                    matTensorColumsToUse = find(~cellfun('isempty',MasterTensor.Features));

                    intDatapoints = length(rowInd);

                    %%% X
                    X = double(matAllPossibleCombinations(rowInd,:));
                    X = X - 1; 
                    X = [ones(intDatapoints,1),X]; 

                    %%% W
                    W = (matClassTotalCells(rowInd)).^(1/3);
                    W(isinf(W)) = 0;
                    W(isnan(W)) = 0;
                    W(W<2)=0;
                    W = diag(sparse(W));% - 1;

                    %%% Y
                    Y = matClassInfectionIndex(rowInd);
                    Y(isnan(Y))=0;

                    % DO MODEL
                    matModelParams = inv(X'*W*X)*X'*W*Y;% WEIGHED
                    if sum(isnan(matModelParams)) == length(matModelParams)
                        disp('WARNING: MODEL INVERSE STEP FAILED, USING PSEUDO-INVERSE')
                        matModelParams = pinv(X'*W*X)*X'*W*Y;% WEIGHED, PSEUDOINVERSE
                    end

%                     if iSwitch == 1
%                         tempDataPerOligo = [tempDataPerOligo, matModelParams];                    
%                     elseif iSwitch == 2
%                         tempDataPerGene = [tempDataPerGene, matModelParams];
%                     end     

                    

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% ACCORDING TO WIKIPEDIA: LINEAR REGRESSION %%%

                    n = length(Y);
                    p = size(X,2)-1; % without constant
                    u = ones(n,1);
                    nu = n-p; % degrees of freedom

                    Yhat = (X*matModelParams);
                    Yhat(diag(W)<=0) = [];

                    intSSR = matModelParams'*X'*Y - (1/n)*(Y'*u*u'*Y);
                    intESS = Y'*Y-matModelParams'*X'*Y;
                    intTSS = intSSR + intESS;
                    intMSE = intESS/nu;
                    intRMSE = sqrt(intMSE);

                    if iSwitch == 1
                        tempDataPerOligo = [tempDataPerOligo, matModelParams];                    
                        matSigmaPerOligo = [matSigmaPerOligo,sqrt( ( Y'*Y - matModelParams'*X'*Y ) / ( n - p - 1 ) )];
                        matRSquarePerOligo = [matRSquarePerOligo,1 - (intESS/intTSS)];
                        matAdjustedRSquaredPerOligo = [matAdjustedRSquaredPerOligo,1 - ((intESS*(n-1))/(intTSS*nu))];                        
                    elseif iSwitch == 2
                        tempDataPerGene = [tempDataPerGene, matModelParams];
                        matSigmaPerGene = [matSigmaPerGene,sqrt( ( Y'*Y - matModelParams'*X'*Y ) / ( n - p - 1 ) )];
                        matRSquarePerGene = [matRSquarePerGene,1 - (intESS/intTSS)];
                        matAdjustedRSquaredPerGene = [matAdjustedRSquaredPerGene,1 - ((intESS*(n-1))/(intTSS*nu))];                        
                    end     
                    


                else %NOT ENOUGH CELLS
                    disp('   --> not enough cells...')
                    if iSwitch == 1
                        tempDataPerOligo = [tempDataPerOligo, NaN(size(tempDataPerOligo,1),1)];                    
                        matSigmaPerOligo = [matSigmaPerOligo,NaN];
                        matRSquarePerOligo = [matRSquarePerOligo,NaN];
                        matAdjustedRSquaredPerOligo = [matAdjustedRSquaredPerOligo,NaN];
                    elseif iSwitch == 2
                        tempDataPerGene = [tempDataPerGene, NaN(size(tempDataPerGene,1),1)];
                        matSigmaPerGene = [matSigmaPerGene,NaN];
                        matRSquarePerGene = [matRSquarePerGene,NaN];
                        matAdjustedRSquaredPerGene = [matAdjustedRSquaredPerGene,NaN];
                    end     
                    
                end % total cell number check
                
                
                if iSwitch == 1
%                     disp(sprintf('\t%.4f',tempDataPerOligo(:,end)'))
                    disp(sprintf('\t%d',size(tempDataPerOligo,2)))
                elseif iSwitch == 2
%                     disp(sprintf('\t%.4f',tempDataPerGene(:,end)'))                
                    disp(sprintf('\t%d',size(tempDataPerGene,2)))
                end

            end % iOligo
            
        end % iSwitch: all oligos combined or per oligo
    end % iCols
end % iRows




TensorDataPerWell = struct();
TensorDataPerWell.Features = MasterTensor.Model.Features;

TensorDataPerWell.PerOligo.ModelParameters = tempDataPerOligo;
TensorDataPerWell.PerOligo.Sigma = matSigmaPerOligo;
TensorDataPerWell.PerOligo.RSquared = matRSquarePerOligo;
TensorDataPerWell.PerOligo.AdjustedRSquared = matAdjustedRSquaredPerOligo;
TensorDataPerWell.PerOligo.TotalCellNumber = matTCNPerOligo;

TensorDataPerWell.PerGene.ModelParameters = tempDataPerGene;
TensorDataPerWell.PerGene.Sigma = matSigmaPerGene;
TensorDataPerWell.PerGene.RSquared = matRSquarePerGene;
TensorDataPerWell.PerGene.AdjustedRSquared = matAdjustedRSquaredPerGene;
TensorDataPerWell.PerGene.TotalCellNumber = matTCNPerGene;

strOutputFile = fullfile(strRootPath,'ProbModel_TensorDataPerWell.mat');
save(strOutputFile,'TensorDataPerWell');
disp(sprintf(' STORED %s',strOutputFile))
% if boolsucces
%     disp(sprintf(' STORED %s',strOutputFile))
% else
%     disp(sprintf(' !!! FAILED TO STORE %s',strOutputFile))    
% end








%%% DO CLUSTERING AND VISUALIZE
% % % tempData(find(tempData<-2)) = NaN;
% % % tempData(find(tempData>2)) = NaN;
% % % 
% % % matAdjustedRSquared(find(matAdjustedRSquared>2)) = NaN;
% % % 
% % % figure();
% % % subplot(2,1,1)
% % % boxplot(reshape(matAdjustedRSquared,3,50))
% % % title('adjusted R Squared')
% % % 
% % % subplot(2,1,2)
% % % boxplot(reshape(real(matSigma),3,50))
% % % title('Root Mean Squared Error')
% % % 
% % % 
% % % rowlabels = cellstrLabels;
% % % columnlabels = MasterTensor.Model.Features(1:end)';
% % % data2 = tempData(1:end,:)';
% % % 
% % % % column normalize
% % % data2=data2-repmat(nanmean(data2),size(data2,1),1);
% % % data2=data2./repmat(nanstd(data2),size(data2,1),1);
% % % 
% % % 
% % % data2(isnan(data2)) = 0;
% % % data2(data2>0) = 1;
% % % data2(data2<0) = -1;
% % % 
% % % [xRows, xCols] = find(sum(data2,2) == 0)
% % % data2(xRows,:) = [];
% % % rowlabels(xRows) = [];
% % % 
% % % figure
% % % clustergram_Pauli(data2,'dimension',2,'LINKAGE','average','ROWLABELS',rowlabels,'COLUMNLABELS',columnlabels ,'PDIST','euclidean' ) %averege, correlation,@ownmetric, cosine, correlation, euclidean
% % % set(gca,'FontSize',9)

