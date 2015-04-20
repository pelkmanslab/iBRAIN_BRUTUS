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

%%% MATCH TO THIS, and use input and output file names
% computeVesicle_modules('${BATCHDIR}','${BATCHDIR}','${count}','${SVMOUTPUTFILE}','${SVMSETTINGSFILE}');
% function [t]=computeVesicles_modules(batch_in,batch_out,settings_file,vesicle_file,cell_file)

% if nargin==0
batch_in=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH');
batch_out=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP395-1ad/BATCH');
settings_file=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/TfVes.txt');
vesicle_file=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH/Measurements_Vesicles_CustomSingleChtxVes.mat');
cell_file=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090928_A431_Chtx_Lamp1/090309_A431_Chtx_Lamp1_CP394-1ba/BATCH/Measurements_Cells_CustomSingleChtxVes.mat');
% end

assay_index=1;
% if(exist(vesicle_file,'file'))
%     return;
% end;
%Load vesicle settings

batch_in=npc(batch_in);
batch_out=npc(batch_out);

all_200=1:200;

% open the file
[fid, message] = fopen(npc(settings_file));
if fid == (-1)
    error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', filename, message);
end

try
    % read file
    out = fread(fid,'*char')';
catch exception
    % close file
    fclose(fid);
    throw(exception);
end

% close file
fclose(fid);
eval(out);

% if(exist(npc(vesicle_file),'file'))
%     return;
% end;
indices=strfind(settings_file,filesep);
prob_settings=strcat(settings_file(1:indices(end)),'ProbModel_Settings_Minimal.txt');
[~,~,meta] =getRawProbModelData2(batch_in,npc(prob_settings));
last_path_part=settings_file(indices(end)+1:end-4);
% vesicle_names={
%  'ChtxVes',...
%  'TfVesicles',...
%       'TfVesicles',...
%         'ChtVesicles',...
%     'DextranVesicles',...
%     'ChtVesicles',...
%     'LDLVesicles',...
%     'EGFVesicles',...
%     'GFPVesicles',...
%    'MacroVesicles',...
%    };
%
%
%
%
%         channels=[
%             2,2,2,3,3,3,3,2,3,3
%
%              ];
%
%          channel_names={'RescaledGreen','RescaledGreen','RescaledGreen','RescaledRed','RescaledRed','RescaledRed','RescaledRed','RescaledGreen','RescaledRed','RescaledRed'};

%Loop over plates

%Load basic data

basic_files=dir(npc(strcat(batch_in,'/*BASICDATA*')));
if(size(basic_files,1)>1)
    sprintf(strcat('More than 1 basic data file:',basic_file{1}.name,' is used'))
end;
basic_path=basic_files.name;
load(npc(strcat(batch_in,filesep,basic_path)));
% [features,~,meta] =getRawProbModelData2(npc(batch_in),npc(config_paths));
%Load parents,locations and intensities

%Special case TF plates
%         if((plate<13)&&(plate>4))
%                    load(npc(strcat(batch_in,filesep,'Measurements_','TfPixel','_Parent.mat')));
%     parents1=eval((strcat('handles.Measurements.',vesicle_names{assay_index},'.Parent')));
load(npc(strcat(batch_in,filesep,'Measurements_',vesicle_names{assay_index},'_Location.mat')));
locations1=eval((strcat('handles.Measurements.',vesicle_names{assay_index},'.Location')));
load(npc(strcat(batch_in,filesep,'Measurements_',vesicle_names{assay_index},'_Parent.mat')));
parents1=eval((strcat('handles.Measurements.',vesicle_names{assay_index},'.Parent')));
%Load nuclei locatio
load(npc(strcat(batch_in,filesep,'Measurements_Nuclei_Location')));
nuclei=eval('handles.Measurements.Nuclei.Location');
PlateDataHandles = struct();
PlateDataHandles = LoadMeasurements(PlateDataHandles,npc([batch_in,filesep,'Measurements_Image_FileNames.mat']));
load(npc(strcat(batch_in,filesep,'Measurements_Image_ObjectCount')));
object_features=eval('handles.Measurements.Image.ObjectCountFeatures');
object_count=eval('handles.Measurements.Image.ObjectCount');
object_count=cat(1,object_count{:});
object_count=object_count(:,find(strcmp('Cells',object_features)));

%Allocate space for single vesicle vesicles: empty cell per image
vesicle_features=cell(size(locations1,2),1);
%Allocate space for cell vesicle features: empty cell per image
cell_features=cell(size(locations1,2),1);
dist=10;
K = zeros(length(dist),1);
%Path to TIFF directory of current plate
image_path=strrep(batch_in,'BATCH','TIFF');
%'Z:/Data/Users/Prisca/endocytome/090203_MZ_w2Tf_w3EEA1/090203_Mz_Tf_EEA1_CP392-1ad/TIFF/';
%Path to Segmentation directory of current plate
segmentation_path=strrep(batch_in,'BATCH','SEGMENTATION');
load(npc(strcat(batch_in,filesep,'Batch_data.mat')));
%Get rescaled information for channel to treat out of BATCH_DATA
ident_column=handles.Settings.VariableValues;
ident_column1=ident_column(:,2);

