%pca-test reads in the measurements specified in measurements_list . The
%features are concatenated toa cell-feature matrix. On this matrix a PCA is
%applied. All of the cells are distributed into 10 bins according to theior
%first component coefficient. Each bin has equal number of cells. For each
%of the 10 bins a SVM to distungish the cells in the bin and a random sample of sample_size.
%Using the resulting normal vectopr the distance of each cell
%to the SVM separator is calculated to detrmine in which of the two regions
% the cell resides.
%set(0,'DefaultFigureRenderer','opengl')
classdef pca_test_headless_rfe < handle
    properties
    
        num_bins %Number fo bins
        gene_names %Complete list of gene names
        feature_names;
        feature2_names;
        orig_features;%Features used for seperating population
        meta;%Meta vector of features seperating population
        BASICDATA1;
        features2;
        output;
        normal_vector;
        output1;
        output2;
        calculate_normals;
        coefficient_variation;
        gene_variation;
        pop_coef;%PCA coefficients of whole population
        cells_bin;%Matruix with number of cells for each bin of each gene
        all_flag=true;%This flag is false if only the PCA of the population should be computed
        root_path1;
        num_cells;
        num_pca;
        coeff_all;
        b_values;%b values of hyper plane, can be used to calculate the distance to the hyper plane from an arbitarz point
        robust_measure;
        C;
        bias;
        std_class;%Standard deviation of classification accuracy
        spec;%Specificity for each bin and gene
        sens;%Sensitivity of each gene and bin
        template_string;%String containing settings fiel of this plate
        output_path;
    end;
    
    methods
        function obj=pca_test_headless_rfe(root_path,config1_path,fullfile_path,num_p,num_c,output_path1)
            NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
 obj.num_cells=num_c;
            obj.num_pca=num_p;
        obj.calculate_normals=true;
            obj.root_path1=root_path;
            obj.output_path=output_path1;
            obj.num_bins=6;%Number of bins the population shoould be distributed into
            strRootPath = root_path;
           %%Feature loading: 3 Population features and 20 intensity and
            %%texture features
            obj.template_string=fileread(npc(strcat(config1_path(1:strfind(config1_path,'.txt')-1),'_final','.txt')));
         [temp_features,tempfeature_names,obj.meta] =getRawProbModelData2(npc(strRootPath),npc(config1_path));
