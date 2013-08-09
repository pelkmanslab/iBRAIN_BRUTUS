%pca_test_headless_6bin Classification of genes
%This function classfies all genes of a plate specified by a path to its
%BATCH directory plate_path and a path to a valid getRAWProbModelData2
%config file. For each gene with sufficient cell number (currently 40
%cells) for a given bin we train SVM classifiers. The outputs b,Classification accuracy,
%Normal vector and Average_margin store all SVM related information.
%Furthermore, we store some general information such as Cell number per
%bin,Gene names,Gene ids and feature names which are not related to SVM
%classification
function pca_test_headless_all(plate_path,config_file,input_path,write_path)
%    plate_path=npc('\\pelkmans.uzh.ch\camelot-share-2\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\BATCH');
%    config_file=npc('\\pelkmans.uzh.ch\camelot-share-2\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\RFEcp395_MacroVes.txt');
%    write_path=npc('\\pelkmans.uzh.ch\camelot-share-2\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\BATCH\Measurements_Classification6bin_RFEcp395_MacroVes_v2.mat');
global treated_population;
global control_population;
% input_path=strcat('C:\Users\heery\Desktop\current_code\pca_stick\','general_inputfile.txt');
% plate_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH';
% config_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/RFEcp395_TfVes.txt';
[fid, message] = fopen(npc(input_path));
if fid == (-1)
    error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', filename, message);
end

try
    % read file
    out = fread(fid,'*char')';
catch exception
   
    fclose(fid);
    throw(exception);
end

% close file
fclose(fid);
eval(out);
basic_files=dir(npc(strcat(plate_path,'/*BASICDATA*')));
if(size(basic_files,1)>1)
    sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
end;
basic_path=basic_files.name;
%  pc_ref=pca_test_headless_6bin(plate_path,config_file,basic_path,20,40);
root_path=plate_path;
fullfile_path=basic_path;
NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
num_cells=30;
if(isfield(multivariate_config,'num_cells'))
    num_cells=multivariate_config.num_cells;
end;
% multivariate_config.write_path=npc(strcat(plate_path,'/','Measurements_Classification6bin_RFEcp395_',multivariate_config.vesicle.vesicle_names,'.mat'));
% if(~isfield(multivariate_config.classification,'write_path'))
%     error(sprintf('Reclassification.write_path not defined. Please supply a reclassification output path in file %s',settings_file))
% end;
num_iterations=100;
if(isfield(multivariate_config.classification,'num_iterations'))
    num_iterations=multivariate_config.classification.num_iterations;
end;
num_normalvectors=100;
if(isfield(multivariate_config.classification,'num_normalvectors'))
    num_normalvectors=multivariate_config.classification.num_normalvectors;
end;
% write_path=multivariate_config.classification.write_path;
num_cells=40;
num_bins=6;%Number of bins the population should be distributed into
strRootPath = root_path;
[temp_features,tempfeature_names,meta] =getRawProbModelData2(npc(strRootPath),npc(config_file));
%Check for cedlls having NaN vesicle values and cat them to zero
temp_features(find(temp_features~=temp_features))=0;
orig_features=temp_features(:,NUM_POPULATION_FEATURES:23);
features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
load(fullfile(npc(strRootPath),npc(fullfile_path)))
BASICDATA1=BASICDATA;
remove_group={'Control',''};
if(isfield(multivariate_config,'remove_group'))
    control_group=multivariate_config.remove_group;
end;
binning_method=18;
if(isfield(multivariate_config,'binning_method'))
    binning_method=multivariate_config.binning_method;
end;
[gene_names,gi]=setdiff(BASICDATA1.GeneData,remove_group);
gene_id=BASICDATA1.GeneID(gi);
[sorted_coefficients,bin_starts,bin_indices]=calculationPopulationScoreSize(features2,18,1);
%[sorted_coefficients,bin_starts]=calculationPopulationScore(features2,2,pop_coef);
features = nanzscore(orig_features);
median_c1=NaN(24,20);
median_r1=NaN(16,20);
%rng('shuffle');

    for(col=1:max(BASICDATA1.WellCol))
        col_cells=find(BASICDATA1.WellCol==col);
        matNonTargetingImageIX = BASICDATA1.ImageIndices(col_cells);
        matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
        col_cells= find(ismember(meta(:,6),matNonTargetingImageIX));
        %Exclude cells not in current bin to do a plaet effect
        %correction accounting for population context
%         col_cells=intersect(col_cells,sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
        median_c1(col,:)=nanmean(features(col_cells,:));
        features(col_cells,:)=bsxfun(@minus,features(col_cells,:),median_c1(col,:));
        
    end;
    for(row=1:max(BASICDATA1.WellRow))
        row_cells=find((BASICDATA1.WellRow==row));
        matNonTargetingImageIX = BASICDATA1.ImageIndices(row_cells);
        matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
        row_cells= find(ismember(meta(:,6),matNonTargetingImageIX));
%         row_cells=intersect(row_cells,sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
        median_r1(row,:)=nanmean(features(row_cells,:));
        features(row_cells,:)=bsxfun(@minus,features(row_cells,:),median_r1(row,:));
        
    end;
    

count=0;

%
%      for(f=1:20)
%      all_plate=NaN(16,24);
%            for(gene=1:length(gene_names))
%             %Get plate index of gene
%
%                 %Get index of gene in BASICDATA
%                 basic_index=find(strcmp(BASICDATA1.GeneData,gene_names{gene}));
%                  matGeneImageIX = BASICDATA1.ImageIndices(strcmpi(BASICDATA1.GeneData,gene_names{gene}));
%                             matGeneImageIX = cat(1,matGeneImageIX{:});
%                             matGeneCellIX = ismember(meta(:,6),matGeneImageIX);
%                 all_plate(BASICDATA1.WellRow(basic_index),BASICDATA1.WellCol(basic_index))=mean(features(matGeneCellIX,f));%length(find(abs(features(matGeneCellIX,3))<0.1))/length(features(matGeneCellIX,3));%mean(features(matGeneCellIX,3));

%            end;
%            figure;
%           % sprintf('Feature %d, Row Correlation:%d,Column correlation:%d',f,corr(repmat([1:16]',24,1),lin(all_plate)),corr(repmat([1:24]',16,1),lin(all_plate')))
%            imagesc(all_plate);
%      end;

output=[];output1=[];output2=[];normal_vector=[];
BASICDATA1.GeneID(cellfun(@(x) isempty(x),BASICDATA1.GeneID))={NaN};
BASICDATA1.GeneID(find(strcmp(BASICDATA1.GeneID,'Blank')))={NaN};
GeneID=cell2mat(BASICDATA1.GeneID);
%Allocate mean values of features per bin
mean_wells=NaN(20,6);
%Create control population
for(gene=1:1)
   
    count=count+1;
    %Construct feature matrix just for the current gene
    if(~strcmp(gene_names{gene},'Non-targeting'))
    matGeneImageIX = BASICDATA1.ImageIndices(GeneID==gene_id{gene});
    else
    matGeneImageIX = BASICDATA1.ImageIndices(strcmp(BASICDATA1.GeneData,'Non-targeting'));
    end;
    matGeneImageIX = cat(1,matGeneImageIX{:});
    matGeneCellIX = ismember(meta(:,6),matGeneImageIX);
    index_v=1:size(sorted_coefficients,1);
    log_treated=ismember(sorted_coefficients(:),index_v(matGeneCellIX));
    treated_population=features(sorted_coefficients(log_treated(:)),:);
    %Loop over all bins
    for(bin=1:num_bins)
    
        %If either
        temp_vec=bin_starts((bin-1)*3+1):bin_starts(bin*3+1);
        %Check whether the bin is full
        if(length(temp_vec)>1)
            treated_population=features(sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                                  control_indices=bin_indices((((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                                 perturbed_indices=bin_indices((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)));
                               control_population=features(:,:);
            %Compute mean value of all features
            mean_wells(bin,1:20)=nanmean(treated_population);
            cells_bin(gene,bin)=size(treated_population,1);
            % Stop if either of the two poulation has less than40 cells
            if((size(treated_population,1)<num_cells))
                % sprintf('Cells with perturbed gene %s are not contained in bin %d',gene_names{gene},bin)
                continue;
            end;
            
           
           
           perturbed_indices=perturbed_indices-(bin-1)*3;
           sample_size=size(treated_population,1);
           control_indices=bin_starts((bin-1)*3+1:3*bin+1)-bin_starts((bin-1)*3+1)+1;
            permu=randi([1 size(treated_population,1)],size(treated_population,1),1);
%Randomly shuffle the cells of the perturbed bin and their cell size in
%indices to allow for splitting the randomly into two halves
treated_population=treated_population(permu,:);
perturbed_indices=perturbed_indices(permu);
size_sample=hist(perturbed_indices,[1,2,3]);
feature_size=1:size(treated_population,2);
sample_size1=200;%floor(min(size(treated_population,1)/2,100));

C=0.02/sample_size1;

sample_size=floor((sample_size1/size(treated_population,1))*size_sample);
population=([treated_population;control_population]);
                             groups=ones(size(population,1),1);
                                groups(1:size(treated_population,1))=1;
                                groups(size(treated_population,1)+1:size(population,1))=-1;
                            size(treated_population,2);
                               normal_vector1=NaN(num_iterations,length(feature_size));
                                b=NaN(num_iterations,1);
                                classification_accuracy=NaN(num_iterations,1);
                               average_margin1=cell(100,1);
                           
                                  test_cases1=arrayfun(@(x) [randi([ceil(size(treated_population,1)/2) size(treated_population,1)],sample_size1,1)],1:num_iterations,'UniformOutput',false);
test_cases2=arrayfun(@(x) [randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)],1:num_iterations,'UniformOutput',false);

% res=NaN(20,1);
% for(cc1=1:length(c1))
C=1;
                          command_string=strcat('-s 3 -q -B 1   -c', sprintf(' %d',1),' -w1 1 -w-1 1' );
          
                                for(cross=1:num_normalvectors) %Select 10 times random training and tesing samples, the solution belonging to the median classification accuracy is returned
        
                                    train = [randi2([1 ceil(size(treated_population,1)/2)],sample_size1,1);randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)];
          
model = train4(groups(train),sparse(population(train,feature_size)),command_string);
% model = train4(groups(train),sparse(population(train,[4,7])),command_string);
% figure;
% hold on;
%  svmtrain(population(train,[4,7]),groups(train),'Showplot',true,'BoxConstraint',1,'Autoscale',false)
normal_vector1(cross,:)=model.w(1:length(feature_size));
                                    if(sum(normal_vector1(cross,:)==0)==20)
                                        normal_vector1(cross,:)=NaN(1,20);
                                        model.w(length(feature_size)+1)=NaN;
                                        average_margin1{cross}=NaN(1,400);
                                        b(cross)=NaN;
                                        continue;
                                    end;
                                    b(cross)=model.w(length(feature_size)+1);
                                    %population(train(1:202),7)=50;   
%  model.w(7)=0;
test_cases3=arrayfun(@(x) population( test_cases1{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
test_cases4=arrayfun(@(x) population( test_cases2{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
%
   test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size1),1:num_iterations,'UniformOutput',true);
  
   %Take the mean of the third of tzhe perturbation population hacving
        %maximal distance from the control
  C=1;
        c_criteria=C*arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true)+C*arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:num_iterations,'UniformOutput',true)  ;     
% c_criteria1=C*arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true);
% c_criteria2=C*arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:100,'UniformOutput',true)  ; 
  %    c_criteria1(cross,:)=norm(normal_vector1(cross,:),1)+(arrayfun(@(x) sum(max(0,1-(test_cases3{x})).^2),1:100,'UniformOutput',true)+arrayfun(@(x) sum(max(0,1+test_cases4{x}).^2),1:num_iterations,'UniformOutput',true))*C   ;     
average_margin1{cross}=[test_class,c_criteria,cellfun(@(x) mean(x),test_cases3),cellfun(@(x) mean(x),test_cases4)];
        end;
    
%         ccr=c_criteria1;
%         imagesc(population( [test_cases1{1};test_cases2{1}],feature_size).*repmat(model.w(1:length(feature_size)),405,1))
        normal_vector{count,bin}=normal_vector1;
%         res(cc1)=nanmean(normal_vector1(:,7));
%         n_rep=repmat(normal_vector1(100,:),398,1);
%         imagesc(n_rep.*population(train,feature_size));
%         scatter(population(train(1:200),4),population(train(1:200),7),'b')
%         hold on;
%         scatter(population(train(201:398),4),population(train(201:398),7),'r')
% end;
% plot(res);
        bias{count,bin}=b;
        average_margin{count,bin}=average_margin1;
    end;
end;
end


    
Bias=bias;
Gene_list=gene_names;
Normal_vector_matrix_bin_after_bin=normal_vector;
Cells_per_bin=cells_bin;
Gene_id=gene_id;
Average_margin=average_margin;
Feature_names=tempfeature_names;

save(npc(write_path), 'Gene_list','Gene_id','Bias','Normal_vector_matrix_bin_after_bin','Cells_per_bin','Average_margin','Feature_names','mean_wells','-v7.3');

end
