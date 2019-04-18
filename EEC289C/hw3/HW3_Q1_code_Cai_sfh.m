function [ret] = HW3_Q1_code_Cai_sfh(h,card)
[hv,u] = HW3_Q1_code_Cai_hv(h);
card = mod( card - 1, 13 ) + 1; 
ret = [ hv, card, u ]; 
return; 




