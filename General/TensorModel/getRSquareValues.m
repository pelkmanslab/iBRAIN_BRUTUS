strRootPath = '\\nas-biol-imsb-1\share-2-$\Data\Users\Berend\BATCH_RESULTS\Data\Users\50K_final\';

cellstrTargetFolderList = SearchTargetFolders(strRootPath,'ProbModel_Tensor.mat');

intNumOfFolders = length(cellstrTargetFolderList);
disp(sprintf('ProbMod: found %d target folders',intNumOfFolders))

%%% IF NO TARGET FOLDERS ARE FOUND, QUIT
if intNumOfFolders==0
    return
end

%%% ADD MODEL SPECIFIC MEASUREMENTS, LIKE A OUT-OF-FOCUS IMAGE CORRECTED
%%% TOTAL CELL NUMBER AND TOTAL INFECTED NUMBER PER WELL. ALL FUNCTIONS
%%% SHOULD SKIP IF THE MEASUREMENT IS ALREADY PRESENT.
disp('reading RSquare values')
RSquares = [];
for i = 1:intNumOfFolders
    strFileName = fullfile(cellstrTargetFolderList{i},'ProbModel_Tensor.mat');
    load(strFileName)
    disp(sprintf('loading %s',strFileName))
    RSquares = [RSquares, str2double(Tensor.Model.Description.PearsonsR2)];
end