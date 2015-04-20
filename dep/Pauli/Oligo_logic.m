function oligo=oligo_logic(platename)
%added default 0 if no oligo number found (BS)
oligo = 0;
if not(isempty(strfind(platename,'1_1'))) | not(isempty(strfind(platename,'1_2'))) | not(isempty(strfind(platename,'1_3')))
	oligo=1;
end
if not(isempty(strfind(platename,'2_1'))) | not(isempty(strfind(platename,'2_2'))) | not(isempty(strfind(platename,'2_3')))
	oligo=2;
end
if not(isempty(strfind(platename,'3_1'))) | not(isempty(strfind(platename,'3_2'))) | not(isempty(strfind(platename,'3_3')))
	oligo=3;
end

if not(isempty(strfind(platename,'1_1_'))) 
	oligo=1;
end
if not(isempty(strfind(platename,'2_1_')))
	oligo=2;
end
if not(isempty(strfind(platename,'3_1_')))
	oligo=3;
end

% (BS) added some extra logics for AD3, which should work overall... 
if not(isempty(strfind(platename,'_P1_'))) 
	oligo=1;
end
if not(isempty(strfind(platename,'_P2_')))
	oligo=2;
end
if not(isempty(strfind(platename,'_P3_')))
	oligo=3;
end
if not(isempty(strfind(platename,'_p1_'))) 
	oligo=1;
end
if not(isempty(strfind(platename,'_p2_')))
	oligo=2;
end
if not(isempty(strfind(platename,'_p3_')))
	oligo=3;
end

if not(isempty(strfind(platename,'_pooled_1_'))) 
	oligo=1;
end
if not(isempty(strfind(platename,'_pooled_2_')))
	oligo=2;
end
if not(isempty(strfind(platename,'_pooled_3_')))
	oligo=3;
end