index_rescaled=find(strcmp(ident_column1,channel_names{(ceil(assay_index))}));
LowestPixelOrig=str2num(ident_column{index_rescaled,4});
HighestPixelOrig=str2num(ident_column{index_rescaled,5});
LowestPixelRescale=str2num(ident_column{index_rescaled,6});
HighestPixelRescale=str2num(ident_column{index_rescaled,7});
%out_values and out_sorted should coorespond to the maximum number of
%pixles of a cell since we don't know this number we allocate sufficent
%space to hold all pixles of an enitre TIFF image
out_values=zeros(1392*1040,1);
out_sorted=zeros(1392*1040,2);
t=zeros(800,800);
[x,y]=find(t==0);
[~,out]=sort((x-400).*(x-400)+(y-400).*(y-400));
cell_data=zeros(800,800);
%Offsets with rising diatance
complete=sub2ind(size(cell_data),x(out),y(out));
complete_dist=[x(out),y(out)]-400;
complete_dist1=arrayfun(@(x) norm(complete_dist(x,:)),1:length(complete_dist));
dist_indices=arrayfun(@(x) find(complete_dist1>=x,1,'first'),1:400);
%Loop over images

for(image=1:size(nuclei,2))
    %Copied from the cprescale function: Rescale image
    %Load proper channel
    
    string_r=npc([image_path,filesep,PlateDataHandles.Measurements.Image.FileNames{image}{channels(ceil(assay_index))}]);
    channel_image1 = imread(string_r);
    
    channel_image2=double(channel_image1)/double((2^16)-1);
    %%% Rescales the Image.
    InputImageMod = channel_image2;
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
    clear OutputImage;
    string_r=npc([segmentation_path,filesep,PlateDataHandles.Measurements.Image.FileNames{image}{1}(1:end-4),'_SegmentedCells.png']);
    
    current_segmentation = imread(string_r);
    
    
    %Progress bar for results file
%     if(mod(image,100)==0)
        fprintf('%s: working on image %d\n',mfilename,image)
