close all;
clear all;
clc; 

rand('seed',0); randn('seed',0); 

state_num = prod([21-12+1,13,2]);
action_num = 2; 
Q_valu = zeros(state_num,action_num);  
firSum = zeros(state_num,action_num);   
firCou = zeros(state_num,action_num);
pol_pi = unidrnd(2,1,state_num)-1; 

plays_num=5e6;
tic
for episode=1:plays_num  
  stateMat = []; 
  all_cards = randperm( 52 ); 
  card_player = all_cards(1:2); 
  all_cards = all_cards(3:end); 
  player_current = HW3_Q1_code_Cai_hv(card_player);
  dealer = all_cards(1:2); 
  all_cards = all_cards(3:end); 
  deal_current = HW3_Q1_code_Cai_hv(dealer); 
  open_card = dealer(1); 
  
  while( player_current < 12 ) 
    card_player = [card_player, all_cards(1)]; 
    all_cards = all_cards(2:end); 
    player_current = HW3_Q1_code_Cai_hv(card_player); 
  end
  
  stateMat(1,:) = HW3_Q1_code_Cai_sfh(card_player, open_card);
    
  state_init = 1; 
  policy = sub2ind([21-12+1,13,2], stateMat(state_init,1)-12+1, stateMat(state_init,2), stateMat(state_init,3)+1);
  pol_pi(policy) = unidrnd(2)-1;     
  policy_current = pol_pi(policy);
  while( policy_current && (player_current < 22) )
    card_player = [card_player, all_cards(1)]; 
    all_cards = all_cards(2:end); 
    player_current = HW3_Q1_code_Cai_hv(card_player); 
    stateMat(end+1,:) = HW3_Q1_code_Cai_sfh( card_player, open_card ); 

    if( player_current <= 21 ) 
      state_init = state_init+1; 
      policy  = sub2ind( [21-12+1,13,2], stateMat(state_init,1)-12+1, stateMat(state_init,2), stateMat(state_init,3)+1 ); 
      policy_current = pol_pi(policy);
    end
  end
  while( deal_current < 17 )
    dealer = [ dealer, all_cards(1) ]; 
    all_cards = all_cards(2:end); 
    deal_current = HW3_Q1_code_Cai_hv(dealer); 
  end
  rew = HW3_Q1_code_Cai_dr(player_current,deal_current);
  
  for state_init=1:size(stateMat,1)
    if((stateMat(state_init,1)>=12) && (stateMat(state_init,1)<=21)) 
      staInd = sub2ind([21-12+1,13,2], stateMat(state_init,1)-12+1, stateMat(state_init,2), stateMat(state_init,3)+1); 
      actInd = pol_pi(staInd)+1; 
      firCou(staInd,actInd) = firCou(staInd,actInd)+1; 
      firSum(staInd,actInd) = firSum(staInd,actInd)+rew; 
      Q_valu(staInd,actInd) = firSum(staInd,actInd)/firCou(staInd,actInd); % <-take the average 
      [dum,greedyChoice] = max(Q_valu(staInd,:));
      pol_pi(staInd) = greedyChoice-1;
    end
  end  
end 
toc

% plot the optimal state-value
mc_value_fn = max(Q_valu, [], 2);
mc_value_fn = reshape(mc_value_fn, [21-12+1,13,2]); 

figure; 
mesh(1:13, 12:21, mc_value_fn(:,:,1)); 
xlabel('dealer showing'); 
ylabel('player sum'); 
axis xy; 
view([146,-71]);
title('No usable ace'); 
drawnow; 

figure; 
mesh( 1:13, 12:21,  mc_value_fn(:,:,2) ); 
xlabel( 'dealer showing' ); 
ylabel( 'player sum' ); 
axis xy; 
view([146,-71]);
title( 'Usable ace' ); 
drawnow; 

% plot the optimal policy: 
pol_pi = reshape( pol_pi, [21-12+1,13,2] ); 
 
figure; 
imagesc( 1:13, 12:21, pol_pi(:,:,1) ); 
colorbar; 
xlabel( 'dealer showing' ); 
ylabel( 'player sum' ); 
axis xy;
title( 'No usable ace (0: Stick 1:Hit)' ); 
drawnow; 

figure; 
imagesc( 1:13, 12:21,  pol_pi(:,:,2) ); 
colorbar; 
xlabel( 'dealer showing' ); 
ylabel( 'player sum' ); 
axis xy;
title( 'Usable ace' ); 
drawnow; 
return; 
