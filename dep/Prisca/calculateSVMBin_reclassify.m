
function [classification_accuracy,c_crit] = calculateSVMBin_reclassify(test_cases1,test_cases2,gene_name,C,sample_size,w,b)
%   Detailed explanation goes here


feature_size=1:20;

   
        
  test_cases3=arrayfun(@(x)  test_cases1{x}*w'+b,1:100,'UniformOutput',false);

test_cases4=arrayfun(@(x) test_cases2{x}*w'+b,1:100,'UniformOutput',false);


test_class=arrayfun(@(x) (length(find(test_cases3{x}>0))+length(find(test_cases4{x}<0)))/(2*sample_size),1:100,'UniformOutput',true);

  c_criteria=arrayfun(@(x) sum(max(0,1-(test_cases3{x}))),1:100,'UniformOutput',true)/min(sample_size,120)+arrayfun(@(x) sum(max(0,1+test_cases4{x})),1:100,'UniformOutput',true)/min(sample_size,120)   ;     
        
% if(ttest(c_criteria(1:50),1,0.01)==1)
    %Signficamt classification
    c_crit=mean(c_criteria);
    classification_accuracy=mean(test_class);
% end;

end

