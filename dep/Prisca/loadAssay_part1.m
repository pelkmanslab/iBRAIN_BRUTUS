function [ Classification_accuracy1,margin1,Cells_per_bin1,Normal_vector_matrix_bin_after_bin1,Gene_list1,Normal_vector_matrix_bin_after_bin3,bias1 ,c_crit1,plate_indices,Feature_names,Average_distance,pvalue,pvalue_control,entrez,length_std1,class_std1] = loadAssay_part1( plate_paths,load_string,class_flag )
%loadAssay_part1 Loads all plates of an assay and returns the union of
%classification accuracy,margin,gene Lists. The paths to the plates are
%given in plate_paths 
Classification_accuracy=[];
Gene_list1=[];Classification_accuracy1=[];All_normal_vectors=[];  margin1=[];bias1=[];
      Cells_per_bin1=[];Normal_vector_matrix_gene_after_gene=[];robust_measure=[];std_class=[];sens=[];spec=[];
      Normal_vector_matrix_bin_after_bin1=[];plate_paths1={};bias=[];average_margin1=[];c_crit1=[];
      Normal_vector_matrix_bin_after_bin3=[];entrez=[];
      Average_distance=[];Feature_names=[];
      Std_distance=[];
      Average_distance_control=[];
      pvalue=[];pvalue_control=[];length_std1=[];class_std1=[];
      plate_indices={};
                     for(plate=1:length(plate_paths))
                         

                         strcat((plate_paths{plate}),'/',load_string)
     if(exist((npc(strcat((plate_paths{plate}),'/',load_string,'.mat'))),'file'))
                         load(npc(strcat((plate_paths{plate}),'/',load_string,'.mat')));
     end;
     strcat((plate_paths{plate}),'/',load_string)
              if(size(Cells_per_bin,1)>0)
                         Gene_list1=[Gene_list1,Gene_list];
                         entrez=[entrez,Gene_id];
                         temp_class=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                          temp_crit=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                              temp_bias=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                              temp_dist=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                            length_std=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                            class_std=NaN(size(Cells_per_bin,1),size(Cells_per_bin,2));
                              temp_pvalue=cell(size(Cells_per_bin,1),size(Cells_per_bin,2));
                              temp_pvalue_control=cell(size(Cells_per_bin,1),size(Cells_per_bin,2));

                           Cells_per_bin1=[Cells_per_bin1;Cells_per_bin];

margin=NaN(size(Average_margin,1),size(Average_margin,2));
Normal_vector_matrix_bin_after_bin2=NaN(size(Average_margin,1),size(Average_margin,2)*20);

                                              for(ll1=1:size(Average_margin,1))
            for(ll2=1:size(Average_margin,2))
                
                %Set bins to NaN if classification accuracy is less than
                %0.5
                %spec(ll1,ll2),
                normal_vectors=Normal_vector_matrix_bin_after_bin{ll1,ll2};
        
                      Average_margin1=Average_margin{ll1,ll2};
                  
                                  
                if(length(Average_margin1)<60)
                                    margin(ll1,ll2)=NaN;
             temp_class(ll1,ll2)=NaN;
             temp_bias(ll1,ll2)=0;
             temp_crit(ll1,ll2)=NaN;
             temp_dist(ll1,ll2)=NaN;
                else
                 average_length=arrayfun(@(x) norm(normal_vectors(x,1:20),2),[1:100]); 
                 %Accumlation of margin
                          margin_acc=0;
                 margin_count=1;
                 class_acc=0;
                 bias_acc=0;
     emptyindex=cellfun( @(x) length(x),Average_margin1);
