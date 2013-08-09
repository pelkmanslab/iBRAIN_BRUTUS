
function []=pcagui_headless_finalclass(plate_path,config_file,output_path1bin,output_path6bin)
%   plate_path=npc('Z:\Data\Users\110920_A431_w2Tf\110920_A431_w2Tf_s2-CP393-4ad\BATCH');
%   config_file=npc('Z:\Data\Users\110920_A431_w2Tf\RFEcp395_TfVes.txt');
%   output_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/');
       basic_files=dir(strcat(plate_path,'/*BASICDATA*'));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;

                   pc_ref=pca_test_headless_6bin(plate_path,config_file,basic_path,20,40);
pc_ref.updateGeneList('');
 pc_ref.writeOutput(output_path6bin);
%               pc_ref=pca_test_headless_1bin(plate_path,config_file,basic_path,20,30);
%  pc_ref.updateGeneList('');
%  pc_ref.writeOutput(output_path1bin);

end