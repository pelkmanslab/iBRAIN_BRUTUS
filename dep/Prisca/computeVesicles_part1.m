%This script prepeares is used for preparartion of vesicle features. As of
%Jan 2011 the Ibrain pipelines in use do not compute some of the vesicles
%features such as location or clustering.
%The script read the basic vesicle information available and uses it
%together with cell information to derive all other informations

%Path to plate to create vesicle features for

%Config files which include vesicle features

%Filename to store single cell vesicle features
%The following vesicle features are stored here
% -v5:Rel. Distance to nucleus Number between 0 and 1 obtained by distance)(GFP
% Pixel-Nucleus Position)/Cell size
% -v6:Number of neighbours within 2.75 um
% -v7: Number of neighbours within 3.8 um
% -v8: Radious containing 40 % of all vesicles
%-v9: Radius containing 60 % of all vesicles
function [t]=computeVesicles_part1(assay_index)

vesicle_file='Measurements_Vesicle_Features-v2';
%Constant which defines the number of pixle per um
um_pixel=100;

if((assay_index>=37)||((assay_index>=5)&&(assay_index<=12)))

%Filename to store vesicle features of a total cell
%-c1: Number of vesicles per cell area
%-c2: Clusering of spatial point pattern Ripleys K
%-c3: Regularity of spatial point pattern Ripley K

          plate_paths={        
              '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090309_A431-Chtx-GM130/090309_A431-Chtx-GM130-CP392-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090309_A431-Chtx-GM130/090309_A431-Chtx-GM130-CP393-1af/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090309_A431-Chtx-GM130/090309_A431-Chtx-GM130-CP394-1af/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090309_A431-Chtx-GM130/090309_A431-Chtx-GM130-CP395-1af/BATCH', ...
 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP392-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP393-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP394-1ad/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1_harlink_03_1ad/090203_Mz_Tf_EEA1_CP395-1ad/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090217_A431_Tf_EEA1/090217_A431_Tf_EEA1_CP392-1ae/BATCH',  ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090217_A431_Tf_EEA1/090217_A431_Tf_EEA1_CP393-1ae/BATCH', ...
                             '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090217_A431_Tf_EEA1/090217_A431_Tf_EEA1_CP394-1ae/BATCH' , ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090217_A431_Tf_EEA1/090217_A431_Tf_EEA1_CP395-1ae/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP392-1ba/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP393-1ba/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH', ...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP395-1ba/BATCH', ...
                           '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090403_A431_Dextran_GM1/090403_A431_Dextran_GM1-CP392-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090403_A431_Dextran_GM1/090403_A431_Dextran_GM1-CP393-1ag/BATCH', ...
                        '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090403_A431_Dextran_GM1/090403_A431_Dextran_GM1-CP394-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090403_A431_Dextran_GM1/090403_A431_Dextran_GM1-CP395-1ag/BATCH', ...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091127_A431_Chtx_Golgi_AcidWash/091127_A431_Chtx_Golgi_AcidWash_CP392-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091127_A431_Chtx_Golgi_AcidWash/091127_A431_Chtx_Golgi_AcidWash_CP393-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091127_A431_Chtx_Golgi_AcidWash/091127_A431_Chtx_Golgi_AcidWash_CP394-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091127_A431_Chtx_Golgi_AcidWash/091127_A431_Chtx_Golgi_AcidWash_CP395-1bf/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100215_A431_Actin_LDL/100215_A431_Actin_LDL_CP392-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100215_A431_Actin_LDL/100215_A431_Actin_LDL_CP393-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100215_A431_Actin_LDL/100215_A431_Actin_LDL_CP394-1bi/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100215_A431_Actin_LDL/100215_A431_Actin_LDL_CP395-1bi/BATCH',...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100224_A431_EGF_Cav1/100224_A431_EGF_Cav1_CP392-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100224_A431_EGF_Cav1/100224_A431_EGF_Cav1_CP393-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100224_A431_EGF_Cav1/100224_A431_EGF_Cav1_CP394-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100224_A431_EGF_Cav1/100224_A431_EGF_Cav1_CP395-1ba/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091113_A431_GPIGFP/091113_A431GPIGFP_CP392-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091113_A431_GPIGFP/091113_A431GPIGFP_CP393-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091113_A431_GPIGFP/091113_A431GPIGFP_CP394-1be/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/091113_A431_GPIGFP/091113_A431GPIGFP_CP395-1be/BATCH',...
                          '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100402_A431_Macropinocytosis/100402_A431_Macropinocytosis_CP392-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100402_A431_Macropinocytosis/100402_A431_Macropinocytosis_CP393-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100402_A431_Macropinocytosis/100402_A431_Macropinocytosis_CP394-1bd/BATCH',...
                         '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/100402_A431_Macropinocytosis/100402_A431_Macropinocytosis_CP395-1bd/BATCH'};
