function [] = HW1_Q2_code_Cai(run,karm,plays)
% in this test case, in order to reproduce the figure in our book,
% we set:
% run(the number of bandits) 2000
% karm(the number of arms) = 10
% play(the number of plays) = 1000
randn('state',0); 

qsm=mvnrnd(zeros(run,karm),eye(karm)); 
epslons=[2 0.1]; 
% epsilons are settled down as mentioned in out test book
averageReward=zeros(length(epslons),plays); 
qTinit=mvnrnd(qsm,eye(karm));

for epslon=1:length(epslons) 
  tEps=epslons(epslon); 
  qT=zeros(size(qTinit));  
  qN=ones( run, karm );  
  qSum=qT;             

  allRewards=zeros(run,plays); 
  for bandit=1:run 
    aT=ones(10,1);
    aN=ones(10,1);   
    for play=1:plays
      if(epslon == 0.1)
        if(rand(1)<=tEps) 
          [dum,arm]=histc(rand(1),linspace(0,1+eps,karm+1)); 
          clear dum; 
        else                
          [dum,arm]=max( qT(bandit,:) ); 
          clear dum; 
        end
      else
          if(rand(1)<=tEps) 
            [nouse,arm]=max(aT);
            clear nouse
          else                
            [dum,arm]=max( qT(bandit,:) ); 
            clear dum; 
          end
      end
      [dum,bestArm]=min(qsm(bandit,:) );
      
      reward = qsm(bandit,arm) + randn(1); % the standard deviation is 1.0 all the time
      allRewards(bandit,play) = reward; 

      qN(bandit,arm) = qN(bandit,arm)+1;
      qSum(bandit,arm) = qSum(bandit,arm)+reward; 
      qT(bandit,arm) = qSum(bandit,arm)/qN(bandit,arm); 
      arm;
      aN(arm)=aN(arm)+1;
      for a=1:10
        aT(a)=qT(bandit,a)+(2)*sqrt(log(play)/aN(a));
      end
      aN;
      aT;
    end
  end

  avgRew=mean(allRewards,1);
  averageReward(epslon,:)=avgRew(:).'; 
end

figure; 
hold on; 
colors = 'rk'; 
ax1 = []; 
for epslon=1:length(epslons)
  ax1(epslon)=plot(1:plays,averageReward(epslon,:),[colors(epslon),'-']); 
end 
legend(ax1,{'ucb c=2','epsilon: 0.1'},'Location','best'); 
axis tight; 
grid on; 
xlabel('plays'); 
ylabel('Average Reward'); 
