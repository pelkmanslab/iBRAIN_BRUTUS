%This script gives a full report on all aspects of an assay. The following
%aspects are reported:
% -Feature distribution of all 4 plates of all 8 vesicle features
%-Plate effect of all GMM classes for all 4 plates
%-GMM class distribution with vesicle fraction 
%-GMM centres embedded in PCA of 4 plate samples
%-Nonhit and hit classification accuracy curves for all 4 plates
%-Heatmap showing ranks of removed features in all 4 plates
%-Classification vs Margin in 4 colors
%-Plate effect of multivariate distance
%-Multivariate distance distributions
%-BIC of cluster of size 2-15 (if possible)
function []=finalReport(assay)
%         assay=6;
% input_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/multivariate_settings_LampVes.txt';
 plate_paths={   
            '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1',...
       '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1',...
  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1', ...
  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1', ...
              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130', ...
                    '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130', ...
  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1',  ...
   '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1',  ...
  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran', ...
  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091127_A431_w3ChtxAW2',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1',...
                       '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091113_A431_w3GPIGFP',...
        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100402_A431_w3Macro',...
        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF'
         };
            
            
%             'Y:\Prisca\endocytome\090203_MZ_w2Tf_w3EEA1\090203_Mz_Tf_EEA1_CP392-1ad\BATCH',...
%                          'Y:\Prisca\endocytome\090203_MZ_w2Tf_w3EEA1\090203_Mz_Tf_EEA1_CP393-1ad\BATCH',...
%                          'Y:\Prisca\endocytome\090203_MZ_w2Tf_w3EEA1\090203_Mz_Tf_EEA1_CP394-1ad\BATCH',...
%                          'Y:\Prisca\endocytome\090203_MZ_w2Tf_w3EEA1\090203_Mz_Tf_EEA1_CP395-1ad\BATCH', ...
plate1_paths={    '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP392-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP393-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP394-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP392-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP393-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP394-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH', ...
       '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP392-1ba/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP393-1ba/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH', ...
                           '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP395-1ba/BATCH', ...
                              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP392-1ba/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP393-1ba/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH', ...
                           '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090928_A431_w2LAMP1_w3ChtxAW1/090309_A431_Chtx_Lamp1_CP395-1ba/BATCH', ...
              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP392-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP393-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP394-1af/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP395-1af/BATCH', ...
              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP392-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP393-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP394-1af/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090309_A431_w2ChtxNAW_w3GM130/090309_A431-Chtx-GM130-CP395-1af/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP392-1ae/BATCH',  ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP393-1ae/BATCH', ...
                             '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP394-1ae/BATCH' , ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP395-1ae/BATCH', ...
                               '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP392-1ae/BATCH',  ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP393-1ae/BATCH', ...
                             '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP394-1ae/BATCH' , ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090217_A431_w2Tf_w3EEA1/090217_A431_Tf_EEA1_CP395-1ae/BATCH', ...
 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP392-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP393-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP394-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP395-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP392-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP393-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP394-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP395-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091127_A431_w3ChtxAW2/091127_A431_Chtx_Golgi_AcidWash_CP392-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091127_A431_w3ChtxAW2/091127_A431_Chtx_Golgi_AcidWash_CP393-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091127_A431_w3ChtxAW2/091127_A431_Chtx_Golgi_AcidWash_CP394-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091127_A431_w3ChtxAW2/091127_A431_Chtx_Golgi_AcidWash_CP395-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP392-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP393-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP394-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP395-1bi/BATCH',...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP392-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP393-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP394-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP395-1ba/BATCH',...
                                              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP392-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP393-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP394-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100224_A431_w2EGF_w3CAV1/100224_A431_EGF_Cav1_CP395-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091113_A431_w3GPIGFP/091113_A431GPIGFP_CP392-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091113_A431_w3GPIGFP/091113_A431GPIGFP_CP393-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091113_A431_w3GPIGFP/091113_A431GPIGFP_CP394-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/091113_A431_w3GPIGFP/091113_A431GPIGFP_CP395-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100402_A431_w3Macro/100402_A431_Macropinocytosis_CP392-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100402_A431_w3Macro/100402_A431_Macropinocytosis_CP393-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100402_A431_w3Macro/100402_A431_Macropinocytosis_CP394-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100402_A431_w3Macro/100402_A431_Macropinocytosis_CP395-1bd/BATCH',...
                                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF/110721_MZ_w2EGF-CP392-2ar/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF/110721_MZ_w2EGF-CP393-2ar/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF/110721_MZ_w2EGF-CP394-2ar/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF/110721_MZ_w2EGF-CP395-2ar/BATCH' };
                     load_strings={'Measurements_Classification6bin_RFEcp395_TfVes_v2','Measurements_Classification6bin_RFEcp395_EEA1Ves_v2','Measurements_Classification6bin_RFEcp395_ChtxVes_v2','Measurements_Classification6bin_RFEcp395_LampVes_v2','Measurements_Classification6bin_RFEcp395_ChtxVes_v2','Measurements_Classification6bin_RFEcp395_GM130Ves_v2','Measurements_Classification6bin_RFEcp395_EEA1Ves_v2','Measurements_Classification6bin_RFEcp395_TfVes_v2','Measurements_Classification6bin_RFEcp395_DextranVes_v2','Measurements_Classification6bin_RFEcp395_GM1Ves_v2','Measurements_Classification6bin_RFEcp395_ChtxVes_v2','Measurements_Classification6bin_RFEcp395_LDLVes_v2','Measurements_Classification6bin_RFEcp395_EGFVes_v2','Measurements_Classification6bin_RFEcp395_CavVes_v2','Measurements_Classification6bin_RFEcp395_GPIVes_v2','Measurements_Classification6bin_RFEcp395_MacroVes_v2','Measurements_Classification6bin_RFEcp395_EGFVes_v2'};
                     load_strings2={'Measurements_Classification6bin_RFEcp395_TfVes','Measurements_Classification6bin_RFEcp395_EEA1Ves','Measurements_Classification6bin_RFEcp395_ChtxVes','Measurements_Classification6bin_RFEcp395_LampVes','Measurements_Classification6bin_RFEcp395_ChtxVes','Measurements_Classification6bin_RFEcp395_GM130Ves','Measurements_Classification6bin_RFEcp395_EEA1Ves','Measurements_Classification6bin_RFEcp395_TfVes','Measurements_Classification6bin_RFEcp395_DextranVes','Measurements_Classification6bin_RFEcp395_GM1Ves','Measurements_Classification6bin_RFEcp395_ChtxVes','Measurements_Classification6bin_RFEcp395_LDLVes','Measurements_Classification6bin_RFEcp395_EGFVes','Measurements_Classification6bin_RFEcp395_CavVes','Measurements_Classification6bin_RFEcp395_GPIVes','Measurements_Classification6bin_RFEcp395_MacroVes','Measurements_Classification6bin_RFEcp395_EGFVes'};
                     load_strings3={'Measurements_Classification6bin_RFEcp395_TfVes_v3','Measurements_Classification6bin_RFEcp395_EEA1Ves_v3','Measurements_Classification6bin_RFEcp395_ChtxVes_v3','Measurements_Classification6bin_RFEcp395_LampVes_v3','Measurements_Classification6bin_RFEcp395_ChtxVes_v3','Measurements_Classification6bin_RFEcp395_GM130Ves_v3','Measurements_Classification6bin_RFEcp395_EEA1Ves_v3','Measurements_Classification6bin_RFEcp395_TfVes_v3','Measurements_Classification6bin_RFEcp395_DextranVes_v3','Measurements_Classification6bin_RFEcp395_GM1Ves_v3','Measurements_Classification6bin_RFEcp395_ChtxVes_v3','Measurements_Classification6bin_RFEcp395_LDLVes_v3','Measurements_Classification6bin_RFEcp395_EGFVes_v3','Measurements_Classification6bin_RFEcp395_CavVes_v3','Measurements_Classification6bin_RFEcp395_GPIVes_v3','Measurements_Classification6bin_RFEcp395_MacroVes_v3','Measurements_Classification6bin_RFEcp395_EGFVes_v3'};
%Open multivariate settings file

                     num_plates=4
                              vesicle_strings6={'TfVes','EEA1Ves','ChtxVes','LampVes','ChtxVes','GM130Ves','EEA1Ves','TfVes','DextranVes','GM1Ves','ChtxVes','LDLVes','EGFVes','CavVes','GPIVes','MacroVes','EGFVes'};
selected_assays1=[1,4,6,7,8,9,10,11,12,13,15,16,17]; 

     if(~ismember(assay,  selected_assays1  ))
         return;
     end;
     input_path=strcat(plate_paths{assay},'/','multivariate_settings_',vesicle_strings6{assay},'.txt');
                     [fid, message] = fopen(npc(input_path));
    if fid == (-1)
        error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', npc(input_path), message);
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
    %set parameters
    vesicle_names=multivariate_config.vesicle.vesicle_names
    channel_names=multivariate_config.vesicle.channel_names
    if(strcmp(multivariate_config.vesicle.channel_names,'RescaledGreen'))
    channels=2
    else
        channels=3
    end;
    if(isfield(multivariate_config.vesicle,'vesicle_file'))
%         vesicle_file=multivariate_config.vesicle.vesicle_file;
        vesicle_file=strcat('Measurements_Vesicles_CustomSingle',multivariate_config.vesicle.vesicle_names2,'.mat');    
    else
        vesicle_file=strcat('Measurements_Vesicles_CustomSingle',multivariate_config.vesicle.vesicle_names2,'.mat');    
    end;
    if(isfield(multivariate_config.vesicle,'cell_file'))
%         cell_file=multivariate_config.vesicle.cell_file;
        cell_file=strcat('Measurements_Cells_CustomSingle',multivariate_config.vesicle.vesicle_names2,'.mat');    
    else
        cell_file=strcat('Measurements_Cells_CustomSingle',multivariate_config.vesicle.vesicle_names2,'.mat');    
    end;
    %Figure to contain all of the subsequent assay plots
    figure;
    hold on;
    fig_count=0;
    plate_color={'r','b','k','g'};
    %Load vesicle data and concatenate,Note that it only contains vesicles
    %from cleaned up cells
    vesicle_features=[];
    plate_limit(1)=1;
    vesicle_names=multivariate_config.vesicle.vesicle_names;
    vesicle_names2=multivariate_config.vesicle.vesicle_names2;
    channel_names=multivariate_config.vesicle.channel_names
    vesicle_file=strcat('Measurements_Vesicles_CustomSingle',vesicle_names2,'.mat');  
    gmm_file=strcat('Measurements_GMM_CustomGMM',vesicle_names2,'.mat');
    %     prob_file=npc(strcat(assay_path,'/','ProbModel_Settings_Minimal.txt'));

    eval(out);
    %Only run vesicle reports for non GM1 asssays
    if(assay~=10)
        
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
    
    plate_vesicle=1;
    num_vesicles=0;
    
    %Count number of vesicles in all (usually 4 ) plates using the
    %ObjectCount measurements
    for(plate=1:num_plates)
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'\','Measurements','_Image_ObjectCount.mat')));
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
    for(plate=1:num_plates)
        %Derive path of vesicle and cell file using the assay and the plate
        %indices
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'\','Measurements_',vesicle_names,'_Parent.mat')));
        parents1=eval((strcat('handles.Measurements.',vesicle_names,'.Parent')));
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'\','Measurements_',vesicle_names,'_Intensity_',channel_names,'.mat')));
        vesicle_intensity=eval((strcat('handles.Measurements.',vesicle_names,'.Intensity_',channel_names)));
        
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'\',vesicle_file)));
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

        global_count=global_count+size(vesicle_plate,1);
     plate_limit(plate+1)=plate_limit(plate)+size(vesicle_plate,1)-1;
         clear('vesicle_plate');
        clear('vesicle_intensity');
        clear('vesicle_custom');
        clear('parents1');

    end;

 
    
    %Loop over all vesicles to display distributions of every vesicle
    %feature
    for(f=[1,2,3,4,5,6,7,8])
        fig_count=fig_count+1;
           subplot(5,8,fig_count);
           hold on;
        %Plot vesicles coming from the different plates in red,black,green
        %and blue
        for(plate=1:num_plates)
            max_f=quantile(vesicles(plate_limit(plate):plate_limit(plate+1),f),0.97);
                        min_f=quantile(vesicles(plate_limit(plate):plate_limit(plate+1),f),0.05);

        [count,~]=hist(vesicles(plate_limit(plate):plate_limit(plate+1),f),min(min_f,-1.5):0.05:max_f);
        rangex=min(min_f,-1.5):0.05:max_f;
        plot(rangex(2:end-1),count(2:end-1),plate_color{plate});
        title(sprintf('Vesicle feature %d',f),'FontSize', 8);
        end;
        axis tight;
    end;
    
 %Now we load the assaz wide GMM and draw the centres of this GMM ina  PCA space of the all vesicles from all plates.        
 %RFE part
   load(npc(strcat(plate_paths{assay},'/','Measurements_GMM_CustomGMM',vesicle_strings6{assay},'_new.mat')));
   %Compute the right cluster size
    BIC=nanmean(BIC,2);
 diff_bic=arrayfun(@(x) BIC(x)-BIC(x-1),3:length(BIC))
 diff_bic=diff_bic/min(diff_bic)
 min_index=find(smooth(diff_bic)<1/10,1,'first')
 if(isempty(min_index)) 
   min_index=find(smooth(diff_bic)<1/5,1,'first')
 end;
 if(~isempty(min_index))
 min_index=min(8,min_index);
 else
     min_index=6;
 end;
 diff_bic=(BIC(2:15)-BIC(1:14));
[~,min_index]=min(diff_bic(3:14));
min_index=min_index+2;
if(min_index>8)
    min_index=8;
end;
% min_index=size(results{min_index}.mu,1);
    fig_count=fig_count+1;
        subplot(5,8,fig_count)
        hold on;
        title('Number of clusters vs BIC derivative','FontSize',8);
        %Show BIC curve of current plate
        plot(diff_bic);
        
        hold on;
%   if(min_index==1)
%         min_index=6;
%     end;
 %Take PCA on a large random of vesicles

 vesicles1=[];
 for(plate=1:num_plates)
 vesicles1=[vesicles1;vesicles(randi([plate_limit(plate) plate_limit(plate+1)],50000,1),1:8)];
 end;
 clear('vesicles');
 %Generate 200000 vesicles distrbuted according to a Gaussian of the GMM
 %the fraction of vesicle in each cluster are detrmined bz the fill levels
 %of each cluster
 random_vesicles=NaN(50000*num_plates+9,8);
 random_count=ones(size(results{min_index}.mu,1)+1,1);
 for(clus=1:size(results{min_index}.mu,1))
     num_random=floor(results{min_index}.PComponents(clus)*50000*num_plates)+1;
     random_vesicles(random_count(clus):random_count(clus)+num_random-1,:)=mvnrnd(results{min_index}.mu(clus,:),results{min_index}.Sigma(:,:,clus),num_random);
 random_count(clus+1:end)=random_count(clus+1:end)+num_random;
 end;

   [pc,score,latent,tsquare] = princomp([vesicles1(:,1:8);random_vesicles(1:50000*num_plates,:)]);
  %Get class of every vesicle
  cluster_indices=cluster(results{min_index},[vesicles1(:,1:8);results{min_index}.mu]);
                  fig_count=fig_count+1;
        subplot(5,8,fig_count)
        hold on;
        cluster_color=[1 1 0
            1 1 1 
            0 0 1
            1 0 0
             0 1 0
             1 0 1
             0 1 1
             ];


%                  axis tight;
                 title('GMM centres','FontSize',8);
                 %Save old color map
               hold on;
                old_map=colormap;
                       matColorMap = imresize([flipud(redbluecmap)],[255,3],'lanczos2');
matColorMap(matColorMap>1)=1;
matColorMap(matColorMap<0)=0;
                 colormap(matColorMap);
                 freezeColors;
                 minx=100;
                 miny=100;
                 maxx=0;
                 maxy=0;
                 
n = hist3(score(1:50000*num_plates,1:2),{quantile(score(:,1),0):0.3:quantile(score(:,1),1),quantile(score(:,2),0):0.3:quantile(score(:,2),1)}); % Extract histogram data;
                % default to 10x10 bins
n1 = n'; 
% n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 




xb = linspace(min(score(:,1)),max(score(:,1)),size(n,1));
yb = linspace(min(score(:,2)),max(score(:,2)),size(n,2));

 num_elem=sum(sum(n));
n1=n1/sum(sum(n));
%  pcolor(xb,yb,n1);
imagesc(n1);
 max_elem=max(max(n1));

  
 axis tight;
 %Loop over clusters and display clusters
 for(clus=1:size(results{min_index}.mu,1))
     fig_count=fig_count+1;
        subplot(5,8,fig_count)
         hold on;
         matColorMap = imresize([flipud(redbluecmap)],[255,3],'lanczos2');
matColorMap(matColorMap>1)=1;
matColorMap(matColorMap<0)=0;
                 colormap(matColorMap);
                 freezeColors;
                         title(sprintf('Cluster %d',clus),'FontSize',8);
             sel_indices=find(cluster_indices==clus);
                 
n = hist3(score(sel_indices,1:2),{quantile(score(:,1),0):0.3:quantile(score(:,1),1),quantile(score(:,2),0):0.3:quantile(score(:,2),1)}); % Extract histogram data;
                % default to 10x10 bins

                n1 = [n'/num_elem,zeros(size(n',1),1)+max_elem]; 
