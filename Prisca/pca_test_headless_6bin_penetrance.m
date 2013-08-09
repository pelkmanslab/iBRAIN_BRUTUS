
function pca_test_headless_6bin_penetrance(plate_path,config_file,input_path,write_path,command_string1)
%Classify genes of a plate. 
%Classification of genes is done by a SVM classifier which compares samples of perturbed cells to
%samples of random cells coming from all over the plate. The rational is
%that cells showing a significant difference are a small minority so that
%perturbations showing some systematic difference should also be detected
%even when the plate sample contains some "hit" cells.
%
%Inputs:
%plate_path: Path to a BATCH directory 
%config_file: path to a valid getRawProbModelData2 config file
%input_path: Path to a multivariate settings file 
%write_path: Path to a mat file where the output is stored
%command_string1: Allows to change all SVM parameters. This is useful to
%get a more sensitive SVM or an SVM returning more meaningful phenotypes.
%
%Outputs
%
%The output is .mat file written to the location indicated by the parameter
%function parameter write_path. The following is the list of outputs with
%their description
%-b: Cell array Number genes x Num. bins x Number of normal vectors: Entry
%(i,j,k) is the normal vector in iteration k for gene i and bin j
%-Normal_vector_matrix_bin_after_bin: Cell array, Number of genes x (Number of bins) . Entry (i,j) contains a Num iterations x Number of
%features*Number of bins matrix with all Normal vector for all bins written
%to a single row one after the other. To access feature f of bin k use
%(Number of features)*(k-1)+f: The first part of the sum targets the last
%feature of the Normal vector before the one to select, f moves to the
%Normal vector we actually want so select. 
%-Average_margin: Number of genes x (Number of bins), Entry (i,j) contains
%a Num iterations x 4*Num sample cell array performance information for gene i and bin j. The first num sample block contains for every iteration the classification accuracies, the next block are the c-criteria values.
%The third block is the distance from the hyperplane of perturbed cells.
%The last block contains the distance of controll cells from the
%hyperplane.
%-Cells_per_bin: Num genes x num bin matrix. Entry (i,j) contains the number
%of cells after clean up in bin j of gene i
%-Gene_list: Contains the gene names in alphabetic order
%-Gene_id: Contains Gene ids for unique gene names. Empy or non number Gene
%ids are set to NaN.

    
% input_path=strcat('C:\Users\heery\Desktop\current_code\pca_stick\','general_inputfile.txt');
% plate_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH';
% config_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/RFEcp395_TfVes.txt';
%     
%             plate_path='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytome\090309_A431_w2ChtxNAW_w3GM130\090309_A431-Chtx-GM130-CP392-1af\BATCH';
%         % % % % % batch_out='\BIOL\imsb\fs3\bio3\bio3\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%         input_path='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytome\090309_A431_w2ChtxNAW_w3GM130\multivariate_settings_GM130Ves.txt';
%         config_file='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytom\090309_A431_w2ChtxNAW_w3GM130\RFEcp395_GM130Ves.txt'
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
    NUM_POPULATION_FEATURES=4;%Hard coded constant for number of population features
                              %The next few lines prepare the parameters
                              %
    num_cells=40;
    if(isfield(multivariate_config,'num_cells'))
        num_cells=multivariate_config.num_cells;
    end;
    num_iterations=100; 
    if(isfield(multivariate_config.classification,'num_iterations'))
        num_iterations=multivariate_config.classification.num_iterations;
    end;
    num_normalvectors=100; 
    if(isfield(multivariate_config.classification,'num_normalvectors'))
        num_normalvectors=multivariate_config.classification.num_normalvectors;
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
    %SVM command string
    command_string=strcat('-s 5 -q -B 1   -c', sprintf(' %d',1),' -w1 1 -w-1 1' );
    if(exist('command_string1'))
        command_string=command_string1;
    end;
    %Hard coded constants, still need to decide whether to put into
    %multivariate settigns file or function arguments
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
    %[sorted_coefficients,bin_starts]=calculationPopulationScore(features2,2,pop_coef);
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

    % %Uncommented code can be used to plot various properties of
    % features across a plate, only useful for debugging purposes
    %      for(f=1:20)
    %      all_plate=NaN(16,24);
    %            for(gene=1:length(gene_names))
    %             %Get plate index of gene
    %
    %                 %Get index of gene in BASICDATA
    %                 basic_index=find(strcmp(BASICDATA.GeneData,gene_names{gene}));
    %                  matGeneImageIX = BASICDATA.ImageIndices(strcmpi(BASICDATA.GeneData,gene_names{gene}));
    %                             matGeneImageIX = cat(1,matGeneImageIX{:});
    %                             matGeneCellIX = ismember(meta(:,6),matGeneImageIX);
    %                 all_plate(BASICDATA.WellRow(basic_index),BASICDATA.WellCol(basic_index))=mean(features(matGeneCellIX,f));%length(find(abs(features(matGeneCellIX,3))<0.1))/length(features(matGeneCellIX,3));%mean(features(matGeneCellIX,3));

    %            end;
    %            figure;
    %           % sprintf('Feature %d, Row Correlation:%d,Column correlation:%d',f,corr(repmat([1:16]',24,1),lin(all_plate)),corr(repmat([1:24]',16,1),lin(all_plate')))
    %            imagesc(all_plate);
    %      end;

    output=[];output1=[];output2=[];normal_vector=[];
    %Convert GeneIds (which are numbers stored in cell arrays)
    %empty and blank and gene ids are set tio NaN. All other
    %enrties are valid numbers
    BASICDATA.GeneID(cellfun(@(x) isempty(x),BASICDATA.GeneID))={NaN};
    BASICDATA.GeneID(find(strcmp(BASICDATA.GeneID,'Blank')))={NaN};
    GeneID=cell2mat(BASICDATA.GeneID);
    %Loop over genes
    for(gene=1:length(gene_id))
        
        count=count+1;
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
        %gene via exploiting getRawProbModelData2 metadata 
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
                %Cell size aware sampling by exploiting that adjacent
                %triples of bins are all having the same LCD and edge
                %range.
                treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                control_population=features(sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                control_indices=bin_indices((((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                perturbed_indices=bin_indices((temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
                %Record number of cells
                cells_bin(gene,bin)=size(treated_population,1);
                % Stop if either of the two poulation has less than 40 cells
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
                sample_size1=floor(min(size(treated_population,1)/2,250));
                %Prepare test samples for SVM training and make sure test and train
                %perturbed populations are disjoint
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
                %Perturbed sample for evaluating performance of SVM
                %classifier
                test_cases1=arrayfun(@(x) [randi([ceil(size(treated_population,1)/2) size(treated_population,1)],sample_size1,1)],1:num_iterations,'UniformOutput',false);
                %Cell size sampled control sample to evaluate performance
                test_cases2=arrayfun(@(x) [randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)],1:num_iterations,'UniformOutput',false);
                
                for(cross=1:num_normalvectors) 
                    %Training sample with perturtbed cells coming just
                    %from the first half. This ensures that perturbed
                    %training and test samples are disjoint.
                    train = [randi2([1 ceil(size(treated_population,1)/2)],sample_size1,1);randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)];
                    %Train SVM       
                    model = train4(groups(train),sparse(population(train,feature_size)),command_string);
                    normal_vector1(cross,:)=model.w(1:length(feature_size));
                    %Check for zero normal vector. This is indciation for a
                    %trivial (bad) classification so wet the normal vector
                    %and all performance parmaters top NaN.
                    if(sum(normal_vector1(cross,:)==0)==20)
                        normal_vector1(cross,:)=NaN(1,20);
                        model.w(length(feature_size)+1)=NaN;
                        average_margin1{cross}=NaN(1,400);
                        b(cross)=NaN;
                        continue;
                    end;
                    b(cross)=model.w(length(feature_size)+1);
                    %Evaluate SVM performance and store all
                    %information
                    test_cases3=arrayfun(@(x) population( test_cases1{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
                    test_cases4=arrayfun(@(x) population( test_cases2{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
                    test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size1),1:num_iterations,'UniformOutput',true);
                    C=1;
                    c_criteria=C*arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true)+C*arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:num_iterations,'UniformOutput',true)  ;     
                    average_margin1{cross}=[test_class,c_criteria,cellfun(@(x) mean(x),test_cases3),cellfun(@(x) mean(x),test_cases4)];
                end;
                normal_vector{count,bin}=normal_vector1;
                bias{count,bin}=b;
                average_margin{count,bin}=average_margin1;
            end;
        end;
    end
    %Rename variables and store information
    Bias=bias;
    Gene_list=gene_names;
    Normal_vector_matrix_bin_after_bin=normal_vector;
    Cells_per_bin=cells_bin;
    Gene_id=gene_id;
    Average_margin=average_margin;
    Feature_names=tempfeature_names;
    save(npc(write_path), 'Gene_list','Gene_id','Bias','Normal_vector_matrix_bin_after_bin','Cells_per_bin','Average_margin','Feature_names','-v7.3');

end
