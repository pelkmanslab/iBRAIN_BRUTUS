
function []=pcagui_headless_finalclass(plate_path,config_file,output_path1bin,output_path6bin)
%  plate_path=npc('Y:\Prisca\endocytome\100402_A431_w3Macro\100402_A431_Macropinocytosis_CP392-1bd\BATCH');
%  config_file=npc('Y:\Prisca\endocytome\100402_A431_w3Macro\RFEcp395_MacroVes.txt');
%  output_path=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/');
       basic_files=dir(strcat(plate_path,'/*BASICDATA*'));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;

                   pc_ref=pca_test_headless_all(plate_path,config_file,basic_path,20,40);
pc_ref.updateGeneList('');
 pc_ref.writeOutput(output_path6bin);
%               pc_ref=pca_test_headless_1bin(plate_path,config_file,basic_path,20,30);
%  pc_ref.updateGeneList('');
%  pc_ref.writeOutput(output_path1bin);

end