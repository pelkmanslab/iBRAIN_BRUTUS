function [ output_args ] = projectGMM_part1( plate_paths,assay_path,settings_file)
%Projects single vesicle features to one cell feature
%The function reads in a reference GMM for all plates of the assay and uses
%it to cluster all vesicles of the plate located in plate_path. For every
%cell the fractions of vesicle being part of the different clusters and the total number of vesicles of the cell is
%stored.
%Input
%plate_paths:Paths of one BATCH directory in which the input vesicle data
%is located
%assay_path:Path to directory containing the reference GMM for all plates
%of the assay
%settings_file: Path to multivariate settings
%
%Output: 
%The projection file is a file containing a handle strucutre for the GMM
%fractions encoded in the usual CellProfiler-like way. Everey row contains
%Number of clusters+1 columns as the fractions of vesicle located in each
%GMM clusters are stored as well as total number of vesicles. When the
% the function has write permission to the POSTANALYSIS folder of the assay we
%also write the fraction distrbituion and vesicle number distributions for all GMM clusters and plates to a
%pdf file. The pdf file also contains number of clusters vs BIC to show the
%course of the BIC criterium.

%  assay_path='Y:\Prisca\endocytome\090217_A431_w2Tf_w3EEA1';
% 
%    plate_paths={'Y:\Prisca\endocytome\090217_A431_w2Tf_w3EEA1\090217_A431_Tf_EEA1_CP392-1ae\BATCH'};
% % % % % batch_out='\BIOL\imsb\fs3\bio3\bio3\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%     settings_file='Y:\Prisca\endocytome\090217_A431_w2Tf_w3EEA1\multivariate_settings_TfVes.txt';
%   vesicle_file='Measurements_Vesicles_CustomSingleEEA1Ves.mat';
% % 
% input_path=strcat('C:\Users\heery\Desktop\current_code\pca_stick\','general_inputfile.txt');

    [fid, message] = fopen(npc(settings_file));
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
    vesicle_names=multivariate_config.vesicle.vesicle_names;
    vesicle_names2=multivariate_config.vesicle.vesicle_names2;
    channel_names=multivariate_config.vesicle.channel_names
    %     vesicle_file=multivariate_config.vesicle.vesicle_file;
    prob_file=multivariate_config.setting_file;
    %     gmm_file=multivariate_config.gmm.gmm_file;
    projection_file=strcat('Measurements_Cells_',vesicle_names2,'GMM','_new.mat');
    analysis_path=strrep(plate_paths,strcat(filesep,'BATCH'),strcat(filesep,'POSTANALYSIS'));
    vesicle_file=strcat('Measurements_Vesicles_CustomSingle',vesicle_names2,'.mat');  
    gmm_file=strcat('Measurements_GMM_CustomGMM',vesicle_names2,'_new.mat');
    gmm_file1=strcat('Measurements_GMM_CustomGMM',vesicle_names2,'.mat');
    [fid, message] = fopen((settings_file));
    if fid == (-1)
        error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', filename, message);
    end

    try
        % read file
        out = fread(fid,'*char')';
    catch exception
        % close file
        fclose(fid);
	throw(exception);
    end

    % close file
    fclose(fid);
    eval(out);
    vesicles=[];
    %Allocate space for log likelihood,BIC and AIC
    %criteria for 15 clusters sizes and 100 different test
    %runs of a GMM 
    log_like=NaN(15,100);
    BIC=NaN(15,100);
    AIC=NaN(15,100);
    %Loop over clusters
    vesicle_features1=[];
    count=1;
    indices=strfind(settings_file,filesep);
    last_path_part=settings_file(indices(end)+1:end-4)
    plate_vesicle=1;
    num_vesicles=0;
    
    %Count number of vesicles in all (usually 4 ) plates using the
    %ObjectCount measurements
    for(plate=1:length(plate_paths))
        load(npc(strcat(plate_paths{plate},'\','Measurements','_Image_ObjectCount.mat')));
        vesicle_index=find(strcmp(handles.Measurements.Image.ObjectCountFeatures,vesicle_names)); 
        %Count total number of vesicles in current plate
        num_vesicles=num_vesicles+sum(cellfun(@(x) x(vesicle_index),handles.Measurements.Image.ObjectCount));
    end;
    %     vesicles=NaN(num_vesicles,8);
    global_count=1;
    mu=NaN(4,8);
    sigma=NaN(4,8);

    load(npc(strcat(plate_paths{1},'/',gmm_file1)));
    mu1=mu;
    sigma1=sigma;
    load(npc(strcat(assay_path,'/',gmm_file)));
    %Coompute average BIC per Cluster and inter cluster BIC differences 
    BIC=nanmean(BIC,2);
    %Computee differences pf BIC criteria upon increasing the number of
    %clusters
    
    diff_bic=arrayfun(@(x) BIC(x)-BIC(x-1),3:length(BIC))
    diff_bic=diff_bic/min(diff_bic)
    min_index=find(smooth(diff_bic)<1/10,1,'first')
    %Take the cluster haivng less than 1/5 of the previousd differences or at
    %most 8 clusters. Most clusters we obtained thereby made biological sense.

    if(isempty(min_index)) 
        min_index=find(smooth(diff_bic)<1/5,1,'first')
    end;
    if(~isempty(min_index))
        min_index=min(8,min_index);
    else
        %Take an arbitray number of 6 clusters

        min_index=6;
    
    end;
    
diff_bic=BIC(2:15)-BIC(1:14);
[~,min_index]=min(diff_bic(3:14));
min_index=min_index+2;
if(min_index>8)
    min_index=8;
end;
% min_index=size(results{min_index}.mu,1);
%      if(min_index==1)
%         min_index=6;
%     end;

    %Use GMM and project all vescles to of each cleaned up cell to fractions
    %of gaussians
    texture_cell=cell(size(results{min_index}.mu,1)+1,1);
    for(nc=1:size(results{min_index}.mu,1))
        texture_cell{nc}=sprintf(' Cluster%d',nc);
    end;
    texture_cell{size(results{min_index}.mu,1)+1}='Number of vesicles';

    %Now we load agin the plate. This seems like a redundant step as we loaded
    %the data perviously. However, in this step we work per plate (and not using all
    %plates at the same time) which reduces memory and swap consumption quite a
    %bit. In our hands we observed main memroy erductions of up to 50 % (at the
    %expendse of longer runtime)
    
    for(plate=1:length(plate_paths))
        load(npc(strcat(plate_paths{plate},'\','Measurements_Image_ObjectCount.mat')));
        object_features=eval('handles.Measurements.Image.ObjectCountFeatures');
        object_count=eval('handles.Measurements.Image.ObjectCount');
        object_count=cat(1,object_count{:});
        object_count=object_count(:,find(strcmp('Cells',object_features)));
        [~,~,meta] =getRawProbModelData2((plate_paths{plate}),npc(prob_file));
        %Load vesicle measurements
        load(npc(strcat(plate_paths{plate},'\','Measurements_',vesicle_names,'_Parent.mat')));
        parents1=eval((strcat('handles.Measurements.',vesicle_names,'.Parent')));
        load(npc(strcat(plate_paths{plate},'\','Measurements_',vesicle_names,'_Intensity_',channel_names,'.mat')));
        vesicle_intensity=eval((strcat('handles.Measurements.',vesicle_names,'.Intensity_',channel_names)));
        vesicle_path=(strcat(plate_paths{plate},'\',vesicle_file)) 
        load(npc(strcat(plate_paths{plate},'\',vesicle_file)));
        vesicle_custom=eval((strcat('handles.Measurements.Vesicles.',vesicle_names)));
        clear('handles');
        %Count total number of vesicles in current plate
        num_vesicles=sum(cellfun(@(x) size(x,1),parents1));
        vesicle_plate=NaN(num_vesicles,9);
        vesicle_count=1;
        cell_features=cell(length(parents1),1);
        num_images=min([length(vesicle_custom),length(vesicle_intensity),length(parents1)]);
        for(image=1:num_images)
            temp_intensity=vesicle_intensity{image};
            temp_vesicle=vesicle_custom{image};
            %Check that image contains vesicles
            if(~isempty(temp_vesicle)&&(~isempty(parents1{image})))
                parents=parents1{image};
                vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:2)=temp_intensity(:,1:2);
                %
                %Use column 8 (index of vesicle in image) to put the the
                %derived vesicle features into the correct rows
                I_source=find(~isnan(temp_vesicle(:,8)));
                I_batch=temp_vesicle(I_source,8);
                if(~isempty(I_batch))
                    vesicle_plate(vesicle_count+I_batch-1,3:9)=temp_vesicle(I_source,[1,2,3,4,5,7,6]);
                end;
                %zscore vesicles of the plate using the previiusly stored
                %mu and sigma value. Note that 9. column is not zscored as
                %it contains the cell index of the vesicle
                vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:8)=bsxfun(@minus, vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:8),mu1(plate,:));
                vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:8)=bsxfun(@rdivide,vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:8),sigma1(plate,:));
                %zscore vesicle data
                good_cells=meta(find((meta(:,6)==image)),7);
                temp_data=NaN(object_count(image),size(results{min_index}.mu,1)+1);
                cell_count=1;
                good_cells=unique(temp_vesicle(:,6));
                good_cells(find(good_cells~=good_cells))=[];
                PARENT_SEL=2;
                if(size(parents,2)==1)
                    %Switch for EGF vesicles
                    PARENT_SEL=1;
                end;
                %This a is a complex expression looping over all cells and their
                %associated vesicles. Each such vesicle group is projected with
                %cluster to a set of cluster indices. This set of cluster indices
                %is scored for abundance of each cluster using histc
%                  try
       
                t=arrayfun(@(cell1) [transpose(histc(cluster(results{min_index},vesicle_plate(vesicle_count-1+find(vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,9)==cell1),1:8)),1:size(results{min_index}.mu,1),1)/length(find(parents(:,PARENT_SEL)==cell1))),length(find(parents(:,PARENT_SEL)==cell1))],good_cells,'UniformOutput',false);
           
%     catch exception
%         % close file
%        sprintf('Image is %d',image)
% 	throw(exception);
%     end
                if(~isempty(good_cells))
                    temp_data(good_cells,:)=cat(1,t{:},[]);
                end;
                cell_features{image}=temp_data(:,1:size(results{min_index}.mu,1)+1);
                vesicle_count=vesicle_count+size(vesicle_intensity{image},1);
                
            else
                %If there are no cells allocate one empty cell with just zeros
                %cell_features{image}=zeros(1,length(texture_cell));
            end;
        end;
        %PCA on all vesicles of the plate+GMM centres
        [IX,IY]=find(isnan(vesicle_plate));
        vesicle_plate(IX,:)=[];
                  [pc,score,latent,tsquare] = princomp([vesicle_plate(:,1:8);results{min_index}.mu]);
                 h=figure;
                 hold on;
                 rand_indices=randi([1 size(vesicle_plate,1)],200,1);
                     %Draw 200 random vesicles in black
                 scatter(score(rand_indices,1),score(rand_indices,2),[],'k');
                 %Draw the GMM centres in red
                 rand_indices=size(vesicle_plate,1)+1:size(vesicle_plate,1)+size(results{min_index}.mu,1);
                 
                 scatter(score(rand_indices,1),score(rand_indices,2),[],'r');
                
        gcf2pdf(npc(analysis_path{1}),'gmm_clusters');
         close(h);
                 handles=struct('Measurements',struct('Cells',struct(strcat(vesicle_names2,'GMMFeatures'),{texture_cell},strcat(vesicle_names2,'GMM'),{cell_features'})));
        sprintf('Cluster finished')
        save(npc(strcat(plate_paths{plate},'/',projection_file)),'handles');  
        %Put single cell gmm features into one matrix
        cell_features1=cat(1,[],cell_features{:});
        %-Histrogram of GMM of the cells to see distribution of clusters
        figure;
        hold on;
        subplot(2,2,1);hold on;
        boxplot(bsxfun(@times,cell_features1(:,1:min_index),cell_features1(:,min_index+1)));
        title(sprintf('Distribution of vesicle numbers for all clusters from 1 to %d',min_index+1));
        subplot(2,2,2);
        hold on;
        result_gmm=results{min_index};
        imagesc(result_gmm.mu)
        title('GMM cluster means')
        xlabel('Vesicle features')
        ylabel('GMM Clusters')
        subplot(2,2,3);
        hold on;
        plot(1:length(BIC),BIC)
        title('GMM clusters vs BIC');
        xlabel('Number of clusters');
        ylabel('BIC');
        %         gcf2pdf(analysis_path{plate},'vesicle_report.pdf','overwrite')
        %Memory clearup to reduce memory footprint
        clear('vesicle_plate');
        clear('vesicle_intensity');
        clear('vesicle_custom');
        clear('parents1');
    end;
end
