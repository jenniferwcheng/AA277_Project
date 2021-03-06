%% Simulate pursuit-evasion
clear all; close all; clc;

%----Parameters-----------
global ne;
global np;
ne = 2; % Number of evaders
np = 3; % Number of pursuers
n = ne + np; % Total number of robots
dim = 4; % Order of states

capture_radius = 0.2; % [m] (If changing this value, remember to change in termEvent.m as well)
global caught; % Global variable to determine whether an evader is caught: 0 - not caught, 1 - caught
caught = zeros(ne, 1);
vmax = 1; % [m/s] Same for both methods
amax = 10; % [m/s^2] 
grid_size = 20; % [m] size of environment (length) -> area = grid_size^2
global F; % For video

% Flags
method = 0; % 0 for potential, 1 for Voronoi
save_video = 0; % 1 to plot in real time and save video
monte_carlo = 0; % 1 - on, 0 - off

t_end = 60; % [s] length of simulation time

% Monte Carlo params
MAX_ITERS = 100; % Iterations for Monte Carlo
success_rate = 0; % Number of successes/MAX_ITERS
average_capture_time = 0; % Total capture time/MAX_ITERS

%----Initial conditions------

% Random positions:
x0 = grid_size/2*rand([n*dim,1]) - grid_size/4;
x0(3:dim:end) = 0; % zero velocity
x0(4:dim:end) = 0; % zero acceleration

% x0 = [0; 0; 0; 0; -4; -4; 0; 0; 4; 4; 0; 0; 5; -4; 0; 0; -4; 4; 0; 0]; % square
% x0 = [0; 0; 0; 0; 6; 3; 0; 0; 5; 5; 0; 0];
% x0 = [-5; -5; 0; 0; 5; 0; 0; 0; -5; -4; 0; 0; 4; 0; 0; 0; 6; 0; 0; 0];

%-------Run ODE function---------------
Opt = odeset('Events', @termEvent); % Terminate when within capture radius
% [t, x] = ode23(@ode_fun,tspan, x0, Opt);
if monte_carlo
    for i = 1:MAX_ITERS
        % Random positions:
        x0 = grid_size/2*rand([n*dim,1]) - grid_size/4;
        x0(3:dim:end) = 0; % zero velocity
        x0(4:dim:end) = 0; % zero acceleration
        caught = zeros(ne, 1);

        [t, x] = ode23(@(t,x) ode_fun(t,x, method, save_video, vmax, amax, ne, np, grid_size),[0 t_end], x0, Opt);
%         t(end)
        if t(end) < t_end
            success_rate = success_rate + 1;
            average_capture_time = average_capture_time + t(end);
        end
    end
    average_capture_time = average_capture_time/MAX_ITERS;
    success_rate = success_rate/MAX_ITERS;
    
    fprintf('Number of pursuers: %0.5g \n', np)
    fprintf('Number of evaders: %0.5g \n', ne)
    fprintf('Capture radius: %0.5g \n', capture_radius)
    fprintf('Number of iterations: %0.5g \n', MAX_ITERS)
    fprintf('Success rate: %0.5g \n', success_rate)
    fprintf('Average capture time: %0.5g \n', average_capture_time)
else
    tspan = [0 t_end];
    [t, x] = ode23(@(t,x) ode_fun(t,x, method, save_video, vmax, amax, ne, np, grid_size),tspan, x0, Opt);

    %-------Video--------------------------
%     if save_video % Save video
%         writerObj = VideoWriter('video.avi');
%         writerObj.FrameRate = 10;
%         open(writerObj);
%         % write the frames to the video
%         for i=1:length(F)
%             % convert the image to a frame
%             frame = F(i) ;    
%             writeVideo(writerObj, frame);
%         end
%         close(writerObj);
%     end

    %-------Determine capture time-----------
    capture_time = t(end);
    if capture_time < t_end
        fprintf('Number of pursuers: %0.5g \n', np)
        fprintf('Number of evaders: %0.5g \n', ne)
        fprintf('Capture radius: %0.5g \n', capture_radius)
        fprintf('Capture time: %0.5g \n', capture_time)
        t_end = capture_time;
    else
        fprintf('Number of pursuers: %0.5g \n', np)
        fprintf('Number of evaders: %0.5g \n', ne)
        fprintf('Capture radius: %0.5g \n', capture_radius)
        disp("Capture not successful")
    end

    %-------Trajectory plot-----------------
    close all;
    set(0,'DefaultFigureWindowStyle','docked')
    figure
    for i = 1:n
        if i <= ne % Evader
            plot(x(:,4*i-3), x(:,4*i-2), 'r', 'MarkerSize', 10) % Trajectory 
            hold on
            plot(x(1,4*i-3), x(1,4*i-2), '.r', 'MarkerSize', 10) % Initial position
            plot(x(end,4*i-3), x(end,4*i-2), 'xr', 'MarkerSize', 10) % Final position
        else % Pursuer 
            plot(x(:,4*i-3), x(:,4*i-2), '--b', 'MarkerSize', 10) % Trajectory
            plot(x(1,4*i-3), x(1,4*i-2), '.b', 'MarkerSize', 10) % Initial position
            plot(x(end,4*i-3), x(end,4*i-2), 'xb', 'MarkerSize', 10) % Final position
        end
    end
    grid on
    title('Trajectories')
    xlabel('x1 [m]')
    ylabel('x2 [m]')
    axis equal
    xlim([-grid_size/2 grid_size/2])
    ylim([-grid_size/2 grid_size/2])

    %----------Plot distance to evader-----------

    figure % Distance to evader 
    
    if ne > 1
        plot_color = rand(np,3);
        for i = 1:ne
            subplot(ne,1,i)
            plot(t, capture_radius*ones(length(t)), 'k--')
            hold on
            for j = ne+1:n
                plot(t, vecnorm(x(:,4*i-3:4*i-2) - x(:,4*j-3:4*j-2),2,2), 'color', plot_color(j-ne,:))
                hold on
                grid on
            end
            plot(t, capture_radius*ones(length(t)), 'k--')
            title(['Distance to Evader ', num2str(i)])
            xlabel('Time [s]')
            ylabel('Distance [m]')
            legend('Capture Radius')
        end
    else
        plot(t, capture_radius*ones(length(t)), 'k--')
        hold on
        for i = 2:n
            plot(t, vecnorm(x(:,1:2) - x(:,4*i-3:4*i-2),2,2))
            hold on
            grid on
        end
        xlabel('Time [s]')
        ylabel('Distance [m]')
    end

    legend('Capture Radius')
    title('Distance to Evader')


    %----------Plot velocities----------------
    figure
    subplot(2,1,1) % x velocity
    for i = 1:n
        plot(t, x(:,4*i-1))
        hold on
    end
    plot(t, vmax*ones(length(t)),'k--', t, -vmax*ones(length(t)), 'k--') % min max lines
    title('X Velocities')
    xlabel('t')
    ylabel('Vx')
    grid on
    ylim(2*[-vmax,vmax])
    xlim([0,t_end])

    subplot(2,1,2) % y velocity
    for i = 1:n
        plot(t, x(:,4*i))
        hold on
    end
    plot(t, vmax*ones(length(t)), 'k--', t, -vmax*ones(length(t)), 'k--') % min max line
    grid on
    title('Y Velocities')
    xlabel('t')
    ylabel('Vy')
    ylim(2*[-vmax,vmax])
    xlim([0,t_end])
end