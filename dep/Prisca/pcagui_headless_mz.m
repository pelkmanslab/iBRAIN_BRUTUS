

%Plot all diagrams with 0.55 as classification treshold,8.8 as upper
%gradient limit and 0.6 as lower 
 %    strRootPath='C:\Users\Ramo\Documents\090203_Mz_Tf_EEA1_CP395\BATCH';
  %strRootPath = 'C:\Users\Ramo\Documents\BATCH-A431_Tf_EEA1_CP395';
         %Tf EEA1
            
            %                 [obj.orig_features,obj.feature_names,obj.meta] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot-all-BATCH-Tf_EEA1_CP395.txt');
            %                 [obj.features2,obj.feature2_names,meta2] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot-BATCH-Tf_EEA1_CP395.txt');
            %                    load(fullfile(strRootPath,'BASICDATA_CP395-5.mat'))
            
            %Lamp
            
      
            %
            
            %Mz-TfEEA1
            %                 [obj.orig_features,obj.feature_names,obj.meta] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot-all-Mz-Tf_EEA1_CP395.txt');
            %                 [obj.features2,obj.feature2_names,meta2] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot-Mz-Tf_EEA1_CP395.txt');
            %                    load(fullfile(strRootPath,'BASICDATA_CP395-4.mat'))
            
            % [features,dummy2,meta] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot-all.txt');
            % [features2,dummy2,meta2] =getRawProbModelData2(strRootPath,'C:\Users\Ramo\Documents\MATLAB\Code\Yanic\pca\ProbModel_Settings_QuantPlot.txt');
            %Do the Same but just for Non-targeting
            % load(fullfile(strRootPath,'BASICDATA_CP395-4.mat'))

clear all;
            plate_paths={'\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP392-1ad\BATCH',...
                         '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP393-1ad\BATCH',...
                         '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP394-1ad\BATCH',...
                         '\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP395-1ad\BATCH'};
                     basic_data={ 'BASICDATA_CP392-4.mat','BASICDATA_CP393-4.mat','BASICDATA_CP394-4.mat','BASICDATA_CP395-4.mat'};
for(i=1:length(plate_paths))
                     pc_ref=pca_test_headless('\\nas-biol-imsb-1\share-3-$\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad',plate_paths{i},'Z:\Data\Users\Yanic\measurement_output\ProbModel_Settings_QuantPlot-all-090203_Mz_Tf_EEA1.txt','Z:\Data\Users\Yanic\measurement_output\ProbModel_Settings_QuantPlot-090203_Mz_Tf_EEA1.txt','Classification',basic_data{i},20,80);
pc_ref.updateGeneList('');
pc_ref.writeOutput();
clear pc_ref;
end;