% n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 




xb = linspace(min(score(:,1)),max(score(:,1)),size(n,1));
yb = linspace(min(score(:,2)),max(score(:,2)),size(n,2));



%  pcolor([xb,xb(end)+1],yb,n1);
  imagesc(n1);
 
 axis tight
 end;
  for(clus=1:size(results{min_index}.mu,1))
     fig_count=fig_count+1;
        subplot(5,8,fig_count)
         hold on;
         matColorMap = imresize([flipud(redbluecmap)],[255,3],'lanczos2');
matColorMap(matColorMap>1)=1;
matColorMap(matColorMap<0)=0;
                 colormap(matColorMap);
                 freezeColors;
                         title(sprintf('Cluster %d',clus),'FontSize',8);
             sel_indices=random_count(clus):random_count(clus+1);
             sel_indices=sel_indices+50000*num_plates-9;
              if(sel_indices(1)<=0)
                  continue;
              end;
n = hist3(score(sel_indices,1:2),{quantile(score(:,1),0):0.3:quantile(score(:,1),1),quantile(score(:,2),0):0.3:quantile(score(:,2),1)}); % Extract histogram data;
                % default to 10x10 bins

                n1 = [n'/num_elem,zeros(size(n',1),1)+max_elem]; 
% n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0; 




xb = linspace(min(score(:,1)),max(score(:,1)),size(n,1));
yb = linspace(min(score(:,2)),max(score(:,2)),size(n,2));



