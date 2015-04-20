
%This function takes a directory and returns there a list of filenames
%sorted according to increasing time point for channel ch
%ch:Channels trin g top recognized filenames belonging to channel ch
%batch:Directory containing al images
function [ tiffiles_all,subfile,divfile] = analyseHighspeedDirectory( batch,site )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
filenames=dirc((strcat(batch,'/','TIFF')),'f');
filenames=filenames(:,1);
tiffindices=strfind(filenames,'png');
tiffiles=filenames(find(cellfun(@(x) ~isempty(x),tiffindices)));
tiffiles=sort(tiffiles);
%Get a list of all possible sites
possible_sites=regexp(tiffiles,'F\d\d\d','match');
possible_sites(cellfun(@(x) isempty(x),possible_sites))=[];
possible_sites1=cellfun(@(x) x{1}(2:end),possible_sites,'UniformOutput',false);
possible_sites=cellfun(@(x) str2num(x),possible_sites1);
tiffiles_all=[];
for(site=unique(possible_sites))
    %Loop over sites
out=regexp(tiffiles,strcat('T\d\d\d\d',sprintf('F00%d',site)),'match');

%Remove non timepoint tif files
tiffiles=tiffiles(cellfun(@(x) ~isempty(x),out));
out=out(cellfun(@(x) ~isempty(x),out));
out1=cellfun(@(x) x{1}(2:5),out,'UniformOutput',false);
a=cellfun(@(x) str2num(x),out1);
if(a~=(1:length(a))')
    error('Timpoint after sorting do not match natural order');
end;
tiffiles_all=[tiffiles_all,tiffiles];
end;
tiffiles_all=strcat(batch,'/TIFF/',tiffiles_all);
subfile=strcat(batch,'/','DC_Andor #1_CAM1.tif');
divfile=strcat(batch,'/','SC_BP620_60xW_CH01.tif');
end

