% function displayLinearFits_intensities2(strRootPath)

% if nargin == 0
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\50K_Tfn\20071130131036_M1_071129_A431_50k_Tfn_P3_2\BATCH\';
    strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\Tfn_MZ\philip_071006_Tfn_MZ_AWaa\';
%     strRootPath = '\\Nas-biol-imsb-1\share-2-$\Data\Users\Berend\Philip\S6K\221007_Philip_Tfn_S6Kp_DAPI_CP0001-1aa\BATCH\';     
% end

load(fullfile(strRootPath,'ProbModel_Tensor.mat'));

figure();

subplot(2,3,1)
boxplot(single(Tensor.TrainingData(:,1)), 'symbol','.b')
title(sprintf('%s (%g)',strrep(Tensor.Features{1},'_','\_'), std(single(Tensor.TrainingData(:,1)))));
drawnow

x = size(Tensor.TrainingData,1);
for i = 1:10
    y=randperm(x);
    y=y(1:10000);
    std(single(Tensor.TrainingData(y,1)))
end


matDimensionMedians = nanmedian(MasterTensor.TrainingData,1);
intNumDims = length(matDimensionMedians);
intNumIndices = size(MasterTensor.Model.X,1);
matAllDims = 1:intNumDims;
for iDim = 2:intNumDims % skipping first dimension, constant
    itnCurrentDimBins = MasterTensor.BinSizes(iDim);
    
    matCurrentCellIndices = [];
    matCurrentMedianIndices = [];
    for iBin = 1:itnCurrentDimBins
        
        disp(sprintf('processing bin %d of dim %d',iBin,iDim))
        
        matCurrentClass = zeros(size(matAllDims));
        matCurrentClass(matAllDims~=iDim) = matDimensionMedians(matAllDims(matAllDims~=iDim));
        matCurrentClass(iDim) = iBin;
%         matCurrentClass = matCurrentClass - 1;
        matCurrentClass(1) = 1;%constant term

        %%%
        matCurrentCellIndices = [matCurrentCellIndices; find(ismember(MasterTensor.TrainingData(:,2:end),matCurrentClass(2:end), 'rows'))];

        
        if iBin == double(matDimensionMedians(iDim))
            disp(sprintf('   --> bin %d equales %d, median of dim %d',iBin,matDimensionMedians(iDim),iDim))            
            matCurrentClass(2:end)
            matCurrentMedianIndices = find(ismember(MasterTensor.TrainingData(:,2:end),matCurrentClass(2:end), 'rows'));
        end
        
    end
    
    subplot(2,3,iDim)
    boxplot(single(MasterTensor.TrainingData(matCurrentCellIndices,1)),single(MasterTensor.TrainingData(matCurrentCellIndices,iDim)), 'symbol','.b')
%     title(strrep(Tensor.Features{iDim},'_','\_'));
    title(sprintf('%s (%g)',strrep(Tensor.Features{1},'_','\_'), std(single(Tensor.TrainingData(matCurrentMedianIndices,1)))));
    drawnow
end
        
return






for iDim = 2:length(Tensor.Features)
    subplot(2,3,iDim)
    hold on
    
    y2=y;
    [x,x2] = histc(single(Tensor.TrainingData(:,iDim)),1:Tensor.BinSizes(:,iDim)+1);
    matIndicesToExclude = find(x<intBarThreshold);
    for i = matIndicesToExclude';
        y2(x2==i)=[];
        x2(x2==i)=[];
    end
    
    bar(double(x) / max(double(x)),'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8])
    boxplot(y2,x2,'positions',find(x>intBarThreshold), 'symbol','.b')
    title(strrep(Tensor.Features{iDim},'_','\_'));
    hold off
    drawnow
end

subplot(2,3,6)
matUpperRange = 129;
[n]=histc(Tensor.TrainingData(:,1),1:matUpperRange);
[n2]=histc(Tensor.TrainingData(Tensor.TrainingData(:,2)==1,1),1:matUpperRange);
[n3]=histc(Tensor.TrainingData(Tensor.TrainingData(:,2)==7,1),1:matUpperRange);
x = [1:matUpperRange] .* Tensor.StepSizes(1);
% y = [n';n2';n3'] ./ repmat(max([n';n2';n3'],[],2),1,matUpperRange);
y = [;n2';n3'] ./ repmat(max([n2';n3'],[],2),1,matUpperRange);
plot(x(:,1:128),y(:,1:128))
drawnow







%%%
%%% SAVING PDF
%%%

scrsz = [1,1,1920,1200];
set(gcf, 'Position', [1 scrsz(4) scrsz(3) scrsz(4)]);     
orient landscape
shading interp
set(gcf,'PaperPositionMode','auto', 'PaperOrientation','landscape')
set(gcf, 'PaperUnits', 'normalized'); 
printposition = [0 .2 1 .8];
set(gcf,'PaperPosition', printposition)
set(gcf, 'PaperType', 'a4');            
orient landscape

drawnow

return

filecounter = 0;
filepresentbool = 1;
while filepresentbool
    filecounter = filecounter + 1;    
    strPrintName = fullfile(strRootPath,['ProbModel_ReproduceTrainingData_intensities_',getlastdir(strRootPath),'_',num2str(filecounter)]);
    filepresentbool = fileattrib([strPrintName,'.*']);
end
disp(sprintf('stored %s',strPrintName))

%%% UNIX CLUSTER HACK, TRY PRINTING DIFFERENT PRINT FORMATS UNTIL ONE
%%% SUCCEEDS, IN ORDER OF PREFERENCE
    
cellstrPrintFormats = {...
    '-dpdf',...
    '-depsc2',...      
    '-depsc',...      
    '-deps2',...        
    '-deps',...        
    '-dill',...
    '-dpng',...   
    '-tiff',...
    '-djpeg'};

boolPrintSucces = 0;
for i = 1:length(cellstrPrintFormats)
    if boolPrintSucces == 1
        continue
    end        
    try
        print(gcf,cellstrPrintFormats{i},strPrintName);    
        disp(sprintf('PRINTED %s FILE',cellstrPrintFormats{i}))        
        boolPrintSucces = 1;
    catch
        disp(sprintf('FAILED TO PRINT %s FILE',cellstrPrintFormats{i}))
        boolPrintSucces = 0;            
    end
end
close(gcf) 