Average_margin1(emptyindex==0)=[];
if(length(Average_margin1)>50)
[~,best_normal]=sort(cellfun( @(x) mean(x(101:200)),Average_margin1));
best_normal=best_normal(50);

                temp_vec=Average_margin1{best_normal};
                class_acc=arrayfun( @(x) (Average_margin1{x}(1:100)),1:100,'UniformOutput',false);
                  class_std(ll1,ll2)=quantile(cat(2,[],class_acc{:}),0.10);
                class_acc=nanmean(cat(2,[],class_acc{:}));
            
                c_crit2=arrayfun( @(x) (Average_margin1{x}(101:200)),1:100,'UniformOutput',false);
                c_crit2=nanmean(cat(2,[],c_crit2{:}));
                
             
                   a_dist=arrayfun( @(x) (Average_margin1{x}(201:300)),1:100,'UniformOutput',false);
                a_dist=nanmean(cat(2,[],a_dist{:}));
                margin_acc=2/average_length(best_normal);
%                   

              margin(ll1,ll2)=margin_acc;
              temp_class(ll1,ll2)=class_acc;
                   temp_bias(ll1,ll2)=nanmean(Bias{ll1,ll2}(:));
                   temp_crit(ll1,ll2)=c_crit2;
                   temp_dist(ll1,ll2)=a_dist;
                   %+0.5*normal_vectors(x,1:20)*normal_vectors(x,1:20)'
                   %(Average_margin1{x}(201:300))
                   %*(2/average_length(x))  +(average_length(x))
                   temp_temp=arrayfun( @(x) (Average_margin1{x}(1:100)),1:100,'UniformOutput',false);
     
                 %*(2/average_length(x))
                  temp_temp=cat(1,[],temp_temp{:});
                     temp_temp2=arrayfun( @(x) (Average_margin1{x}(301:400)),1:100,'UniformOutput',false);
                
                  temp_temp2=cat(1,[],temp_temp2{:});
                      temp_pvalue{ll1,ll2}=lin(temp_temp)';%-lin(temp_temp2)';
                      %-Average_margin1{x}(301:400),*(Average_margin1{x}(20
                      %1:300)-Average_margin1{x}(301:400))
                      temp_temp3=arrayfun( @(x) (average_length(x))+(Average_margin1{x}(101:200)),1:100,'UniformOutput',false);
                       temp_temp4=arrayfun( @(x) (average_length(x))+(Average_margin1{x}(101:200)),1:100,'UniformOutput',false);
                                  length_std(ll1,ll2)=nanstd(cat(2,[],temp_temp4{:}));
                     temp_temp3=cat(1,[],temp_temp3{:});
                      temp_pvalue_control{ll1,ll2}=lin(temp_temp3)';
                             
                   
%                     end;
             
              
                           
                            temp=nanmean(normal_vectors,1);
                            
                    Normal_vector_matrix_bin_after_bin2(ll1,(ll2-1)*20+1:ll2*20)=temp;%normal_vectors(best_normal,1:20)
                 
                end;
                  
            end;
            end;
                                                   end;
                                                   margin1=[margin1;margin];
                                                   class_std1=[class_std1;class_std];
                                                   length_std1=[length_std1;length_std];
                                                   c_crit1=[c_crit1;temp_crit];
                                                   Classification_accuracy1=[Classification_accuracy1;temp_class]; 
                                                   bias1=[bias1;temp_bias];
                                                   Average_distance=[Average_distance;temp_dist];
                                                        pvalue=[pvalue;temp_pvalue];
                                                        pvalue_control=[pvalue_control;temp_pvalue_control];

                                                   Normal_vector_matrix_bin_after_bin1=[Normal_vector_matrix_bin_after_bin1;Normal_vector_matrix_bin_after_bin2];
                                                    Normal_vector_matrix_bin_after_bin3=[Normal_vector_matrix_bin_after_bin3;Normal_vector_matrix_bin_after_bin];
                                                  new_indices=cell(size(temp_class,1),1);
                                                  new_indices(:)={plate_paths{plate}};
                                               
                                                    plate_indices=[plate_indices;new_indices];
                     end;  
                     end;
end




