%pca-test reads in the measurements specified in measurements_list . The
%features are concatenated toa cell-feature matrix. On this matrix a PCA is
%applied. All of the cells are distributed into 10 bins according to theior
%first component coefficient. Each bin has equal number of cells. For each
%of the 10 bins a SVM to distungish the cells in the bin and a random sample of sample_size.
%Using the resulting normal vectopr the distance of each cell
%to the SVM separator is calculated to detrmine in which of the two regions
% the cell resides.
%set(0,'DefaultFigureRenderer','opengl')
classdef pca_test_headless_6bin_old < handle
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
        average_margin;
        gene_id;
    end;
    methods
        function obj=pca_test_headless_6bin_old(root_path,config1_path,fullfile_path,num_p,num_c,selected_vesicle)
            NUM_POPULATION_FEATURES=4;%Hrad coded constant for number of population features
 obj.num_cells=num_c;
            obj.num_pca=num_p;
        obj.calculate_normals=true;
            obj.root_path1=root_path;
            obj.num_bins=6;%Number of bins the population shoould be distributed into
            strRootPath = root_path;
           %%Feature loading: 3 Population features and 20 intensity and
            %%texture features
         [temp_features,tempfeature_names,obj.meta] =getRawProbModelData2(strRootPath,config1_path);
   
         %Check for cedlls having NaN vesicle values and cat them to zero
         temp_features(find(temp_features~=temp_features))=0;
         obj.orig_features=temp_features(:,NUM_POPULATION_FEATURES:23);
         obj.feature_names=tempfeature_names(:,NUM_POPULATION_FEATURES:23);
          %  [obj.orig_features,obj.feature_names,obj.meta] =getRawProbModelData2(strRootPath,config1_path);
           % [obj.features2,obj.feature2_names,meta2] =getRawProbModelData2(strRootPath,config2_path);
           obj.features2=temp_features(:,1:NUM_POPULATION_FEATURES-1);
       
            load(fullfile(strRootPath,fullfile_path))
            obj.pop_coef=1;%load(strcat(super_root,'\Measurement_PCA_coeff_all.mat'));
            obj.BASICDATA1=BASICDATA;
           
            

    %PCA of population contedxt then sortn according to first
    %component and report PCA of population context
  %  [coeff_population,scores_population,dummy12]=princomp_nan(features(matNonTargetingCellIX,:));
            
            
        end;
        
        %Write output
        %Saves the normal vectors for convenience in three redundamnt ways
        % 1.
        function writeOutput(obj,write_path)
            count=1;
            dummy1=1;
          %  showClassification1D(0,'LAMP1',1,dummy1,dummy1,dummy1,dummy1);
            if(obj.all_flag)
                
