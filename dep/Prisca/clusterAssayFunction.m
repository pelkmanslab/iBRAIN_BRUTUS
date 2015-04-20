%This scripts looas the c'criteria of all reClassifications of all assazs
%and concatenates the matrices
function []=clusterAssayFunction(num)

 plate_paths={  '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1',...
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
            
            out_path='/BIOL/imsb/fs2/bio3/bio3/Data/Users/Prisca/110315_Compounds_A431_Tf/modules/';
            
plate1_paths={  
     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP392-1ad/BATCH',...
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
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/110721_MZ_w2EGF/110721_MZ_w2EGF-CP395-2ar/BATCH'};
              load_strings6={'Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LampVes.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_GM130Ves.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_DextranVes.mat','Measurements_Classification6bin_RFEcp395_GM1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LDLVes.mat','Measurements_Classification6bin_RFEcp395_EGFVes.mat','Measurements_Classification6bin_RFEcp395_CavVes.mat','Measurements_Classification6bin_RFEcp395_GPIVes.mat','Measurements_Classification6bin_RFEcp395_MacroVes.mat','Measurements_Classification6bin_RFEcp395_EGFVes.mat'};
       load_strings3={'Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LampVes.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_GM130Ves.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_DextranVes.mat','Measurements_Classification6bin_RFEcp395_GM1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LDLVes.mat','Measurements_Classification6bin_RFEcp395_EGFVes.mat','Measurements_Classification6bin_RFEcp395_CavVes.mat','Measurements_Classification6bin_RFEcp395_GPIVes.mat','Measurements_Classification6bin_RFEcp395_MacroVes.mat','Measurements_Classification6bin_RFEcp395_EGFVes.mat'};
          
                    load_strings1={'Measurements_ReClassification1bin_RFEcp395_TfVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_EEA1Ves_v2.mat','Measurements_ReClassification1bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_LampVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_EEA1Ves_v2.mat','Measurements_ReClassification1bin_RFEcp395_TfVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_DextranVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_LDLVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_EGFVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_CavVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_GPIVes_v2.mat','Measurements_ReClassification1bin_RFEcp395_MacroVes_v2.mat'};
          load_strings61={'Measurements_ReClassification6bin_RFEcp395_TfVes.mat','Measurements_ReClassification6bin_RFEcp395_EEA1Ves.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes.mat','Measurements_ReClassification6bin_RFEcp395_LampVes.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes.mat','Measurements_ReClassification6bin_RFEcp395_GM130Ves.mat','Measurements_ReClassification6bin_RFEcp395_EEA1Ves.mat','Measurements_ReClassification6bin_RFEcp395_TfVes.mat','Measurements_ReClassification6bin_RFEcp395_DextranVes.mat','Measurements_ReClassification6bin_RFEcp395_GM1Ves.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes.mat','Measurements_ReClassification6bin_RFEcp395_LDLVes.mat','Measurements_ReClassification6bin_RFEcp395_EGFVes.mat','Measurements_ReClassification6bin_RFEcp395_CavVes.mat','Measurements_ReClassification6bin_RFEcp395_GPIVes.mat','Measurements_ReClassification6bin_RFEcp395_MacroVes.mat','Measurements_ReClassification6bin_RFEcp395_EGFVes.mat'};
             % load_strings61={'Measurements_ReClassification6bin_RFEcp395_TfVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_EEA1Ves_v2.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_LampVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_GM130Ves_v2.mat','Measurements_ReClassification6bin_RFEcp395_EEA1Ves_v2.mat','Measurements_ReClassification6bin_RFEcp395_TfVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_DextranVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_GM1Ves_v2.mat','Measurements_ReClassification6bin_RFEcp395_ChtxVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_LDLVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_EGFVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_CavVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_GPIVes_v2.mat','Measurements_ReClassification6bin_RFEcp395_MacroVes_v2.mat'};
          
        %  load_strings6={'Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LampVes.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_GM130Ves.mat','Measurements_Classification6bin_RFEcp395_EEA1Ves.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_DextranVes.mat','Measurements_Classification6bin_RFEcp395_GM1Ves.mat','Measurements_Classification6bin_RFEcp395_ChtxVes.mat','Measurements_Classification6bin_RFEcp395_LDLVes.mat','Measurements_Classification6bin_RFEcp395_EGFVes.mat','Measurements_Classification6bin_RFEcp395_CavVes.mat','Measurements_Classification6bin_RFEcp395_GPIVes.mat','Measurements_Classification6bin_RFEcp395_MacroVes.mat'};
           sv40_uphits=[5,10,11,13,24,25,38,46,58,61,64,67,76,82,89,95,105,118,120,125,132,134,146,151,160,166,170,174,185,192,199,214,228,231,245,275,291,297,305,310,323,325,334,365,371,375,376,382,393,396,400,403,408,426,430,442,448,449,463,496,498,508,516,525,527,530,532,548,549,553,568,569,570,614,622,629,633,644,660,662,677,679,686,695,715,721,755,756,758,768,773,795,796,812,816,819,831,835,836,839,857,881,887,888,904,905,908,909,914,918,924,926,942,944,952,955,960,962,963,975,977,980,983,987,992,1000,1001,1003,1010,1021,1029,1038,1046,1054,1063,1069,1070,1071,1072,1076,1080,1083,1090,1095,1100,1102,1109,1111,1114,1117,1118,1120,1124,1125,1132,1134,1135;];
           sv40_downhits=[23,30,35,36,54,66,72,88,107,127,129,139,145,147,155,163,172,178,182,195,203,208,220,251,252,267,271,272,274,285,296,301,309,330,353,402,405,416,421,444,453,458,460,467,473,479,488,489,502,507,521,534,537,547,555,565,585,604,617,653,668,692,698,727,732,742,751,772,774,777,787,802,810,828,847,849,856,860,869,870,871,873,884,886,892,893,894,895,897,898,901,906,907,910,921,925,931,934,935,936,937,938,946,948,950,956,961,967,984,988,989,993,995,997,1006,1007,1013,1017,1019,1020,1023,1028,1032,1033,1035,1037,1039,1045,1048,1049,1057,1058,1059,1064,1065,1066,1067,1073,1077,1078,1079,1091,1099,1101,1105,1106,1107,1112,1116,1121,1136;];
                     selected_assays1=[1,4,6,7,8,9,10,11,12,13,14,15,16,17];    
                      assay_names={'MZ TF','MZ EEA1','A431 Chtx1','A431 Lamp','A431 Chtx2','A431 GM130','A431 EEA1','A431 TF','A431 Dextran','A431 GM1','A431 Chtx3','A431 LDL','A431 EGF','A431 CAV','A431 GPI','A431 Macro','MZ EGF'};
   num=5;
                      for(assay1=5)
     clusters={{	'FLJ10986', 'WDR44', 'PRKD1', 'TTBK2', 'RAB1B', 'NCK2', 'MARK1', 'TSSK3', 'VPS35', 'ARRB1', 'MAST1', 'RAB32', 'GSK3B', 'LMTK2', 'STX17', 'IPMK', 'PTPN9', 'PRKAR2B', 'GSG2', 'TAF1', 'EHD4', 'FLOT2', 'SEC14L4', 'SRPK2', 'CLTA', 'RAB1A', 'RAB39B', 'PANK3', 'RIPK4', 'ALPK2', 'SPEG', 'ARPC3', 'PRKAG3'},
{'VPS36', 'AKT2', 'MYO1F', 'EZR', 'MAP2K7', 'NME6', 'MAPRE1', 'IRAK3', 'MVK', 'NUMB', 'TRIB1', 'DYNC1H1', 'CFL1', 'RHOH', 'RAB40A', 'PDPK1', 'RIOK2', 'HUNK', 'AP3M1', 'JAK3'},
{'PLK3', 'STON2', 'PDK2', 'AP2M1', 'AP3M1', 'RAB40A', 'TRPM7', 'MYO1F', 'COASY', 'MAP2K4', 'MAPRE1', 'STK39', 'PHKA1', 'VPS18'},
{'SEC14L2', 'DAB2', 'IKBKE', 'STON2', 'GALK1', 'BRD3', 'NSF', 'MARK3', 'ERBB4', 'AP3B1', 'MAP3K14', 'STK39', 'EPN1', 'MLCK', 'CDC2', 'PLK3', 'RAF1'},
{'CLTC', 'PLK3', 'CDC2', 'CRKRS', 'LRRK2', 'CLK2', 'NEDD4L', 'MAP3K14', 'STK38L', 'TP53RK', 'STK39', 'VPS18', 'CDC2L2_4', 'BTK', 'MYO7A', 'MULK', 'CDC2L1'},
{'MPP4', 'STX5', 'HUNK', 'RIOK2', 'VPS36', 'PDPK1', 'RAB40A', 'PDK2', 'AP2M1', 'SRPK1', 'SRC', 'TRPM7'},
{'DAB2', 'MARK3', 'EPN1', 'NEDD4L', 'PBK', 'MLCK', 'MYO7A', 'SRPK1', 'GALK1', 'TP53RK', 'STK38L'},
{	'AP3B1', 'CAPZB', 'CDC2L2_4', 'TP53RK', 'ILK', 'STK3', 'MYO7A', 'FRAP1', 'TSG101', 'DGKG'},
{	'PAK1', 'MYO7A', 'HUNK', 'GALK1', 'PAPSS2', 'DAB2', 'STON2', 'NEDD4L'},
{	'JAK3', 'TNK2', 'SEC14L2', 'STK38L', 'PAK1', 'RAF1', 'TRRAP', 'PAPSS2', 'IKBKE', 'STON2', 'NEDD4L'},
{	'PRKAG3', 'ARPC3', 'RAB39B', 'BECN1', 'DCK', 'STX17', 'VRK3', 'AK5'},
{'IKBKE', 'MARK3', 'STK39', 'VPS36', 'EPN1', 'STK38L', 'CDC2L1'},
{'STX5', 'PDPK1', 'PDK2', 'RIOK2', 'CLK2', 'SNX5', 'VPS11', 'VPS28'},
{	'RAB40A', 'CRKRS', 'MAP2K4', 'CKMT1B', 'TRRAP', 'MYO1F', 'JAK3'},
{'TRIB1', 'STX5', 'NUMB', 'MPP4', 'ITPK1', 'TRPM7', 'MAPRE1'},
{	'MAP2K4', 'COASY', 'HERC2', 'ITPK1', 'SRC', 'MYO7A', 'BRD3', 'NEDD4L'},
{'PHKA1', 'CRKRS', 'TNK2', 'PAK1', 'TRPM7'},
{	'PANK3', 'BECN1', 'NUAK2', 'RIPK4'},
{	'TRPM7', 'CRKRS', 'BRD3', 'MULK', 'SRC', 'CDC2L1'},
{	'HERC2', 'ITPK1', 'PHKA1', 'PBK', 'MAPRE1'},
{	'BTK', 'NSF', 'MAPK15', 'RIMS1', 'MAP2K2'}};
        assay=selected_assays1(assay1);
                  load(npc(strcat(plate_paths{assay},'/',load_strings6{assay})))
%                   search_s=[find(strcmp(Gene_list,'BCR')),find(strcmp(Gene_list,'BRD4')),find(strcmp(Gene_list,'FLOT1')),find(strcmp(Gene_list,'HERC2')),find(strcmp(Gene_list,'AP2M1')),find(strcmp(Gene_list,'ABCC1')),find(strcmp(Gene_list,'RALB')),find(strcmp(Gene_list,'ARF4')),find(strcmp(Gene_list,'AP3B1')),find(strcmp(Gene_list,'RIMS1'))];
%                   n=Normal_vector_matrix_bin_after_bin(search_s,81:100);
% mean_well1=[];
% for(l=1:4)
%     load(npc(strcat(plate1_paths{(assay-1)*4+l},'/','Measurements_MultiVariate_Wells_ChtxVes.mat')))
%     mean_well1=[mean_well1;mean_well];
% end;
%  HeatMap(n.*mean_well1(search_s,81:100),'ColumnLabels',feature_names(1:end),'RowLabels',{'BCR','BRD4','FLOT1','HERC2','AP2M1','ABCC1','RALB','ARF4','AP3B1','RIMS1'})
%  HeatMap(n,'ColumnLabels',feature_names(1:end),'RowLabels',{'BCR','BRD4','FLOT1','HERC2','AP2M1','ABCC1','RALB','ARF4','AP3B1','RIMS1'})
 Cells_per_bin=Cells_per_bin5;
        Cells_per_bin(find(c_crit5~=c_crit5))=NaN;
Cells_per_bin(find(Cells_per_bin==0))=NaN;
          total_cells=nansum(Cells_per_bin,2);
        I=find(total_cells<200);
     
        pvalue(I,:)=NaN;
        norm_length=NaN(1138,6);
        [J,~]=find(pvalue<0.03);
           load(npc(strcat(plate_paths{assay},'/',load_strings3{assay})))
           Classification_accuracy1(I,:)=NaN;
        margin1(I,:)=NaN;
        c_crit5(I,:)=NaN;
        Average_distance(I,:)=NaN;
        Normal_vector_matrix_bin_after_bin(I,:)=NaN;
        cell_feature=[6];
        membrane_features=[10];
        J=unique(J);
        pvalue3=pvalue(J,:);
       [non_hit1,non_hit2]=find(pvalue>=0.03);
       % cg=clustergram((Normal_vector_matrix_bin_after_bin(J,:)),'RowPDist',@cos_nan,'RowLabels',Gene_list(J),'linkage','average','Symmetric',true,'Standardize','none','Colormap',[flipud((redbluecmap))],'ImputeFun', @knnimpute,'DisplayRange',0.75,'OptimalLeafOrder',false,'Cluster','column');
      membrane_features=[membrane_features,membrane_features+20,membrane_features+40,membrane_features+60,membrane_features+80,membrane_features+100];
       average_membrane=nanmean(Normal_vector_matrix_bin_after_bin(:,membrane_features),2);
%        [length(intersect(J,sv40_uphits))/length(J),length(intersect(J,sv40_downhits))/length(J)]
       


         
         for(i=1:1138)
            for(bin=1:6)
                 norm_length(i,bin)=sum(abs(Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)));%0.5*(Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)*Normal_vector_matrix_bin_after_bin(i,(bin-1)*20+1:bin*20)')+0.5*bias(i,bin)*bias(i,bin);
            end;
        end;
        

        hitlist_size(assay)=length(J);
      
        I=J;
        load(npc(strcat(plate_paths{assay},'/',load_strings61{(assay)})));
        c_crit1=c_crit;
        test=squeeze(c_crit(:,2,:));
        test=NaN(1,1,1138);
          for(gene=1:1138)
            for(bin=1:6)
                test=squeeze(c_crit(gene,bin,1:1138)) +squeeze(norm_length(:,bin));
              
                    c_crit(gene,bin,1:1138)=test;
                    
                
            end;
        end;
        %Extract distacn e matrix just for the hits
       % c_crit=Classification_accuracy;
        D=c_crit1(I(1:hitlist_size(assay)),:,I(1:hitlist_size(assay)));
 F=c_crit(I(1:hitlist_size(assay)),:,I(1:hitlist_size(assay)));
 Gene_list_all=Gene_list;
        Gene_list=Gene_list(I(1:hitlist_size(assay)));
        D1=NaN(size(D));
        D2=NaN(size(D));
        for(bin=1:6)
            for(i=1:size(D,1))
                for(j=1:size(D,1))
                    D1(i,bin,j)=F(i,bin,j)/F(i,bin,i);
                end;
            end;
        end;
          for(bin=1:6)
            for(i=1:size(D,1))
                for(j=1:size(D,1))
                    
                    D(i,bin,j)=max(D(i,bin,j),D(j,bin,i));
                    if(isnan(D1(i,bin,j))~=isnan(D1(j,bin,i)))
                        % If one difference is NaN set all also the
                        % difference to NaN
                       D1(i,bin,j)=NaN;
                       D1(j,bin,i)=NaN;
                    end;
                    D2(i,bin,j)=min(D1(i,bin,j),D1(j,bin,i));
                end;
            end;
        end;
        D(isinf(D))=NaN;
        D2(isinf(D2))=NaN;
        
           
%             for(i=1:size(D,1))
%                 non_hit2=pvalue3(i,:)>0.03;
%          for(i=1:size(D,1))
%               non_hit3=pvalue3(j,:)>0.03;
%                D2(i,non_hit2&non_hit3,j)=NaN;
%             D2(j,non_hit2&non_hit3,i)=NaN;
%          end;
%             end;
            clusters=ownClustering_boot(squeeze(nanmean(D(:,:,:),2)),squeeze(nanmean(D2(:,:,:),2)),0.032,1.25);
                  
            clusters=arrayfun(@(x) Gene_list(clusters{x}),1:length(clusters),'UniformOutput',false);
%              sel=cellfun(@(x) find(strcmp(x,'TGFBR1')),clusters,'UniformOutput',false);
            save('C:\Users\heery\Desktop\local_data\test\a431clusters.mat','clusters');
            overlap=NaN(length(clusters),length(clusters));
for(i=1:length(clusters))
    for(j=1:length(clusters))
        overlap(i,j)=length(intersect(clusters{i},clusters{j}));
    end;
end;

figure;
hold on;
imagesc(overlap);
t1=squeeze(nanmean(F(:,:,:),2));
t=t1([clusters{2},clusters{4}],[clusters{2},clusters{4}]);
        for(bin=5:6)
         cytoscape(nanmedian(D(:,:,:),2)*10,Gene_list,nanmedian(D2(:,:,:),2)*100)
end;

      is_string=cellfun(@(x) ~isnumeric(x),Gene_id);
      Gene_id(is_string==1)={-1};
        Gene_id=cat(1,Gene_id{:},[]);
        Gene_id1=Gene_id;
                Gene_id=Gene_id(I(1:hitlist_size(assay)));
        Cells_per_bin=Cells_per_bin(I(1:hitlist_size(assay)),:);
        norm_length=norm_length(I(1:hitlist_size(assay)),:);
        total_cells=nansum(Cells_per_bin,2);
%         D1=zeros(size(D,1),size(D,1));
%          D2=zeros(size(D,1),size(D,1));
%             D3=zeros(size(D,1),size(D,1));
%          D(find(D==0))=NaN;
%        
%         for(i=1:hitlist_size(assay))
%             for(j=1:hitlist_size(assay))
%             D1(i,j)=nanmean(squeeze(D(i,:,j)).*Cells_per_bin(i,:))/total_cells(i);
%             D2(i,j)=nansum(squeeze(norm_length(i,:)).*Cells_per_bin(i,:))/total_cells(i);
%     
%             if(sum(squeeze(D(i,:,j)).*Cells_per_bin(i,:)~=squeeze(D(i,:,j)).*Cells_per_bin(i,:))==6)
%                 D1(i,j)=NaN;
%                 D2(i,j)=NaN;
%             end;
%         end;
%         %Compute ranks per row
%         D3(i,:)=tiedrank(D3(i,:));
%                    end;
%        % D1=squeeze(nanmean(D,2));
%           F=nanstd(D1(sub2ind(size(D),1:size(D1,1),1:size(D1,2))));
%         E=zeros(size(D,1),size(D,1));
%         G=zeros(size(D,1),6,size(D,1));
%         for(i=1:length(D))
%             for(j=1:i-1);
%                 for(bin=1:6)
% %                 f1=max([(((D(i,bin,j)+D(i,bin,i)))/2)-D(i,bin,i),((((D(i,bin,j)+D(i,bin,i)))/2)-0.93)]);%min((D1(i,j)-D1(i,i)));%/(D1(i,i));%,(D2(i,j)-D2(i,i))/D2(i,i));
% %                 f2=max([(((D(j,bin,i)+D(j,bin,j)))/2)-D(j,bin,j),((((D(j,bin,i)+D(j,bin,j)))/2)-0.93)]);%min((D1(j,i)-D1(j,j)));%/(D1(j,j));%,(D2(j,i)-D2(j,j))/D2(j,j));
% %                 G(i,bin,j)=max([f1,f2]);
% %                 G(j,bin,i)=max([f1,f2]);
% f1=max([D(j,bin,j),D(i,bin,i),D(i,bin,j),D(j,bin,i),D(j,bin,j)]);
% f2=max([D(j,bin,j),D(i,bin,i),D(i,bin,j),D(j,bin,i),D(j,bin,j)]);
% test_nan=[isnan(D(j,bin,j)),isnan(D(i,bin,i)),isnan(D(i,bin,j)),isnan(D(j,bin,i)),isnan(D(j,bin,j))];
% G(i,bin,j)=(max([D(i,bin,j),D(j,bin,i)]));%-D(i,bin,i))/F;
% G(j,bin,i)=(max([D(i,bin,j),D(j,bin,i)]));%-D(j,bin,j))/F;
% if(~isempty(find(test_nan==1)))
%   G(j,bin,i)=NaN;
%   G(i,bin,j)=NaN;
% end;
%                 end;
%  E(i,j)=nanmean(G(i,:,j),2);
%  E(j,i)=nanmean(G(j,:,i),2);    
%  max_v=max(E(i,j),E(j,i));
%  E(i,j)=max_v;
%  E(j,i)=max_v;
%             end;
%                     %Compute ranks per row
%      
%          end;
%          for(i=1:length(D))
%                  E(i,:)=tiedrank(E(i,:));
%                    end;
%                    for(i=1:length(D))
%                         for(j=1:i-1)
%                  E(i,j)=max([E(i,j),E(j,i)]);
%                  E(j,i)=E(i,j);
%                         end;
%                    end;
%           for(i=1:length(D))
%                  E(i,i)=0;
%                    end;
% %                for(i=1:length(D))
% %          
% %                    D3(i,:)=tiedrank(E(i,:));
% %                end;
% %                   for(i=1:length(D))
% %          for(j=1:i-1)
% %                                E(i,j)=max([D3(i,j),D3(j,i)]);
% %                    E(j,i)=max([D3(i,j),D3(j,i)]);
% %          end;
% %                end;
%           E(E<0)=0;
%           %D1=D;
%           Gene_list1=Gene_list;
% %            Z=linkage(squareform(E/max(E(:))),'average');
% % E=(E/max(E(:)));
% % a=1;
% %  for(round=1:3)
% %      num_covered=arrayfun(@(x) length(find(D1(:,x)<0.8)),1:size(D1,1));
% %      [~,I]=max(num_covered);
% %      Gene_list1(I)
% %      
% %      del_ind=find(D1(:,I(1))<0.80);
% %      Gene_list1(del_ind)=[];
% %      D1(find(D1(:,I(1))<0.80),:)=[];
% %      D1(:,del_ind)=[];
% %  end;
% 
% 
% 
% %           E(isnan(E))=2;
% %       
%                   Z=linkage(squareform(E),'average');
%    
%                    a=1;
% % E(find(E==0))=NaN;
% % E(E>1)=1;
% % for(l=1:200)
% % %     Pick l random numbers
% %     rand_n=randi([1 length(Gene_list1)],[l,1500]);
% % %     Pick corresponding subset of genes
% %     output(l)=nanmean(arrayfun(@(x) nanmean(lin(E(rand_n(:,x),rand_n(:,x)))),1:1500));
% % end;
% % plot(1:200,output(1:200))
% %     xlabel('Number of genes in cluster')
% %     ylabel('Expected average inter module rank')
% 
%                   [matBestTree, h, matAllSubtrees, matTreeLinkageSet,average_distance]=bootclust_function(E,sprintf('%d',1:length(Gene_list1)),100,Gene_list1,Gene_id);
%                   matSumSubtreeFrequencyPerTree = NaN(size(matTreeLinkageSet,3),1);
% K=inconsistent(matBestTree);
% for iTree = 1:size(matTreeLinkageSet,3)
%     
%     % sum edge scores
%     matSumSubtreeFrequencyPerTree(iTree) = sum(matAllSubtrees(matTreeLinkageSet(:,4,iTree),4));
%     
% end
% 
% 
% % find the tree with the highest sum of subtree frequencies
% [~,intMaxIX] = max(matSumSubtreeFrequencyPerTree);
%                   for iBranch = 1:size(matTreeLinkageSet,1)
%     
%     % get the handle to the current branch
% 
%     
%     % calculate absolute and percentage occurence of current branch
%     intSubtreePercent(iBranch) = 100*matAllSubtrees(matTreeLinkageSet(iBranch,4,intMaxIX),4);
%     intSubtreeCount(iBranch) = round(1000*matAllSubtrees(matTreeLinkageSet(iBranch,4,intMaxIX),4));
%                   end;
%                   Z=matBestTree;
%                     num_genes=NaN(length(Gene_list1)+length(Gene_list1)-1,1);
%                     num_genes(1:length(Gene_list1))=1;
%                     for(k=1:length(Gene_list1)-1)
%                         num_genes(length(Gene_list1)+k)=num_genes(Z(k,1))+num_genes(Z(k,2));
%                     end;
%                     num_genes=min(200,num_genes);
%                              
%                                [H,T,P]=dendrogram(matBestTree,0);
%                                  [T] = cluster(matBestTree,'cutoff',35,'criterion','distance'); 
%     
% 
%                     
%                     
%          clusters=arrayfun(@(x) Gene_list1(find(T==x)),unique(T),'UniformOutput',false)
%              clusters_id=arrayfun(@(x) Gene_id1(find(T==x)),unique(T),'UniformOutput',false)
%              
%                  T=T(P);
%              
%                
% %          
%           
% %                   %Evaluate stability of clustering by picking rasndom rows
% %                   %and clustering them
% %                   result_svm=NaN(length(Gene_list1),length(Gene_list1),1000);
% %                   for(boot=1:1000)
% %                       sample=randi(length(Gene_list1),[0.5*length(Gene_list1),1]);
% %                       L=linkage(squareform(E(sample,sample)),'average');
% %                       [T,P]=dendrogramnop(L,0);
% %                       %j is left gene of the pair to compare we adapt the
% %                       %distances of all pairs (j,j+1),...j,P
% %                       for(j=1:length(P))
% %                           result_svm(sample(P(j)),sample(P(j+1:length(P))),boot)=[1:length(P)-j];
% %                       end;
% %                   end;
% %                   %Now we take the stanard deviation for each pair and then take the mean across all standrad deviations
% %                   std_dev=NaN(length(Gene_list1),length(Gene_list1));
% % for(i=1:length(Gene_list1))
% %                       for(j=i+1:length(Gene_list1))
% %                           std_dev(i,j)=nanstd([squeeze(result_svm(i,j,:));squeeze(result_svm(j,i,:))])/nanmean([squeeze(result_svm(i,j,:));squeeze(result_svm(j,i,:))]);
% %                       end;
% %                   end;
% %                   a=lin(std_dev(:));
% %                   [~,I]=sort(a,'ascend');
% %                   q1=nanmean(a(I(1:length(I)/16)))
% 
% 
% 
% %                  Z=matBestTree;
% %          [H,T,P]=dendrogram(Z,0);
% %          
% 
%                 cluster_names={'Cluster1','Cluster2','Cluster3','Cluster4','Cluster5','Cluster6','Cluster7','Cluster8'};
            channels={'RescaledRed','RescaledGreen','RescaledGreen','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledRed'};
