cars_number = 20; 
trans_max = 5; 
gamma = 0.9; 

A_return = 3; 
A_rental = 3; 
B_return = 2; 
B_rental = 4; 

[Ra,Pa] = HW2_Q3_code_Cai_PR(A_rental,A_return,cars_number,trans_max);
[Rb,Pb] = HW2_Q3_code_Cai_PR(B_rental,B_return,cars_number,trans_max);

V = zeros(cars_number+1,cars_number+1); 

pol_pi = zeros(cars_number+1,cars_number+1); 

stable = 0; 
step = 0; 
while( ~stable )
    figure; 
    imagesc( 0:cars_number, 0:cars_number, pol_pi ); 
    colorbar; 
    xlabel( '#Cars at second location' ); 
    ylabel( '#Cars at first location' ); 
    title( ['pi=', num2str(step)] ); axis xy; drawnow;
  
  V = HW2_Q3_code_Cai_eval(V,pol_pi,gamma,Ra,Pa,Rb,Pb,trans_max);

  if( step==4 )   
      figure; 
      mesh( 0:cars_number, 0:cars_number, V ); 
      colorbar; 
      xlabel( '#Cars at second location' ); 
      ylabel( '#Cars at first location' );
      axis xy; 
      title( ['state-value pi=4'] ); 
      view(27,49)
      drawnow;    
  end

  [pol_pi,stable] = HW2_Q3_code_Cai_impv(pol_pi,V,gamma,Ra,Pa,Rb,Pb,trans_max);
  step=step+1; 
end




