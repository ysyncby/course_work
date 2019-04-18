function [reward] = HW3_Q1_code_Cai_dr(player,dealer)

if( player>21 ) 
  reward = -1; 
  return; 
end
if( dealer>21 ) 
  reward = +1; 
  return; 
end
if( player==dealer ) 
  reward = 0; 
  return;
end
if( player>dealer ) 
  reward = +1; 
else
  reward = -1; 
end