cell_file='Measurements_Cell_Vesicle_Features-v2';
vesicle_names={
 'ChtxVes',...    
 'TfVesicles',...
      'TfVesicles',...
        'ChtVesicles',...
    'DextranVesicles',...
    'ChtVesicles',...
    'LDLVesicles',...
    'EGFVesicles',...
    'GFPVesicles',...
   'MacroVesicles',...
   };

           config_paths={

                 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090309_A431-Chtx-GM130.txt',...
                 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090309_A431-Chtx-GM130.txt',...
                 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090309_A431-Chtx-GM130.txt',...
                 '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090309_A431-Chtx-GM130.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090203_Mz_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090203_Mz_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090203_Mz_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090203_Mz_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090217_A431_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090217_A431_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090217_A431_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090217_A431_Tf_EEA1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090928_A431_Chtx_Lamp1_chtxchannel.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090928_A431_Chtx_Lamp1_chtxchannel.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090928_A431_Chtx_Lamp1_chtxchannel.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090928_A431_Chtx_Lamp1_chtxchannel.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090403_A431_Dextran_GM1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090403_A431_Dextran_GM1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090403_A431_Dextran_GM1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-090403_A431_Dextran_GM1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091127_A431_Chtx_Golgi_AcidWash.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091127_A431_Chtx_Golgi_AcidWash.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091127_A431_Chtx_Golgi_AcidWash.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091127_A431_Chtx_Golgi_AcidWash.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100215_A431_Actin_LDL.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100215_A431_Actin_LDL.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100215_A431_Actin_LDL.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100215_A431_Actin_LDL.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100224_A431_EGF_Cav1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100224_A431_EGF_Cav1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100224_A431_EGF_Cav1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100224_A431_EGF_Cav1.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091113_A431_GPIGFP.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091113_A431_GPIGFP.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091113_A431_GPIGFP.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-091113_A431_GPIGFP.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100402_A431_Macropinocytosis.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100402_A431_Macropinocytosis.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100402_A431_Macropinocytosis.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100402_A431_Macropinocytosis.txt',...
                     '/BIOL/imsb/fs3/bio3/bio3/Data/Users/Yanic/measurement_output/ProbModel_Settings_QuantPlot-100402_A431_Macropinocytosis.txt'
                     
                 };
        channels=[
            2,2,2,3,3,3,3,2,3,3 
             
             ];
     
         channel_names={'RescaledGreen','RescaledGreen','RescaledGreen','RescaledRed','RescaledRed','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledRed'};
status=fileattrib(strcat('/cluster/home/biol/lprisca/vesicles/ves',sprintf('%d',ceil(assay_index/4)),'/',vesicle_file,sprintf('%d',assay_index)));
         if(~status)
%Loop over plates
for(plate=assay_index:assay_index)
    %Load basic data
    
                       basic_files=dir(npc(strcat(plate_paths{plate},'/*BASICDATA*')));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;
        load(npc(strcat(plate_paths{plate},'/',basic_path)));
        [features,~,meta] =getRawProbModelData2(npc(plate_paths{plate}),npc(config_paths{plate}));
        %Load parents,locations and intensities
        
        %Special case TF plates
%         if((plate<13)&&(plate>4))
%                    load(npc(strcat(plate_paths{plate},'/','Measurements_','TfPixel','_Parent.mat')));
       %     parents1=eval((strcat('handles.Measurements.',vesicle_names{ceil(plate/4)},'.Parent')));
        load(npc(strcat(plate_paths{plate},'/','Measurements_',vesicle_names{ceil(plate/4)},'_Location.mat')));
        locations1=eval((strcat('handles.Measurements.',vesicle_names{ceil(plate/4)},'.Location')));
            load(npc(strcat(plate_paths{plate},'/','Measurements_',vesicle_names{ceil(plate/4)},'_Parent.mat')));
        parents1=eval((strcat('handles.Measurements.',vesicle_names{ceil(plate/4)},'.Parent')));
         %  load(strcat(plate_paths{plate},'/','Measurements_',vesicle_names{plate},'_Intensity_RescaledRed.mat'));
        %intensities1=eval(strcat('handles.Measurements.',vesicle_names{plate},'.Intensity_RescaledRed'));
    load(npc(strcat(plate_paths{plate},'/','Measurements_Nuclei_Location')));
    %Load nuclei locatio
    nuclei=eval('handles.Measurements.Nuclei.Location');
    PlateDataHandles = struct();
    PlateDataHandles = LoadMeasurements(PlateDataHandles,npc([plate_paths{plate},'/','Measurements_Image_FileNames.mat']));

    %Allocate mariz for v8 features
    size1=size(cat(1,nuclei{:}),1);
    %Allocate cell array for image
    vesicle_features=cell(size(locations1,2),1);
    %Loop over all images
    cell_count=1;
