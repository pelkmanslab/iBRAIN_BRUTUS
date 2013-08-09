function [ output_args ] = computeGMM_modules( plate_paths,settings_file)
%Computes a GMM to map single vesicle features to cell features. 
%All vesicle features (Absolute distance, relative distance, Intensity in 9 pixel distance, Intensity in
%15 pixels distance, Radius to cover 40 % intensity,Radius to cover 60 % intensity)
%and the total and mean intensity of the vesicles are normalized per plate 
%by a zscore procedure.Then for cluster sizes between 2 and 15 a random
%subset of 60000 vesicles across all 4 plates is sampled (where the 60000
%is an arbitraty choice). On these set of vesicles a GMM is trained with
%the given number of clusters. The performance of the GMM is recored by
%measuring log likelihood, AIC and BIC on 99 further samples of size 60000. The
%final cluster number is chosen according to the following rule:
%1.At one cluster number the decrease in BIC is falling below 1/10 of the
%previous difference: Choose this cluster number unless it higher than 8 in this
%case 8 is chosen.
%If there is never a steep choice there are two alternatives either the
%true number of clusters is higher or the assumptions of gaussian
%mixture models are not satisfied. Since we cannot rule out possibility 2
%we arbitrarily fix the number of clusters to 6.
%
%Input
%plate_paths:Paths of plates to bootrap vesicles from
%settings_file: Path to multivariate settings
%
%Output: The ouput file contains the variables 'log_like', 'AIC' and 'BIC' which are always 15x100 (number of clusters x number of samples). They hold the respective value of those 3 criteria for all cluster and sample combinations. 
% The variable 'results' contains the 15 trained GMMs (which can be readily
% used in MATLAB code).
%  plate_paths={'Y:\Prisca\endocytome\090217_A431_w2Tf_w3EEA1\090217_A431_Tf_EEA1_CP392-1ae\BATCH'};
% % % % batch_out='\BIOL\imsb\fs3\bio3\bio3\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%    settings_file='Y:\Prisca\endocytome\090217_A431_w2Tf_w3EEA1\multivariate_settings_EEA1Ves.txt';
if(nargin==2)
%There are some arguments

 
% %   vesicle_file='Measurements_Vesicles_CustomSingleEEA1Ves.mat';
% % 
% input_path=strcat('C:\Users\heery\Desktop\current_code\pca_stick\','general_inputfile.txt');
% assay_path='Y:\Prisca\endocytome\090403_A431_w2GM1_w3Dextran';
% 
%   plate_paths={'Y:\Prisca\endocytome\090403_A431_w2GM1_w3Dextran\090403_A431_Dextran_GM1-CP392-1ag\BATCH'};
% % % % % batch_out='\BIOL\imsb\fs3\bio3\bio3\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH';
%    settings_file='Y:\Prisca\endocytome\090403_A431_w2GM1_w3Dextran\multivariate_settings_DextranVes.txt';
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
    vesicle_file=strcat('Measurements_Vesicles_CustomSingle',vesicle_names2,'.mat');  
    gmm_file=strcat('Measurements_GMM_CustomGMM',vesicle_names2,'.mat');
    %     prob_file=npc(strcat(assay_path,'/','ProbModel_Settings_Minimal.txt'));
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
    vesicles=NaN(num_vesicles,8);
    global_count=1;
    mu=NaN(4,8);
    sigma=NaN(4,8);
    %Load all vesicle data and zscore data to obtain their averages and
    %standard deviations
    for(plate=1:length(plate_paths))
        %Derive path of vesicle and cell file using the assay and the plate
        %indices
        load(npc(strcat(plate_paths{plate},'\','Measurements_',vesicle_names,'_Parent.mat')));
        parents1=eval((strcat('handles.Measurements.',vesicle_names,'.Parent')));
        load(npc(strcat(plate_paths{plate},'\','Measurements_',vesicle_names,'_Intensity_',channel_names,'.mat')));
        vesicle_intensity=eval((strcat('handles.Measurements.',vesicle_names,'.Intensity_',channel_names)));
        vesicle_path=(strcat(plate_paths{plate},'\',vesicle_file)) 
        load(npc(strcat(plate_paths{plate},'\',vesicle_file)));
        vesicle_custom=eval((strcat('handles.Measurements.Vesicles.',vesicle_names)));
        clear('handles')
        %Count total number of vesicles in current plate
        num_vesicles=sum(cellfun(@(x) size(x,1),parents1));
        %Array keeping the vesicle features of all vesicles of a plate
        vesicle_plate=NaN(num_vesicles,8);
        vesicle_count=1;
        num_images=min([length(vesicle_custom),length(vesicle_intensity),length(parents1)]);
        for(image=1:num_images)
            temp_intensity=vesicle_intensity{image};
            temp_vesicle=vesicle_custom{image};
            if(~isempty(temp_vesicle))
                
                %Fill in  the two intensity measurements
                vesicle_plate(vesicle_count:vesicle_count+size(vesicle_intensity{image},1)-1,1:2)=temp_intensity(:,1:2);
                %Get non nan vesicle indices for current batch of vesicles
                %used later to position the vesicles 
                I_source=(~isnan(temp_vesicle(:,8)));
                I_batch=temp_vesicle(I_source,8);
                if(~isempty(I_batch))
                    %Just copy absolute distance, Intensity in 9 and 15
                    %pixel distance,Radius to cover 40 % and 60 % distance.
                    %and relative distance. Vesicle index and cell index
                    %(both within current image) are not copied.
                    vesicle_plate(vesicle_count+I_batch-1,3:8)=temp_vesicle(I_source,[1,2,3,4,5,7]);
                end;
                %Increment vesicle_count for the next image
                vesicle_count=vesicle_count+size(vesicle_intensity{image},1);
            end;
        end;
        [IX,IY]=find(isnan(vesicle_plate));
        vesicle_plate(IX,:)=[];
        %zscore vesicles per plate to account for plate effects which areb there
        %for intensity values
        [vesicles(global_count:global_count+size(vesicle_plate,1)-1,:),mu(plate,1:8),sigma(plate,1:8)]=zscore(vesicle_plate);
        %Inactiviated code to check vesicle feature distributions
        %         figure;
        %         hold on;
        %         for(jj=1:8)
        %             subplot(3,3,jj)
        %             hold on;
        %         histfit(vesicles(global_count:global_count+size(vesicle_plate,1)-1,jj));
        %         end;
        %         hold off;
        global_count=global_count+size(vesicle_plate,1);
        %Inactivated code to check vesicle feature distribution in a PCA
        %induced 2D space
        %         [pc,score,latent,tsquare] = princomp(vesicles(global_count:global_count+size(vesicle_plate,1)-1,:));
        %         biplot(pc(:,1:2)*4,'Scores',score(randi([1 size(vesicle_plate,1)],200,1),1:2));
        %         options = statset('Display','final');
        % obj = gmdistribution.fit(score(randi([1 size(vesicle_plate,1)],200,1),1:2),3,'Options',options)
        % 
        % h = ezcontour(@(x,y)pdf(obj,[x y]),[-8 8],[-8 8])
        clear('vesicle_plate');
        clear('vesicle_intensity');
        clear('vesicle_custom');
        clear('parents1');

    end;

else
    %We are in test case mode, generate 200000 vesicles with coming from
    %and 8D multivariate normal distribution having integer means between 1
    %and 10 and a random covariance
    
    %Generate sigma as a random diagonal matrix
    vesicles=[];
    mu=randi([1 10],6,8);
    for(i=1:6)
    vesicles=[vesicles;mvnrnd(mu(i,:),2*eye(8,8),30000)];
        end;
    global_count=179999;
end;

    results=cell(15,1);
    for(num_cluster=2:15)
        num_cluster
        for(boot=1:100)
            %Train GMM in first iteration
            if((boot==1))
                try
                    global_count-1
                    %
                    %Take a large sample this should diminsh any sampling effects
                    results{num_cluster}=gmdistribution.fit(vesicles(randi([1 global_count-1],min(60000,global_count-1),1),[1,2,3,4,5,6,7,8]),num_cluster,'Regularize',0.0000001,'Replicates',20,'CovType','diagonal');
                catch err
                    err.message
                    %Go to next cluster
                    break;
                end;

            end;
                res=results{num_cluster};
                AIC(num_cluster,boot)=res.AIC;
                %Just get log likelihood in all further samples
                [~,log_like(num_cluster,boot)]=cluster(res,vesicles(randi([1 global_count-1],min(60000,global_count-1),1),1:8));
                %BIC computation according to official formula
                BIC(num_cluster,boot)=2*log_like(num_cluster,boot)+log(min(60000,global_count-1))*(num_cluster*8+(8*(8+1)/2)+num_cluster-1);
           
            
        end;
        
    end;         
    clear('vesicles');
    if(nargin==2)
     save(npc(strcat(plate_paths{1},'/',gmm_file)),'log_like','AIC','BIC','results','mu','sigma');
    else
        figure;
        hold on;
        plot(1:15,BIC);
        xlabel('Cluster number');
        ylabel('BIC');
        results{6}.mu
        mu
        %An automatical comparison of the mu's to the input mu would be
        %nice, currently this is not implemented so compare results{6].mu
        %and mu. In our experience the optimal BIC is close to 6 and also
        %the identified GMM centres match the input centres closely.
        %Sometimes it happens that 2 GMM centres are close to an input
        %centre and that on the other hand a input centre has no GMM match.
    end;

end
