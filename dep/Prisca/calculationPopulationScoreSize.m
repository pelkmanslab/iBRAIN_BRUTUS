function [sorted_coefficients,bin_starts,first_coefficients]=calculationPopulationScoreSize(features2,method,PCA_coefficients)
%This function uses the population context features in features2 and
%associated every cell with a bin index
%sorted_coefficients: Index of every cell when sorted according to bin
%index
%first_coefficents: Sorted bin indices
%bin_starts: Start indices of all bin indices
%method=18:6 binning with 3 cell size bins with a total number of bins
%equal to 18
%method6 :Binning into three cell size bins
%method=4:6 binning without cell size sampling support
%PCA of population contedxt then sortn according to first
                %component and report PCA of population context
                if(method==4)
                        %Dynamic binning into LCD bins and split up of each
                        %bin into edge/ non-edge
                      
%                                            lcd_extreme=quantile(features2(:,1),[.025 .975]);
        %     lcd_extreme=quantile(features2(:,1), [0.025:0.3166:0.975]);
                                lcd_extreme=quantile(features2(:,1), [0.0,0.33333,2*0.33333,1]);
                         [~,bin_indices]=histc(features2(:,1),lcd_extreme(1:4));
%                           %Set bin index 4 to 6 due to additon of edge bins
 bin_indices(find(bin_indices==3))=5;                   
bin_indices(find(bin_indices==2))=3;
%                   %Set bin indices of 3 to 4
                 
%                   %Add 1 to the index of celsl in bin and being and edge
%                   %cell
                   bin_indices(:)=bin_indices(:)+features2(:,2);