%Set NaN to zero
         temp_features(find(temp_features~=temp_features))=0;
         
         obj.orig_features=temp_features(:,NUM_POPULATION_FEATURES:end);
         obj.feature_names=tempfeature_names(NUM_POPULATION_FEATURES:end);
          %  [obj.orig_features,obj.feature_names,obj.meta] =getRawProbModelData2(strRootPath,config1_path);
           % [obj.features2,obj.feature2_names,meta2] =getRawProbModelData2(strRootPath,config2_path);
           obj.features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
            load(fullfile_path)
            obj.pop_coef=1;%load(strcat(super_root,'\Measurement_PCA_coeff_all.mat'));
            obj.BASICDATA1=BASICDATA;
           
            

    %PCA of population contedxt then sortn according to first
    %component and report PCA of population context
  %  [coeff_population,scores_population,dummy12]=princomp_nan(features(matNonTargetingCellIX,:));
            
            
        end;
        
        %Write output
        %Saves the normal vectors for convenience in three redundamnt ways
        % 1.
        function writeOutput(obj)
            count=1;
            dummy1=1;
          %  showClassification1D(0,'LAMP1',1,dummy1,dummy1,dummy1,dummy1);
            if(obj.all_flag)
                
                normal_vectors=[];
                for(i=1:length(obj.gene_names))
                    for(j=1:obj.num_bins)
                       new_entry=obj.normal_vector{i,j}(:);count=count+1;
                        normal_matrix(i,(j-1)*20+1:j*20)=new_entry;
                        normal_vectors=[normal_vectors;new_entry'];
                    end;
                end;
                %Calculate PCA of normal vector with high classification
                %accuracy
               
                %Second normal matrix with sequence of features
                for(j=1:length(obj.normal_vector{i,j}(:)))
                    normal_matrix2(:,(j-1)*obj.num_bins+1:(j-1)*obj.num_bins+obj.num_bins)=normal_matrix(:,[j:20:obj.num_bins*20]);
                end;
                if(obj.calculate_normals)
                        head_output=struct('Gene_list',{obj.gene_names},'Classification_accuracy',obj.output1,'Bias',obj.bias,'Normal_vector_matrix_bin_after_bin',normal_matrix,'Normal_vector_matrix_gene_after_gene',normal_matrix2,'All_normal_vectors',normal_vectors,'Cells_per_bin',obj.cells_bin,'Robust',obj.robust_measure,'Std',obj.std_class,'Specificity',obj.spec,'Sensitivity',obj.sens);
                       out_string=strcat(obj.root_path1,'\Measurement_normal');
                       
                        save(strcat(obj.root_path1,'\Measurement_normal_all-run2-bin10'), 'head_output');
                        
                    end;
                        head_output=struct('Gene_list',{obj.gene_names},'Coefficent_variation',obj.coefficient_variation,'Gene_variation',obj.gene_variation);
                        save(strcat(obj.root_path1,'\Measurement_coefficient_all-bin10'), 'head_output');
                
                    %              clusterGenes(hand,normal1,normal2,obj.gene_list,obj.output,obj.con_min,obj.con_max,obj.treshhold,normal_matrix,normal_matrix2)
             
            end;
            
        end;
        
        function updateGeneList(obj,new_list,output_path,output_path1,local_bound,global_bound)
            global treated_population; 
global control_population;
           
                obj.gene_names=setdiff(obj.BASICDATA1.GeneData,{'Control','','DMSO','Blank'});
         
                %Create indices of cells with non-targeting siRNA
                %
                matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(strcmpi(obj.BASICDATA1.GeneData,'Non-targeting'));
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                matNonTargetingCellIX = ismember(obj.meta(:,6),matNonTargetingImageIX);
                
                %PCA of population contedxt then sortn according to first
                %component and report PCA of population context
                scores_population=zeros(size(obj.features2,1),1);
               %%% obj.features2=zscore(obj.features2);
            
                    
               %Old version for PCA based binning [first_coefficients,sorted_coefficients]=calculationPopulationScore(obj.features2,1,obj.pop_coef.head_output.PCA_coefficients);
               [sorted_coefficients,bin_starts,bin_indices]=calculationPopulationScoreSize(obj.features2,18,obj.pop_coef);
                %[first_coefficients,sorted_coefficients]=sort(obj.features2(:,1));
                dummy=1;
                %reportPrincipal(dummy,dummy,dummy,coeff_population,scores_population,obj.feature2_names,obj.num_bins);
                %zscore of texture and intensity features
                        %Remove all features having more than 40 % of zero
                    %values
%                    num_zero=arrayfun(@(x) length(find(obj.orig_features(:,x)==0))/size(obj.orig_features,1),1:size(obj.orig_features,2));
%                    obj.orig_features(:,find(num_zero>0.4))=[];
%                    if(length(find(num_zero>0.4)))
%                    sprintf('The following features were removed:')
%                    obj.feature_names(find(num_zero>0.4))
%                    obj.feature_names(find(num_zero>0.4))=[];
%                    end;
                    features=nanzscore(obj.orig_features(:,:));
                    %Remove features with very big differenc ebetween mean
                    %and median
%                     medians=abs(nanmedian(features)-nanmean(features));
% 
% features(:,medians>0.3)=[];
% obj.feature_names(medians>0.3)=[];
               %Take median of all columns
total_med=nanmedian(features());
num_zero=NaN(max(obj.BASICDATA1.WellCol),size(features,2));
                    %Loop over rows
                    for(col=1:max(obj.BASICDATA1.WellCol))
                                     col_cells=find(obj.BASICDATA1.WellCol==col);
                                matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(col_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                col_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
                            features(col_cells,:)=bsxfun(@minus,features(col_cells,:),nanmedian(features(col_cells,:)));
                              num_zero(col,:)=arrayfun(@(x) length(find(features(col_cells,x)==0))/length(find(col_cells==1)),1:size(features,2));
%                             
                        end;
                   
                    for(row=1:max(obj.BASICDATA1.WellRow))
                        row_cells=find(obj.BASICDATA1.WellRow==row);
                                matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(row_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                row_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
                        features(row_cells,:)=bsxfun(@minus,features(row_cells,:),nanmedian(features(row_cells,:)));
                        
                    end;
                         %Remove all features having very big differences of
                        %fraction of zero among columns
                        I=find((max(num_zero)-min(num_zero))>0.5);
                        obj.feature_names(I)=[];
                        features(:,I)=[];
%                     row_med=bsxfun(@minus,row_med,nanmedian(row_med));
%                     col_med=bsxfun(@minus,col_med,nanmedian(col_med));
%                     %Apply correction factors
%             for(row=1:max(obj.BASICDATA1.WellRow))
%                       row_cells=find(obj.BASICDATA1.WellRow==row);
%                                 matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(row_cells);
%                 matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
%                 row_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
%                         features(row_cells,:)=bsxfun(@minus,features(row_cells,:),row_med(row,:));
%             end;
%                        
%                         for(col=1:max(obj.BASICDATA1.WellCol))
%                                   col_cells=find(obj.BASICDATA1.WellCol==col);
%                                 matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(col_cells);
%                 matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
%                 col_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
%                            features(col_cells,:)=bsxfun(@minus,features(col_cells,:),col_med(col,:));
%                             
%                         end;
                
                    obj.coeff_all=eye(20);
     
                
                %
                %Prepare all fields by setting them to zero or empty list
                gene_names1={};%Temporary for gene names of gene_list
                count=0;
     
                obj.output=[];obj.output1=cell(length(obj.gene_names),6,size(features,2));obj.output2=[];obj.normal_vector=[];
                     %Initialize vector storing ranking criterion
                            ranking_c=zeros(size(features,2),size(features,2));
                            num_features=size(features,2);
                            removed_features=cell(size(features,2),1);
                %Only run SVM if necessary
                if(obj.all_flag)
                    for(removal_counter=1:10:num_features-10)
                        tic
                          gene_names1={};%Temporary for gene names of gene_list
                count=0;
                gene_contrib=NaN(length(obj.gene_names),6,size(features,2));
                      for(gene=1:length(obj.gene_names))
                        
                            gene_names1=[gene_names1;obj.gene_names{gene}];
                            count=count+1;
                            
                            %Construct feature matrix just for the current gene
                            %
                            matGeneImageIX = obj.BASICDATA1.ImageIndices(strcmpi(obj.BASICDATA1.GeneData,obj.gene_names(gene)'));
                            matGeneImageIX = cat(1,matGeneImageIX{:});
                            matGeneCellIX = ismember(obj.meta(:,6),matGeneImageIX);
                           
                            
                            %Construct feature matrix just for the current
                   
                            %
                         
                            features1=features(matGeneCellIX,:);
                            index_v=1:size(sorted_coefficients,1);
                        %  log_control=ismember(1:length(sorted_coefficients), :);
                           log_treated=ismember(sorted_coefficients(:),index_v(matGeneCellIX));
                         treated_population=features(sorted_coefficients(log_treated(:)),:);
                            obj.gene_variation(gene)=sum(std(treated_population,0,2)./abs(mean(treated_population,2)));
%                             for(init_bin=1:obj.num_bins)
%                                               obj.normal_vector{count,init_bin}=NaN(1,size(features,2));end;
%                                 obj.output(count,:)=0.5;
%                                 obj.output1(count,:)=NaN;
%                                 obj.output2(count,:)=0.5;
%                                 obj.robust_measure(count,:)=NaN;
%                                 obj.bias(count,:)=0;
%                                 obj.sens(count,:)=NaN;
%                                 obj.spec(count,:)=NaN;
                            %Loop over all bins (default is 10)
                              
                            for(bin=1:obj.num_bins)% (length(bin_starts)-1))
                                %Initialize output values for current bin in
                                %case the number of cells is to small and no
                                %SVM are run
                                %
              
                                %Extract the non-targeting population and the
                                %population of the current gene in the binth
                                %bin of the global population
                                
% % %                                 first_index=(round((bin-1)*length(first_coefficients)*0.96/obj.num_bins))+1+round(0.02*length(first_coefficients));
% % %                                 last_index=(round((bin)*length(first_coefficients)*0.96/obj.num_bins))+1+round(0.02*length(first_coefficients));
% % %                                 temp_vec=first_index:last_index;
% % %                                 treated_population=features(sorted_coefficients(temp_vec(log_treated(first_index:last_index))),:);
% % %                                 control_population=features(sorted_coefficients(temp_vec(log_control(first_index:last_index))),:);%Control population is entire population->Bootstraping
treated_population(:,:)=[];
control_population(:,:)=[];
temp_vec=bin_starts((bin-1)*3+1):bin_starts(bin*3+1);
%size_comp=b
treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                                  control_population=features(sorted_coefficients(((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                                  control_indices=bin_indices((((bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))),:);
                                 perturbed_indices=bin_indices((temp_vec(log_treated(bin_starts((bin-1)*3+1):bin_starts(bin*3+1)))));
                                 
%                     treated_population=features(sorted_coefficients((log_treated(:))),:);
%                                                       control_population=features(sorted_coefficients((log_control(:))),:);


obj.coefficient_variation(gene,bin)=sum(std(treated_population,0,2)./abs(mean(treated_population,2)));
                                obj.cells_bin(gene,bin)=size(treated_population,1);
                                % Stop if either of the two poulation has less than 200 cells
                                if((size(treated_population,1)<obj.num_cells)||(size(control_population,1)<obj.num_cells))
                                    % sprintf('Cells with perturbed gene %s are not contained in bin %d',gene_names{gene},bin)
                                    continue;
                                end;
                                [normal_vectors,obj.output1{count,bin,removal_counter},obj.bias{count,bin},Average_margin1]=calculateSVMBincluster(obj.gene_names{gene},1,size(treated_population,1),perturbed_indices-(bin-1)*3,bin_starts((bin-1)*3+1:3*bin+1)-bin_starts((bin-1)*3+1)+1);
                         obj.output1{count,bin,removal_counter}=obj.output1{count,bin,removal_counter};
                                %Set normal vector to NaN wehn being part of a
                            %low margin gene
                            normal_count=0;
                                  for(normals=1:10)
                                    if(~isnan(Average_margin1(normals)))
                               
                                        
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
                               
                                            %Add ranking contribution of 30
                                            % top contributing genes
                                            %current bin if the normal
                                            %vector is not empty
                                            gene_contrib(gene,bin,:)=temp.*(median(treated_population(ceil(size(treated_population,1)/2):size(treated_population,1),:),1)-median(control_population(:,:),1));

                                            
                                       
                                    end;
                                end;
                            end;
                            %One new classification iteration is complete
                            %we remove the feature having the lowest impact
                            
                            %Calculate mean classification accuracy per bin
                             if(global_bound>0)
                               mean_classaccuracy=cellfun(@nanmean,obj.output1);
                            mean_classaccuracy=lin(mean_classaccuracy(:,:,removal_counter));
                            Idel=find(mean_classaccuracy~=mean_classaccuracy);
                                mean_classaccuracy(Idel)=[];
                               
                                                                           [~,index]=sort(mean_classaccuracy,'descend');
                             end;
                            %Get for each feature the total contribution of
                            %the 40 % best contributors. This is done
                            %seperatelty for each feature
                         
                            for(feat=1:size(features,2))
                                temp_contrib=gene_contrib(:,:,feat);
                                temp_contrib=lin(temp_contrib);
                                temp_contrib(temp_contrib~=temp_contrib)=[];
                                if(local_bound>0)
                                                                           [~,index]=sort(temp_contrib,'descend');
                                end;
        
                                        ranking_c(removal_counter,feat)=nanmean(temp_contrib(index(1:ceil(max(local_bound,global_bound)*length(find(temp_contrib==temp_contrib))))))-nanmean(temp_contrib(index(ceil(max(local_bound,global_bound)*length(find(temp_contrib==temp_contrib))):length(find(temp_contrib==temp_contrib)))));
                            end;
                            
                            %Find index of feature with smallest ranking
                            %criterion
                          
                            [~,removal_indices]=sort(ranking_c(removal_counter,1:size(features,2)),'ascend');
                            %Since several features might have the same
                            %ranking criterion just remove the first
                            %feature
                            features(:,removal_indices(1:10))=[];
                            removed_features(removal_counter:removal_counter+9)=obj.feature_names(removal_indices(1:10));
                            obj.feature_names(removal_indices(1:10))
                            obj.feature_names(removal_indices(1:10))=[];
                            toc
                    
                            
                    end;
                    end;
                    
                    removal_counter=removal_counter+10;
                                 %Output the the sequence of removed features and the
                %ranking used for deciding to remove which feature
                removed_features(removal_counter:removal_counter+size(features,2)-1)=obj.feature_names(1:end);
                Classification_accuracy=obj.output1;
                save(obj.output_path,'ranking_c','removed_features','Classification_accuracy');  
                %Strings able to idnetify measurement category of a feature
                category_strings={'SumIntensity_.+Cells','MeanIntensity_.+Cells','Intensity_.+Cells','Texture_3.+Cells','Intensity.+PlasmaMembrane','Ves_Cells','GMM','Texture_3.+PlasmaMembrane','Intensity.+Cytoplasm','Texture_3.+Cytoplasm','Intensity.+Perinuclear','Texture_3.+Perinuclear'};
                   %Strings identifieng features to load for each categroy
                replacement_strings={'','','','','','','','','','','',''};
               for(f=length(removed_features)-19:length(removed_features))
                   for(j=1:length(category_strings))
                       if(regexp(removed_features{f},category_strings{j})>0)
                           %Find feature index by taling substing from the
                           %last underscore to the end of the string
                           under=strfind(removed_features{f},'_');
                           feat=removed_features{f};
                           feature_num=str2num(feat(under(end)+1:length(removed_features{f})));
                           replacement_strings{j}=strcat(replacement_strings{j},sprintf('%d',feature_num),',');
                           break;
                       end;
                   end;
               end;
               %Apply replacements
               target_strings={'Cells_SumIntensity1','Cells_MeanIntensity1','Cells_Intensity1','Cells_Texture_31','PlasmaMembrane_Intensity1','Cells_CustomSingle1','GMM2','PlasmaMembrane_Texture_31','Cytoplasm_Intensity1','Cytoplasm_Texture_31','Perinuclear_Intensity1','Perinuclear_Texture_31'};
               for(j=1:length(replacement_strings))
                   obj.template_string=strrep(obj.template_string,target_strings{j},replacement_strings{j});
               end;
               %Open output settings file
fid=fopen(output_path1,'w');
fprintf(fid,'%s',obj.template_string);
fclose(fid);
sprintf('RFE finished')
                end;
             
                   
                
   
        
    end
end




