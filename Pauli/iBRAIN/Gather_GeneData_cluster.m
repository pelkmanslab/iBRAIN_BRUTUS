function Gather_GeneData_cluster(genes)

strPath=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/DG_data_combined/');
strPathTemp=npc('/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015-berend/');

disp('Loading RawData4...')
load([strPath,'RawData4.mat']);
disp('Loading RawData...')
load([strPath,'RawData.mat']);
disp('Loading MetaData...')
load([strPath,'MetaData.mat']);

% Generating Gene-based data 
% Discards well data based on Out-Of-Focus and Manual discarding

% reserving the data
for assay=1:length(MetaData.AssayNames);
    for target=1:length(MetaData.ReadoutNames)
        DataFields=fieldnames(RawData4.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}));
        for field=1:length(DataFields)
            Data_full.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})=nan(10,3,3);
            Data_oligo.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})=nan(10,3);
        end
    end
end

%foo=memory;
gene_index=0;
for gene=((genes-1)*10+1):min((genes*10),6986)
    gene_index=gene_index+1;
    disp(['Creating gene based data, Gene: ',num2str(gene)])
    
    for assay=1:length(MetaData.AssayNames);
        
        gene_indices=MetaData.gene_indices{assay}{gene};
        oligos=MetaData.oligos{assay}{gene};
        replicas=MetaData.replicas{assay}{gene};
        replicas=mod(replicas-1,3)+1;
        
        oligos_unique=unique(oligos);
        oligos_unique(oligos_unique==0)=[];
        oligos_unique(isnan(oligos_unique))=[];
        
        replicas_unique=unique(replicas);
        replicas_unique(replicas_unique==0)=[];
        replicas_unique(isnan(replicas_unique))=[];
        
        for target=1:length(MetaData.ReadoutNames)
            DataFields=fieldnames(RawData4.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}));
            for field=1:length(DataFields)
                gene_data=RawData4.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(gene_indices);
                oligo_index=0;
                
                for oligo=lin(oligos_unique)'
                    oligo_index=oligo_index+1;
                    replica_index=0;
                    for replica=lin(replicas_unique)'
                        replica_index=replica_index+1;
                        index=oligos==oligo&replicas==replica;
                        
                        % Out of focus well discarding
                        if sum(RawData.(MetaData.AssayNames{assay}).OOF(gene_indices(index)))>7 %the sum is to avoid crashed when there are identical wells
                            gene_data(index)=NaN;
                        end
                        
                        % Manual discarding of data
                        col=num2str(MetaData.Column.(MetaData.AssayNames{assay})(gene_indices(index)));
                        row=char(MetaData.Row.(MetaData.AssayNames{assay})(gene_indices(index))+64);
                        well=[row,col];
                        if sum(ismember(MetaData.Discarded_wells.(MetaData.AssayNames{assay}),well))>0
                            gene_data(index)=NaN;
                        end
                        
                        Data_full.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(gene_index,oligo_index,replica_index)=nanmean(gene_data(index)); %nanmean over possible identical wells
                        
                    end
                end
            end
        end
    end
end

% Calculating oligo based data (nanmedian over replicates)
for assay=1:length(MetaData.AssayNames);
    for target=1:length(MetaData.ReadoutNames)
        %disp(['Creating oligo data...assay: ',MetaData.AssayNames{assay},', target: ',num2str(target)])
        DataFields=fieldnames(RawData4.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}));
        for field=1:length(DataFields)
            for gene=1:10
                for oligo=1:3
                    Data_oligo.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(gene,oligo)=...
                        nanmedian(Data_full.(MetaData.AssayNames{assay}).(MetaData.ReadoutNames{target}).(DataFields{field})(gene,oligo,:));
                end
            end
        end
    end
end

disp(['Saving results'])
save([strPathTemp,'Data_full_',num2str(genes),'.mat'],'Data_full');
save([strPathTemp,'Data_oligo_',num2str(genes),'.mat'],'Data_oligo');
disp(['Results saved'])


