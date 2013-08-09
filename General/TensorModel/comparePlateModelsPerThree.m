% function comparePlateModels(strRootPath)


    strRootPaths = { ...
        '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';...
        '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\Ad5_MZ\';...
        '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\MHV_KY\';...
        }

h = figure();
plotcounter = 0;

cellstrModelFeatures2 = {'CONST','LCD','SIZE','EDGE','TCN','MITOT','APOPT'};

% if nargin==0
for iAssay = 1:3
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\RV_KY\';
    strRootPath = strRootPaths{iAssay};
% end


%%% LOOK FOR ALL FOLDERS BELOW TARGETFOLDER THAT CONTAIN TARGET FILE
disp('ProbMod: checking target folders')
cellstrTargetFolderList = SearchTargetFolders(strRootPath,'ProbModel_Tensor.mat');

intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('ProbMod: found %d target folders',intNumOfFolders))

%%% IF NO TARGET FOLDERS ARE FOUND, QUIT
if intNumOfFolders==0
    return
end

disp('ProbMod: calculating per plate model parameters')
matPlateModelParams = [];
cellstrModelFeaturs = {};
modelcounter = 0;
for i = 1:intNumOfFolders
    clear Tensor    
    try
        load(fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat'));
    catch
        disp(sprintf('  failed to add tensor %s',fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat')))
        break
    end
    
    [rowInd,colInd]=find(Tensor.Indices(:,end)+1);
    matTensorColumsToUse = find(~cellfun('isempty',Tensor.Features));

    intDatapoints = length(rowInd);
    X = double(Tensor.Indices(rowInd,:));
    X = X - 1; 
    X = [ones(intDatapoints,1),X]; 
    W = (Tensor.TotalCells(rowInd)).^(1/3);
    W(isinf(W)) = 0;
    W(isnan(W)) = 0;
    W = diag(sparse(W));% - 1;
    Y = Tensor.InfectionIndex(rowInd);
    Y(isnan(Y))=0;
    
    matModelParams = inv(X'*W*X)*X'*W*Y;% WEIGHED
    if sum(isnan(matModelParams)) == length(matModelParams)
        disp('WARNING: MODEL INVERSE STEP FAILED, USING PSEUDO-INVERSE')
        matModelParams = pinv(X'*W*X)*X'*W*Y;% WEIGHED, PSEUDOINVERSE
    end

    if sum(abs(matModelParams) > 0)
        modelcounter = modelcounter + 1;
        if modelcounter == 1
            matPlateModelParams = matModelParams';
            cellstrModelFeatures = cellstrModelFeatures2;%[{'Constant'},Tensor.Features'(2:end)];
        else
            matPlateModelParams(modelcounter,:) = matModelParams';
            cellstrModelFeatures(modelcounter,:) = cellstrModelFeatures2;%[{'Constant'},Tensor.Features(2:end)];        
        end
    end    
    
end

plotcounter = plotcounter + 1;
subplot(3,2,plotcounter)
bar(matPlateModelParams')
title(strrep(getlastdir(strRootPath),'_','\_'))
ylabel('model parameter values')
axis tight
set(gca,'XTickLabel',cellstrModelFeatures2)

plotcounter = plotcounter + 1;
subplot(3,2,plotcounter)
boxplot(matPlateModelParams(:),cellstrModelFeatures(:))
axis tight
hline(0,'-k')
title(strrep(getlastdir(strRootPath),'_','\_'))
drawnow

end



    figure(h)

    % prepare for pdf printing
    scrsz = [1,1,1920,1200];
    set(h, 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
    orient landscape
    shading interp
    set(h,'PaperPositionMode','auto', 'PaperOrientation','landscape')
    set(h, 'PaperUnits', 'normalized'); 
    printposition = [0 .2 1 .8];
    set(h,'PaperPosition', printposition)
    set(h, 'PaperType', 'a4');            
    orient landscape

    drawnow

    filecounter = 1;
    strPrintName = fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
    filepresentbool = fileattrib(fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']));
    while filepresentbool
        filecounter = filecounter + 1;    
        strPrintName = fullfile(strRootPath,['ProbModel_CurveReproduction_',getlastdir(strRootPath),'_',num2str(filecounter),'.pdf']);
        filepresentbool = fileattrib(strPrintName);
    end
    disp(sprintf('stored %s',strPrintName))
    print(h,'-dpdf',strPrintName);
    close(h)