%  pcolor([xb,xb(end)+1],yb,n1);
  imagesc(n1);
 
 axis tight
 end;
  colormap(old_map);
  freezeColors;
%                  for(plate=1:num_plates)
%                      %Draw 50 random vesicles in black
%                      rand_indices=randi([50000*(plate-1)+1 50000*plate],60,1);
%                  scatter(score(rand_indices,1),score(rand_indices,2),[],cluster_indices(rand_indices),'.');
%                  minx=min(minx,min(score(rand_indices,1)));
%                  miny=min(miny,min(score(rand_indices,2)));
%                  maxx=max(maxx,max(score(rand_indices,1)));
%                  maxy=max(maxy,max(score(rand_indices,2)));
%                  end;

                 hold on;
%                  axis([minx maxx miny maxy]);
                 %Use again the standard color map
%                  colormap(old_map);
                 %Draw the GMM centres in red
%                  rand_indices=200000+1:200000+size(results{min_index}.mu,1);
%                  
%                  scatter(score(rand_indices,1),score(rand_indices,2),'.','y');
                 %Next we load the GMM ratios of single cells and use these
                 %measurements to display 2 figures: 
                 %-Fraction s of vesicles in the different GMM classes
                 %-Plate effect of all GMM ratios for all plates
        
           load(npc(strcat(plate1_paths{(assay-1)*4+1},'/','Measurements_Cells_',vesicle_strings6{assay},'GMM_new.mat')));
