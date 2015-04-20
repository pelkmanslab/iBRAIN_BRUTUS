
function []=createAssayList_script(assay)
%Function to compute p-values for per genes and bin. This function can be
%only used for the endoytome and is tailored to its needs (no controls,no
%replicates).  
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

                     %            super_path='U:\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd';
%            paths={'U:\Data\Users\Yanic\test\100402_A431_Macropinocytosis_CP392-1bd\BATCH'};
                     %Read general settings
%                      assay=1;
                    
          super_path=plate_paths{assay};
    store_filenames=[];
    current=1;
    num_bins=6;

  paths=plate1_paths((assay-1)*4+1:(assay-1)*4+4);
           % for(assay=1:length(plate_paths))
           pvalue=NaN(1138,num_bins); 
            pvalue_dist=NaN(1138,num_bins); 
%                   [ Classification_accuracy_c,margin_c,Cells_per_bin5_c,Normal_vector_c_matrix_bin_after_bin_c,Gene_list_c,Normal_vector_matrix_bin_after_bin3_c,bias_c ,c_crit5_c,plate_indices_c,feature_names,Average_distance_c,pvalue15_c,pvalue15_control_c,entrez_c] =loadAssay_part1(paths,strcat(load_strings2{assay},'_control'),1);
         
           [ Classification_accuracy,margin,Cells_per_bin5,Normal_vector_matrix_bin_after_bin,Gene_list,Normal_vector_matrix_bin_after_bin3,bias ,c_crit5,plate_indices,feature_names,Average_distance,pvalue15,pvalue15_control,entrez,length_std,class_std] =loadAssay_part1(paths,load_strings{assay},1);
        plate_limit=[1,285,570,855,1138];
           for(plate=1:4)%ceil(size(Classification_accuracy,1)/285))
               %Extract c-criteria,pvalues and cells per bin for current
               %plate
 c_crit=c_crit5(plate_limit(plate):plate_limit(plate+1)-1,:);
 pvalue1=pvalue15(plate_limit(plate):plate_limit(plate+1)-1,:);
 pvalue1_c=pvalue15_control(plate_limit(plate):plate_limit(plate+1)-1,:);
Cells_per_bin=Cells_per_bin5(plate_limit(plate):plate_limit(plate+1)-1,:);
%Number of cells per gene
total_cells=nansum(Cells_per_bin,2);

        %Bin genes into 3 bins according to cell number:low,medium and high
        %cell number
                        
   pvalue1( find(cellfun(@(x) isempty(x),pvalue1)))={NaN(1,10000)};
pvalue1_c( find(cellfun(@(x) isempty(x),pvalue1_c)))={NaN(1,10000)};
 for(bin=1:num_bins) 
             cell_extreme=quantile(Cells_per_bin(:,bin), [0.0,0.33333,2*0.33333,1]);
     [~,bin_indices]=histc(Cells_per_bin(:,bin),cell_extreme(1:4));
        %Set bin index 4 to 3:Gene with most cells (non-targteing wells) is
     %put into bin3
     bin_indices(bin_indices==4)=3;
      temp_crit=c_crit(find(~isnan(c_crit(:,bin))),bin);
      [~,c_critindex]=sort(temp_crit);
      %If current plate contains less than 200 genes where the SVM could be
      %succcesfully run go to next bin
 
     for(cell_bin=1:3)
    
  if(length(intersect(c_critindex(:),find(bin_indices==cell_bin)))<60)
       continue;
   end;
%         cell_bin=1
  %Restrict control distances to genes being in the same clel number bin
  pvalue3=pvalue1(intersect(c_critindex(:),find(bin_indices==cell_bin)),:);
  pvalue3_c=pvalue1_c(intersect(c_critindex(:),find(bin_indices==cell_bin)),:);
   %Get distances for all genes for all samples and put them into one
   %vector
   aggregate_distance=lin(cat(1,[],pvalue3{:,bin}));%nansum(cat(1,[],pvalue3{:,bin}),1);
   aggregate_distance=aggregate_distance(find(~isnan(aggregate_distance)));
aggregate_distance_c=lin(cat(1,[],pvalue3_c{:,bin}));%nansum(cat(1,[],pvalue3{:,bin}),1);
   aggregate_distance_c=aggregate_distance_c(find(~isnan(aggregate_distance_c)));
 
   if(length(aggregate_distance)<10000*30)
       continue;
   end;
 %As the null hypthesis we test for Distance control >Distance gene in a
 %non parmeetic way by taking many samples of average distance of genes and
 %the distance ditribution of the current gene
 %pvalue1_c{1,bin};%
     data_control=nanmean(aggregate_distance(randi([1,length(aggregate_distance)],[100,10000])),1);
     data_control_c=nanmean(aggregate_distance_c(randi([1,length(aggregate_distance_c)],[100,10000])),1);
     temp_index=find(bin_indices==cell_bin);
for(gene=temp_index')
%         gene=11

 pvalue2=cellfun(@(x) x,pvalue1(:,bin),'UniformOutput',false);
      %pvalue2=cellfun(@(x) x/sum(x),pvalue1(:,bin),'UniformOutput',false);
 pvalue2=cat(1,pvalue2{:});
 pvalue2_c=cellfun(@(x) x,pvalue1_c(:,bin),'UniformOutput',false);
      %pvalue2=cellfun(@(x) x/sum(x),pvalue1(:,bin),'UniformOutput',false);
 pvalue2_c=cat(1,pvalue2_c{:});
%Some NaN test
if(pvalue2(gene,1:10000)~=pvalue2(gene,1:10000))
    continue;
end;
data_gene=pvalue2(gene,1:10000);
data_gene_c=pvalue2_c(gene,1:10000);
%Get the prbability of control bin number is higher than the perturbed bin
%number
    pvalue(gene+plate_limit(plate)-1,bin) =max(length(find((data_control(randperm(10000))>(data_gene(randperm(10000))))==1))/10000);
pvalue_dist(gene+plate_limit(plate)-1,bin) =max(length(find((data_control_c(randperm(10000))<(data_gene_c(randperm(10000))))==1))/10000);
    %     pvalue(gene+plate_limit(plate)-1,bin) =max(length(find((data_gene(randperm(10000))>0)==1))/10000);
end;
 
 end;
 end;
           end;


    Gene_id=entrez;
    save(npc(strcat(super_path,'/',load_strings2{assay})),'Gene_list','Gene_id','Normal_vector_matrix_bin_after_bin','margin','Cells_per_bin5','Classification_accuracy','c_crit5','plate_indices','bias','feature_names','Average_distance','pvalue','pvalue_dist','length_std','class_std');
    
        

end
          