%                   bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
           %       bin_indices(z)=0;
                    %Sort the cells based on the logical vectors
                    [first_coefficients,sorted_coefficients]=sort(bin_indices);
                 bin_starts=[1];
                 for(bin=2:7)
                     if(~isempty(max(find(first_coefficients==bin-1))))
                         %Bin has some cells add index of last cell to the
                         %bin_starts vector
                    bin_starts=[bin_starts,max(find(first_coefficients==bin-1))];
                     else
                         %Bin has no cells add just cellend index of last
                         %bin as end index of this bin. Since there is only
                         %1 cell in this bin no SVMs wikll be trained
                         bin_starts=[bin_starts,bin_starts(bin-1)];
                     end;
                 end;
                                                 elseif(method==18)
                        %Dynamic binning into LCD bins and split up of each
                        %bin into edge/ non-edge
                      %Check for every column whether it contains more than
                      %2 features
                      
                      non_binary1=(arrayfun(@(x) length(unique(features2(:,x)))>2,1:size(features2,2)));
                      non_binary=find(non_binary1);
                      binary=find(non_binary1==0);
                      %Get quantuiles of all non binary population context feature at
                      %the same time
                   
                      feature_quantiles=quantile(features2(:,non_binary),[0.0,0.33333,2*0.33333,1]);
                   
                      bin_indices=zeros(size(features2,1),1');
                      
                       %Counter variable to keep track of number of possible
                          %bins encoded by the 
                          count=3;
                           for(f=binary)
                              %Here we simply add the value of the bnary
                              %feature multiplied with 2^f
                              bin_indices=bin_indices+(count)*(features2(:,f));
                              count=count*2;
                          end;
                          count=1;
                      for(f=length(non_binary):-1:1)
                         feature_inc=0;
                          %Loop over features
                          
                          for(bin=2:3)
                              %The current fearture can have three ppssible
                              %values which is controlled by increasing
                              %feature_inc
                              bin_indices=bin_indices+(count)*(((features2(:,non_binary(f))<feature_quantiles(bin,f))&((features2(:,non_binary(f))>=feature_quantiles(bin-1,f))))*feature_inc);
                                     feature_inc=feature_inc+1;
                          end;
                          bin=bin+1;
                          %Special bounds for the last bin this because of
                          %cells lieng exactly on the bin boundary
                            bin_indices=bin_indices+(count)*(((features2(:,non_binary(f))<=feature_quantiles(bin,f))&((features2(:,non_binary(f))>=feature_quantiles(bin-1,f))))*feature_inc);
                            
                          %The current feature multiplied the total number
                          %of combinations by three so adapt count
                          count=count*3*2;
                  
                         
                      end;
                            %Sort the cells based on the logical vectors
                    [first_coefficients,sorted_coefficients]=sort(bin_indices+1);
                 bin_starts=[1];
                 for(bin=2:19)
                     if(~isempty(max(find(first_coefficients==bin-1))))
                         %Bin has some cells add index of last cell to the
                         %bin_starts vector
                    bin_starts=[bin_starts,max(find(first_coefficients==bin-1))];
                     else
                         %Bin has no cells add just cellend index of last
                         %bin as end index of this bin. Since there is only
                         %1 cell in this bin no SVMs wikll be trained
                         bin_starts=[bin_starts,bin_starts(bin-1)];
                     end;
                 end;
%                       bin_indices1=bin_indices+1;
%                       
% %                                            lcd_extreme=quantile(features2(:,1),[.025 .975]);
%         %     lcd_extreme=quantile(features2(:,1), [0.025:0.3166:0.975]);
%                                 lcd_extreme=quantile(features2(:,1), [0.0,0.33333,2*0.33333,1]);
%                          [~,bin_indices]=histc(features2(:,1),lcd_extreme(1:4));
% %                           %Set bin index 4 to 6 due to additon of edge bins
%  bin_indices(find(bin_indices==3))=13;                   
% bin_indices(find(bin_indices==2))=7;
% %                   %Set bin indices of 3 to 4
%                  
% %                   %Add 1 to the index of celsl in bin and being and edge
% %                   %cell
%                    bin_indices(:)=bin_indices(:)+features2(:,2)*3;
%                    %Bin into three size bins and add index of bin-1
%                            size_extreme=quantile(features2(:,3), [0.0,0.33333,2*0.33333,1]);
%                          [~,size_indices]=histc(features2(:,3),size_extreme(1:4));
%                    bin_indices=bin_indices+size_indices-1;
%                    find(bin_indices~=bin_indices1);
% %                   bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
%            %       bin_indices(z)=0;
              
                 
                        
                elseif(method==5)
                        %Dynamic binning into 4 LCD binsd and then binning
                        %of the two middle bins with edge&non/edge
                                            lcd_extreme=quantile(features2(:,1),[.025 .975]);
distance_extreme=quantile(features2(:,2),[.025  .975]);
size_extreme=quantile(features2(:,3),[.025  .975]);
z = arrayfun(@(x) (x<lcd_extreme(1))||(x>lcd_extreme(2)),features2(:,1))|arrayfun(@(x) (x<distance_extreme(1))||(x>distance_extreme(2)),features2(:,2))|arrayfun(@(x) (x<size_extreme(1))||(x>size_extreme(2)), features2(:,3));

                         lcd_extreme=quantile(features2(:,1), [0.025:0.2374:0.975]);
                         [~,bin_indices]=histc(features2(:,1),lcd_extreme(1:5));
%                           %Set bin index 4 to 6 due to additon of edge bins
%                   bin_indices(find(bin_indices==4))=6;
%                   %Set bin indices of 3 to 4
%                   bin_indices(find(bin_indices==3))=4;
%                   %Add 1 to the index of celsl in bin and being and edge
%                   %cell
%                   bin_indices(find(bin_indices==2))=bin_indices(find(bin_indices==2))+features2(find(bin_indices==2),2);
%                   bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
                  
                %Set bin index 4 to 6 due to additon of edge bins
                  bin_indices(find(bin_indices==4))=6;
                  %Set bin indices of 3 to 4
                  bin_indices(find(bin_indices==3))=4;
                  %Add 1 to the index of celsl in bin and being and edge
                  %cell
                  bin_indices(find(bin_indices==2))=bin_indices(find(bin_indices==2))+features2(find(bin_indices==2),2);
                  bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
bin_indices(z)=0;
                  
                    %Sort the cells based on the logical vectors
                    [first_coefficients,sorted_coefficients]=sort(bin_indices);
                 
                    bin_starts=[min(find(first_coefficients==1)),max(find(first_coefficients==1)),max(find(first_coefficients==2)),max(find(first_coefficients==3)),max(find(first_coefficients==4)),max(find(first_coefficients==5)),max(find(first_coefficients==6))];
                elseif(method==6)
                    %Return the entire population:1 bin binned into theree
                    %cell size bins
%                     sorted_coefficients=1:size(features2,1)';
%                     bin_starts=[1,size(features2,1)];
       
                           size_extreme=quantile(features2(:,3), [0.0,0.33333,2*0.33333,1]);
                         [~,bin_indices]=histc(features2(:,3),size_extreme(1:4));
                 
%                   bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
           %       bin_indices(z)=0;
                    %Sort the cells based on the logical vectors
                    [first_coefficients,sorted_coefficients]=sort(bin_indices);
                 bin_starts=[1];
                 for(bin=2:4)
                     if(~isempty(max(find(first_coefficients==bin-1))))
                         %Bin has some cells add index of last cell to the
                         %bin_starts vector
                    bin_starts=[bin_starts,max(find(first_coefficients==bin-1))];
                     else
                         %Bin has no cells add just cellend index of last
                         %bin as end index of this bin. Since there is only
                         %1 cell in this bin no SVMs wikll be trained
                         bin_starts=[bin_starts,bin_starts(bin-1)];
                     end;
                 end;
  end;
end
     
                