% function plotTrainingDataAndMesh(strRootPath,strFigureTitle)

% if nargin == 0
    strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\EV1_MZ\';
    strFigureTitle = [strrep(getlastdir(strRootPath),'_','\_'),' '];
% end

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'Measurements_Image_FileNames.mat');
intNumOfFolders = length(cellstrTargetFolderList);

PlateTensor = cell(intNumOfFolders,1);

MasterTensor = load(fullfile(strRootPath,'ProbModel_Tensor.mat'));
MasterTensor = MasterTensor.Tensor;

matRows = cellstr(regexp(char(65:80),'\w','match'));
matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');


matRawIIs = {};
matRawTotalCells = {};
matRawInfectedCells = {};
matModelExpectedInfectedCells = {};
matTensorExpectedInfectedCells = {};
strDimFeature = {};

cellstrDataLabels = cell(intNumOfFolders,16);
    
for i = 1:intNumOfFolders
    
    disp(sprintf('processing %s',getlastdir(cellstrTargetFolderList{i})))   

    try
        PlateTensor{i} = load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('  failed to add tensor %s',fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
        break
    end
    PlateTensor{i} = PlateTensor{i}.Tensor;

    for iDim = 2:length(PlateTensor{i}.Features)
        strDimFeature{iDim} = strrep(PlateTensor{i}.Features{iDim},'_','\_');

        for iBin = 1:16


            if not(isempty(PlateTensor{i}.TrainingData))

                matCurBinCellIndices = find(PlateTensor{i}.TrainingData(:,iDim) == iBin);

                %%% ORIGINAL INFECTION INDEX                
                intInfectedCells = sum(PlateTensor{i}.TrainingData(matCurBinCellIndices,1)-1);
                intTotalCells = length(matCurBinCellIndices);

                % SET TOTALCELLS<=100 TOT NaN
                if intTotalCells==0
                    intTotalCells = NaN;
                    intInfectedCells = NaN; 
                end                

                matRawInfectedCells{iDim}(i,iBin) = intInfectedCells;
                matRawTotalCells{iDim}(i,iBin) = intTotalCells;
                matTempII=intInfectedCells./intTotalCells;
                matRawIIs{iDim}(i,iBin) = matTempII;


                %%% MODEL EXPECTED INFECTION INDEX            
                X = PlateTensor{i}.TrainingData(matCurBinCellIndices,2:end);
                X = X - 1;

                X = [ones(size(X,1),1),X];
                Y = repmat(MasterTensor.Model.Params',size(X,1),1) .* double(X);
                matModelExpectedInfectedCells{iDim}(i,iBin) = round(sum(Y(:)));

            else % if TrainingData is empty
                disp(sprintf('warning: bin %d of %s is empty',iBin,strDimFeature{iDim}))
                matRawInfectedCells{iDim}(i,iBin) = NaN;
                matRawTotalCells{iDim}(i,iBin) = NaN;
                matRawIIs{iDim}(i,iBin) = NaN;
                matModelExpectedInfectedCells{iDim}(i,iBin) = NaN;

            end% if not TrainingData is empty        
        end   
    end
end


i=1;
Xmesh = double(repmat(([1:PlateTensor{i}.BinSizes(2)]),PlateTensor{i}.BinSizes(3),1));
Ymesh = double(repmat(([1:PlateTensor{i}.BinSizes(3)])',1,PlateTensor{i}.BinSizes(2)));
Zmesh_upper = (MasterTensor.Model.Params(2) .* Xmesh) + (MasterTensor.Model.Params(3) .* Ymesh) + MasterTensor.Model.Params(1);
Zmesh_lower = (MasterTensor.Model.Params(2) .* Xmesh) + (MasterTensor.Model.Params(3) .* Ymesh) + double(sum([PlateTensor{i}.BinSizes(4:end)-1].*MasterTensor.Model.Params(4:end)') + MasterTensor.Model.Params(1));

Weights = diag(MasterTensor.Model.W);
[plotPoints,foo] = find(Weights>2);

Xfull = MasterTensor.Model.X(plotPoints,:);
Xscatter = MasterTensor.Model.X(plotPoints,2);
Yscatter = MasterTensor.Model.X(plotPoints,3);
Zscatter = MasterTensor.Model.Y(plotPoints,1);
Cscatter = Zscatter;
Wscatter = (full(Weights(plotPoints,1))-1).*10;

Zmesh_heaviest = NaN(16,16);
Zmesh_median = NaN(16,16);
Zmesh_mean = NaN(16,16);
for xi=1:16
    for xii=1:16
        pointindices=find(Xscatter==xi & Yscatter==xii);
        if not(isempty(pointindices))
            %%% find heaviest point of all available bins matching X1=xi &
            %%% X2 = xii
            [heaviestpoint,foo]=find( Wscatter(pointindices) == max(Wscatter(pointindices)) );
            
            Zmesh_heaviest(xii,xi)= sum(Xfull(pointindices(heaviestpoint(1,1)),:) .* MasterTensor.Model.Params');
            
            Zmesh_median(xii,xi)= nanmedian(sum(Xfull(pointindices,:) .* repmat(MasterTensor.Model.Params',length(pointindices),1),2));
            Zmesh_mean(xii,xi)= nanmean(sum(Xfull(pointindices,:) .* repmat(MasterTensor.Model.Params',length(pointindices),1),2));            
        end
    end
end

Zmesh_upper(Zmesh_upper<0)= 0;
Zmesh_lower(Zmesh_lower<0)= 0;
Zmesh_heaviest(Zmesh_heaviest<0)= 0;
Zmesh_median(Zmesh_median<0)= 0;
Zmesh_mean(Zmesh_mean<0)= 0;


% Xscatter = MasterTensor.Model.X(plotPoints,2) + (rand(length(plotPoints),1)-.5);
% Yscatter = MasterTensor.Model.X(plotPoints,3) + (rand(length(plotPoints),1)-.5);

Xscatter = MasterTensor.Model.X(plotPoints,2);
Yscatter = MasterTensor.Model.X(plotPoints,3);

figure()
clf

hold on
% mesh(Xmesh,Ymesh,Zmesh1);
% mesh(Xmesh,Ymesh,Zmesh_mean,'LineWidth',0,'FaceColor','interp');

% surf(Xmesh,Ymesh,Zmesh_median,'LineWidth',0,'FaceColor','interp')

mesh(Xmesh,Ymesh,Zmesh_median,'LineWidth',1,'FaceColor','interp');
% mesh(Xmesh,Ymesh,Zmesh_heaviest,'LineWidth',0,'FaceColor','interp');
% mesh(Xmesh,Ymesh,Zmesh_upper,'LineWidth',0,'FaceColor','interp');
% mesh(Xmesh,Ymesh,Zmesh_lower,'LineWidth',0,'FaceColor','interp');

% scatter3(Xscatter,Yscatter,Zscatter,ones(size(Cscatter))+5,Cscatter,'filled') 

% surf(X,Y,Z) 

% axis([1 PlateTensor{i}.BinSizes(2) 1 PlateTensor{i}.BinSizes(3) - 1])
view(30,30)
hold off
drawnow
