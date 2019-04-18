clear all;
close all;
clc;
runs = 2;
N_STATES = 1000;
STATES = 1:N_STATES;
episodes = 1;
num_of_tilings = 50;
% each tile will cover 200 states
tile_width = 200;
tilingSize = floor(1000 / tile_width) + 1;
true_value = compute_true_value();
params = zeros(num_of_tilings, tilingSize);
params2 = zeros(floor(N_STATES / tile_width));

% how to put so many tilings
tiling_offset = 4;
tilings = -tile_width + 1 : tiling_offset : 0;

%track errors for each episode
errors = zeros(2, 5000);

for run = 1 : runs
    %value_functions = [TilingsValueFunction(num_of_tilings, tile_width, tiling_offset), ValueFunction(floor(N_STATES / tile_width))];
    for i = 1 : 2
        for episode = 1 : episodes
            alpha = 1.0 / (episode + 1);            
            %gradient Monte Carlo algorithm
            [params, params2] = gradient_monte_carlo(i, alpha, floor(N_STATES / tile_width), num_of_tilings, tilings, tile_width, params, params2);            
            %get state values under current value function
            if i == 1
                for state = STATES                
                state_values = [state_values, TilingsValueFunction(params, num_of_tilings, tile_width, tiling_offset, state)];            
                end
            else
                for state = STATES                
                state_values = [state_values, ValueFunction(params2, floor(N_STATES / tile_width), state)];            
                end
            end      
            %get the root-mean-squared error
            errors(i, episode) = errors(i, episode) + rms(power((true_value(2 : length(true_value) - 1) - state_values) , 2));            
        end
    end    
end

errors = errors / runs;

for i = 1 : 2
    plot(errors(i));
end

function  [stateValue] = TilingsValueFunction(params, tilings, tile_width, tiling_offset, state)
    
    stateValue = 0.0;

    %tilingSize = floor(1000 / tileWidth) + 1;  
    for tilingIndex = 1 : length(tilings)
        
        tileIndex = floor((state - tilings(tilingIndex)) / tile_width)+1;
        tileIndex
        stateValue = stateValue + params(tilingIndex, tileIndex);
    
    end
    
end

function  params = TilingsValueFunction_update(state, params, delta, tilings, num_of_tilings, tilewidth)    
    delta = delta / num_of_tilings;
    
    for tilingIndex = 1 : length(tilings)
    
        tileIndex = floor((state - tilings(tilingIndex)) / tilewidth)+1;
    
        params(tilingIndex, tileIndex) = params(tilingIndex, tileIndex) + delta;
        
    end    
end

function  params2 = ValueFunction_update(params2, delta, num_of_groups, state)
    
    group_size = floor(1000 / num_of_groups);

    %params2 = zeros(num_of_groups);
    
    %END_STATES = [1, 1000];
    
    group_index = floor((state - 1) / group_size);
    
    params2(group_index) = params2(group_index) + delta;
    
end
function  [stateValue] = ValueFunction(params2, num_of_groups, state)
    
    group_size = floor(1000 / num_of_groups);

    %params2 = zeros(num_of_groups);
    
    %END_STATES = [1, 1000];
    
    if state == 1 || state == 1000        
        stateValue = 0;    
    else    
        group_index = floor((state - 1) / group_size);        
        stateValue = params2(group_index);        
    end    
end

function [params, params2] = gradient_monte_carlo(i, alpha, num_of_groups, num_of_tilings, tilings, tilewidth, params, params2)
    state = 500;    
    tiling_offset = 4;    
    trajectory = [state];    
    reward = 0.0;   
    while(state ~= 1 || state~= 1001)
        state
        if binornd(1,0.5) == 1
            action = 1;
        else
            action = -1;
        end        
       [next_state, reward] = step_reward(state, action);     
        trajectory = [trajectory, next_state];       
        state = next_state;       
    end
    
    for state = trajectory(1: length(trajectory) - 1)      
        if i == 1
            delta = alpha * (reward - TilingsValueFunction(params, num_of_tilings, tilewidth, tiling_offset, state));           
            params = TilingsValueFunction_update(state, params, delta, tilings, num_of_tilings, tilewidth);                   
        else
            delta = alpha * (reward - ValueFunction(params2, num_of_groups, state));            
            params2 = ValueFunction_update(params2, delta, num_of_groups, state);          
        end     
    end
end

function [next_state, reward] = step_reward(state, action)
    step = randi(100);    
    step = step * action;    
    state = state + step;   
    next_state = max(min(state, 1001), 1);    
    if state == 0
        reward = -1;
    elseif state == 1001
        reward = 1;
    else
        reward = 0;
    end
end

function [true_value] = compute_true_value()
    true_value = (-1001 : 2 : 1002) / 1001;
    while true
        old_value = true_value;        
        for state = 1:1000
            true_value(state) = 0;           
            for action  = [-1, 1]
                for step = 1 : 100                    
                    step = step * action;                    
                    next_state1 = state + step;                    
                    next_state1 = max(min(next_state1, 1001), 1);                    
                    true_value(state) = true_value(state) +  (1/ (2 * 100)) * true_value(next_state1);
                end
            end        
        end
        error = sum(abs(old_value - true_value));       
        if error < 0.01
                break;
        end  
    end
    true_value(1) = 0;
    true_value(length(true_value)) = 0;
end