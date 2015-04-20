%Script to check overlap between TOp20 feature lists of different plates of
%the same assay

function []=createAssayList_scriptpool(assay)
 plate_paths={   
           '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s1-CP392-4ad',...
           '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s2-CP392-4ad',...
           '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s3-CP392-4ad',...
           '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_CP392-2as'
                };
            
            
            
                    
                 plate1_paths={'/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s1-CP392-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s1-CP393-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s1-CP394-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s1-CP395-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s2-CP392-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s2-CP393-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s2-CP394-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s2-CP395-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s3-CP392-4ad/BATCH',...
        '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s3-CP393-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s3-CP394-4ad/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_s3-CP395-4ad/BATCH',...
        '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_CP392-2as/BATCH',...
        '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_CP393-2as/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_CP394-2as/BATCH',...
    '/cluster/home/biol/heery/2NAS/Data/Users/110920_A431_w2Tf/110920_A431_w2Tf_CP395-2as/BATCH'
     };    
                     
                     
                     
                     
                     load_strings={'Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat','Measurements_Classification6bin_RFEcp395_TfVes.mat'};
                       save_strings={'Measurements_Classification6bin_RFEcp395_Tf1Ves.mat','Measurements_Classification6bin_RFEcp395_Tf2Ves.mat','Measurements_Classification6bin_RFEcp395_Tf3Ves.mat','Measurements_Classification6bin_RFEcp395_Tf4Ves.mat'};
                   
                     %Read general settings
         
    store_filenames=[];
    current=1;
    num_bins=6;

  
           % for(assay=1:length(plate_paths))
           pvalue=NaN(1138,num_bins); 
           pvalue_control=NaN(1138,num_bins); 
           [ Classification_accuracy,margin,Cells_per_bin5,Normal_vector_matrix_bin_after_bin,Gene_list,Normal_vector_matrix_bin_after_bin3,bias ,c_crit5,plate_indices,feature_names,Average_distance,pvalue15,pvalue15_control,entrez] =loadAssay_part1(plate1_paths((assay-1)*4+1:(assay-1)*4+4),load_strings{assay},1);
        plate_limit=[1,285,570,855,1138];
           for(plate=1:4)
 c_crit=c_crit5(plate_limit(plate):plate_limit(plate+1)-1,:);
 pvalue1=pvalue15(plate_limit(plate):plate_limit(plate+1)-1,:);
  pvalue1_control=pvalue15_control(plate_limit(plate):plate_limit(plate+1)-1,:);
 Cells_per_bin=Cells_per_bin5(plate_limit(plate):plate_limit(plate+1)-1,:);
 %Average_distance1=cellfun(@(x) nanmean(x),Average_distance);
 %Infer average distribution of cells and their distance by counting the
 %number of cells per bin and casting this number to fractions
   pvalue1( find(cellfun(@(x) isempty(x),pvalue1)))={NaN(1,10000)};
   pvalue1_control( find(cellfun(@(x) isempty(x),pvalue1_control)))={NaN(1,100)};
 for(bin=1:num_bins)
     temp_crit=c_crit(find(~isnan(c_crit(:,bin))),bin);
      [~,c_critindex]=sort(temp_crit);
   if(length(c_critindex)<200)
       continue;
   end;
  %pvalue1(find(svi um(Cells_per_bin,2)<200))=NaN;
 


 
  pvalue3=pvalue1(c_critindex(:),:);

   aggregate_distance=lin(cat(1,[],pvalue3{:,bin}));%nansum(cat(1,[],pvalue3{:,bin}),1);
   aggregate_distance=aggregate_distance(find(~isnan(aggregate_distance)));
  pvalue3_control=pvalue1_control(c_critindex(:),:);
   aggregate_distance_control=lin(cat(1,[],pvalue3_control{:,bin}));%nansum(cat(1,[],pvalue3{:,bin}),1);
   aggregate_distance_control=aggregate_distance_control(find(~isnan(aggregate_distance_control)));  
   aggregate_cells=nansum(aggregate_distance);
   if(nansum(Cells_per_bin(:,bin))<10000)
       continue;
   end;
 %aggregate_distance=aggregate_distance/aggregate_cells;
 
 


 

 data_control2=nanmean(aggregate_distance_control(randi([1,length(aggregate_distance_control)],[400,100])),1);
     data_control=nanmean(aggregate_distance(randi([1,length(aggregate_distance)],[400,10000])),1);%nanmean(anyrnd([-0.8:0.0231:1.5;aggregate_distance]',800,500),2);   
for(gene=1:size(c_crit,1))
    %New gene
    data_gene=0;
 pvalue2=cellfun(@(x) x,pvalue1(:,bin),'UniformOutput',false);
      %pvalue2=cellfun(@(x) x/sum(x),pvalue1(:,bin),'UniformOutput',false);
 pvalue2=cat(1,pvalue2{:});
  pvalue2_control=cellfun(@(x) x,pvalue1_control(:,bin),'UniformOutput',false);
      %pvalue2=cellfun(@(x) x/sum(x),pvalue1(:,bin),'UniformOutput',false);
 pvalue2_control=cat(1,pvalue2_control{:});
%Get the porbability of control bin number is higher than the perturbed bin
%number
if(pvalue2(gene,1:10000)~=pvalue2(gene,1:10000))
    continue;
end;
data_gene=pvalue2(gene,1:10000);%nanmean(anyrnd([-0.8:0.0231:1.5;pvalue2(gene,1:100)]',800,500),2);
data_p=pvalue2_control(gene,1:100);
%prob=sum(arrayfun(@(x) nansum(pvalue2(gene,1:100).*([1:100]-x))*aggregate_distance(x),1:100));
%std_prob=sum(arrayfun(@(x) (nansum(pvalue2(gene,1:100).*([1:100]-x-prob).^2)*aggregate_distance(x)),1:100));
    pvalue(gene+plate_limit(plate)-1,bin) =max(length(find((data_control>(data_gene))==1))/10000);
    pvalue_control(gene+plate_limit(plate)-1,bin) =max(length(find((data_control2>(data_p))==1))/100);
end;
 
 end;
           end;


    Gene_id=entrez;
    save(strcat(plate_paths{assay},'/',save_strings{assay}),'Gene_list','Gene_id','Normal_vector_matrix_bin_after_bin','margin','Cells_per_bin5','Classification_accuracy','c_crit5','plate_indices','bias','feature_names','Average_distance','pvalue','pvalue_control');
    
        

end
          
