close all
clear all
clc

%% Modelo do circuito elétrico 
a = 10.4167;
s = tf('s');
Kp = 595;
Gp = a * Kp /(s + a);
Gp_zpk = zpk(Gp); % forma fatorada

[num, den] = tfdata(Gp, 'v'); 
[Ac, Bc, Cc, Dc] = tf2ss(num, den); % conversão para espaço de estados

sys = ss(Ac, Bc, Cc, Dc); % sistema contínuo

%% Discretização
Ts = 0.008; % período de amostragem
sysD = c2d(sys, Ts, 'zoh'); % modelo discreto por ZOH

F = sysD.A;
G = sysD.B;
H = sysD.C;
D = sysD.D;

%% Condições iniciais da simulação
u = 1;                 % entrada constante
xk = zeros(size(F,1), 1); % estado inicial da planta (vetor zero com mesma dimensão de F)

%% Inicialização do filtro de Kalman
x_n = zeros(size(F,1), 1);       % estimativa inicial
P_n = eye(size(F));              % incerteza da estimativa inicial
Q = 1.5 * eye(size(F));        % ruído de processo (modelo) pequeno
R = 1 * eye(size(H,1));       % ruído de medição

%% Inicialização dos vetores de armazenamento
iter = 1000;
x1_w = zeros(1, iter);  % estado com distúrbio
x1   = zeros(1, iter);  % estado real sem ruído
y    = zeros(1, iter);  % saída com ruído
x_FK = zeros(size(F,1), iter); % estimativas do filtro de Kalman

%% Loop de Simulação 
for j = 1:iter
    %% Simulação da planta
    w = normrnd(0, 0.5);   % ruído de processo (distúrbio)
    v = normrnd(0, 10);     % ruído de medição
    xk = F * xk + G * u;   % evolução do estado
    yk = H * xk;           % saída ideal (sem ruído)
    
    % saída com ruído e armazenamento
    x1_w(j) = xk(1) + w; 
    x1(j)   = xk(1);       
    y(j)    = yk + v; 
    z_n     = yk + v; % mesma saída com ruído para o filtro

    %% Filtro de Kalman
    % Previsão (predição)
    x_n = F * x_n + G * u;
    P_n = F * P_n * F' + Q;

    % Atualização
    K_n = P_n * H' / (H * P_n * H' + R); 
    x_n = x_n + K_n * (z_n - H * x_n);
    P_n = (eye(size(F)) - K_n * H) * P_n;

    % Armazena a estimativa
    x_FK(:, j) = x_n;
end

%% Plotagem dos resultados
figure(1)
hold on
grid on
plot(x_FK(1,:) * H , 'k', 'LineWidth', 1.5)      % estimativa Kalman
plot(y, 'b:', 'LineWidth', 1.5)                  % medição com ruído
plot(x1 * H , 'r-.', 'LineWidth', 1.5)           % estado real
xlabel('Iterações')
ylabel('Tensão [V]')
legend('Medição', 'x_1 estimado (FK)', 'x_1 real')
title('Filtro de Kalman aplicado ao sistema discreto')
