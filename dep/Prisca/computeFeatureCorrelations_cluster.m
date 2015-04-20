
function []=computeFeatureCorrelations_cluster(plate_path,config_file)
%   plate_path=npc('Y:\Prisca\endocytome\090928_A431_w2LAMP1_w3ChtxAW1\090309_A431_Chtx_Lamp1_CP392-1ba\BATCH');
%   config_file=npc('Y:\Prisca\endocytome\090928_A431_w2LAMP1_w3ChtxAW1\RFE_ChtxVes.txt');
% %  output_path1=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP392-1ad/BATCH');
% output_path1='C:\Users\heery\Desktop\test1.txt';
% % output_path='C:\Users\heery\Desktop\test1.txt';
% % global_i=0.25;
% % local_i=00;
% plate_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP395-1ag/BATCH');
% config_file=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/RFE_DextranVes.txt');
% output_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/');
% local_i=1
plate_path
config_file

% global_i=0;
       basic_files=dir(strcat(plate_path,'/*BASICDATA*'))
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;
         [temp_features,tempfeature_names,meta] =getRawProbModelData2(npc(plate_path),npc(config_file));
%Set NaN to zero
NUM_POPULATION_FEATURES=4;
load(npc(strcat(plate_path,'/',basic_path)))
BASICDATA1=BASICDATA;
     %    temp_features(find(temp_features~=temp_features))=0;
         
         orig_features=temp_features(:,NUM_POPULATION_FEATURES:end);
         feature_names=tempfeature_names(NUM_POPULATION_FEATURES:end);
         features=nanzscore(orig_features);
            total_med=nanmedian(features());
num_zero=NaN(max(BASICDATA1.WellCol),size(features,2));
                    %Loop over rows
                    for(col=1:max(BASICDATA1.WellCol))
                                     col_cells=find(BASICDATA1.WellCol==col);
                                matNonTargetingImageIX = BASICDATA1.ImageIndices(col_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                col_cells= ismember(meta(:,6),matNonTargetingImageIX);
                            features(col_cells,:)=bsxfun(@minus,features(col_cells,:),nanmedian(features(col_cells,:)));
                              num_zero(col,:)=arrayfun(@(x) length(find(features(col_cells,x)==0))/length(find(col_cells==1)),1:size(features,2));
%                             
                        end;
                   
                    for(row=1:max(BASICDATA1.WellRow))
                        row_cells=find(BASICDATA1.WellRow==row);
                                matNonTargetingImageIX = BASICDATA1.ImageIndices(row_cells);
                matNonTargetingImageIX = cat(1,matNonTargetingImageIX{:});
                row_cells= ismember(meta(:,6),matNonTargetingImageIX);
                        features(row_cells,:)=bsxfun(@minus,features(row_cells,:),nanmedian(features(row_cells,:)));
                        
                    end;
                    corr_all=corr(features,'rows','pairwise');
                    indices1=strfind(config_file,'_');
                    indices2=strfind(config_file,'.');
%                     delete(strcat(npc(plate_path),'/','Measurements_Correlations_all_.mat'));
%                     delete(strcat(npc(plate_path),'/','Measurements_Correlations_all.mat'));
                    save(strcat(npc(plate_path),'/','Measurements_Correlations_all_',config_file(indices1(end)+1:indices2(end)-1)),'corr_all','feature_names');

end