
function []=pcagui_headless_rfe(plate_path,config_file,output_path,output_path1,local_i,global_i)
%   plate_path=npc('Y:\Prisca\endocytome\110721_MZ_w2EGF\110721_MZ_w2EGF-CP395-2ar\BATCH');
%   config_file=npc('Y:\Prisca\endocytome\110721_MZ_w2EGF\RFE_EGFVes.txt');
% %  output_path1=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP392-1ad/BATCH');
% output_path1='C:\Users\heery\Desktop\test1.txt';
%  output_path='C:\Users\heery\Desktop\test1.txt';
% global_i=0.0;
% local_i=0.5;
% plate_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/090403_A431_Dextran_GM1-CP395-1ag/BATCH');
% config_file=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090403_A431_w2GM1_w3Dextran/RFE_DextranVes.txt');
% output_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/');
% local_i=1
plate_path
config_file
local_i
% global_i=0;
       basic_files=dir(strcat(plate_path,'/*BASICDATA*'))
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;

                     pc_ref=pca_test_headless_rfe(npc(plate_path),npc(config_file),npc(strcat(plate_path,'/',basic_path)),20,60,output_path);
pc_ref.updateGeneList('',output_path,output_path1,local_i,global_i);

end