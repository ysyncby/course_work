function [handsum,usableAce] = HW3_Q1_code_Cai_hv(hand)
values = mod( hand - 1, 13 ) + 1; 
values = min( values, 10 );
sv     = sum(values); 
if (any(values==1)) && (sv<=11)
   sv = sv + 10;
   usableAce = 1; 
else
   usableAce = 0; 
end

handsum = sv; 
