%PCA_TEST_HEADLESS_RECLASSIFY Evaluate classifciation performance of all SVMS for a given SVM.

%[]=pca_test_headless_reclassify(plate_path,config1_path,input_path,write_p
%ath) computes 
%

function []=pca_test_headless_reclassify(plate_path,config_file,input_path,write_path)
NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features


NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
num_cells=30;
% if(isfield(multivariate_config,'num_cells'))
%     num_cells=multivariate_config.num_cells;
% end;
% multivariate_config.write_path=npc(strcat(plate_path,'/','Measurements_Classification6bin_RFEcp395_',multivariate_config.vesicle.vesicle_names,'.mat'));
% if(~isfield(multivariate_config.classification,'write_path'))
%     error(sprintf('Reclassification.write_path not defined. Please supply a reclassification output path in file %s',settings_file))
% end;
num_iterations=50;
% if(isfield(multivariate_config.reclassification,'num_iterations'))
%     num_iterations=multivariate_config.reclassification.num_iterations;
% end;
num_normalvectors=100;
% if(isfield(multivariate_config.classification,'num_normalvectors'))
%     num_normalvectors=multivariate_config.classification.num_normalvectors;
% end;
% write_path=multivariate_config.classification.write_path;
num_cells=40;
num_bins=6;%Number of bins the population should be distributed into


%    plate_path=npc('U:\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\BATCH');
%    config1_path=npc('U:\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\RFEcp395_MacroVes.txt');
%    write_path=npc('U:\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\BATCH\Measurements_ReClassification6bin_RFEcp395_MacroVes_v2.mat');

% input_path=npc('Y:\Prisca\endocytome\100215_A431_w3LDL\100215_A431_Actin_LDL_CP393-1bi\BATCH\Measurements_Classification6bin_RFEcp395_LDLVes_v2.mat');
basic_files=dir(strcat(plate_path,'/*BASICDATA*'));
if(size(basic_files,1)>1)
    sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
end;
fullfile_path=basic_files.name;
num_bins=6;%Number of bins the population shoould be distributed into
strRootPath = plate_path;
%%Feature loading: 3 Population features and 20 intensity and
%%texture features
[temp_features,tempfeature_names,meta] =getRawProbModelData2(strRootPath,config_file);
%Check for cedlls having NaN vesicle values and cat them to zero
temp_features(find(temp_features~=temp_features))=0;
orig_features=temp_features(:,NUM_POPULATION_FEATURES:23);
features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
load(fullfile(strRootPath,fullfile_path))
BASICDATA1=BASICDATA;
indices=strfind(strRootPath,'/');
indices2=strfind(input_path,'/');
load(strcat(strRootPath(1:indices(end-1)),input_path(indices2(end)+1:end)));
normal_vectors= Normal_vector_matrix_bin_after_bin;
treated_population=[];
control_population=[];
remove_group={'Control',''};
binning_method=18;
[gene_names,gi]=setdiff(BASICDATA1.GeneData,remove_group);
gene_id=BASICDATA1.GeneID(gi);
[sorted_coefficients,bin_starts,bin_indices]=calculationPopulationScoreSize(features2,binning_method,1);
%[sorted_coefficients,bin_starts]=calculationPopulationScore(features2,2,pop_coef);
features = nanzscore(orig_features);
median_c1=NaN(24,size(orig_features,2));
median_r1=NaN(16,size(orig_features,2));
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
output1=NaN(length(gene_names),6,1138);c_crit=NaN(length(gene_names),6,1138);
%Create control population
BASICDATA1.GeneID(cellfun(@(x) isempty(x),BASICDATA1.GeneID))={NaN};
BASICDATA1.GeneID(find(strcmp(BASICDATA1.GeneID,'Blank')))={NaN};
GeneID=cell2mat(BASICDATA1.GeneID);
%Create control population
for(gene=1:length(gene_names))
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
    %  log_control=ismember(1:length(sorted_coefficients), :);
    log_treated=ismember(sorted_coefficients(:),index_v(matGeneCellIX));
    treated_population=features(sorted_coefficients(log_treated(:)),:);
    
    %Loop over all bins (default is 10)
    for(bin=1:num_bins)% (length(bin_starts)-1))
        treated_population(:,:)=[];
        control_population(:,:)=[];
        temp_vec=bin_starts((bin-1)*3+1):bin_starts(bin*3+1);
        %Check whether the bin is full
        if(length(temp_vec)>1)
            treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
            control_population=features(sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
            perturbed_indices1=bin_indices((temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
            perturbed_indices=perturbed_indices1-(bin-1)*3;
            control_indices=bin_starts((bin-1)*3+1:3*bin+1)-bin_starts((bin-1)*3+1)+1;
            cells_bin(gene,bin)=size(treated_population,1);
            % Stop if either of the two poulation has less than 200 cells
            if((size(treated_population,1)<num_cells))
                % sprintf('Cells with perturbed gene %s are not contained in bin %d',gene_names{gene},bin)
                continue;
            end;
         
            population=[treated_population;control_population];
            size_sample=hist(perturbed_indices,[1,2,3]);
            sample_size1=floor(min(size(treated_population,1)/2,250));
               C=0.02/sample_size1;
               C=1;
            sample_size=floor((sample_size1/size(treated_population,1))*size_sample);
            test_cases1=arrayfun(@(x) population([randi([1 size(treated_population,1)],sample_size1,1)],1:size(orig_features,2)),1:100,'UniformOutput',false);
            test_cases2=arrayfun(@(x) population([randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)],1:size(orig_features,2)),1:100,'UniformOutput',false);
            for(score_svm=1:1138)
                %Loop over all support vector machines
                %of the bin
                if(size(normal_vectors,1)>0)
                    w=normal_vectors(score_svm,(bin-1)*size(orig_features,2)+1:(bin-1)*size(orig_features,2)+size(orig_features,2));
                    b=bias(score_svm,bin);
                    test_cases3=arrayfun(@(x)  test_cases1{x}*w'+b,1:num_iterations,'UniformOutput',false);
                    test_cases4=arrayfun(@(x) test_cases2{x}*w'+b,1:num_iterations,'UniformOutput',false);
                    test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size1),1:num_iterations,'UniformOutput',true);
                    %/(2*sample_size1)
                    c_criteria=arrayfun(@(x) C*sum(max(0,(1-(test_cases3{x}))).^2),1:num_iterations,'UniformOutput',true)+arrayfun(@(x) C*sum(max(0,(1+test_cases4{x})).^2),1:num_iterations,'UniformOutput',true)   ;
                    c_crit(count,bin,score_svm)=mean(c_criteria);
                    output1(count,bin,score_svm)=mean(test_class);
                end;
            end;
        end;
    end;
end;

a=1;
Classification_accuracy=output1;
c_crit=c_crit;
Gene_list=gene_names;
save(npc(write_path), 'Gene_list','Classification_accuracy','c_crit');
end
