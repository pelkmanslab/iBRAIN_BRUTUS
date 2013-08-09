function []=pca_test_headless_rfe(plate_path,assay_path,input_path)
%This function find a short feature selected from a larger feature set with
%the goal to classify the data equally well while reducing overfitting.
%The procedure starts by classifying the whole plate with the entire feature set. Subsequently, the 10 worst feature hacvingh only minimal
%impact on SVM performance are removed. Then the SVMs are reclassified with
%the shorter feature set this proecedure is repeated until the feature set
%contains less than 10 features. 
%
%Inputs
%plate_path:Path to BATCH directory
%assay_path: Path containing the directory with 2 files: the RFE file to
%load all features (up to 150 features) and the RFE_final list with
%placeholders suitabel to be replaced by selected feature lists. Refer to
%the scripts/deriveSettings.m script to see the format of those files.
%input_path: Path to multivariate settigns file
%Output: No output parameters. 2 mat files stored in plate_path,
%describing the 20 TOP features in getRawProbModelDat2 format and a .mat
%file having the following varioablesé
%-ranking_c:Impact of feature in a a certain RFE rounds
%-Classification_accuracy:Classification_accuracy of gene g and bin b in step i is Classification_accuracy{g,b,i}
%-removed_features: List of feature in the sequence they were removed removed_features{1}=first removed feature. Within blocks of the 10 features removed at a  time. The features are sorted according to increasing contribution to the objective function of the SVMs    
    test_flag=0;
    global_bound=0.0;
    local_bound=0.5
    
%             plate_path='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytome\100402_A431_w3Macro\100402_A431_Macropinocytosis_CP392-1bd\BATCH';
%         % % % % % batch_out='\BIOL\imsb\fs3\bio3\bio3\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%         input_path='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytome\100402_A431_w3Macro\multivariate_settings_MacroVes.txt';
%         assay_path='\\nas-unizh-imsb1.ethz.ch\share-3-$\data\users\Prisca\endocytome\100402_A431_w3Macro';
    if(nargin==3)

        plate_path
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
        command_string=strcat('-s 5 -q -B 1   -c', sprintf(' %d',1) );
        %Strings able to identify measurement category of a feature
        category_strings={'SumIntensity_.+Cells','MeanIntensity_.+Cells','Intensity_.+Cells','Texture_3.+Cells','Intensity.+PlasmaMembrane','Ves_Cells','GMM','Texture_3.+PlasmaMembrane','Intensity.+Cytoplasm','Texture_3.+Cytoplasm','Intensity.+Perinuclear','Texture_3.+Perinuclear'};
        if(isfield(multivariate_config.rfe,'category_strings'))
            category_strings=multivariate_config.rfe.category_strings;
        end;
        target_strings={'Cells_SumIntensity1','Cells_MeanIntensity1','Cells_Intensity1','Cells_Texture_31','PlasmaMembrane_Intensity1','Cells_CustomSingle1','GMM2','PlasmaMembrane_Texture_31','Cytoplasm_Intensity1','Cytoplasm_Texture_31','Perinuclear_Intensity1','Perinuclear_Texture_31'};
        if(isfield(multivariate_config.rfe,'target_strings'))
            target_strings=multivariate_config.rfe.target_strings;
        end;
        local_i=0.5;
        if(isfield(multivariate_config.rfe,'local_i'))
            local_i=multivariate_config.rfe.local_i;
        end;
        %Name of the template containing suitable palceholders for easy
        %generation of feature lists
        template_name=strcat(assay_path,'/RFE_',multivariate_config.vesicle.vesicle_names2,'_final_new.txt');
        if(isfield(multivariate_config.rfe,'template_name'))
            template_name=multivariate_config.rfe.template_name;
        end;
        %Output file containing all iteration information
        mat_file=strcat(plate_path,'/Measurements_100local1normsamplesizeRFE_',multivariate_config.vesicle.vesicle_names2,'_new.mat');
        if(isfield(multivariate_config.rfe,'mat_file'))
            mat_file=multivariate_config.rfe.mat_file;
        end;
        %Output getRawProbModelData2 to load 20 features
        prob_file=strcat(plate_path,'/RFE100local1normsample_RFE_',multivariate_config.vesicle.vesicle_names2,'_new.txt');
        if(isfield(multivariate_config.rfe,'prob_file'))
            prob_file=multivariate_config.rfe.prob_file;
        end;
        root_path=npc(plate_path);

        basic_files=dir(npc(strcat(plate_path,'/*BASICDATA*')))
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        %Input getRawProbModelData2 to load all features
        config_file=strcat(assay_path,'/RFE_',multivariate_config.vesicle.vesicle_names2,'_new.txt');
        basic_path=basic_files.name;
        fullfile_path=npc(strcat(plate_path,'/',basic_path));
        num_c=60;
        num_iterations=10;
        if(isfield(multivariate_config.rfe,'num_iterations'))
            num_iterations=multivariate_config.rfe.num_iterations;
        end;
        num_normalvectors=10;
        if(isfield(multivariate_config.rfe,'num_normalvectors'))
            num_normalvectors=multivariate_config.rfe.num_normalvectors;
        end;
        NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
        num_cells=num_c;
        num_bins=6;%Number of bins the population shoould be distributed into
        strRootPath = root_path;
        %Load template
        template_string=fileread(npc(template_name));
        %Load features
        [temp_features,tempfeature_names,meta] =getRawProbModelData2(npc(strRootPath),npc(config_file));
        %Set NaN to zero
        temp_features(find(temp_features~=temp_features))=0;
        %Set INF to zero. INF occur very seldom due to CP issues
        temp_features(find(isinf(temp_features)))=0;
        orig_features=temp_features(:,NUM_POPULATION_FEATURES:end);
        feature_names=tempfeature_names(NUM_POPULATION_FEATURES:end);
        features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
        load(fullfile_path)
        %Remove wells known to be special wells such as Controls,DMSO or
        %BLANKS
        [gene_names,gi]=setdiff(BASICDATA.GeneData,{'Control','','DMSO','Blank'});
        gene_id=BASICDATA.GeneID(gi);
        [sorted_coefficients,bin_starts,bin_indices]=calculationPopulationScoreSize(features2,18,1);
     %We remove features having a relatove standard deviation (standard
     %deviation/mean)>10 since such feature are often instable and plate
     %effetc correction might cause them to be a unique tag for every well
     means=nanmean(orig_features);