features=eval(strcat('handles.Measurements.Cells.',vesicle_strings6{assay},'GMM'));
features=cat(1,[],features{:});
%Allocate table for plates and vesicle class
table_gmm=NaN(4,size(features,2)-1);
    for(plate=1:num_plates)
        plate_effect=zeros(16,24);
        if(exist(npc(strcat(plate1_paths{(assay-1)*4+plate},'/','Measurements_Cells_',vesicle_strings6{assay},'GMM_new.mat')),'file')==2)
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'/','Measurements_Cells_',vesicle_strings6{assay},'GMM_new')));
features=eval(strcat('handles.Measurements.Cells.',vesicle_strings6{assay},'GMM'));

    %Find and load BASICDATA 
        basic_files=dir(npc(strcat(plate1_paths{(assay-1)*4+plate},'/*BASICDATA*')));
    if(size(basic_files,1)>1)
        sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
    end;
    basic_path=basic_files.name;
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'/',basic_path)));
        feature_well1=cellfun(@(x) nanmean(cat(1,[],features{x})),BASICDATA.ImageIndices,'UniformOutput',false); 
        empty_cell=cellfun(@(x) length(x)==1,feature_well1);
                feature_well1(empty_cell)={NaN(1,size(results{min_index}.mu,1)+1)};

        empty_cell=cellfun(@(x) isempty(x),feature_well1);
        feature_well1(empty_cell)={NaN(1,size(results{min_index}.mu,1)+1)};
        feature_well=cat(1,[],feature_well1{:});
        features=nanzscore(cat(1,[],features{:}));
