function Plate_Effects_Normalization_cluster(item)

strPath=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/DG_data_combined/');
strPathTemp=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015-berend/');

disp('Loading RawData2...')
load([strPath,'RawData2.mat']);
disp('Loading MetaData...')
load([strPath,'MetaData.mat']);

assay=ceil(item/10);
target=mod(item-1,10)+1;

% Plate normalizations
% Version 6:
% 0: No plate correction
% 1: local B-score 
% 2: Global B-score
% 3: Global average
% 4: 3D-Bscore!

Col_labels=1:24;
Row_labels={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'};

%for assay=1:length(MetaData.AssayNames);

%for target=1:length(MetaData.ReadoutNames)
disp(['Plate normalizations: ',MetaData.AssayNames{assay},' ',MetaData.ReadoutNames{target}])
DataFields=fieldnames(RawData2.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}));
for field=1:length(DataFields)
   
    
    plates=MetaData.plates.(MetaData.AssayNames{assay});
    
    average_plate=zeros(16,24,plates);
    for i=1:3
       W{i}=cell(1,plates);
       S{i}=cell(1,plates);
    end
    for i=4:7
        W{i}=nan(16,24);
        S{i}=nan(16,24);
    end
    
    disp(['Plate normalizing: Field: ',DataFields{field}])
    for plate=1:plates
        
        
        siRNAwells=MetaData.siRNAwells.(MetaData.AssayNames{assay}){plate};
        platedata=RawData2.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(plate,:);
        
        plate_format=nan(16,24);
        plate_format_siRNA_well=zeros(16,24);
        for well=1:length(platedata)
            row=MetaData.Row.(MetaData.AssayNames{assay})(plate,well);
            column=MetaData.Column.(MetaData.AssayNames{assay})(plate,well);
            plate_format(row,column)=platedata(well);
            plate_format_siRNA_well(row,column)=siRNAwells(well);
        end
        % using all wells (including control wells)
        plate_format(isinf(plate_format))=NaN;
        plate_format(not(arrayfun(@isreal,plate_format)))=NaN;
        
        W{1}{plate}=repmat(nanmean(plate_format(:,:)),[16 1]);     %local column mean
        W{2}{plate}=repmat(nanmean(plate_format(:,:)')',[1 24]);   %local row mean
        W{3}{plate}=nlfilter(plate_format,[5 5],@block_mean);       %local window mean
        
        S{1}{plate}=repmat(nanstd(plate_format(:,:)),[16 1]);      %local column std
        S{2}{plate}=repmat(nanstd(plate_format(:,:)')',[1 24]);    %local row std
        S{3}{plate}=nlfilter(plate_format,[5 5],@block_std);        %local window std
        
        average_plate(:,:,plate)=plate_format;
    end
    W{4}=nanmean(average_plate,3); % global well mean
    S{4}=nanstd(average_plate,[],3); % global well std
    
    for row=1:16
        global_row=squeeze(average_plate(row,:,:));
        W{5}(row,:)=repmat(nanmean(global_row(:)),[1 24]); % global row mean
        S{5}(row,:)=repmat(nanstd(global_row(:)),[1 24]);  % global row std
    end
    
    for column=1:24
        global_row=squeeze(average_plate(:,column,:));
        W{6}(:,column)=repmat(nanmean(global_row(:)),[16 1]); % global column mean
        S{6}(:,column)=repmat(nanstd(global_row(:)),[16 1]);  % global column std
    end
    
    for row=1:16
        minrow=max(1,row-2);
        maxrow=min(16,row+2);
        for column=1:24
            mincol=max(1,column-2);
            maxcol=min(24,column+2);
            
            global_window=average_plate(minrow:maxrow,mincol:maxcol,:);
            W{7}(row,column)=nanmean(global_window(:)); % global window mean
            S{7}(row,column)=nanstd(global_window(:));  % global window std
        end
    end
    
    for plate=1:plates
          
        platedata=RawData2.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(plate,:);
        for well=1:length(platedata)
            row=MetaData.Row.(MetaData.AssayNames{assay})(plate,well);
            column=MetaData.Column.(MetaData.AssayNames{assay})(plate,well);
            
            
            if strcmp(DataFields{field},(MetaData.ReadoutMinimumLevel2{target})) % Control case where no normalization steps done
                % P0: no plate normalization
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P0'])(plate,well)=...
                    platedata(well);
            end
            if strcmp(DataFields{field},MetaData.ReadoutBaselLevel2{target}) % Different plate normalization combinations only in this case
                % P0: no plate normalization
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P0'])(plate,well)=...
                    platedata(well);
                
                % P1: local B-score
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P1'])(plate,well)=...
                    platedata(well)-(W{1}{plate}(row,column)+W{2}{plate}(row,column))/2;
                
                % P2: Global B-score
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P2'])(plate,well)=...
                    platedata(well)-(W{5}(row,column)+W{6}(row,column))/2;
                
                % P3: Global average
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P3'])(plate,well)=...
                    platedata(well)-W{4}(row,column);
                
                % P4: 3D-Bscore!
                PScore=((1/S{1}{plate}(row,column))*W{1}{plate}(row,column)+...
                    (1/S{2}{plate}(row,column))*W{2}{plate}(row,column)+...
                    (1/S{3}{plate}(row,column))*W{3}{plate}(row,column)+...
                    (1/S{4}(row,column))*W{4}(row,column)+...
                    (1/S{5}(row,column))*W{5}(row,column)+...
                    (1/S{6}(row,column))*W{6}(row,column)+...
                    (1/S{7}(row,column))*W{7}(row,column))./...
                    (1/S{1}{plate}(row,column)+1/S{2}{plate}(row,column)+1/S{3}{plate}(row,column)+...
                    1/S{4}(row,column)+1/S{5}(row,column)+1/S{6}(row,column)+1/S{7}(row,column));
                
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P4'])(plate,well)=...
                    platedata(well)-PScore;
                
            else
                RawData3.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).([DataFields{field},'P1'])(plate,well)=...
                    platedata(well)-(W{1}{plate}(row,column)+W{2}{plate}(row,column))/2;
            end
        end
    end
end
disp(['Saving results'])
save([strPathTemp,'RawData3_part_',num2str(item),'.mat'],'RawData3');
disp(['Results saved'])

%end
%end
