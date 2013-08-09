function [t]=computeVesicles_modules(batch_in,input_path)
%computeVesicle_modules- Compute derived vesicle features based on basic vesicle features
% Output: The function computes the following vesicle features for every vesicle in the order indicated below:
%  -Distance of vesicle centre to nucleus centre in pixels
%  -Fraction of intensity contained in a circle with raduius 9 pixels around a vesicle
%  -Fraction of intensity contained in a circle with raduius 15 pixels around a vesicle
%  -Radius of a circle around the vesicle covering more than 40 % of the cell's intensity
%  -Radius of a circle around the vesicle covering more than 60 % of the cell's intensity
%  -Index of associated cell in image
%  -Relative distances of vesicle obtained by dividing the absolute distance by the length of the line starting from the nucleus crossing the vesicle centre and reaching the membrane
%  -Vesicle index
%  Furthermore, 2 per cell features are computed for each cell:
%  -Number of vesicles per cell divided by cell area
%  -Ripley K for the vesicle pattern of the cell
%
%  Input:
%  -batch_in: Path of Batch directory containing the following files:
%  -config_file: Path to getRawProbModelDat2 file which is used to exclude
%  cells for which computation of vesicles is not necessary.
%  -input_path: Path to a multivariate settings file containing parameters
%  for the vesicle step of the pipeline
%Example: computeVesicles_modules('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/111017_A431_w2Chtx_CP84-1ac/BATCH','/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/Settings_Cells_MeanIntensity_RescaledGreen_multivariate.txt','/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/multivariate_settings.txt')
%computes vesicles for the specified plate

%   batch_in='Y:\Prisca\endocytome_FollowUps\111001_A431_w2Tf\111001_A431_w2Tf_CP82-1aa\BATCH';
%   config_file='Y:\Prisca\endocytome_FollowUps\Settings_Cells_MeanIntensity_RescaledGreen_multivariate.txt';
%   input_path='Y:\Prisca\endocytome_FollowUps\multivariate_settings.txt';
%   batch_in='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/100215_A431_Actin_LDL_CP392-1bi/BATCH';
%   input_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/100215_A431_w3LDL/multivariate_settings_LDLVes.txt';
% %  vesicle_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH/Measurements_Vesicles_CustomSingleChtxVes.mat';
% %  cell_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH/Measurements_Cells_CustomSingleChtxVes.mat';

%     batch_in='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/111017_A431_w2Chtx_CP84-1ac/BATCH'
%     input_path='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/multivariate_settings.txt'
%     config_file='/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome_FollowUps_hardlinks01/111017_A431_w2Chtx/Settings_Cells_MeanIntensity_RescaledGreen_multivariate.txt'
%Load vesicle settings
    batch_in=npc(batch_in);
    all_200=1:200;
    [fid, message] = fopen(npc(input_path));
    if fid == (-1)
        error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', input_path, message);
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
        vesicle_file=strcat('Measurements_Vesicles_CustomSingle',multivariate_config.vesicle.vesicle_names2);    
    else
        vesicle_file=strcat('Measurements_Vesicles_CustomSingle',multivariate_config.vesicle.vesicle_names2);    
    end;
    if(isfield(multivariate_config.vesicle,'cell_file'))