for(col=1:size(features,2))

feature_well(BASICDATA.TotalCells<200,:)=NaN;

plate_effect=plate_effect+abs(reshape(nanzscore(feature_well(:,col)),24,16)');
end;
%  fig_count=fig_count+1;
%         subplot(5,8,fig_count)
%         hold on;
%         axis([1 24 1 16])
%         imagesc(reshape(nanzscore(lin(plate_effect)),16,24),[-2,2])
%         hold on;
%         title(sprintf('Plate %d',plate),'FontSize',5);
  
        
       
%For each column we plot the distribution ain a color controlled by plate
for(col=1:size(features,2))

    %Get all vesicles of class for current plate
%     table_gmm(plate,col)=nansum(features(:,col).*features(:,size(features,2)));
    if(any(~isnan(features(:,col))))
        if(col<size(features,2))
    table_gmm(plate,col)=nansum(features(:,col).*features(:,size(features,2)));
        else
table_gmm(plate,col)=nansum(features(:,col));    
        end;

    end;
    
end;
        end;
          
    end;
    
    
    
    
     table_gmm=bsxfun(@rdivide,table_gmm,nansum(table_gmm));
       fig_count=fig_count+1;
              subplot(5,8,fig_count)
              heatmaptext(table_gmm)
%     gcf2pdf(analysis_path,assay_names{assay});
    end;
 rfe_offset=6;

          
     
        fig_count=fig_count+1;
        fig_count=fig_count+1;
        
        subplot(5,8,fig_count-1);
    for(plate=1:4)
   
     hold on
         if(exist(npc(strcat(plate1_paths{(assay-1)*4+plate},'\','Measurements_100local1normsamplesizeRFE_',vesicle_strings6{assay},'_new.mat'))))
             load(npc(strcat(plate1_paths{(assay-1)*4+plate},'\','Measurements_100local1normsamplesizeRFE_',vesicle_strings6{assay},'_new.mat')));
             current_step=1;
             for(removal_step=1:10:size(Classification_accuracy,3)-10)
                 %figure;
                 current_matrix=Classification_accuracy(:,:,removal_step);
                 current_matrix1=cellfun(@nanmean,current_matrix);
                 %histfit(current_matrix1(:));
                 t=nanmean(current_matrix1,2);
                
                 [v,I]=sort(-t,'ascend');
                 
                 
                 result_assay(current_step,:)= arrayfun(@(x) nanmean(t(I(1:x))),1:length(I));
                 result_assay2(current_step)= nanmean(t(I(end-120:end)));
                 
                 current_step=current_step+1;
             end;
             %Get rank of every feature which is used to later vsiaulize
             %ranks fo feature in the 4 plates
                 if(plate==1)
           
           first_plate=union(removed_features,instable_features);
                 end;
             
              [~, ~,removal_indices{plate}]=intersect(first_plate,removed_features);
     
              [~, removal_indices1{plate},~]=intersect(first_plate,removed_features(length(removed_features)-19:length(removed_features)));
             subplot(5,8,fig_count-1);
             hold on;
              plot(10:10:(current_step-1)*10,lin(result_assay(1:current_step-1,50)),strcat('-',plate_color{plate}));
              plot(10:10:(current_step-1)*10,lin(result_assay2(1:current_step-1)),strcat('--',plate_color{plate}));
plot(length(removed_features)-19+zeros(length(0.5:0.05:1),1),0.5:0.05:1,'y');
subplot(5,8,fig_count);
hold on;
   plot(1:length(I),lin(result_assay(current_step-2,:))-result_assay2(current_step-2),strcat('-',plate_color{plate}));
              plot(1:length(I),lin(result_assay(1,:))-lin(result_assay2(1)),strcat('--',plate_color{plate}));
              %               clear('result_assay');
%               clear('result_assay2');
            
         end;
         clear('result_assay');
    end;
 subplot(5,8,fig_count-1);
 xlabel('Removal step');
              ylabel('Average classification accuracy','FontSize', 8);
              title('Removed features vs classification accuracy','FontSize', 8)
             subplot(5,8,fig_count);
              xlabel('Hit list length','FontSize', 8);
              ylabel('Average classification accuracy','FontSize', 8');
              title('Hitlist length vs Classification accuracy')
%               fig_count=fig_count+1;
%               subplot(5,8,fig_count)
%               hold on;
%               imagesc(removal_indices)
%               title('RFE ranks in 4 plates','FontSize', 8)
               %Get counts of every feature in the TOP20
                     fig_count=fig_count+1;
        subplot(5,8,fig_count)
        hold on;
        
    feature_count=hist(lin(cat(2,[],removal_indices1{:})),[1:150]);
    %Use again hist to count number of features with a 1,2 3 or 4
    feature_count=hist(feature_count(feature_count>0),1:4).*[1,2,3,4];
    bar(feature_count);
    xlabel('Number of occurence in TOP 20 feature list of plate','FontSize',8)
ylabel('Number of features','FontSize', 8);
title('RFE feature distribution','FontSize',10);
    xlabel('Number of removed feature','FontSize', 8);
%Classification subreport
        %Load penetrance SVM
        load(npc(strcat(plate_paths{assay},'/',load_strings2{assay})));
         
     
 for(i=1:1138)
            for(bin=1:6)
                 margin(i,bin)=2/((norm([Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)],2)^2)*0.5+c_crit5(i,bin));%/([Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)]*[Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)]');%norm([Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)],2);%0.5*(Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)*Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)')+0.5*bias(i,bin)*bias(i,bin);
            end;
        end;
        plate_limit=[1,285,570,855,1138];
        for(bin=1:6)
        fig_count=fig_count+1;
        subplot(5,8,fig_count)
        hold on;
        axis tight;
   for(plate=1:4)

 plate_sel=zeros(1138,1);
 all=1:1138;
 plate_sel(plate_limit(plate):plate_limit(plate+1)-1)=1;
%  class_std2((bin_indices==1)&plate_sel,bin)=nanzscore(class_std2((bin_indices==1)&plate_sel,bin));

 scatter(log(lin(margin(plate_sel==1,bin))/nanmean(lin(margin(plate_sel==1,bin)))),lin(Classification_accuracy(plate_sel==1,bin)),'.',plate_color{plate});



%,*2,'r'

hold on;
    end;   
    xlabel('Soft Margin','FontSize', 8)
ylabel('Classification accuracy','FontSize', 8)
title(sprintf('Margin vs class. acc. in bin %d',bin),'FontSize',5)

end

%Load multivariate distance of all plates and zscore per plate. At the same
%time we show the distribution of those distances
    fig_count=fig_count+1;
    fig_count1=fig_count;
        
        plate_effect=zeros(16,24);
        hold on;
        features1=[];
        %Plate_effect keeps the absolute sum of all distance per well of
        %all plates
    for(plate=1:num_plates)
        if(exist(npc(strcat(plate1_paths{(assay-1)*4+plate},'/','Measurements_Cells_SingleCellMultiVariateDistance',channel_names,'.mat')),'file')==2)
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'/','Measurements_Cells_SingleCellMultiVariateDistance',channel_names,'.mat')));
        %Find and load BASICDATA 
        basic_files=dir(npc(strcat(plate1_paths{(assay-1)*4+plate},'/*BASICDATA*')));
    if(size(basic_files,1)>1)
        sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
    end;
    basic_path=basic_files.name;
        load(npc(strcat(plate1_paths{(assay-1)*4+plate},'/',basic_path)));
features=eval(strcat('handles.Measurements.Cells.SingleCellMultiVariateDistance',channel_names));
feature_well=cellfun(@(x) nanmean(cat(1,[],features{x})),BASICDATA.ImageIndices); 
feature_well(BASICDATA.TotalCells<200)=NaN;
features=nanzscore(cat(1,[],features{:}));
plate_effect=abs(reshape(nanzscore(feature_well),24,16)');
 fig_count=fig_count+1;
        subplot(5,8,fig_count)
        hold on;
        axis([1 24 1 16])
        imagesc(reshape(nanzscore(lin(plate_effect)),16,24),[-2,2])
        hold on;
        title(sprintf('Multivariate distance Plate %d',plate),'FontSize',5);
   [count,~]=hist(features,-5:0.05:6);
subplot(5,8,fig_count1)
        plot(-5:0.05:6,count,plate_color{plate});
        hold on;
        title('Multivariate distance','FontSize', 8);
%Show plate effects of multivariate distance

        end;
    end;
    
    
        gcf2pdf(npc((plate_paths{assay})),strcat('multivariate_report_',vesicle_strings6{assay}),'overwrite','A3')
%