%            vesicle_strings6={'TfVes','EEA1Ves','ChtxVes','LampVes','ChtxVes','GM130Ves','EEA1Ves','TfVes','DextranVes','GM1Ves','ChtxVes','LDLVes','EGFVes','CavVes','GPIVes','MacroVes','EGFVes'};
%        indices1=strfind(plate_paths{assay},'/');
%         indices2=strfind(plate_paths{assay},'_');  
%         save(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/','Measurement_Assay_Tree.mat')),'clusters','T')
% genes2=cat(1,[],clusters{:});
%      HeatMap(E(P,P))
% % P=NaN(length(genes2),1);
% % for(k=1:length(genes2))
% %     P(k)=find(strcmp(Gene_list1,genes2{k}),1,'first');
% % end;
% 
% 
% 
% 
% %          %Get average normals of cluster
% %          average_normals=arrayfun(@(x) nanmean(Normal_vector_matrix_bin_after_bin(J(find(T==x)),:),1),unique(T),'UniformOutput',false);
%        
%          %Loop over cluster
% 
% 
%   %  E(find(E>0.84))=NaN;
% %         cytoscape(E,Gene_list);
%                 
% 
% 
% 
% % clusters{1}=intersect(hits,clusters{1});
% % clusters{2}=intersect(hits,clusters{2});
% all_genes=cat(1,[],clusters{:});
% plate_paths2=         plate1_paths((assay-1)*4+1:assay*4);    
% i=1;
% hit_wells=NaN(length(all_genes),120);
% for(j=1:4)
%     load(npc(strcat(plate_paths2{j},'/','Measurements_MultiVariate_Wells','_',vesicle_strings6{assay},'.mat')));
%     
%        for(k=1:length(all_genes))
%         %Get index of well harboring perturbation
%        index=find(strcmp(gene_names,Gene_list{k}));
%        if(~isempty(index))
%        %Get image indices
%       hit_wells(k,:)=mean_well(index,:);
%       genes_indices(k)=index;
%        end;
%       % row{i}=strcat(plate_path_jpg{j},'\','Well_',row_translation{BASICDATA.WellRow(index)},col_translation{BASICDATA.WellCol(index)},'_SegmentedCells_RGB2.jpg');
%        i=i+1;
%        end;
% end;
%                
%                  
%              
% % hit_wells(hit_wells~=hit_wells)=0;
% % hit_wells1=1-corr(hit_wells','rows','pairwise');
% %      result_svm2=NaN(length(Gene_list1),length(Gene_list1),1000);
% %                   for(boot=1:1000)
% %                       sample=randi(length(Gene_list1),[0.5*length(Gene_list1),1]);
% %                       L=linkage(squareform(hit_wells1(sample,sample)),'average');
% %                       [T,P]=dendrogramnop(L,0);
% %                       %j is left gene of the pair to compare we adapt the
% %                       %distances of all pairs (j,j+1),...j,P
% %                       for(j=1:length(P))
% %                           result_svm2(sample(P(j)),sample(P(j+1:length(P))),boot)=[1:length(P)-j];
% %                       end;
% %                   end;
% %                   %Now we take the stanard deviation for each pair and then take the mean across all standrad deviations
% %                   std_dev2=NaN(length(Gene_list1),length(Gene_list1));
% %                   for(i=1:length(Gene_list1))
% %                       for(j=i+1:length(Gene_list1))
% %                           std_dev2(i,j)=nanstd([squeeze(result_svm2(i,j,:));squeeze(result_svm2(j,i,:))])/nanmean([squeeze(result_svm2(i,j,:));squeeze(result_svm2(j,i,:))]);
% %                       end;
% %                   end;
% %                         a=lin(std_dev2(:));
% %                   [~,I]=sort(a,'ascend');
% %                   q2=nanmean(a(I(1:length(I)/16)))
% % save(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/','Measurement_Assay_Average.mat')),'q1','q2');
%                  
%                   
           indices1=strfind(plate_paths{assay},'/');
        indices2=strfind(plate_paths{assay},'_');
         vesicle_strings6={'TfVes','EEA1Ves','ChtxVes','LampVes','ChtxVes','GM130Ves','EEA1Ves','TfVes','DextranVes','GM1Ves','ChtxVes','LDLVes','EGFVes','CavVes','GPIVes','MacroVes','EGFVes'};
% 
% 
%         % HeatMap((E(P,P)),'RowLabels',Gene_list(P),'ColumnLabels',Gene_list(P));
% %         load(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/','Measurement_Assay_Tree.mat')))
% %                load(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/','Measurement_Assay_Tree.mat')),'matAllSubtrees', 'matTreeLinkageSet')
% %            [T] = cluster(matBestTree,'criterion','distance','cutoff',0.2); 
% %        
% %          clusters=arrayfun(@(x) Gene_list(find(T==x)),unique(T),'UniformOutput',false)
%    
%          %Get average normals of cluster
%          average_normals=arrayfun(@(x) nanmean(Normal_vector_matrix_bin_after_bin(J(find(T==x)),:),1),unique(T),'UniformOutput',false);
%        
%          %Loop over cluster
%          cluster_names={'Cluster1','Cluster2','Cluster3','Cluster4','Cluster5','Cluster6','Cluster7','Cluster8'};
%            channels={'RescaledRed','RescaledGreen','RescaledGreen','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledRed','RescaledRed','RescaledGreen'};
%       
% all_genes=cat(1,[],clusters{:});
% plate_paths2=         plate1_paths((assay-1)*4+1:assay*4);    
% i=1;
% hit_wells=NaN(length(all_genes),120);
% for(j=1:4)
%     load(npc(strcat(plate_paths2{j},'/','Measurements_MultiVariate_Wells','_',vesicle_strings6{assay},'.mat')));
%     
%        for(k=1:length(all_genes))
%         %Get index of well harboring perturbation
%        index=find(strcmp(gene_names,Gene_list{k}));
%        if(~isempty(index))
%        %Get image indices
%       hit_wells(k,:)=mean_well(index,:);
%       genes_indices(k)=index;
%        end;
%       % row{i}=strcat(plate_path_jpg{j},'\','Well_',row_translation{BASICDATA.WellRow(index)},col_translation{BASICDATA.WellCol(index)},'_SegmentedCells_RGB2.jpg');
%        i=i+1;
%        end;
% end;
% 
% 
%      
% %gcf2pdf('C:\Users\heery\Desktop\local_data\modules',assay_names{assay});
% selected_indices=[];
%   for(f=1:20)    
% selected_indices=[selected_indices,f:20:100+f];
%   end;
%   fnames=cell(120,1);
%   for(f=1:120)
%       if((mod(f, 6))==0)
%       fnames{f}=feature_names{( ceil(f/6))};
%       
%       else
%           fnames{f}='';
%           end;
%   end;
%        hmo=HeatMap((hit_wells(P,selected_indices)),'Symmetric',true,'RowLabels',Gene_list,'ColumnLabels',fnames,'Standardize','none','Colormap',[flipud(smoothcolormap(redbluecmap))],'DisplayRange',2);
%   h=plot(hmo);    
% gcf
% set(gcf,'Position',[1 1 1000 1000]);
% figure(1)
% 
% 
%  axes(h)
% % 
%  hold on;
% %Add cluster borders
% last_element=1;
% mkdir(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay})))
% 
% 
% 
% for(i=1:length(clusters))
%     hold on;
%     plot(1:120,find(T==(i),1,'last'),'-y','LineWidth',15);
%     text(120,find(T==(i),1,'last'),sprintf('%d',i),'FontSize',0.5);
%     %Draw for each cluster some text indicating the correlation of a random
% %subset of that size and the correlation achieved  in that cluster
%  last_element=last_element+length(find(T==(i)));
% end;
% title(strcat(assay_names{assay},' modules'))
% %Load and sort univariate data and reorder to have same genelist order
% % load('C:\Users\heery\Desktop\current_code\official_univariate.mat');
% % 
% % 
% % [~,I]=sort(-abs(matAllData(1,:)),'ascend');
% % %Plot fractions of univariate overlap
% %               Z=matBestTree;
% %               [H,T,P]=dendrogram(Z,0);
% %                     num_genes=cell(length(Gene_list1)+length(Gene_list1)-1,1);
% %                     for(k=1:length(Gene_list1))
% %                         
% %                     num_genes{k}={Gene_list1{k}};
% %                     end;
% %                     univ_overlap=NaN(length(Gene_list1)-1,1);
% %                     for(k=1:length(Gene_list1)-1)
% %                         num_genes{length(Gene_list1)+k}=union(num_genes{Z(k,1)},num_genes{Z(k,2)});
% %                         univ_overlap(k)=length(intersect(num_genes{length(Gene_list1)+k},cellGeneSymbols(I(1:200))))/length(num_genes{length(Gene_list1)+k});
% %                         set(H(k),'Color',[univ_overlap(k),0,0]);
% %                     end;
% print('-dtiff','-r600',strcat('C:\Users\heery\Desktop\local_data\modules\',assay_names{assay},'.tiff'));
% close(gcf);

%         cytoscape(E,Gene_list);
                
clusters={
 {'MAST1', 'ULK3', 'SPHK1', 'CAMK1D', 'ROCK1', 'JAK3', 'CYTH3', 'DLG3', 'COPB1', 'ROCK2', 'ARRB1', 'RAB40C', 'BIN1', 'AMPH', 'EIF2AK4', 'RAB3D', 'GRK6', 'NRBP2', 'AP3B1', 'RAB7L1', 'ARRB2', 'MAP3K11', 'TJP3', 'SNAP23', 'PRKACG', 'PRKD3', 'NPR2', 'MAP3K2', 'DAPK1', 'RHOBTB1', 'PIP5K1B', 'COG1', 'SNX1', 'SYT2', 'RIMS1', 'PDK1', 'ERBB4', 'RPS6KA6', 'RAB5A', 'NAALADL1', 'PCK1', 'RAB6A', 'MAPK12'},
 {'FYN', 'RABGEF1', 'SNAP25', 'TCEB3C', 'GSK3B', 'RAB40C', 'RAB5A', 'CAPZA1', 'MAPRE3', 'COPB2', 'TJP3', 'AP1M1', 'RALB', 'CAV2', 'LAMP1', 'ARHGAP8', 'STX17', 'FLJ30698 ', 'DLG3', 'SEC14L5', 'EIF2AK3', 'TSG101', 'SDPR', 'COPB1', 'AP2M1', 'CBLB', 'RPS6KA6', 'RHOA', 'FGR', 'ALPK2', 'NPC1', 'ROR1', 'FLJ10986', 'STK32B', 'RAB39B', 'STARD9', 'ABCC1'},
 {'SPHK2', 'RAC3', 'FYN', 'DLG1', 'RAB7B', 'PRPS1', 'DYNC1H1', 'AP3B1', 'HIPK1', 'SNAP23', 'PRKACG', 'RAB3D', 'NME1', 'EIF2AK4', 'PRKD3', 'AMPH', 'CSNK1G1', 'UCK2', 'MPP3', 'ACTB', 'LTK', 'FLOT1', 'SEPT3', 'PITPNM2'},
 {'PRPS1', 'RABEP1', 'EIF2AK4', 'RHOA', 'MAPK11', 'OSBP2', 'CRKL'},
 {'AK1', 'HGS', 'PKN2', 'MAP3K10', 'ALPK2'},
 {'CYTH3', 'MVK', 'RAF1', 'ERBB4', 'PRKCG', 'ABCC1'},



};
%cluster dense
clusters={
    {'MAP3K2', 'SNX1', 'STX10', 'COPB2', 'SEC14L5', 'NPR2', 'SNAP25', 'RAF1', 'DLG3', 'JAK3', 'GSG2', 'MAP3K11', 'HIPK4', 'BCR', 'ROCK2', 'CDC2L5', 'ROCK1', 'SEPT3', 'DIAPH1', 'TAOK3', 'PIK3C2B', 'PRKCG', 'RPS6KA6', 'STX17', 'NEK6', 'CAMK1D', 'RABL4', 'ARRB2', 'PCK1', 'RIMS1', 'PDK1'},
    {'EIF2AK4', 'RIMS1', 'PRKCQ', 'DLG1', 'NME6', 'PRKD3', 'ARRB1', 'BRD4', 'AMPH', 'AP3B1', 'SEPT3', 'CPLX1', 'CSNK1G1', 'SEC14L1', 'PRKACG', 'NME1', 'PRPS1', 'FLOT1', 'PKN2', 'CRKL', 'LTK'},
{'MINK1', 'ARPC2', 'TSG101', 'AP1M1', 'CBLB', 'FGR', 'C9orf96', 'MYO6', 'AP2M1', 'STK32B', 'RALB', 'CAPZA1', 'STARD9', 'ARHGAP8', 'SDPR', 'RAB9A', 'KIF5B'},
{'CAMK1D', 'TJP3', 'DLG3', 'NRBP2', 'EIF2AK3', 'CAPZA1', 'RALB', 'RAB40C', 'AP2M1', 'CBLB', 'C9orf96', 'MAP3K2', 'NEDD4L'},
{'ULK3', 'RAB7B', 'SPHK1', 'SNAP23'},
{'NPC1', 'MAPRE3', 'HGS', 'VRK3', 'MYO6', 'RAB9A', 'ALPK2'}
};

%cluster dense v2
clusters={
{'PRKCG', 'HIPK4', 'STX17', 'MPP2', 'CKM', 'SNAP25', 'CDC2L5', 'COPB2', 'CAMK1D', 'TAOK3', 'TRIM28', 'BCR', 'ROCK1', 'STX10', 'MAP3K2', 'SEC14L5', 'NPR2', 'MAP3K11', 'GSG2', 'JAK3', 'GSK3B', 'CAMKK1', 'DLG3', 'NRBP2', 'PIK3C2B', 'NEK6', 'RAF1', 'ROCK2', 'LAMP1', 'RPS6KA6', 'RAB40C', 'TJP3', 'CBLB', 'COPA', 'ITPK1', 'RALB', 'EIF2AK3', 'AP2M1' },
{'RAC1', 'BRD4', 'PRPS1', 'PRKD3', 'PRKACG', 'HIPK1', 'ARRB1', 'PRKCQ', 'RAB7B', 'MAPK11', 'LTK', 'SEPT3', 'MPP3', 'CSNK1G1', 'FLOT1', 'CPLX1', 'DLG1', 'SEC14L1', 'SPHK2', 'MAST1', 'NME6', 'NME1', 'PKN2', 'CRKL', 'AP3B1', 'AMPH', 'MAP3K10', 'FLJ10986', 'VPS35', 'HERC2', 'MAPRE1', 'FLJ40852', 'SEPT7', 'RAB33B'},
{'SDPR', 'AP1M1', 'MINK1', 'FGR', 'C9orf96', 'TSG101', 'ARPC2', 'AP2M1', 'CBLB', 'MAPRE3'},
{'HGS', 'NPC1', 'NAPA', 'MAPRE3', 'KIF5B', 'ABCC1', 'ALPK2', 'AK1', 'MYO6', 'RAC3', 'STARD9', 'RAB9A', 'FYN', 'OSBP2', 'HERC2', 'MAPRE1'},
{'EIF2AK3', 'RALB', 'CAPZA1', 'RABGEF1', 'ARHGAP8', 'NEDD4L'},
{'CFL1', 'ARF4', 'TXNDC6', 'TAOK1', 'ULK3', 'SPHK1', 'RAB6A', 'RAB3C', 'SNAP23'},
{'GRK6', 'PITPNM2', 'AP3B1', 'SEPT3', 'DYNC1H1', 'UCK2', 'ACTB'},
{'PDK1', 'NEDD4L', 'NAALADL1', 'SNAP23', 'SPHK1', 'RIMS1', 'PCK1'}};

%sparse v2
clusters={{'CAPZA1', 'SNAP25', 'CBLB', 'GSK3B', 'TCEB3C', 'RABGEF1', 'SEC14L5', 'RAB40C', 'RAB5A', 'NPC1', 'COPB1', 'TJP3', 'AP1M1', 'COPB2', 'RALB', 'LAMP1', 'ARHGAP8', 'FLJ30698_', 'TAOK3', 'EIF2AK3', 'TSG101', 'RHOA', 'FGR', 'ALPK2', 'AP2M1', 'SDPR', 'FYN', 'STK32B', 'NRBP2', 'MAPRE3', 'BCR', 'CAV2', 'ARPC2', 'PDPK1', 'STX17', 'CDK7', 'RAB39B', 'STARD9', 'ABCC1'},
{'ARRB1', 'JAK3', 'NPR2', 'CAMK1D', 'MAP3K2', 'ROCK1', 'DLG3', 'COPB1', 'TJP3', 'MAP3K11', 'RAB40C', 'HIPK1', 'BIN1', 'DAPK1', 'AMPH', 'RAB3D', 'PIP5K1B', 'SYT2', 'GRK6', 'NRBP2', 'RIMS1', 'ROCK2', 'PDK1', 'STX17', 'RPS6KA6', 'CYTH3', 'ERBB4', 'PRKCG', 'ABCC1'},
{	'RAB7B', 'PRPS1', 'FLJ40852', 'AP3B1', 'NME6', 'DYNC1H1', 'RAB7L1', 'ARRB2', 'MAP3K11', 'TJP3', 'SNAP23', 'DAPK1', 'RHOBTB1', 'PIP5K1B', 'COG1', 'SNX1', 'NAALADL1', 'SYT2', 'RIMS1', 'PDK1', 'RAB5A', 'RAB3D', 'MAST1', 'ULK3', 'SPHK1', 'PCK1', 'RAB6A', 'MAPK12'},
{	'DYNC1H1', 'PRKD3', 'NME6', 'FLJ40852', 'DLG1', 'PRKACG', 'TAOK1', 'RAB3D', 'SNAP23', 'NME1', 'HIPK1', 'AMPH', 'EIF2AK4', 'RAC3', 'FYN', 'CSNK1G1', 'UCK2', 'MPP3', 'ACTB', 'LTK', 'FLOT1', 'SEPT3', 'PITPNM2'},
{'PRPS1', 'RABEP1', 'RHOA', 'MAPK11', 'OSBP2', 'CRKL'},
{	'MAP3K10', 'PKN2', 'AK1', 'HGS', 'ALPK2'},
{	'MINK1', 'RAC1', 'SDPR', 'C9orf96'}};
%  n_temp=zeros(length(clusters),20);
%   m_temp=zeros(length(clusters),20);
% for(c=1:length(clusters))
%    
%     %Loop over genes
%     for(n=1:length(clusters{c}))
%         n_temp(c,:)=n_temp(c,:)+Normal_vector_matrix_bin_after_bin(find(strcmp(Gene_list,clusters{c}{n})),81:100);
%         m_temp(c,:)=m_temp(c,:)+mean_well1(find(strcmp(Gene_list,clusters{c}{n})),81:100);
%     end;
%     n_temp(c,:)=n_temp(c,:)/length(clusters{c});
%    
% end;
%  HeatMap(n_temp,'ColumnLabels',feature_names(1:end),'RowLabels',1:length(clusters))
%  HeatMap(m_temp,'ColumnLabels',feature_names(1:end),'RowLabels',1:length(clusters))
% clusters{1}=intersect(hits,clusters{1});
% clusters{2}=intersect(hits,clusters{2});
all_genes=cat(2,[],clusters{:});

plate_paths2=         plate1_paths((assay-1)*4+1:assay*4);           

      
                     tiff_paths=strrep(plate_paths2,'BATCH','TIFF');
                     plate_path_jpg=strrep(plate_paths2,'BATCH','JPG_HR');
                     plate_path_jpg1=strrep(plate_paths2,'BATCH','JPG_SEGM');
                     segmentation_paths=strrep(plate_paths2,'BATCH','SEGMENTATION');
PlateDataHandles = struct();
plate_names={'CP392','CP393','CP394','CP395'};
count=1;
%plate_path_jpg={'/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP392-1bi/JPG_SEGM','/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP393-1bi/JPG_SEGM','/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP394-1bi/JPG_SEGM','/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP395-1bi/JPG_SEGM'}

row_translation={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'};
col_translation={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'};
i=1;
  i1=1;
  seg=[5,5,5,5,5,5,5,5,5,5,4,5,5,5,4,4,4];
   green=[2,3,3,2,2,3,3,2,3,2,3,3,2,3,3,3,2];
   top_meta={};
    top_image_names={};
    top_segmentation_names={};
    top30={};
    top_current_image=[];
    plate_current=[];
    row={};
    row1={};
    app={'091127_A431_Chtx_Golgi_AcidWash_CP392-1bf_','091127_A431_Chtx_Golgi_AcidWash_CP393-1bf_','091127_A431_Chtx_Golgi_AcidWash_CP394-1bf_','091127_A431_Chtx_Golgi_AcidWash_CP395-1bf_'};
for(j=1:4)
    %
    
    [f,fname,meta]=getRawProbModelData2(npc(plate_paths2{j}),npc(strcat(plate_paths{assay},'/RFEcp395_',vesicle_strings6{assay},'.txt')));
    global_mean(j)=nanmean(f(:,5));
    global_std(j)=nanstd(f(:,5));
    load(npc(strcat(plate_paths2{j},'/','Batch_data.mat')));
%Get rescaled information for channel to treat out of BATCH_DATA
ident_column=handles.Settings.VariableValues;
ident_column1=ident_column(:,2);

index_rescaled=find(strcmp(ident_column1,channels{(ceil(assay))}));
LowestPixelOrig(j)=str2num(ident_column{index_rescaled,4});
HighestPixelOrig(j)=str2num(ident_column{index_rescaled,5});
LowestPixelRescale(j)=str2num(ident_column{index_rescaled,6});
HighestPixelRescale(j)=str2num(ident_column{index_rescaled,7});
   % [f,~,meta]=getRawProbModelData2(plate_paths{j},strrep(plate_paths{j},'/BATCH','/ProbModel_Settings_Minimal.txt'));
% f(isnan(f))=0;
% corr_c=corr(f);
% HeatMap(corr_c,'RowLabels',fname','ColumnLabels',fname');
         basic_files=dir(npc(strcat(plate_paths2{j},'/*BASICDATA*')));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_data=basic_files.name;
  PlateDataHandles = LoadMeasurements(PlateDataHandles,npc([plate_paths2{j},'/','Measurements_Image_FileNames.mat']));
    load(npc(strcat(plate_paths2{j},'/',basic_data)));
    
    for(k=1:length(all_genes))
        %Get index of well harboring perturbation
       index=find(strcmp(BASICDATA.GeneData,all_genes{k}));
       %Get image indices
       if(~isempty(index))
           index=index(find(index>0,1,'first'));
       image_indices=PlateDataHandles.Measurements.Image.FileNames(BASICDATA.ImageIndices{index});
       top_meta{i}=arrayfun(@(x) meta(find(meta(:,6)==x),7),BASICDATA.ImageIndices{index},'UniformOutput',false);
       top_image_names{i}=cellfun(@(x) (strcat(tiff_paths{j},'/',x)),image_indices,'UniformOutput',false);
       top_segmentation_names{i}=cellfun(@(x) (strcat(segmentation_paths{j},'/',x{1}(1:end-4),'_SegmentedCells.png')),image_indices,'UniformOutput',false);
       top30{i}=all_genes{k};
       plate_current(i)=j;
       top_current_image(i)=1;
      row{i}=strcat(plate_path_jpg{j},'/',app{j},row_translation{BASICDATA.WellRow(index)},col_translation{BASICDATA.WellCol(index)},'_RGB2.png');
      row1{i}=strcat(plate_path_jpg1{j},'/','Well_',row_translation{BASICDATA.WellRow(index)},col_translation{BASICDATA.WellCol(index)},'_SegmentedCells_RGB2.jpg');
      i=i+1;
       end;
    end;
  
end;


for(cluster_c=1:length(clusters))
    
    if(length(clusters{cluster_c})<4)
        continue;
    end;

    mkdir(npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/',sprintf('clustersparsev2%d',cluster_c))));
    for(gene=1:length(clusters{cluster_c}))
      matCroppedOriginalImage =uint16([]);

  SEG=seg(assay);
  GREEN=green(assay);
  RED=setdiff([2,3],GREEN);
   I=find(strcmp(top30,clusters{cluster_c}{gene}),1,'first');
%   copyfile(row{I},strcat('C:/Users/heery/Desktop/local_data/modules/ldl/',cluster_names{cluster_c},sprintf('//%s-gene%s',plate_names{j},clusters{cluster_c}{gene}),'.jpg'));
%   continue;

    matChannelIntensities = [];

ind=strfind(row{I},'/');
str=row{I}(ind(length(ind))+1:length(row{I}));
copyfile(npc(row{I}),strcat(sprintf('Z:/Data/Users/Prisca/110315_Compounds_A431_Tf/modules/091127_A431_w3ChtxAW2_ChtxVes/clustersparsev2%d/',cluster_c),clusters{cluster_c}{gene},'-',str));
copyfile(npc(row1{I}),strcat(sprintf('Z:/Data/Users/Prisca/110315_Compounds_A431_Tf/modules/091127_A431_w3ChtxAW2_ChtxVes/clustersparsev2%d/',cluster_c),'zz-',clusters{cluster_c}{gene},'-',str));
continue;

    
    dircoutput = top_image_names{I};

    cellFileNames = cell(1,4);
    cellAllFileNames = {};
    matChannelAndPositionData = [];
    iFile = 0;
    for ii = 1:size(dircoutput,2)
       for(kk=1:length(dircoutput{ii}))
            try
                intChannelNumber = check_image_channel(char(dircoutput{ii}{kk}));
                intPositionNumber = check_image_position(char(dircoutput{ii}{kk}));
                if intChannelNumber > 0
                    iFile = iFile + 1;
                    matChannelAndPositionData(iFile,:) = [intChannelNumber,intPositionNumber];
                    cellFileNames{intChannelNumber} = [cellFileNames{intChannelNumber}; {char(dircoutput{ii}{kk})}];
                    cellAllFileNames = [cellAllFileNames;{char(dircoutput{ii}{kk})}];
                end
            catch
                disp(sprintf('%s: unknown file name: %s',mfilename,char(dircoutput{i}{kk})))
            end
end;
    end
   
  

    [foo,strMicroscopeType] = check_image_position(cellAllFileNames{1,1});
    clear foo;
    disp(sprintf('%s:  microscope type "%s"',mfilename,strMicroscopeType));
    
    disp(sprintf('%s:  %d images per well',mfilename,max(matChannelAndPositionData(:,2))));
    disp(sprintf('/t /t /t /t channel %d present/n',unique(matChannelAndPositionData(:,1))));    


    matChannels = find(~cellfun('isempty',cellFileNames));
    intNumOfChannels = length(matChannels);
    
    strImageName = char(cellFileNames{1}(1));
    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% START MERGE AND STITCH AND JPG CONVERSION %%%
    
    rowstodo = 1:16;
    colstodo = 1:24;
    
    matRows = cellstr(regexp(char(65:80),'\w','match'));
    matCols = regexp(sprintf('%.2d',1:24),'\d\d','match');
    
    matPlateImagesPerWell = zeros(16,24);
tempImage=zeros(1040,1392);
    matImageSize = size(tempImage)/4;

    % get image snake
    [matImageSnake,matStitchDimensions] = get_image_snake(max(matChannelAndPositionData(:,2)), strMicroscopeType);

    %%% BS, 080818, Get Image locations from filterimagenamedata, rather
    %%% than parsing the image names in here. Allows for more flexible
    %%% handling of different naming conventions.
    matImageRow=[];
    matImageColumn=[];
    
    for iChannel = 1:length(cellFileNames)
        if ~isempty(cellFileNames{iChannel})
            [matImageRow(:,iChannel),matImageColumn(:,iChannel)]=cellfun(@filterimagenamedata,cellFileNames{iChannel});
        end
    end
%     if(GREEN==3)
%         GREEN=1;
%     end;
    
%     if length(matChannels) == 4
%         matChannelOrder = [3,2,1,0; ... % BLUE, green, RED, RED
%                            3,2,0,1]; % BLUE, green, RED, RED
        matChannelOrder = [%3,2,1,0; ... % BLUE, green, RED, RED
                           %3,2,0,0; ...  % BLUE, green, RED, RED            
                           0,GREEN,1,0; ...  % BLUE, green, RED, RED    
                           %0,0,1,0; ...  % BLUE, green, RED, RED    
                        %   3,2,0,1;...
                           % 0,0,0,1
                           ]; % BLUE, green, RED, RED
%  
%        disp(sprintf('%s: four channels found, producing two different JPGs',mfilename));            
%     else
%         matChannelOrder = [3,2,1,1];
%     end
    
%     matChannelOrder = [3,2,1,1]; % BLUE, GREEN, RED, RED
    
  %  disp(sprintf('%s: start saving JPG''s in %s',mfilename,strOutputPath)); 
    
    
    for intChannelCombination = 1:size(matChannelOrder,1)
        for rowNum = rowstodo
            for colNum = colstodo

                %%% CHECK IF THERE ARE ANY MATCHING IMAGES FOR THIS WELL...
                str2match = strcat('_',matRows(rowNum), matCols(colNum));
                FileNameMatches = strfind(cellAllFileNames, char(str2match));
                matAllFileNameMatchIndices = find(~cellfun('isempty',FileNameMatches));

                if not(isempty(matAllFileNameMatchIndices))    
                    intIncludedImages = 0;

                    % initialize final output image (RGB), single precision
                    Overlay = zeros(round(matImageSize(1,1)*matStitchDimensions(1)),round(matImageSize(1,2)*matStitchDimensions(2)),3, 'double');                

                    for intChannel = 1:size(matChannels,2)
                        
                        % skip processing current channel if the
                        % corresponding channelOrder value is 0
                        if ~matChannelOrder(intChannelCombination,intChannel)
                            continue
                        end
                        
                        % check which images match the current well position
                        matFileNameMatchIndices = find(matImageRow(:,intChannel)==rowNum & matImageColumn(:,intChannel)==colNum);
                        
                        %Get rescaling parameters for each well
                        intNumberofimages = size(matFileNameMatchIndices,1);
                        intNumOfSamplesPerChannel = (round(intNumberofimages*0.2)+1);
                        randindices = randperm(intNumberofimages);
        
                        matLowerQuantiles = NaN(1,intNumOfSamplesPerChannel);
                        matUpperQuantiles = NaN(1,intNumOfSamplesPerChannel);
        
                        matWellImages = cellFileNames{intChannel}(matFileNameMatchIndices);
                        
                       
                      
                        % initialize current channel image
                       % Patch = zeros(round(matImageSize(1,1)*matStitchDimensions(1)),round(matImageSize(1,2)*matStitchDimensions(2)), 'single');                
                     %  Patch=uint8(Patch1);
                        for k = matFileNameMatchIndices'
                            strImageName = cellFileNames{1,matChannelOrder(intChannelCombination,intChannel)}{k};
                            strImagePosition = check_image_position(strImageName);
                            xPos=(matImageSnake(1,strImagePosition)*matImageSize(1,2))+1:((matImageSnake(1,strImagePosition)+1)*matImageSize(1,2));
                            yPos=(matImageSnake(2,strImagePosition)*matImageSize(1,1))+1:((matImageSnake(2,strImagePosition)+1)*matImageSize(1,1));
                            try
                                 matImage = imresize(imread(npc(fullfile(strImageName))),0.25);
                                intIncludedImages = intIncludedImages + 1; % keep track if we included any images
                            catch caughtError
                                caughtError.identifier
                                caughtError.message
                                warning('matlab:bsBla','%s: failed to load image ''%s''',mfilename,fullfile(strTiffPath,strImageName));
                                matImage = zeros(matImageSize);
                            end
                            matImage=double(matImage);
                       matImage=matImage/double((2^16)-1);
 
if(intChannel==2)
    channel_image=matImage;
        %%% Rescales the Image.
    
    %Any pixel in the original image lower than the user-input lowest bound is
    %pinned to the lowest value.
    
    %Loop over cells

      
        InputImageMod = channel_image;
        InputImageMod(InputImageMod < LowestPixelOrig(plate_current(I))) = LowestPixelOrig(plate_current(I));
    %Any pixel in the original image higher than the user-input highest bound is
    %pinned to the lowest value.
    InputImageMod(InputImageMod > HighestPixelOrig(plate_current(I))) = HighestPixelOrig(plate_current(I));
    %Scales and shifts the original image to produce the rescaled image
    scaleFactor = (HighestPixelRescale(plate_current(I)) - LowestPixelRescale(plate_current(I)))  / (HighestPixelOrig(plate_current(I)) - LowestPixelOrig(plate_current(I)));
    shiftFactor = LowestPixelRescale(plate_current(I)) - LowestPixelOrig(plate_current(I));
    OutputImage = InputImageMod + shiftFactor;
    channel_image = OutputImage * scaleFactor;
    
     % channel_image=((channel_image-0.75*global_mean(plate_current(I)))/global_std(plate_current(I)))*global_std(plate_current(3))+0.75*global_mean(plate_current(3));
    channel_image(find(channel_image<0))=0;
    matImage=channel_image;
%     RGB8(:,:,GREEN)=(channel_image);
% %RGB8(:,:,GREEN)=RGB8(:,:,GREEN)-8800;
% 
% RGB8(:,:,GREEN)=RGB8(:,:,GREEN);
% RGB8(find(RGB8<0))=0;
% [ix,iy]=find(edge_im==1);
% t=squeeze(RGB8(:,:,2));
% third=zeros(length(ix),1);
% 
% RGB8(sub2ind(size(RGB8),ix,iy,third+GREEN))=1;
% RGB8(sub2ind(size(RGB8),ix,iy,third+1))=1;
                        end;
                             Overlay(yPos,xPos,intChannel) =matImage;%round(((matImage))) .*((2^16)/256);% (matImage - matChannelIntensities(intChannel,1)) * (2^16/(matChannelIntensities(intChannel,2)-matChannelIntensities(intChannel,1)));
                        end
                                 
                       % Overlay(:,:,matChannelOrder(intChannelCombination,intChannel)) = Patch;
                    end
                    
                    % make sure different channel combinations do not
                    % overwrite eachother
                 

                    if intIncludedImages > 0
                     %   disp(sprintf('%s:  storing %s',mfilename,strfilename))                
                        imwrite(Overlay*64,npc(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/',sprintf('clusterdense%d',cluster_c),sprintf('/%s-gene%s',plate_names{plate_current(I)},clusters{cluster_c}{gene}),'.tiff')));        
                    else
                        disp(sprintf('%s:s  NOT storing %s',mfilename,strfilename))                
                    end
                  %  drawnow 

                end
            end
        end      
    end


%   
%   image_string=image_string{19};
%    meta=top_meta{I};
%    meta=meta{19};
%   image_string1=top_segmentation_names{I};
%   image_string=[image_string,image_string1{19}];
% for iChannel = 1:SEG
%     
%     if fileattrib(image_string{iChannel})
%         im=(imread(image_string{iChannel}));
%     else
%         error('BS:FileNotFound','%s: file %s does not exist',mfilename,image_string{iChannel})
%     end
% 
%     matCroppedOriginalImage = cat(3,matCroppedOriginalImage,double(im));
% 
% end
% 
% RGB8 = double(matCroppedOriginalImage);
% channel_image=zeros(size(RGB8,1),size(RGB8,2),3);
% %imagesc(box1(:,:,1))
% %Make red channel all zero to remove red channel
% RGB8(:,:,RED)=0;
% 
% 
% %     %Any pixel in the original image lower than the user-input lowest bound is
% %     %pinned to the lowest value.
% %     LowestPixelOrig=0.0024;
% % HighestPixelOrig=1;
% % LowestPixelRescale=0;
% % HighestPixelRescale=1;
% %        InputImageMod = double(RGB8(:,:,2))/65535;
% %     %Any pixel in the original image lower than the user-input lowest bound is
% %     %pinned to the lowest value.
% %     InputImageMod(InputImageMod < LowestPixelOrig) = LowestPixelOrig;
% %     %Any pixel in the original image higher than the user-input highest bound is
% %     %pinned to the lowest value.
% %     InputImageMod(InputImageMod > HighestPixelOrig) = HighestPixelOrig;
% %     %Scales and shifts the original image to produce the rescaled image
% %     scaleFactor = (HighestPixelRescale - LowestPixelRescale)  / (HighestPixelOrig - LowestPixelOrig);
% %     shiftFactor = LowestPixelRescale - LowestPixelOrig;
% %     OutputImage = InputImageMod + shiftFactor;
% %    %RGB8(:,:,2)
% %   
% %    t=OutputImage * scaleFactor;
% 
% [ix,iy]=find(~ismember(double(squeeze(RGB8(:,:,SEG))),meta));
% third=zeros(length(ix),1);
% RGB8(sub2ind(size(RGB8),ix,iy,third+SEG))=0;
% edge_im=edge(double(squeeze(RGB8(:,:,SEG))),'roberts',0);
% 
% 
% %mkdir(strcat('C:/Users/heery/Desktop/local_data/modules/macro/',cluster_names{cluster_c}));
% 
%       
%                
% imwrite(RGB8(:,:,[3,2,1])*64,strcat('C:/Users/heery/Desktop/local_data/modules/',plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/',sprintf('cluster%d',cluster_c),sprintf('//%s-gene%s',plate_names{plate_current(I)},clusters{cluster_c}{gene}),'.tiff'));
     end;
end;
%          for(clus=1:length(clusters))
%              if(length(clusters{clus})<5)
%         continue;
%     end;
%                explanation_string='';
%              %Loop over bins
%              for(bin=1:6)
%                  %Get features having normal vector vlaue above abs(0.7)
%                  important_f=find(abs(average_normals{clus}((bin-1)*20+1:bin*20))>0.7);
%                  if(~isempty(important_f))
%                      %Loop opver features
%                      explanation_string=strcat(explanation_string,sprintf('Bin %d ',bin));
%                      for(f=1:length(important_f))
%                          fv=average_normals{clus}((bin-1)*20+important_f(f));
%                  explanation_string=strcat(explanation_string,sprintf('Feature %s %d ',feature_names{important_f(f)},fv));
%                      end;
%                       explanation_string=strcat(explanation_string,'/n');
%                  end;
%              end;
%              file=fopen(strcat(out_path,plate_paths{assay}(indices1(length(indices1))+1:end),'_',vesicle_strings6{assay},'/',sprintf('cluster%d',clus),'/cluster.txt'),'wt');
%          fprintf(file,explanation_string);
%          fclose(file);
%          end;
    
                   end;
end
      