%         cell_file=multivariate_config.vesicle.cell_file;
        cell_file=strcat('Measurements_Cells_CustomSingle',multivariate_config.vesicle.vesicle_names2);    
    else
        cell_file=strcat('Measurements_Cells_CustomSingle',multivariate_config.vesicle.vesicle_names2);    
    end;
    %Load cells to get information which cells can be excluded from further
    %processing
    [~,~,meta] =getRawProbModelData2(npc(batch_in),npc(multivariate_config.setting_file));
    %Load a couple of files
    try
        basic_files=dir(npc(strcat(batch_in,'/*BASICDATA*')));
        if(size(basic_files,1)>1)
            sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
        end;
        basic_path=basic_files.name;
        load(npc(strcat(batch_in,'/',basic_path)));
        load(npc(strcat(batch_in,'/','Measurements_',vesicle_names,'_Location.mat')));
        locations1=eval((strcat('handles.Measurements.',vesicle_names,'.Location')));
        load(npc(strcat(batch_in,'/','Measurements_',vesicle_names,'_Parent.mat')));
        %This switch is hack allowing for different vesicle input
        %formats sometimes occuring in Prisca screens.
        if(length(eval((strcat('handles.Measurements.',vesicle_names,'.ParentFeatures'))))>1)
            parents1=eval((strcat('handles.Measurements.',vesicle_names,'.Parent')));
            PARENT_SELECTION=2;
        else
            %Relate not available use EGF Pixel to cell information
            load(npc(strrep(strcat(batch_in,'/','Measurements_',vesicle_names,'_Parent.mat'),'Vesicles','Pixel')));
            parents1=eval((strrep(strcat('handles.Measurements.',vesicle_names,'.Parent'),'Vesicles','Pixel')));
            PARENT_SELECTION=1;
        end;
        %Load nuclei location
        load(npc(strcat(batch_in,'/','Measurements_Nuclei_Location.mat')));
        nuclei=eval('handles.Measurements.Nuclei.Location');
        PlateDataHandles = struct();
        PlateDataHandles = LoadMeasurements(PlateDataHandles,npc([batch_in,'/','Measurements_Image_FileNames.mat']));
        load(npc(strcat(batch_in,'/','Measurements_Image_ObjectCount.mat')));
    catch exception
        %If any of the files cannot be loaded we cannot continue, currently we
        %just rethrow the exception
        throw(exception);
    end;
    object_features=eval('handles.Measurements.Image.ObjectCountFeatures');
    object_count=eval('handles.Measurements.Image.ObjectCount');
    object_count=cat(1,object_count{:});
    object_count=object_count(:,find(strcmp('Cells',object_features)));
    dist=10;
    K = zeros(length(dist),1);
    %Path to TIFF directory of current plate
    image_path=strrep(batch_in,strcat(filesep,'BATCH'),strcat(filesep,'TIFF'));
    %Path to Segmentation directory of current plate
    segmentation_path=strrep(batch_in,strcat(filesep,'BATCH'),strcat(filesep,'SEGMENTATION'));
    load(npc(strcat(batch_in,'/','Batch_data.mat')));
    %Get rescaled information for channel to treat out of BATCH_DATA
    ident_column=handles.Settings.VariableValues;
    ident_column1=ident_column(:,2);
    index_rescaled=find(strcmp(ident_column1,channel_names));
    LowestPixelOrig=str2num(ident_column{index_rescaled,4});
    HighestPixelOrig=str2num(ident_column{index_rescaled,5});
    LowestPixelRescale=str2num(ident_column{index_rescaled,6});
    HighestPixelRescale=str2num(ident_column{index_rescaled,7});
    %Ensures that every image data we need is actually available
    num_images=min([length(PlateDataHandles.Measurements.Image.FileNames),length(locations1),length(parents1),length(nuclei)]);
    %Allocate space for single vesicle vesicles: empty cell per image
    vesicle_features=cell(num_images,1);
    %Allocate space for cell vesicle features: empty cell per image
    cell_features=cell(length(object_count),1);
    %Loop over images
    for(image=1:num_images)
        %Rescale channel containing the vesicles
        string_r=npc([image_path,'/',PlateDataHandles.Measurements.Image.FileNames{image}{channels}]);
        channel_image1 = imread(string_r);
        channel_image=double(channel_image1)/double((2^16)-1);
        %%% Rescales the Image.
        %Any pixel in the original image lower than the user-input lowest bound is
        %pinned to the lowest value.
        channel_image(channel_image < LowestPixelOrig) = LowestPixelOrig;
        %Any pixel in the original image higher than the user-input highest bound is
        %pinned to the lowest value.
        channel_image(channel_image > HighestPixelOrig) = HighestPixelOrig;
        %Scales and shifts the original image to produce the rescaled image
        scaleFactor = (HighestPixelRescale - LowestPixelRescale)  / (HighestPixelOrig - LowestPixelOrig);
        shiftFactor = LowestPixelRescale - LowestPixelOrig;
        channel_image = channel_image + shiftFactor;
        channel_image = channel_image * scaleFactor;
        %Get segmentation,vesicle locations, vesicle parents and nuclei for current image
        %
        string_r=npc([segmentation_path,'/',PlateDataHandles.Measurements.Image.FileNames{image}{1}(1:end-4),'_SegmentedCells.png']);
        current_segmentation = imread(string_r);
        vesicle_locations=round(locations1{image});
        vesicle_parents=parents1{image};
        cell_nuclei=nuclei{image};
        %Progress bar for results file or bpeek
        if(mod(image,100)==0)
            image
        end;
        

        %All indices of cells in the current image
        image_cells=find((meta(:,6)==image));
        new_array_c=NaN(object_count(image),2);
        vesicle_count=1;
        %Remove vesicles/pixels having index zero
       
        if(PARENT_SELECTION==1)
            [I1,I2]=find((vesicle_parents==0));
        vesicle_parents(I1,:)=[];
        end;
        %Loop over cell and count number of vesicles expected in the next
        %image. This number is to used to preallocate a matrix storing all
        %vesicle feature of the current image.
        num_vesicles=0;
        for(cell_index=1:object_count(image))
                %Find absolute cell index of the current cell
            absolute_cell=image_cells(find(meta(image_cells,7)==cell_index));
            if((~isempty(vesicle_parents))&&(~isempty(absolute_cell)))
                %Find vesicles having current cell as parent
                num_vesicles=num_vesicles+size(vesicle_locations,1);
            else
                I=[];
            end;
        end;
        %Allocate array keeping the new single vesicle and single cell features for all
        %vesicles and cells of the current image
        if(num_vesicles>0)
            new_array=NaN(size(vesicle_locations,1),8);
        else
            %Empty image allocate one NaN row as done by CellProfiler
            new_array=NaN(1,8);
        end;
        %Loop over cells, Note that if the image is empty object_count(image)
        %will be zero and the loop over cells will not execute
        for(cell_index=1:object_count(image))
            %Find absolute cell index of the current cell
            absolute_cell=image_cells(find(meta(image_cells,7)==cell_index));
            if(~isempty(vesicle_parents))
                %Find vesicles having current cell as parent
                I=find(vesicle_parents(:,PARENT_SELECTION)==cell_index);
            else
                I=[];
            end;
            %Here we do a couple of checks to make sure the current cell is
            %associated with vesicle by checking for nonempty indices vectors
            %of vesicles and that the clel was not removed before
            if((~isempty(absolute_cell)))
                %At least ohne vesicle must be there if we continue
                if(length(I)>=1)
                    %Find pixels of current cell
                    [pixels_x,pixels_y]=find(current_segmentation==cell_index);
                    %If tyhe cell contains no pixels we continue: Last check
                    %that tretament of vesicvles of current cell is visible
                    if(length(pixels_x)==0)
                        continue;
                    end;
                    %Total intensity after rescaling of current cell
                    %                 channel_image1(find(current_segmentation~=cell_index))=0;
                    I_image=sub2ind(size(channel_image),pixels_x,pixels_y);
                    total_intensity=sum(sum(channel_image(I_image)));
                    new_array(I,8)=I;
                    %Absolute Distance to nucleus
                    new_array(I,1)=sqrt((cell_nuclei(cell_index,1)-vesicle_locations(I,1)).^2+(cell_nuclei(cell_index,2)-vesicle_locations(I,2)).^2);
                    %Loop over vesicles
                    for(j=1:length(I))
                        %Fraction of intensity in 9 pixels distance
                        new_array(I(j),2)=sum(sum(channel_image(I_image((((pixels_x-vesicle_locations(I(j),2)).^2+(pixels_y-vesicle_locations(I(j),1)).^2)<81)))))/total_intensity;
                        %Fraction of intensity in 15 pixels distance
                        new_array(I(j),3)=sum(sum(channel_image(I_image((((pixels_x-vesicle_locations(I(j),2)).^2+(pixels_y-vesicle_locations(I(j),1)).^2)<225)))))/total_intensity;
                        %Sort pixels of cells according to rising distance from
                        %vesicle for all vesicles
                        [out_values1,out_sorted1]= sort((pixels_x-vesicle_locations(I(j),2)).^2+(pixels_y-vesicle_locations(I(j),1)).^2);
                        %Slope of ,liine from nucleus to current vesicle centre
                        a=[(vesicle_locations(I(j),2)-cell_nuclei(cell_index,2)),(vesicle_locations(I(j),1)-cell_nuclei(cell_index,1))]./new_array(I(j),1);
                        %Continue further along the line up to 200m steps: If
                        %the cell is very big this code might fail. On the
                        %other hand such cells should be removed in any case as
                        %a missegmentation is the likely cause for the size of
                        %the cell
                        current_nuclei_x=round(vesicle_locations(I(j),2)+all_200*a(1));
                        current_nuclei_y=round(vesicle_locations(I(j),1)+all_200*a(2));
                        %Set all points outside the current image to the border
                        %of the image
                        current_nuclei_x(current_nuclei_x>size(current_segmentation,1))=size(current_segmentation,1);
                        current_nuclei_y(current_nuclei_y>size(current_segmentation,2))=size(current_segmentation,2);
                        current_nuclei_x(current_nuclei_x<1)=1;
                        current_nuclei_y(current_nuclei_y<1)=1;
                        %Get information whether the points are contained in
                        %the cell or not
                        current_nuclei=current_segmentation(sub2ind(size(current_segmentation),current_nuclei_x,current_nuclei_y));
                        %Find first occurence of a cell index in ther
                        %segmentation matrix different than the current cell
                        %index this implies that we have crossed the border and
                        %are outside the cell
                        new_array(I(j),7)=  new_array(I(j),1)./(new_array(I(j),1)+min([NaN,find(current_nuclei~=cell_index,1,'first')]));
                        sum_intensity=cumsum(channel_image(pixels_x(out_sorted1)+size(channel_image,1)*(pixels_y(out_sorted1)-1)));
                        new_array(I(j),4)=sqrt(out_values1(find(sum_intensity>=0.4*total_intensity,1,'first')));
                        new_array(I(j),5)=sqrt(out_values1(find(sum_intensity>=0.6*total_intensity,1,'first')));
                        new_array(I(j),6)=cell_index;
                    end;
                    vesicle_count=length(I);
                    %Cell feature1: Vesicles per cell area (cell size)
                    new_array_c(cell_index,1)=vesicle_count/length(pixels_x);
                    %Cell features 2: Ripley K on the vesicle location vector
                    locs=vesicle_locations(I,1:2);
                    N=length(I);
                    %Implementation for calculating Ripley K from an an
                    %external implementation in MATLAB
                    %(http://www.colorado.edu/geography/class_homepages/geo
                    %g_4023_s07/labs/lab10/RipleysK.m)
                    DX = repmat(locs(:,1),1,N)-repmat(locs(:,1)',N,1);
                    DY = repmat(locs(:,2),1,N)-repmat(locs(:,2)',N,1);
                    DIST = sqrt(DX.^2+DY.^2);
                    DIST = sort(DIST);
                    K=NaN;
                    if(length(find(DIST(2:end,:)<10))>=1)
                        K=sum(sum(DIST(2:end,:)<10))/N;
                        lambda = N/length(pixels_x);
                        K = K/lambda;
                    end;
                    new_array_c(cell_index,2)=K;
                end;
                
            else
                %If the cell doesn not survive cleanup we don't treat its
                %vesicles and consequently do not change vesicle count
%                 vesicle_count=length(I)+vesicle_count;
            end;
            %Deallocate some of the variables occupieng substantial
            %memory. This helps to reclaim memory faster which
            %decreases memory requirements and might increase speed due
            %to decreased swapping
            clear('pixels_x');
            clear('pixels_y');
        end;
        %Store single vesicle feature and cell features for current image
        vesicle_features{image}=new_array;
        cell_features{image}=new_array_c;
    end;
    %Create output by saving the single vesicle and single features
    vesicle_labels={'Distance(in pixels)','Intensity in 9 pixels distance/total intensity','Intensity in 15 pixels distance/total intensity','Radius covering 40 % of total intensity','Radius covering 60 % of total intensity','Cell index','Relative distance','Vesicle index'};
    cell_names={'Number of vesicles/number of pixels of cell','Ripley K value'};
    handles=struct('Measurements',struct('Vesicles',struct(strcat(vesicle_names,'Features'),{vesicle_labels},vesicle_names,{vesicle_features})));
    save(npc(strcat(batch_in,'/',vesicle_file)),'handles');
    cell_names={'Number of vesicles/number of pixels of cell','Ripley K value'};
    cell_features=cell_features';
    handles=struct('Measurements',struct('Cells',struct(strcat(vesicle_names,'Features'),{cell_names},vesicle_names,{cell_features})));
    %Newest save versions are more suitable for very big files
    save(npc(strcat(batch_in,'/',cell_file)),'handles','-v7.3');
end