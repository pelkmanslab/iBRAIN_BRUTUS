clear all
close all

matData = [];
cellstrDataColumnLabels = {};

for iCell = {'_MZ','_KY','_CNX','_TDS'}
    strCellLine = iCell{1};
    load(['\\nas-biol-imsb-1\share-2-$\Data\Code\Matlab\Berend\results\080220_50K_PopProps',strCellLine,'.mat'])
    matData = [matData, cell2mat(matOutput(2:end,2:end))];
    cellstrDataColumnLabels = [cellstrDataColumnLabels,matOutput(1,2:end)];
end

% MAKE COLUMN LABELS NICE
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Nuclei_GridNucleiCountCorrected_1','LCD');
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Nuclei_AreaShape_1','SIZ');
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Nuclei_GridNucleiEdges_1','EDG');
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Image_CorrectedTotalCellNumberPerWell_1','TOT');
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Nuclei_CellTypeClassificationPerColumn_2','MIT');
cellstrDataColumnLabels = strrep(cellstrDataColumnLabels,'Nuclei_CellTypeClassificationPerColumn_3','APO');

% CLUSTERGRAM
map=[ [sqrt(linspace(1,0,32)'),zeros(32,1),zeros(32,1)] ; [zeros(32,1),sqrt(linspace(0,1,32)'),zeros(32,1)]];
colormap(map)                                                               %
clustergram(matData,'dimension',2,'LINKAGE','average','PDIST','cosine','ROWLABELS', dataRowLabels,'COLUMNLABELS',cellstrDataColumnLabels) % euclidean correlation |||averege, correlation,@ownmetric
colormap(map)
drawnow

% PHYTREE CLUSTERING
D=pdist(matData','cosine'); % correlation is the best
t=linkage(D,'average');
Tree=phytree(t,cellstrDataColumnLabels);
phytreetool(Tree);