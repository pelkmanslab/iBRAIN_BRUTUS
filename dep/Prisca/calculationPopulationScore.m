%This function calculates for a set of cells with population features features2(:,:) their rank in the population
%method=1:PCA is used to split the population into 10 bins
%method=2: Thresholds for each feature is used to split up the population:
%sorted_features: Cell sorted according to bin index
%bin_starts>Indcies of start of bins used for faster accessing, the last
%start must be the number of cells in sorted_features
function [sorted_coefficients,bin_starts]=calculationPopulationScore(features2,method,PCA_coefficients)
%PCA of population contedxt then sortn according to first
                %component and report PCA of population context
                if(method==1)
                scores_population=zeros(size(features2,1),1);
                obj.features2=zscore(features2);
                for(i=1:size(obj.features2,1))
                    
                scores_population(i,1)=dot((obj.features2(i,:)),PCA_coefficients(:,1))/norm(PCA_coefficients(:,1));
                end;
                [first_coefficients,sorted_coefficients]=sort(scores_population(:,1));
                
%                 elseif(method==4)
%                         %Dynamic binning into LCD bins and split up of each
%                         %bin into edge/ non-edge
%                       
%                                             lcd_extreme=quantile(features2(:,1),[.025 .975]);
% distance_extreme=quantile(features2(:,2),[.025  .975]);
% size_extreme=quantile(features2(:,3),[.025  .975]);
% z = arrayfun(@(x) (x<lcd_extreme(1))||(x>lcd_extreme(2)),features2(:,1))|arrayfun(@(x) (x<distance_extreme(1))||(x>distance_extreme(2)),features2(:,2))|arrayfun(@(x) (x<size_extreme(1))||(x>size_extreme(2)), features2(:,3));
% 
%                          lcd_extreme=quantile(features2(:,1), [0.025:0.3166:0.975]);
%                          [~,bin_indices]=histc(features2(:,1),lcd_extreme(1:4));
% %                           %Set bin index 4 to 6 due to additon of edge bins
%  bin_indices(find(bin_indices==3))=5;                   
% bin_indices(find(bin_indices==2))=3;
% %                   %Set bin indices of 3 to 4
%                  
% %                   %Add 1 to the index of celsl in bin and being and edge
% %                   %cell
%                    bin_indices(:)=bin_indices(:)+features2(:,2);
% %                   bin_indices(find(bin_indices==4))=bin_indices(find(bin_indices==4))+features2(find(bin_indices==4),2);
%                   bin_indices(z)=0;
%                     %Sort the cells based on the logical vectors
%                     [first_coefficients,sorted_coefficients]=sort(bin_indices);
%                  
%                     bin_starts=[min(find(first_coefficients==1)),max(find(first_coefficients==1)),max(find(first_coefficients==2)),max(find(first_coefficients==3)),max(find(first_coefficients==4)),max(find(first_coefficients==5)),max(find(first_coefficients==6))];
%                  
                                elseif(method==4)
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
                    %Return the entire population:1 bin
                    sorted_coefficients=1:size(features2,1)';
                    bin_starts=[1,size(features2,1)];
                else
                    lcd_extreme=quantile(features2(:,1),[.025 .975]);
distance_extreme=quantile(features2(:,2),[.025  .975]);
size_extreme=quantile(features2(:,3),[.025  .975]);
z = arrayfun(@(x) (x<lcd_extreme(1))||(x>lcd_extreme(2)),features2(:,1))|arrayfun(@(x) (x<distance_extreme(1))||(x>distance_extreme(2)),features2(:,2))|arrayfun(@(x) (x<size_extreme(1))||(x>size_extreme(2)), features2(:,3));

                    lcd_thresh=[1.53416967954436,2.29621622466132,3.05826276977827,4.15];%Thresholds obtained from all assay, for better comparabaility this thresholds are hardcoded and obtained from all relevant assays and all plates
                   %Bin the cells into the 4 LCD bins
                   lcd_edges=[0,lcd_thresh(1)+(lcd_thresh(2)-lcd_thresh(1))/2,lcd_thresh(2)+(lcd_thresh(3)-lcd_thresh(2))/2,lcd_thresh(3)+(lcd_thresh(4)-lcd_thresh(3))/2,10]
                  %Calculate bin index of each cell
                  [~,bin_indices]=histc(features2(:,1),lcd_edges);
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
                end;
end
     
                