%                 normal_vectors=[];
%                 for(i=1:length(obj.gene_names))
%                     for(j=1:obj.num_bins)
%                        new_entry=obj.normal_vector{i,j}(:);count=count+1;
%                         normal_matrix(i,(j-1)*20+1:j*20)=new_entry;
%                         normal_vectors=[normal_vectors;new_entry'];
%                     end;
%                 end;
%                 %Calculate PCA of normal vector with high classification
%                 %accuracy
%                
%                 %Second normal matrix with sequence of features
%                 for(j=1:length(obj.normal_vector{i,j}(:)))
%                     normal_matrix2(:,(j-1)*obj.num_bins+1:(j-1)*obj.num_bins+obj.num_bins)=normal_matrix(:,[j:20:obj.num_bins*20]);
%                 end;
                if(obj.calculate_normals)
                        head_output=struct('Gene_list',{obj.gene_names},'Classification_accuracy',obj.output1,'Bias',obj.bias,'Normal_vector_matrix_bin_after_bin',obj.normal_vector,'Cells_per_bin',obj.cells_bin,'Std',obj.std_class,'Specificity',obj.spec,'Sensitivity',obj.sens);
                       out_string=strcat(obj.root_path1,'\Measurement_normal');
                       Classification_accuracy=obj.output1;
                       Bias=obj.bias;
                       Gene_list=obj.gene_names;
                       Normal_vector_matrix_bin_after_bin=obj.normal_vector;
                       Cells_per_bin=obj.cells_bin;
                       Std=obj.std_class;
                       Specificity=obj.spec;
                       Sensitivity=obj.sens;
                       Gene_id=obj.gene_id;
                       Average_margin=obj.average_margin;
                       Feature_names=obj.feature_names;
                        save(write_path, 'Gene_list','Gene_id','Classification_accuracy','Bias','Normal_vector_matrix_bin_after_bin','Cells_per_bin','Average_margin','Feature_names','-v7.3');
                        
                    end;
                      %  head_output=struct('Gene_list',{obj.gene_names},'Coefficent_variation',obj.coefficient_variation,'Gene_variation',obj.gene_variation);
                     %   save(strcat(obj.root_path1,'/Measurement_coefficient_all-bin1-v16'), 'head_output');
                
                    %              clusterGenes(hand,normal1,normal2,obj.gene_list,obj.output,obj.con_min,obj.con_max,obj.treshhold,normal_matrix,normal_matrix2)
             
            end;
            
        end;
        
        function updateGeneList(obj,new_list)
            global treated_population; 
global control_population;
           
                [obj.gene_names,gi]=setdiff(obj.BASICDATA1.GeneData,{'Control',''});
         obj.gene_id=obj.BASICDATA1.GeneID(gi);
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
                   [sorted_coefficients,bin_starts]=calculationPopulationScore(obj.features2,4,obj.pop_coef);
               %[sorted_coefficients,bin_starts]=calculationPopulationScore(obj.features2,2,obj.pop_coef);

                if(obj.num_pca<size(obj.orig_features,2))
                    %Takes the first num_pca as new feature vectors of all
                    %cells
                    [obj.coeff_all,features,dummy3]=princomp(zscore(obj.orig_features));
                    features=features(1:obj.num_pca);
                else
      
features = nanzscore(obj.orig_features);

%Take median of all columns
total_med=nanmedian(features());
              col_med=NaN(24,20);
              row_med=NaN(16,20);    
%                        for(col=1:max(obj.BASICDATA1.WellCol))
%                        
%                                      col_cells=find(obj.BASICDATA1.WellCol==col);
%                                 matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(col_cells);
%                 matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
%                 col_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
%                             %features(col_cells,:)=bsxfun(@minus,features(col_cells,:),nanmedian(features(col_cells,:)));
%                              col_med(col,:)=nanmedian(features(col_cells,:));
%                         end;
%                     for(row=1:max(obj.BASICDATA1.WellRow))
%                         row_cells=find(obj.BASICDATA1.WellRow==row);
%                                 matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(row_cells);
%                 matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
%                 row_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
%                       %  features(row_cells,:)=bsxfun(@minus,features(row_cells,:),nanmedian(features(row_cells,:)));
%                       row_med(row,:)=nanmedian(features(row_cells,:));
%                         
%                     end;
%                     
%                 
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
   %features(:,:)=bsxfun(@minus,features(:,:),nanmedian(features(:,:)));
                               diff_a=(quantile(features(:,:),0.98)-quantile(features(:,:),0.002))/100;

                            %Distrbutions of 20 features across plate
                            for(fc=1:20)
out2{fc}=hist(features(:,fc),quantile(features(:,fc),[0.002]):diff_a(fc):quantile(features(:,fc),0.98))/length(features(:,fc));
                            end;
features1=features;

                  for(col=1:max(obj.BASICDATA1.WellCol))
                                     col_cells=find(obj.BASICDATA1.WellCol==col);
                                matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(col_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                col_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
                median_c(col,:)=nanmedian(features(col_cells,:));
                for(fc=1:20)
                out1=hist(features(col_cells,fc)-nanmean(features(col_cells,fc)),quantile(features(:,fc),[0.002]):diff_a(fc):quantile(features(:,fc),0.98))/length(features(col_cells,fc));
             diff2=abs(out1-out2{fc});
                   out1=hist(features(col_cells,fc),quantile(features(:,fc),0.002):diff_a(fc):quantile(features(:,fc),0.98))/length(features(col_cells,fc));
             diff1=abs(out1-out2{fc});
             if(nanmean(diff2)<nanmean(diff1))
                 sprintf('Column %d corrected feature %d',col,fc)
                
            
                            features1(col_cells,fc)=features(col_cells,fc)-nanmean(features(col_cells,fc));
                end;
                end;
                        end;
                    for(row=1:max(obj.BASICDATA1.WellRow))
                        row_cells=find(obj.BASICDATA1.WellRow==row);
                                matNonTargetingImageIX = obj.BASICDATA1.ImageIndices(row_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                row_cells= ismember(obj.meta(:,6),matNonTargetingImageIX);
                median_r(row,:)=nanmedian(features(row_cells,:));
                            for(fc=1:20)
                out1=hist(features(row_cells,fc)-nanmean(features(row_cells,fc)),quantile(features(:,fc),[0.002]):diff_a(fc):quantile(features(:,fc),0.98))/length(features(row_cells,fc));
             diff2=abs(out1-out2{fc});
             out1=hist(features(row_cells,fc),quantile(features(:,fc),0.002):diff_a(fc):quantile(features(:,fc),0.98))/length(features(row_cells,fc));
             diff1=abs(out1-out2{fc});
             if(nanmean(diff2)<nanmean(diff1))
                 sprintf('Row %d corrected feature %d',row,fc)
           
            
                             features1(row_cells,fc)=features(row_cells,fc)-nanmean(features(row_cells,fc));
                         
                end;
               
                    
                end;
                    end;
                end;
                features=features1;
                clear 'features1';
                count=0;
     gene_names1={};
     
%      for(f=1:20)
%      all_plate=NaN(16,24);
%            for(gene=1:length(obj.gene_names))
%             %Get plate index of gene
%         
%                 %Get index of gene in BASICDATA
%                 basic_index=find(strcmp(obj.BASICDATA1.GeneData,obj.gene_names{gene}));
%                  matGeneImageIX = obj.BASICDATA1.ImageIndices(strcmpi(obj.BASICDATA1.GeneData,obj.gene_names{gene}));
%                             matGeneImageIX = cat(1,matGeneImageIX{:});
%                             matGeneCellIX = ismember(obj.meta(:,6),matGeneImageIX);
%                 all_plate(obj.BASICDATA1.WellRow(basic_index),obj.BASICDATA1.WellCol(basic_index))=mean(features(matGeneCellIX,f));%length(find(abs(features(matGeneCellIX,3))<0.1))/length(features(matGeneCellIX,3));%mean(features(matGeneCellIX,3));
% %                cyto_hit(gene)=cyto_plate{plate_i}(basic_index);
% %               peri_hit(gene)=peri_plate{plate_i}(basic_index);
% %                  plasma_hit(gene)=plasma_plate{plate_i}(basic_index);
% %                     cell_hit(gene)=cell_plate{plate_i}(basic_index);
%            end;
%            figure;
%           % sprintf('Feature %d, Row Correlation:%d,Column correlation:%d',f,corr(repmat([1:16]',24,1),lin(all_plate)),corr(repmat([1:24]',16,1),lin(all_plate')))
%            imagesc(all_plate);
%      end;
     [bootstraped_population]=(find(abs(features(sorted_coefficients(:),1))<2));
  
                obj.output=[];obj.output1=[];obj.output2=[];obj.normal_vector=[];
                
                %Only run SVM if necessary
                if(obj.all_flag)
                    %Create control population
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
%If either 
temp_vec=bin_starts(bin):bin_starts(bin+1);
%size_comp=b

                                 
%Check whether the bin is full
if(length(temp_vec)>1)
treated_population=features(sorted_coefficients(temp_vec(log_treated(bin_starts(bin):bin_starts(bin+1)))),:);
                                  control_population=features(sorted_coefficients(((bin_starts(bin):bin_starts(bin+1)))),:);
                              
%                     treated_population=features(sorted_coefficients((log_treated(:))),:);
%                                                       control_population=features(sorted_coefficients((log_control(:))),:);


obj.coefficient_variation(gene,bin)=sum(std(treated_population,0,2)./abs(mean(treated_population,2)));
                                obj.cells_bin(gene,bin)=size(treated_population,1);
                                % Stop if either of the two poulation has less than 200 cells
                                if((size(treated_population,1)<obj.num_cells))
                                    % sprintf('Cells with perturbed gene %s are not contained in bin %d',gene_names{gene},bin)
                                    continue;
                                end;
                            
                                [obj.normal_vector{count,bin},obj.output1{count,bin},obj.bias{count,bin},obj.average_margin{count,bin}]=calculateSVMBin_Old(obj.gene_names{gene},1,size(treated_population,1));
                                
end;                              
end;
                            end;
                        end;
                        a=1;
                    end;
                    
                    
                end;
                
   
        
    end