cell_features=NaN(size(features,1),2);
dist=10;
    K = zeros(length(dist),1);
    %Path to TIFF directory of current plate
    image_path=strrep(plate_paths{plate},'/BATCH','/TIFF');
%'Z:\Data\Users\Prisca\090203_Mz_Tf_EEA1_harlink_03_1ad\090203_Mz_Tf_EEA1_CP392-1ad\TIFF\';
%Path to Segmentation directory of current plate
segmentation_path=strrep(plate_paths{plate},'/BATCH','/SEGMENTATION');
load(npc(strcat(plate_paths{plate},'/','Batch_data.mat')));
ident_column=handles.Settings.VariableValues;
ident_column1=ident_column(:,2);
%Get index of rescaled green or rescaledred
index_rescaled=find(strcmp(ident_column1,channel_names{(ceil(assay_index/4))}));
LowestPixelOrig=str2num(ident_column{index_rescaled,4});
HighestPixelOrig=str2num(ident_column{index_rescaled,5});
LowestPixelRescale=str2num(ident_column{index_rescaled,6});
HighestPixelRescale=str2num(ident_column{index_rescaled,7});
    for(image=1:size(nuclei,2))
        %Copied from the cprescale function
        %Load proper channel
        string_r=npc([image_path,'\',PlateDataHandles.Measurements.Image.FileNames{image}{channels(ceil(assay_index/4))}]);
        channel_image1 = imread(string_r);
        
        channel_image=double(channel_image1)/double(max(max(channel_image1)));  
        %%% Rescales the Image.
    InputImageMod = channel_image;
    %Any pixel in the original image lower than the user-input lowest bound is
    %pinned to the lowest value.
    InputImageMod(InputImageMod < LowestPixelOrig) = LowestPixelOrig;
    %Any pixel in the original image higher than the user-input highest bound is
    %pinned to the lowest value.
    InputImageMod(InputImageMod > HighestPixelOrig) = HighestPixelOrig;
    %Scales and shifts the original image to produce the rescaled image
    scaleFactor = (HighestPixelRescale - LowestPixelRescale)  / (HighestPixelOrig - LowestPixelOrig);
    shiftFactor = LowestPixelRescale - LowestPixelOrig;
    OutputImage = InputImageMod + shiftFactor;
    channel_image = OutputImage * scaleFactor;
    %End of copy
    
 string_r=npc([segmentation_path,'\',PlateDataHandles.Measurements.Image.FileNames{image}{1}(1:end-4),'_SegmentedCells.png']);
       
            current_segmentation = imread(string_r);
        

  
        if(mod(image,100)==0)
            image
        end;
        %Extarct al vesicle locations for the current image
        cell_locations=locations1{image};
        cell_parents=parents1{image};
        cell_nuclei=nuclei{image};
    %Loop over all cells
    %Allocate array for current image
    new_array=NaN(size(cell_locations,1),6);
    vesicle_count=1;
    image_cells=find((meta(:,6)==image));
    %Loop only over cells which are left over after clean up
    %Since 20 % to 30 % of cells are removed by clean up this saves a lot
    %of time
    for(cell_index1=1:size(image_cells,1))
         %Cast current nucleus index into nucleus indices in meta
         cell_index=meta(image_cells(cell_index1),7);
        %Find absolute cell index of the current cell
        absolute_cell=image_cells(find(meta(image_cells,7)==cell_index));
        %Get 2D locations of all pixels in the current cell
       
       
        if(~isempty(absolute_cell))
            %Get list of vesicle indices for cell cell_index
            I=find(cell_parents(:,2)==cell_index);
            if(length(I)>=1)
                [pixels_x,pixels_y]=find(current_segmentation==cell_index);
                %Feature 5:Distance to nucleus
                 new_array(vesicle_count:length(I)-1+vesicle_count,1)=(arrayfun(@(x) ((cell_nuclei(cell_index,1)-cell_locations(x,1)).^2+(cell_nuclei(cell_index,2)-cell_locations(x,2)).^2),I))/features(absolute_cell,3);
              %Image based variant of features 6 and 7
              new_array(vesicle_count:length(I)-1+vesicle_count,2)=arrayfun(@(x) sum(sum(channel_image((find(((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2)<81))))),I);
              new_array(vesicle_count:length(I)-1+vesicle_count,3)=arrayfun(@(x) sum(sum(channel_image((find(((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2)<144))))),I);
              %Feature 7: Number of neighbours within 9 and 12 pixels
         %Old:Useless due to small number of vesicles       new_array(vesicle_count:length(I)-1+vesicle_count,7)=arrayfun(@(x) length(find(((cell_locations(I,1)-cell_locations(x,1)).^2+(cell_locations(I,2)-cell_locations(x,2)).^2)<144)),I);
         %Old:Useless due to small number of vesicles           new_array(vesicle_count:length(I)-1+vesicle_count,6)=arrayfun(@(x) length(find(((cell_locations(I,1)-cell_locations(x,1)).^2+(cell_locations(I,2)-cell_locations(x,2)).^2)<81)),I);
           
           %Feature 8 : Radious containing 40 % of all vesicles
         indices=1:length(I);
           indices=indices';
%  Old:           out=(arrayfun(@(x) interp1q(indices,sort((cell_locations(I,1)-cell_locations(x,1)).^2+(cell_locations(I,2)-cell_locations(x,2)).^2),[0.4*length(I);0.6*length(I)]),I,'UniformOutput',false));
%  Old:                new_array(vesicle_count:length(I)-1+vesicle_count,8:9)=sqrt(cat(2,out{:}))';
%Images based feature 8 and 9
%(arrayfun(@(x)
%interp1q(indices,sort((pixels_x-cell_locations(x,1)).^2+(pixels_y-cell_locations(x,2)).^2),[0.4*length(I);0.6*length(I)]),I,'UniformOutput',false));
%Sort the pixel values according to distance from a specified vesicle
%indexed
%by I
[out_values,out_sorted]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2),I,'UniformOutput',false));

total_intensity=sum(sum(channel_image(sub2ind(size(channel_image),pixels_x,pixels_y))));
for(j=1:length(I))
temp=0;


count=1;
fract=0.4;
out_values1=sqrt(out_values{j});
out_sorted1=(out_sorted{j});
last_index=0;
%Cumulative sum of intensities
sum_intensity=cumsum(channel_image(pixels_x(out_sorted1)+size(channel_image,1)*(pixels_y(out_sorted1)-1)));
 new_array(vesicle_count+j-1,4)=out_values1(find(sum_intensity>0.4*total_intensity,1,'first'));
 new_array(vesicle_count+j-1,5)=out_values1(find(sum_intensity>0.6*total_intensity,1,'first'));
new_array(vesicle_count+j-1,6)=absolute_cell;
end;

%Calculate 
              vesicle_count=length(I)+vesicle_count;
                  %Cell feature1: Vesicles per cell area (cell size)
    cell_features(absolute_cell,1)=vesicle_count/length(pixels_x);
    %Cell features 2: Ripley K on the vesicle location vector
    locs=cell_locations(I,1:2);
    N=length(I);

% rbox is distance to box

DX = repmat(locs(:,1),1,N)-repmat(locs(:,1)',N,1);
DY = repmat(locs(:,2),1,N)-repmat(locs(:,2)',N,1);
DIST = sqrt(DX.^2+DY.^2);
DIST = sort(DIST);
K=NaN;
if(length(find(DIST(2:end,:)<10))>=1)
 K=sum(sum(DIST(2:end,:)<10))/N;
  lambda = N/features(absolute_cell,3);
K = K/lambda;
end;
cell_features(absolute_cell,2)=K;
    end;

        
 
    end;
    end;
           
    vesicle_features{image}=new_array;
    end;
    %Write new vesicle feature measurement file
    
    mkdir(strcat('/cluster/home/biol/lprisca/vesicles/ves',sprintf('%d',ceil(assay_index/4))));
     save((strcat('/cluster/home/biol/lprisca/vesicles/ves',sprintf('%d',ceil(assay_index/4)),'/',vesicle_file,sprintf('%d',plate))),'vesicle_features');
     save((strcat('/cluster/home/biol/lprisca/vesicles/ves',sprintf('%d',ceil(assay_index/4)),'/',cell_file,sprintf('%d',plate))),'cell_features');  
end;

         end;
end;
end