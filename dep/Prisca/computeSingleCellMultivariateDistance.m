

function [ output_args ] = computeSingleCellMultivariateDistance( plate_path,assay_path,input_path )
%computeSingleCellMultivariateDistance Compute Multivariate single cell distances
%   The function takes a plate and a classification file of that plate and
%   computes the distance of every cell in the feature space to its correct
%   hyperplain. The function loads all needed features (defined by a
%   getRawProbModelData2 file), bins the cells into population context bins
%   and then computes the distan ce of a cell with the formula (normal
%   (vector*features+bias)*margin which corresponds to distance in the
%   featurte (zscored and plate effect corrected) feature space. The resulting numbers are stored in a .mat file.
%Note that distances of cleaned up cells are always naN as vesicle feature
%computation
%were not possible for this cells due to performance reasons. This has the
%implication that always the getRawProbModeldata2 files must be used.
%Otherwise it is suggested to rerun the pipeline.
%Input:
%plate_path: Path to a BATCH directory 
%config_file: path to a valid getRawProbModelData2 config file
%input_path: Path to a multivariate settings file 
%write_path: Path to a mat file where the output is stored
%Output:
%A file in cellprofiler .mat format keeping all single cell multivariate
%distances

% input_path=strcat('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/multivariate_settings_TfVes.txt');
% plate_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH';
% config_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/RFEcp395_TfVes.txt';

%Read multivariate settings file controlling multivariate settings
%

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
    %Now we eval the read text which impllies the multivariate
    %settings file is interpreted as matlab script
    eval(out);
    config_file=strcat(assay_path,'/RFE_',multivariate_config.vesicle.vesicle_names2,'.txt');
    NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
                              %The next few lines prepare the parameters
                              %
    num_cells=30;
    if(isfield(multivariate_config,'num_cells'))
        num_cells=multivariate_config.num_cells;
    end;

    %By default we exclude just Control cells (contains PLK) and ''
    %wells (empty wells)
    remove_group={'Control',''};
    if(isfield(multivariate_config,'remove_group'))
        control_group=multivariate_config.remove_group;
    end;
    binning_method=18;
    if(isfield(multivariate_config,'binning_method'))
        binning_method=multivariate_config.binning_method;
    end;
   
    %Hard coded constants, still need to decide whether to put into
    %multivariate settigns file or function arguments
    num_cells=40;
    channel_names=multivariate_config.vesicle.channel_names;
    num_bins=6;%Number of bins the population should be distributed into
    basic_files=dir(npc(strcat(plate_path,'/*BASICDATA*')));
    if(size(basic_files,1)>1)
        sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
    end;
    basic_path=basic_files.name;
    %  pc_ref=pca_test_headless_6bin(plate_path,config_file,basic_path,20,40);
    [temp_features,tempfeature_names,meta] =getRawProbModelData2(npc(plate_path),npc(config_file));
    %Check for cells NaN feature values and set them to zero, since
    %only vesicle and GMM features are not naN discarded only they should
    %contain NaN values
    temp_features(find(temp_features~=temp_features))=0;
    %Variable renaming
    features=nanzscore(temp_features(:,NUM_POPULATION_FEATURES:23));
    features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
    load(fullfile(npc(plate_path),npc(basic_path)))
    BASICDATA=BASICDATA;
    [gene_names,gi]=setdiff(BASICDATA.GeneData,remove_group);
    gene_id=BASICDATA.GeneID(gi);
    %Bin cells
    [sorted_coefficients,bin_starts,bin_indices]=calculationPopulationScoreSize(features2,18,1);

    %Plate effect correction
    median_c1=NaN(24,20);
    median_r1=NaN(16,20);
    for(bin=1:6)
    for(col=1:max(BASICDATA.WellCol))
        col_cells=find(BASICDATA.WellCol==col);
        matNonTargetingImageIX = BASICDATA.ImageIndices(col_cells);
        matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
        col_cells= find(ismember(meta(:,6),matNonTargetingImageIX));
        %Exclude cells not in current bin to do a plaet effect
        %correction accounting for population context
                 col_cells=intersect(col_cells,sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
        median_c1(col,:)=nanmean(features(col_cells,:));
        features(col_cells,:)=bsxfun(@minus,features(col_cells,:),median_c1(col,:));
        
    end;
    for(row=1:max(BASICDATA.WellRow))
        row_cells=find((BASICDATA.WellRow==row));
        matNonTargetingImageIX = BASICDATA.ImageIndices(row_cells);
        matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
        row_cells= find(ismember(meta(:,6),matNonTargetingImageIX));
                 row_cells=intersect(row_cells,sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
        median_r1(row,:)=nanmean(features(row_cells,:));
        features(row_cells,:)=bsxfun(@minus,features(row_cells,:),median_r1(row,:));
        
    end;
     end;
    count=0;



    output=[];output1=[];output2=[];normal_vector=[];
    %Convert GeneIds (which are numbers stored in cell arrays)
    %empty and blank and gene ids are set tio NaN. All other
    %enrties are valid numbers
    BASICDATA.GeneID(cellfun(@(x) isempty(x),BASICDATA.GeneID))={NaN};
    BASICDATA.GeneID(find(strcmp(BASICDATA.GeneID,'Blank')))={NaN};
    GeneID=cell2mat(BASICDATA.GeneID);
    %Load object count to get number fo images and cells. This is is used
    %to allocate cell arrays and matrices of the correct size so
    %getrawprobModelDat2 can be used on the resulting output files
    load(npc(strcat(plate_path,'/','Measurements_Image_ObjectCount.mat')));
    object_features=eval('handles.Measurements.Image.ObjectCountFeatures');
    object_count=eval('handles.Measurements.Image.ObjectCount');
    object_count=cat(1,object_count{:});
    image_count=size(object_count,1);
    cell_count=object_count(:,find(strcmp('Cells',object_features)));
    %Allocate a cell array for the images
    cell_distances=cell(image_count,1);
    
    %Loop over images and allocate matrices, 
    for(image=1:image_count)
        %Allocate space for the distance matrix
        current_d=NaN(cell_count(image),1);
        cell_distances{image}=current_d;
    end;
    %Load classification data

           [ Classification_accuracy,margin,Cells_per_bin5,Normal_vector_matrix_bin_after_bin,Gene_list,Normal_vector_matrix_bin_after_bin3,bias ,c_crit5,plate_indices,feature_names,Average_distance,pvalue15,pvalue15_control,entrez,length_std,class_std] =loadAssay_part1({plate_path},strcat('Measurements_Classification6bin_RFEcp395_',multivariate_config.vesicle.vesicle_names2),1);
     
    %Find the 
    %Now we loop over gene ids and bins and compute the distances this has
    %the advanathe that everuy normal vector yields exactly one matrix
    %times vector operation
       
    for(gene=1:length(gene_id))
        

        %Construct vector of image indices just for the current gene
        if(~strcmp(gene_names{gene},'Non-targeting'))
            %Use Gene id to find image indices because gene ids are
            %unique
            matGeneImageIX = BASICDATA.ImageIndices(GeneID==gene_id{gene});
        else
            %Note that non-targeting does not contain any Geneid so
            %we use the unique "gene name" in this case
            matGeneImageIX = BASICDATA.ImageIndices(strcmp(BASICDATA.GeneData,'Non-targeting'));
        end;
        %Use image indices to get feature matrix for the current
        %gene via exploting getRawProbModelData2 metadata 
        %
        matGeneImageIX = cat(1,matGeneImageIX{:});
        matGeneCellIX = ismember(meta(:,6),matGeneImageIX);
        index_v=1:size(sorted_coefficients,1);
        
        log_treated=ismember(sorted_coefficients(:),index_v(matGeneCellIX));
     
        %Loop over all bins
        for(bin=1:num_bins)
            temp_vec=bin_starts((bin-1)*3+1):bin_starts(bin*3+1);
            %Check whether the bin is full
            if(length(temp_vec)>1)
                %Select all cells of the bin com ing from all cell size
                %pseudobins
                treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                %Get image and relative cell indices in the respective
                %image
                image_indices=meta(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),6);
                cell_indices=meta(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),7);
                %Compyte multivariate distance as a column vector
                multi_d=(treated_population*Normal_vector_matrix_bin_after_bin(gene,(bin-1)*size(features,2)+1:bin*size(features,2))'+bias(gene,bin))*margin(gene,bin);
                for(l=1:length(image_indices))
                    cell_distances{image_indices(l)}(cell_indices(l))=multi_d(l);
                end;
            end;
        end;
    end;
    %Cast data format to Cellprofiler handles data format
    handles=struct('Measurements',struct('Cells',struct(strcat('SingleCellMultiVariateDistance',channel_names,'Features'),{'Multivariate distance'},strcat('SingleCellMultiVariateDistance',channel_names),{cell_distances})));
 save(npc(strcat(plate_path,'/','Measurements_Cells_SingleCellMultiVariateDistance',channel_names,'.mat')),'handles');
end

