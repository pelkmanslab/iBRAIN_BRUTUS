% should get you 'matCompleteDataPerWell', 'matCompleteDataPerCell', 'cellstrNucleiFieldnames'
strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\RV_KY_2';
load(fullfile(strRootPath,'matCompleteData.mat'))

load(fullfile(strRootPath,'ProbModel_Tensor.mat'))

cellstrNucleiFieldnames

matTempBinnedData = zeros(size(matCompleteDataPerCell),'uint8');

matTotalDataEdges = {};
for i = 1:size(matCompleteDataPerWell,2)
    if i==1 || Tensor.BinSizes(i+1) == 2
        matDataEdges = linspace(nanmin(matCompleteDataPerCell(:,i)),nanmax(matCompleteDataPerCell(:,i)),Tensor.BinSizes(i+1))
    else
        matDataEdges = linspace(nanmin(matCompleteDataPerCell(:,i)),nanmax(matCompleteDataPerCell(:,i)),32)
    end
    matTotalDataEdges{i} = matDataEdges;
    [x,n] = histc(matCompleteDataPerCell(:,i),matDataEdges);
    if max(n)<intmax('uint8')
        matTempBinnedData(:,i) = uint8(n);
    else
        error('oops')
    end
end
return
figure()

%%% PLOT THE CELL SIZE DISTRIBUTIONS OF LOW-DENSE AND HIGH-DENSE CELLS
subplot(3,3,1)
[x1,y1]=hist(matCompleteDataPerCell(matTempBinnedData(:,1)==1,2),40);
[x2,y2]=hist(matCompleteDataPerCell(matTempBinnedData(:,1)==9,2),40);
plot(y1,x1/max(x1),...
    y2,x2/max(x2),'linewidth',2)
legend({'Low dense','High dense'})
xlabel('Cell size','fontsize',14)
ylabel('Normalized cell count','fontsize',14)
set(gca,'fontsize',14)
drawnow

matTotalDataEdges{1}(1)
matTotalDataEdges{1}(9)

subplot(3,3,2)
matUpperRange = Tensor.BinSizes(5);
[n2]=histc(Tensor.TrainingData(Tensor.TrainingData(:,5)==2,2),1:matUpperRange);
[n3]=histc(Tensor.TrainingData(Tensor.TrainingData(:,5)==15,2),1:matUpperRange);
x = [1:matUpperRange] .* Tensor.StepSizes(1);
y = [n2';n3'] ./ repmat(max([n2';n3'],[],2),1,matUpperRange);
plot(x,y,'linewidth',2)
legend({'Low TCN','High TCN'},'fontsize',14)
xlabel('Local cell density','fontsize',14)
ylabel('Normalized cell count','fontsize',14)
set(gca,'fontsize',14)
drawnow

matTotalDataEdges{4}(2:3)
matTotalDataEdges{4}(15:16)

subplot(3,3,3)
matUpperRange = Tensor.BinSizes(4);
n2=nanmean(Tensor.TrainingData(Tensor.TrainingData(:,5)==2,4))-1;
n3=nanmean(Tensor.TrainingData(Tensor.TrainingData(:,5)==15,4))-1;
bar([n2,n3])
ylim([0,1])
set(gca,'xticklabel',{'Low TCN','High TCN'})
ylabel('Fraction edge cells','fontsize',14)
set(gca,'fontsize',14)
drawnow