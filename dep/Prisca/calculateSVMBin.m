
function [normal_vector,classification_accuracy,b,average_margin] = calculateSVMBin(gene_name,C,sample_size,perturbed_indices,control_indices)
%   Detailed explanation goes here
global treated_population; 
global control_population;
permu=randi([1 size(treated_population,1)],size(treated_population,1),1);
%Randomly shuffle the cells of the perturbed bin and their cell size in
%indices to allow for splitting the randomly into two halves
treated_population=treated_population(permu,:);
perturbed_indices=perturbed_indices(permu);
size_sample=hist(perturbed_indices,[1,2,3]);
feature_size=1:size(treated_population,2);
sample_size1=floor(min(size(treated_population,1)/2,250));
sample_size=floor((sample_size1/size(treated_population,1))*size_sample);
population=[treated_population;control_population];
                             groups=ones(size(population,1),1);
                                groups(1:size(treated_population,1))=1;
                                groups(size(treated_population,1)+1:size(population,1))=-1;
                            size(treated_population,2);
                               normal_vector=NaN(100,length(feature_size));
                                b=NaN(100,1);
                                classification_accuracy=NaN(100,1);
                               average_margin=cell(100,1);
                          command_string=strcat('-s 5 -q -B 1  -c', sprintf(' %f',C));
                          test_cases1=arrayfun(@(x) [randi([ceil(size(treated_population,1)/2) size(treated_population,1)],sample_size1,1)],1:100,'UniformOutput',false);
test_cases2=arrayfun(@(x) [randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)],1:100,'UniformOutput',false);

                                for(cross=1:100) %Select 10 times random training and tesing samples, the solution belonging to the median classification accuracy is returned
train = [randi2([1 ceil(size(treated_population,1)/2)],sample_size1,1);randi2([size(treated_population,1)+1 size(treated_population,1)+control_indices(2)-1],sample_size(1),1);randi2([size(treated_population,1)+control_indices(2) size(treated_population,1)+control_indices(3)-1],sample_size(2),1);randi2([size(treated_population,1)+control_indices(3) size(population,1)],sample_size(3),1)];
                            model = train4(groups(train),sparse(population(train,feature_size)),command_string);
                                    normal_vector(cross,:)=model.w(1:length(feature_size));
b(cross)=model.w(length(feature_size)+1);
test_cases3=arrayfun(@(x) population( test_cases1{x},feature_size)*model.w(1:length(feature_size))'+model.w(length(feature_size)+1),1:100,'UniformOutput',false);
test_cases4=arrayfun(@(x) population( test_cases2{x},feature_size)*model.w(1:length(feature_size))'+model.w(length(feature_size)+1),1:100,'UniformOutput',false);
test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size1),1:100,'UniformOutput',true);
    %Take the mean of the third of tzhe perturbation population hacving
        %maximal distance from the control
  c_criteria=arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true)/length(train)+arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:100,'UniformOutput',true)/length(train)   ;     
average_margin{cross}=[test_class,c_criteria,cellfun(@(x) mean(x),test_cases3),cellfun(@(x) mean(x),test_cases4)];
  end;


end

