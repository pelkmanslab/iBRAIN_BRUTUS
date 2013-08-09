
function [normal_vector,classification_accuracy,b,average_margin] = calculateSVMBin_control(gene_name,C,sample_size,bin)
%   Detailed explanation goes here
global treated_population; 
global control_population;
global test_cases_control;
% if(strcmp(gene_name,'AP2M1_4'))
% a=2;
% end;
feature_size=1:size(control_population,2);
treated_population=control_population;
         normal_vector1=NaN(1,length(feature_size));
                                classification_accuracy1=NaN;
                                b1=0;
%Prepare the entire ppulation matrix and set their group association
                                  
                                population=[treated_population;control_population];
                            
                                groups=ones(size(population,1),1);
                                groups(1:size(treated_population,1))=1;
                                groups(size(treated_population,1)+1:size(population,1))=-1;
                                %Create random train and test samples each consisiting of half of the
                                %treated and the untreated population but never more than 200 cells
                                %(performance issue), then set the box constraints(refer to doc svmtrain)
                                %and train the svm
                             %   normal_vector(:,:)=zeros(10,size(treated_population,2));
                                size(treated_population,2);
                               normal_vector=NaN(100,length(feature_size));
                                b=NaN(100,1);
                                classification_accuracy=NaN(100,1);
                               average_margin=cell(100,1);
                          command_string=strcat('-s 2 -q -B 1  -c', sprintf(' %f',C));
                          problem_train=0;
                          test_cases1=arrayfun(@(x) [randi([1 size(treated_population,1)],sample_size,1)],1:100,'UniformOutput',false);

 test_cases2=arrayfun(@(x) [randi([1+size(treated_population,1) size(population,1)],sample_size,1)],1:100,'UniformOutput',false);

                                for(cross=1:100) %Select 10 times random training and tesing samples, the solution belonging to the median classification accuracy is returned

                                 train = [randi([1 size(treated_population,1)],sample_size,1);randi([1+size(treated_population,1) size(population,1)],sample_size,1)];
                               %  test = [randi([1 size(treated_population,1)],sample_size,1);randi([size(treated_population,1)+1 size(population,1)],sample_size,1)];

                                    try
                                      %1:feature_size
                                     % if(cross==1)
                                     
                           
                                       model = train4(groups(train),sparse(population(train,feature_size)),command_string);
                                    normal_vector(cross,:)=model.w(1:length(feature_size));
b(cross)=model.w(length(feature_size)+1);

%    svmStruct3 = svmtrain(population(train, feature_size),groups(train),'Boxconstraint',0.01,'Kernel_Function','linear','Autoscale',false,'Method','QP' );
%    normal_vector(cross,:)=zeros(1,length(feature_size));                                   
%    for(k=1:size(svmStruct3.SupportVectors,1))
%                                         %Add up contribution of each supprt vector, all opther sample vectors
%                                         %halve alpha=0 and don't contribute
%                                         normal_vector(cross,:)=normal_vector(cross,:)+(svmStruct3.Alpha(k)) .*svmStruct3.SupportVectors(k,:);
%                                        
%                                     end;
                                   %   end;
                                       catch exception
                                        %Go to next iteration
                                        sprintf('Error occured during SVM training:gene %s',gene_name)
                                        exception.message
                                        problem_train=1;
                                    end;
                                    if(problem_train<1)
                                                         %Calculate SVM normal vector:alpha(i)*(Data row vector)
                                    
                                    
                                    %possible_b=zeros(length(find(abs(svmStruct3.Alpha)<obj.C)),1);
                                   
                                  