stds=nanstd(orig_features);
rat=stds./means;
instable_features=feature_names(rat>10);
orig_features(:,rat>10)=[];
feature_names(rat>10)=[];
        features=nanzscore(orig_features(:,:));
        num_zero=NaN(max(BASICDATA.WellCol),size(features,2));
        %Perform plate effect correction for all features per bin using a standard
        %bscore method
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
        %Remove all features having very big differences of
        %fraction of zero among plate columns
        I=find((max(num_zero)-min(num_zero))>0.5);
        feature_names(I)=[];
        features(:,I)=[];
        %The feature increment per iteration is by default 10
        feature_step=10;
    else
        %Test plate
        load('C:\Users\heery\Desktop\current_code\pca_stick\testplate.mat');
        feature_names={'Correlated nonhit','Correlated nonhit','Correlated hit','Correlated hit','Correlated -hit','Correlated -hit'};
        p=randperm(6)
        features=features(:,p);
        feature_names=feature_names(p);
        feature_step=2;
    end;
    num_normalvectors=10;
    num_iterations=10;
    classification_acc=cell(length(gene_names),6,size(features,2));
    %Initialize vector storing ranking criterion
    ranking_c=zeros(size(features,2),size(features,2));
    num_features=size(features,2);
    removed_features=cell(size(features,2),1);
    %Convert GeneIds (which are numbers stored in cell arrays)
    %empty and blank and gene ids are set tio NaN. All other
    %enrties are valid numbers
    BASICDATA.GeneID(cellfun(@(x) isempty(x),BASICDATA.GeneID))={NaN};
    BASICDATA.GeneID(find(strcmp(BASICDATA.GeneID,'Blank')))={NaN};
    GeneID=cell2mat(BASICDATA.GeneID);
    Cells_per_bin=NaN(length(gene_names),num_bins);
    for(removal_counter=1:feature_step:num_features-feature_step)
        tic
        gene_names1={};%Temporary for gene names of gene_list
        count=0;
        gene_contrib=NaN(length(gene_names),6,size(features,2));
        for(gene=1:length(gene_names))
            gene_names1=[gene_names1;gene_names{gene}];
            count=count+1;
            %Construct feature matrix just for the current gene
            %
            if(~strcmp(gene_names{gene},'Non-targeting'))
                %Use Gene id to find image indices because gene ids are
                %unique
                matGeneImageIX = BASICDATA.ImageIndices(GeneID==gene_id{gene});
            else
                %Note that non-targeting does not contain any Geneid so
                %we use the unique "gene name" in this case
                matGeneImageIX = BASICDATA.ImageIndices(strcmp(BASICDATA.GeneData,'Non-targeting'));
            end;
            matGeneImageIX = cat(1,matGeneImageIX{:});
            matGeneCellIX = ismember(meta(:,6),matGeneImageIX);
            index_v=1:size(sorted_coefficients,1);
            log_treated=ismember(sorted_coefficients(:),index_v(matGeneCellIX));
            treated_population=features(sorted_coefficients(log_treated(:)),:);
            %Loop over all bins (default is 10)
            for(bin=1:num_bins)% (length(bin_starts)-1))
                               %Extract the non-targeting population and the
                               %population of the current gene in the binth
                               %bin of the global population
                temp_vec=bin_starts((bin-1)*3+1):bin_starts(bin*3+1);
                treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                Cells_per_bin(:,bin)=size(treated_population,1);
                control_population=features(sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                control_indices=bin_indices((((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                perturbed_indices=bin_indices((temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
                % Stop if either of the two poulation has less than 200 cells
                if((size(treated_population,1)<num_cells)||(size(control_population,1)<num_cells))
                    % sprintf('Cells with perturbed gene %s are not contained in bin %d',gene_names{gene},bin)
                    continue;
                end;
                %Train an SVM on the current bin and
                %current gene which yields 10 different
                %normal vector (from 10 different samplings)
                %and 10 classification accuracies
                %                 [normal_vectors,classification_acc{count,bin,removal_counter},~,Average_margin1]=calculateSVMBincluster(gene_names{gene},1,size(treated_population,1),perturbed_indices-(bin-1)*3,bin_starts((bin-1)*3+1:3*bin+1)-bin_starts((bin-1)*3+1)+1);
                %        
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
                sample_size1=floor(min(size(treated_population,1)/2,200));%200;%
                
                %Prepare test samples for SVM training and make sure test and train
                %perturbed populations are disjoint
                sample_size=floor((sample_size1/size(treated_population,1))*size_sample);
                population=([treated_population;control_population]);
                groups=ones(size(population,1),1);
                groups(1:size(treated_population,1))=1;
                groups(size(treated_population,1)+1:size(population,1))=-1;
                size(treated_population,2);
                normal_vectors=NaN(num_iterations,length(feature_size));
                b=NaN(num_iterations,1);
                
                %Perturbed sample for evaluating performance of SVM
                %classifier
                test_cases1=arrayfun(@(x) [randi([ceil(size(treated_population,1)/2) size(treated_population,1)],sample_size1,1)],1:num_iterations,'UniformOutput',false);
                %Cell size sampled control sample to evaluate performance
                test_cases2=arrayfun(@(x) [randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)],1:num_iterations,'UniformOutput',false);
                test_class=NaN(1,num_normalvectors);
                for(cross=1:num_normalvectors) 
                    %Training sample with perturtbed cells coming just
                    %from the first half. This ensures that perturbed
                    %training and test samples are disjoint.
                    train = [randi2([1 ceil(size(treated_population,1)/2)],sample_size1,1);randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)];
                    %Train SVM       
                    model = train4(groups(train),sparse(population(train,feature_size)),command_string);
                    % model = train4(groups(train),sparse(population(train,[4,7])),command_string);
                    % figure;
                    % hold on;
%                        svmtrain(population(train,[4,7]),groups(train),'Showplot',true,'BoxConstraint',1,'Autoscale',false)
                    normal_vectors(cross,:)=model.w(1:length(feature_size));
                    %Check for zero normal vector. This is indciation for a
                    %trivial (bad) classification so wet the normal vector
                    %and all performance parmaters top NaN.
%                     if(sum(normal_vectors(cross,:)==0)==20)
%                         normal_vectors(cross,:)=NaN(1,size(features,2));
%                         model.w(length(feature_size)+1)=NaN;
%                         b(cross)=NaN;
%                         continue;
%                     end;
                    b(cross)=model.w(length(feature_size)+1);
                    %Evaluate SVM performance and store all
                    %information
                    test_cases3=arrayfun(@(x) population( test_cases1{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
                    test_cases4=arrayfun(@(x) population( test_cases2{x},feature_size)*model.w(1:length(feature_size))'+b(cross),1:num_iterations,'UniformOutput',false);
                    test_class(cross)=nanmean(arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(sample_size1+sum(sample_size)),1:num_iterations,'UniformOutput',true));
                  
                end;
                classification_acc{count,bin,removal_counter}=test_class;
                classification_acc{count,bin,removal_counter}=classification_acc{count,bin,removal_counter};
                normal_count=0;
                %Take the average of all 10 normal vectors when
                %applied to a single cell, the average normal
                %vector gives a consensus value on in which
                %class the 10 normal vectors would put the cell
                %into
                for(normals=1:10)
                    if(~isnan(test_class(normals)))
                        normal_count=normal_count+1;
                    else
                        normal_vectors(normals,1:size(features,2))=NaN;
                    end;
                end;
                %temp is the reference normal vector
                %estimated from up to 100 samples
                temp=nansum(normal_vectors,1)/normal_count;
                %Evaluate contribution of that bin and geen
                %to the removal of the different features
                if(~isnan(temp(1)))
                    %Compute the objective value
                    %for one gene  and bin by
                    %computing 
                    %difference of median perturbed
                    %and median control situation.
                    gene_contrib(gene,bin,:)=temp.*(mean(treated_population(ceil(size(treated_population,1)/2):size(treated_population,1),:),1)-mean(control_population(:,:),1));
                    
                end;
            end;
        end;
        %Cell number correction
%         for(bin=1:num_bins)
%            cell_extreme=quantile(Cells_per_bin(:,bin), [0.0,0.33333,2*0.33333,1]);
%      [~,cellbin_indices]=histc(Cells_per_bin(:,bin),cell_extreme(1:4));
%      for(cellbin=1:3)
%          %zscore all contributions of all features for a given bin and cell
%          %bin.
%          %The ration is that bins and cell bins should have the a simialr
%          %distribution of the RFE objective function
%          gene_contrib(cellbin_indices==cellbin,bin,:)=reshape(nanzscore(lin(squeeze(gene_contrib(cellbin_indices==cellbin,bin,:)))),length(find(cellbin_indices==cellbin)),size(gene_contrib,3));
%         end;
%         end;
        %One new classification iteration is complete
        %we remove the features having the lowest impact
        
        %Calculate mean classification accuracy per bin
        if(global_bound>0)
            mean_classaccuracy=cellfun(@nanmean,classification_acc);
            mean_classaccuracy=lin(mean_classaccuracy(:,:,removal_counter));
            Idel=find(mean_classaccuracy~=mean_classaccuracy);
            mean_classaccuracy(Idel)=[];
            [~,index]=sort(mean_classaccuracy,'descend');
        end;
        %Get for each feature the total contribution of
        %the 40 % best contributors. This is done
        %seperatetely for each feature
        for(feat=1:size(features,2))
            temp_contrib=gene_contrib(:,:,feat);
            temp_contrib=lin(temp_contrib);
            temp_contrib(temp_contrib~=temp_contrib)=[];
            if(local_bound>0)
                [~,index]=sort(temp_contrib,'descend');
            end;
            %Store the mean objective value of the genes deciding the important feature importance (Note that some of the values might be NasN ) 
            ranking_c(removal_counter,feat)=nanmean(temp_contrib(index(1:ceil(max(local_bound,global_bound)*length(find(temp_contrib==temp_contrib))))))-nanmean(temp_contrib(index(ceil(max(local_bound,global_bound)*length(find(temp_contrib==temp_contrib))):length(find(temp_contrib==temp_contrib)))));
        end;
        
        %Find index of feature with smallest ranking
        %criterion
        [~,removal_indices]=sort(ranking_c(removal_counter,1:size(features,2)),'ascend');
        %Remove selected features in features matrix and feature_names
        features(:,removal_indices(1:feature_step))=[];
        removed_features(removal_counter:removal_counter+feature_step-1)=feature_names(removal_indices(1:feature_step));
        feature_names(removal_indices(1:feature_step))
        feature_names(removal_indices(1:feature_step))=[];
        toc
    end;
    removal_counter=removal_counter+feature_step;
    %Store features names removed in this last
    %iteration
    removed_features(removal_counter:removal_counter+size(features,2)-1)=feature_names(1:end);
    %Save some information on the RFE
    Classification_accuracy=classification_acc;
    if(nargin==3)
        save(mat_file,'ranking_c','removed_features','Classification_accuracy','instable_features');  
        %category_string are able to match the textual
        %palceholders put into the template config file. We loop
        %over all features and find the block to which we have
        %to add the feature
        
        %Replacement strings contains comma lists 
        replacement_strings=cell(length(category_strings),1);{'','','','','','','','','','','',''};
        replacement_strings(:)={''};
        for(f=length(removed_features)-19:length(removed_features))
            for(j=1:length(category_strings))
                if(regexp(removed_features{f},category_strings{j})>0)
                    %Find feature index by taking substing from the
                    %last underscore to the end of the string
                    under=strfind(removed_features{f},'_');
                    feat=removed_features{f};
                    feature_num=str2num(feat(under(end)+1:length(removed_features{f})));
                    replacement_strings{j}=strcat(replacement_strings{j},sprintf('%d',feature_num),',');
                    break;
                end;
            end;
        end;
        %Now each measurement block is associated with a
        %replacement_string destined to replace the textual place
        %holder, we apply now these replacements
        for(j=1:length(replacement_strings))
            template_string=strrep(template_string,target_strings{j},replacement_strings{j});
        end;
        %Open output settings file and store the the
        %getRawProbModelData2 file
        fid=fopen(prob_file,'w');
        fprintf(fid,'%s',template_string);
        fclose(fid);
        sprintf('RFE finished')
    end;
end
             

