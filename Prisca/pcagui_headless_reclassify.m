
function []=pcagui_headless_reclassify(plate_path,config_file,output_path1bin,output_path6bin)
%   plate_path=npc('Y:\Prisca\endocytome\100215_A431_w3LDL\100215_A431_Actin_LDL_CP393-1bi\BATCH');
%   config_file=npc('Y:\Prisca\endocytome\100215_A431_w3LDL\RFEcp395_LDLVes.txt');
%   output_path1bin=npc('Y:\Prisca\endocytome\100215_A431_w3LDL\100215_A431_Actin_LDL_CP393-1bi\BATCH\Measurements_Classification6bin_RFEcp395_TfVes_v2.mat');
         basic_files=dir(strcat(plate_path,'/*BASICDATA*'));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;

                   pc_ref=pca_test_headless_reclassify(plate_path,config_file,basic_path,20,30,output_path1bin);
pc_ref.updateGeneList('');

 pc_ref.writeOutput(output_path6bin);
         

end