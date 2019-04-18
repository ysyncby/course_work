function [V] = HW2_Q3_code_Cai_eval(V,pol_pi,gamma,Ra,Pa,Rb,Pb,max_num_cars_can_transfer)

max_cars = size(V,1)-1;

states_num = (max_cars+1)^2; 

MAX_N_ITERS = 100; 
iterCnt = 0; 
CONV_TOL = 1e-6;  
delta = +inf;  
tm = NaN; 

while( (delta > CONV_TOL) && (iterCnt <= MAX_N_ITERS) ) 
  delta = 0; 
  for si=1:states_num
    [na1,nb1] = ind2sub( [ max_cars+1, max_cars+1 ], si ); 
    na = na1-1; nb = nb1-1; 
    v = V(na1,nb1); 
    ntrans = pol_pi(na1,nb1); 
    tic;
    V(na1,nb1) = HW2_Q3_code_Cai_bellf(na,nb,ntrans,V,gamma,Ra,Pa,Rb,Pb,max_num_cars_can_transfer);
    tm=toc;
    
    delta = max( [ delta, abs( v - V(na1,nb1) ) ] ); 
  end 
    
  iterCnt=iterCnt+1; 
end 



