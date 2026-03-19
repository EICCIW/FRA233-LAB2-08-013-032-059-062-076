clear; clc; close all;

% Pendulum Param
L = 0.1;     % [m]  (massless link)
mp = 0.05;   % [kg] (point mass)
g = 9.81;    % [m/s^2]
% Motor Param from experiment
% kt = 0.0473;
% ke = 0.0473;
% Lm = 0.003384;
% R = 5.52186; 
% b = 0.000023653;
% J = 0.00001307;

kt = 0.0506;
ke = 0.0528;
Lm = 0.0028445;
R = 3.18;
b = 0.000077581;
J = 0.000058559;
Kp = 1.1305;
Ki = 0.6840;
Kd = 0.46716;

% J_total = J + (mp * L^2);
% s = tf('s');
% plant = kt / (s * ((Lm*s + R)*(J_total*s + b) + kt*ke));
% controlSystemDesigner('rlocus', plant)

    