%                                  
%                                     %Calculate margin b
%                                     possible_b=[];
%                                       %Start with computing b from all
%                                     %examples with abs(alpha_i)<C
%                                       temp_group=groups(train);
%                                     for(k=1:size(svmStruct3.SupportVectors,1))
%                                      if(abs(svmStruct3.Alpha(k))<obj.C)
%                                             b=sign(temp_group(svmStruct3.SupportVectorIndices(k))-1)-(svmStruct3.SupportVectors(k,:)*obj.normal_vector{count,bin}');
%                                             possible_b=[possible_b;b];
%                                      end;
%                                  
%                                     end;
%                                %     mean(groupIndex(sv)' - sum(alphaHat(:,ones(1,numSVs)).*kx(sv,sv)));
%                                     %Final b as average of all b for
%                                     %numerical stability
%                                     b=mean(possible_b);
                                  %  svmStruct3.Bias=b;
                                    %Extract different quality parameters
%                                     classes3 = svmclassify(svmStruct3,population(test,1:feature_size));
%                                     
%[predicted_labels,classification_accuracy(cross),~]=predict4(groups(test),sparse(population(test,feature_size)),model);
%Calculate distance to hyperplain in units of the margin
      %  cell_distances=(population(train,feature_size)*model.w(1:length(feature_size))'+model.w(length(feature_size)+1));
             test_cases_control{bin}=arrayfun(@(x) population( test_cases1{x},feature_size)*model.w(1:length(feature_size))'+model.w(length(feature_size)+1),1:100,'UniformOutput',false);

test_cases4_control=arrayfun(@(x) population( test_cases2{x},feature_size)*model.w(1:length(feature_size))'+model.w(length(feature_size)+1),1:100,'UniformOutput',false);

%test_margin=arrayfun(@(x) max(test_cases3{x}),1:100,'UniformOutput',true);

%test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size),1:100,'UniformOutput',true);
%         if(strcmp(gene_name,'AP2M1_1'))
%                     sprintf('Gene name:%s,Fraction of hit cells:%d',gene_name,length(find(cell_distances>0))/length(cell_distances))
%         end;
        %Take the mean of the third of tzhe perturbation population hacving
        %maximal distance from the control
 % c_criteria=arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true)/length(train)+arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:100,'UniformOutput',true)/length(train)   ;     
        
%average_margin(cross)=mean(cell_distances(cell_distances(1:length(test)/2)>quantile(cell_distances(1:length(test)/2),0.6666)));
% if((length(find(cell_distances>0))/length(cell_distances)<0.58)&&(max(cell_distances(1:length(test)/2))>=0.90))
% average_margin{cross}=[test_class,c_criteria,cellfun(@(x) mean(x),test_cases3),arrayfun(@(x) ttest3(test_cases3{x},test_cases4{x}),1:100)];

% end;
%classification_accuracy(cross)=(length(find(distance_output(1:length(test)/2)>1))+length(find(distance_output(length(test)/2+1:length(test))<-1)))/length(test);
%                                     cp3=classperf(groups(test,:));
%                                     classperf(cp3,classes3,(1:size(population(test,:),1)),'Positive',[2],'Negative',[0]);
%                              
%                                     class_population=population(test,1:feature_size);
%                                     
%                                    % showClassification1D(1,gene,bin,groups(test,:),population(test,:),svmStruct3,'');
%                                     sens(cross)=cp3.Sensitivity;

%                                     spec(cross)=cp3.Specificity;
                                  %  classification_accuracy(cross)=(cp3.DiagnosticTable(1,1)+cp3.DiagnosticTable(2,2))/(cp3.DiagnosticTable(1,1)+cp3.DiagnosticTable(2,2)+cp3.DiagnosticTable(1,2)+cp3.DiagnosticTable(2,1));

                                  %                                     all_eps=[];
%                                       for(k=1:size(svmStruct3.SupportVectors,1))
%                                      if(abs(svmStruct3.Alpha(k))>=obj.C)
%                                             eps=(-sign(temp_group(svmStruct3.SupportVectorIndices(k))))*(dot(obj.normal_vector{count,bin},svmStruct3.SupportVectors(k,:))+b)+1;
%                                             all_eps=[all_eps;eps];
%                                      end;
%                                  
%                                     end;
%                                     
%                                     obj.robust_measure(count,bin)=norm(obj.normal_vector{count,bin})/2+sum(obj.C*all_eps);
                                    %Calculate distance 
                               
                                 %   b(cross)=svmStruct3.Bias;
                                    else
%                                         classification_accuracy(cross)=NaN;
%                                         normal_vector(cross,:)=NaN(1,length(feature_size));
%                                         b(cross)=NaN;
%                                         spec(cross)=NaN;
%                                         sens(cross)=NaN;
                                    end;
                    
                                end;
%                                 [classification_accuracy,indices_class]=sort(classification_accuracy);
%                                 normal_vector1=normal_vector(1,:);
%                                            b1=b(1);
%                                            spec1=spec(indices_class(5));
%                                            sens1=sens(indices_class(5));
%                                            classification_accuracy1=mean(classification_accuracy(:));
                                   
%                                     clear cp;clear groups;
% average_length=nanmean(arrayfun(@(x) 2/norm(normal_vector(x,1:20)),1:100));
% perturbed=(histc(cat(1,test_cases3{:},[])*average_length,-3.5:0.1:3.5));
% control=(histc(cat(1,test_cases4{:},[])*average_length,-3.5:0.1:3.5));
% h=figure;
% hold on
% plot(-3.5:0.1:3.5,(perturbed)/(100*sample_size),'k')
% hold on;
% plot(-3.5:0.1:3.5,control/(100*sample_size),'r');
% gcf2pdf(strcat('C:\Users\heery\Desktop\figures\pool\false_positive\'),strcat(gene_name,'.pdf'),'overwrite');
% close(h);

end

