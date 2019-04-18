function [pol_pi,policyStable] = HW2_Q3_code_Cai_impv(pol_pi,V,gamma,Ra,Pa,Rb,Pb,max_num_cars_can_transfer)

max_n_cars = size(V,1)-1;
nStates = (max_n_cars+1)^2; 
policyStable = 1; 
tm = NaN; 

for si=1:nStates 
    [na1,nb1] = ind2sub( [ max_n_cars+1, max_n_cars+1 ], si ); 
    na = na1-1; nb = nb1-1;
    b = pol_pi(na1,nb1);
    posA = min([na,max_num_cars_can_transfer]); 
    posB = min([nb,max_num_cars_can_transfer]); 
    posActionsInState = [ -posB:posA ]; npa = length(posActionsInState); 
    Q = -Inf*ones(1,npa);
    tic; 
    for ti = 1:npa,
      ntrans = posActionsInState(ti);  
      Q(ti) = HW2_Q3_code_Cai_bellf(na,nb,ntrans,V,gamma,Ra,Pa,Rb,Pb,max_num_cars_can_transfer);
    end 
    tm=toc; 
    
    [dum,imax] = max( Q );
    maxPosAct  = posActionsInState(imax); 
    if( maxPosAct ~= b )      
      policyStable = 0; 
      pol_pi(na1,nb1) = maxPosAct; 
    end
end 



