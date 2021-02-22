%% potential field method
clear all; close all; clc;

% num of robots
n = 5;
dim = 4;
       
tspan = [0 50];
% x0 = [0; 0; 0; 0; -4; -4; 0; 0; 4; 4; 0; 0; 4.5; -4; 0; 0; -4; 4; 0; 0; 0]; 
x0 = 5*rand([n*4,1]);
x0(3:4:end) = 0;
x0(4:4:end) = 0;
x0 = [x0; 0];

Opt = odeset('Events', @termEvent);
[t, x] = ode23(@ode_fun,tspan, x0, Opt);

% plot with trajectories

figure % top down view
% plot each robot vs time
for i = 1:n
    if i == 1 %evader
        plot(x(:,4*i-3), x(:,4*i-2), 'r', 'MarkerSize', 10) % trajectory 
        hold on
        plot(x(end,4*i-3), x(end,4*i-2), 'xr', 'MarkerSize', 10) % final point
        plot(x(1,4*i-3), x(1,4*i-2), '.r', 'MarkerSize', 10) % first point
    else % pursuer 
        plot(x(1,4*i-3), x(1,4*i-2), '.b', 'MarkerSize', 10)
        plot(x(:,4*i-3), x(:,4*i-2), '--b', 'MarkerSize', 10)
        plot(x(end,4*i-3), x(end,4*i-2), 'xb', 'MarkerSize', 10)
    end
end

grid on

% add legend and title
title('Trajectories')
% legend('Evader', 'Pursuer 1', 'Pursuer 2')
xlabel('x1')
ylabel('x2')

%% plotting against time
figure
subplot(2,1,1) % x1 state
for i = 1:n
    plot(t, x(:,2*i-1))
    hold on
end
grid on

% legend('Robot 1', 'Robot 2', 'Robot 3', 'Robot 4', 'Robot 5', 'Robot 6')
title('x1')

xlabel('t')
ylabel('x1')

subplot(2,1,2) % x2 state
for i = 1:n
    plot(t, x(:,2*i))
    hold on
end
grid on

legend('Robot 1', 'Robot 2', 'Robot 3', 'Robot 4', 'Robot 5', 'Robot 6')
title('x2')

xlabel('t')
ylabel('x2')