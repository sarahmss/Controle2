close all
clc

%% Sistema em malha aberta
a = 10.4167;
s = tf('s');
Kp = 595;
Gp = a * Kp /(s + a);
Gp_zpk = zpk(Gp); % forma fatorada

[num, den] = tfdata(Gp, 'v'); 
[Ac, Bc, Cc, Dc] = tf2ss(num, den); % conversão para espaço de estados

sys = ss(Ac, Bc, Cc, Dc); % sistema contínuo

%% Sistema em malha fechada
Q_c = 0.1 * eye(1); % Aumentar Q em relação a R: x(t)->0 mais rapidamente esforço de controle u(t) maior
R_c = 20 * eye(1); % Aumentar R em relação a Q: u(t) é menor e x(t) tende a uma resposta superamortecida 

% Por função LQI e sistema expandido
[Ke, Se, Pe] = lqi(sys, Q_c, R_c);
K  = Ke(1:end-1);
Ki = -Ke(end);

% Sistema em malha fechada com integrador
A_cl = [Ac - Bc*K, Bc*Ki;
            -Cc      ,  0];

B_cl = [0; 1];  % Entrada de referência
C_cl = [Cc 0];
D_cl = 0;

sys_cl = ss(A_cl, B_cl, C_cl, D_cl);

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
