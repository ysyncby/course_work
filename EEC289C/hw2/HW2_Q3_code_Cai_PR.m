function [R,P] = HW2_Q3_code_Cai_PR(lambdaRequests,lambdaReturns,max_n_cars,max_num_cars_can_transfer)

nCM = 0:(max_n_cars+max_num_cars_can_transfer);

R = zeros(1,length(nCM)); 
for n = nCM
tmp = 0.0; 
for nr = 0:(10*lambdaRequests)
  tmp = tmp + 10*min(n,nr)*poisspdf( nr, lambdaRequests );
end
R(n+1) = tmp; 
end

P = zeros(length(nCM),max_n_cars+1); 
for nreq = 0:(10*lambdaRequests) 
  reqP = poisspdf( nreq, lambdaRequests ); 
  
  for nret = 0:(10*lambdaReturns) 
    retP = poisspdf( nret, lambdaReturns ); 
    for n = nCM
      sat_requests = min(n,nreq); 
      new_n = max( 0, min(max_n_cars,n+nret-sat_requests) );
      P(n+1,new_n+1) = P(n+1,new_n+1) + reqP*retP;
    end
  end
end