%     end;
    
    %Extarct al vesicle locations for the current image
    cell_locations=round(locations1{image});
    cell_parents=parents1{image};
    cell_nuclei=nuclei{image};
    
    %Allocate array for current image
    new_array=NaN(size(cell_locations,1),8);
    vesicle_count=1;
    %All indices of cells in the current image
    image_cells=find((meta(:,6)==image));
    new_array_c=NaN(object_count(image),2);
    vesicle_count=1;
    %Loop over cells
    for(cell_index=1:object_count(image))
        
        %Find absolute cell index of the current cell
        absolute_cell=image_cells(find(meta(image_cells,7)==cell_index));
        I=find(cell_parents(:,2)==cell_index);
        if(~isempty(absolute_cell))
            %Get list of vesicle indices for cell cell_index
            
            %At least ohne vesicle must be there
            if(length(I)>=1)
                %Find pixles of current cell
                [pixels_x,pixels_y]=find(current_segmentation==cell_index);
                %Feature 5:Distance to nucleus
                new_array(vesicle_count:length(I)-1+vesicle_count,1)=(arrayfun(@(x) sqrt((cell_nuclei(cell_index,1)-cell_locations(x,1)).^2+(cell_nuclei(cell_index,2)-cell_locations(x,2)).^2),I));
                %Calculate slopes of vesicle to nucleus
                %                 [slope_vesicles]=arrayfun(@(x) (cell_locations(x,2)-cell_nuclei(cell_index,2))/(cell_locations(x,1)-cell_nuclei(cell_index,1)),I);
                %
                %                 %Calculate slopes of edges of cell
                %                 [edge_y,edge_x]=find((edge(current_segmentation&(current_segmentation==cell_index),'roberts',0)==1));
                %                           edge_upper=find(sign((edge_y-cell_nuclei(cell_index,2)))==1);
                %                 edge_lower=find(sign((edge_y-cell_nuclei(cell_index,2)))==-1);
                %                 edge_slopes=arrayfun(@(x) (edge_y(x)-cell_nuclei(cell_index,2))/(edge_x(x)-cell_nuclei(cell_index,1)),1:length(edge_x))';
                %
                %
                
                %Image based variant of features 6 and 7
                I_image=sub2ind(size(channel_image),pixels_x,pixels_y);
                %                  channel_image1(find(current_segmentation~=cell_index))=0;
                total_intensity=sum(sum(channel_image(I_image)));
                new_array(vesicle_count:length(I)-1+vesicle_count,2)=arrayfun(@(x) sum(sum(channel_image((find(((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2)<81)))))/total_intensity,I);
                new_array(vesicle_count:length(I)-1+vesicle_count,3)=arrayfun(@(x) sum(sum(channel_image((find(((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2)<225)))))/total_intensity,I);
                new_array(vesicle_count:length(I)-1+vesicle_count,8)=I;
                %Feature 8 : Radious containing 40 % of all vesicles
                indices=1:length(I);
                indices=indices';
                
                %Sort the pixel values according to distance from a specified vesicle
                %indexed
                %by I
                
                % out_sorted=cell(length(I),1);
                % [out_values(1:ceil(length(I)/6)),out_sorted(1:ceil(length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(1:ceil(length(I)/6)),'UniformOutput',false));
                % [out_values(ceil(length(I)/6)+1:ceil(2*length(I)/6)),out_sorted(ceil(length(I)/6)+1:ceil(2*length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(ceil(length(I)/6)+1:ceil(2*length(I)/6)),'UniformOutput',false));
                % [out_values(ceil(2*length(I)/6)+1:ceil(3*length(I)/6)),out_sorted(ceil(2*length(I)/6)+1:ceil(3*length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(ceil(2*length(I)/6)+1:ceil(3*length(I)/6)),'UniformOutput',false));
                % [out_values(ceil(3*length(I)/6)+1:ceil(4*length(I)/6)),out_sorted(ceil(3*length(I)/6)+1:ceil(4*length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(ceil(3*length(I)/6)+1:ceil(4*length(I)/6)),'UniformOutput',false));
                % [out_values(ceil(4*length(I)/6)+1:ceil(5*length(I)/6)),out_sorted(ceil(4*length(I)/6)+1:ceil(5*length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(ceil(4*length(I)/6)+1:ceil(5*length(I)/6)),'UniformOutput',false));
                % [out_values(ceil(5*length(I)/6)+1:ceil(6*length(I)/6)),out_sorted(ceil(5*length(I)/6)+1:ceil(6*length(I)/6))]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).*(pixels_x-cell_locations(x,2))+(pixels_y-cell_locations(x,1)).*(pixels_y-cell_locations(x,1))),I(ceil(5*length(I)/6)+1:ceil(6*length(I)/6)),'UniformOutput',false));
                %
                %
                
                
%                 % calculate the closest distance between each cell and an edge pixel
%                 matClosestDistanceToEdgePerCell = NaN(size(matNucleiPositions,1),1);
%                 if ~isempty(matEmptySpaceEdgeY)
%                     for iCell = 1:size(matNucleiPositions,1)
%                         matClosestDistanceToEdgePerCell(iCell) = min( sqrt( ...
%                                 (matEmptySpaceEdgeY - matNucleiPositions(iCell,1)) .^2 + ...
%                                 (matEmptySpaceEdgeX - matNucleiPositions(iCell,2)) .^2 ...
%                             ) );
%                     end    
%                 end
                
                
%                 % init result matrix
%                 tic
%                 matDists1 = NaN(length(I),size(pixels_x,1));
%                 matDists2 = NaN(length(I),size(pixels_x,1));
%                 for Ix = 1:length(I)
%                     [matDists1(Ix,:), matDist2(Ix,:)] = sort(sqrt((pixels_x-cell_locations(I(Ix),2)).^2+(pixels_y-cell_locations(I(Ix),1))));
%                 end
%                 toc
                
%                 tic
                [out_values2,out_sorted2]=(arrayfun(@(x) sort((pixels_x-cell_locations(x,2)).^2+(pixels_y-cell_locations(x,1)).^2),I,'UniformOutput',false));
%                 size(cat(2,out_values2{:}))
%                 toc
                
                for j=1:length(I)
                    a=[(cell_locations(I(j),2)-cell_nuclei(cell_index,2)),(cell_locations(I(j),1)-cell_nuclei(cell_index,1))]./new_array(vesicle_count+j-1,1);
                    
                    temp=0;
                    if(sign((cell_locations(I(j),2)-cell_nuclei(cell_index,2)))==1)
                        %Maximum pixles in x direction
                        a=a;
                        
                        
                    else
                        % a=-a;
                        
                        
                    end;
                    current_nuclei_x=round(cell_locations(I(j),2)+all_200*a(1));
                    current_nuclei_y=round(cell_locations(I(j),1)+all_200*a(2));
                    current_nuclei_x(current_nuclei_x>size(current_segmentation,1))=size(current_segmentation,1);
                    current_nuclei_y(current_nuclei_y>size(current_segmentation,2))=size(current_segmentation,2);
                    current_nuclei_x(current_nuclei_x<1)=1;
                    current_nuclei_y(current_nuclei_y<1)=1;
                    current_nuclei=current_segmentation(sub2ind(size(current_segmentation),current_nuclei_x,current_nuclei_y));
                    new_array(j-1+vesicle_count,7)=  new_array(vesicle_count+j-1,1)./(new_array(vesicle_count+j-1,1)+min([NaN,find(current_nuclei~=cell_index,1,'first')]));
                    % out_sorted(1:length(pixels_x),:)=([pixels_x-cell_locations(I(j),2),(pixels_y-cell_locations(I(j),1))]);
                    %
                    % out_sorted(1:length(pixels_x),:)=out_sorted(1:length(pixels_x),:)+400;
                    % I_cell=sub2ind(size(cell_data),out_sorted(1:length(pixels_x),1),out_sorted(1:length(pixels_x),2));
                    out_values1=(out_values2{j});
                    out_sorted1=(out_sorted2{j});
                    sum_intensity=cumsum(channel_image(pixels_x(out_sorted1)+size(channel_image,1)*(pixels_y(out_sorted1)-1)));
                    new_array(vesicle_count+j-1,4)=sqrt(out_values1(find(sum_intensity>=0.4*total_intensity,1,'first')));
                    new_array(vesicle_count+j-1,5)=sqrt(out_values1(find(sum_intensity>=0.6*total_intensity,1,'first')));
                    %Loop over all distances
                    % flag4=0;
                    % % I_max=find(complete_dist1<max_dist);
                    % % cell_data(:)=0;
                    % % cell_data(I_cell)=channel_image(I_image);
                    % current_intensity=sum(cell_data(complete(1:dist_indices(15))));
                    % for(dist=16:400)
                    %     if((current_intensity>0.4*total_intensity)&&(flag4==0))
                    %         flag4=dist-1;
                    %         new_array(vesicle_count+j-1,4)=dist-1;
                    %     elseif ((current_intensity>0.6*total_intensity))
                    %             new_array(vesicle_count+j-1,5)=dist-1;
                    %             break;
                    %         end;
                    %         current_intensity=current_intensity+sum(channel_image(sub2ind(size(channel_image),cell_locations(I(j),2)+complete_dist(dist_indices(dist-1):dist_indices(dist),1),cell_locations(I(j),1)+complete_dist(dist_indices(dist-1):dist_indices(dist),2))));
                    %     end;
                    %         % If we arrive here the dist-1 was not enough to cover 40 % resp.
                    %         % 60 % so adde all iontensities of pxiels having distance dist
                    %
                    %
                    % count=1;
                    % fract=0.4;
                    %
                    %out_sorted1=(out_sorted);
                    last_index=0;
                    %Cumulative sum of intensities for each additonal vesicles, note that cumsum is a builtin function
                    %The resulting speed gain outweights the burden of calculating the sums for
                    %each pixel
                    
                    % out_values(1:length((I_max)))=cumsum(cell_data(complete(I_max)));
                    %  new_array(vesicle_count+j-1,4)=complete_dist1(find(out_values(1:length((I_max)))>0.4*total_intensity,1,'first'));
                    %  new_array(vesicle_count+j-1,5)=complete_dist1(find(out_values(1:length((I_max)))>0.6*total_intensity,1,'first'));
                    %Cell index to whicht eh vesicle belongs this is used to later single
                    %vesicle features to cells
                    new_array(vesicle_count+j-1,6)=cell_index;
                    
                end;
                
                %Calculate
                vesicle_count=length(I)+vesicle_count;
                %Cell feature1: Vesicles per cell area (cell size)
                new_array_c(cell_index,1)=vesicle_count/length(pixels_x);
                
                %Cell features 2: Ripley K on the vesicle location vector
                locs=cell_locations(I,1:2);
                N=length(I);
                
                %Implementation for calculating Ripley K
                
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
            vesicle_count=length(I)+vesicle_count;
        end;
        
    end;
    %Store single vesicle feature and cell features for current image
    vesicle_features{image}=new_array;
    cell_features{image}=new_array_c;
end;


%Write new vesicle feature measurement file

vesicle_names={'Distance(in pixels)','Intensity in 9 pixels distance/total intensity','Intensity in 15 pixels distance/total intensity','Radius covering 40 % of total intensity','Radius covering 60 % of total intensity','Cell index','Relative distance','Vesicle count'};
cell_names={'Number of vesicles/number of pixels of cell','Ripley K value'};
handles=struct('Measurements',struct('Vesicles',struct(strcat(last_path_part,'Features'),{vesicle_names},last_path_part,{vesicle_features})));
save((strcat(vesicle_file)),'handles');
cell_names={'Number of vesicles/number of pixels of cell','Ripley K value'};
cell_features=cell_features';
handles=struct('Measurements',struct('Cells',struct(strcat(last_path_part,'Features'),{cell_names},last_path_part,{cell_features})));

save((strcat(cell_file)),'handles','-v7.3');




% end