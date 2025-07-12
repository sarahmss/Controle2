close all
clear all
clc
%% Modelo do circuito eletrico RLC
% x1(t) = vC(t) ---> tensão no capacitor 
% x2(t) = iL(t) ---> corrente no indutor
% u(t) ---> tensão da fonte
% y(t) ---> tensão no capacitor
A = [-1/3 -4/3;2/3 -4/3];
B = [1/3; 1/3];
C = [1 0];
sys = ss(A,B,C,[]); % modelo Espaço de Estados tempo contínuo
%-----------------------------------------------------------------
Ts = 0.01; % periodo de amostragem
%------------ Discretização --------------------------------------
sysD = c2d(sys,Ts,'zoh'); % modelo Espaço de Estados tempo discreto
F = sysD.A; % mesma notação da palestra sobre Filtro de Kalman
G = sysD.B; % mesma notação da palestra sobre Filtro de Kalman
H = sysD.C; % mesma notação da palestra sobre Filtro de Kalman

%% Condições iniciais da simulação
u = 10; % tensão da fonte
xk = [0; 0]; % condição inicial do circuito (planta)

%% Inicialização do filtro de Kalman
x_n = [1; 1];      % estimativa inicial
P_n = [1 0; 0 1];  % matriz de covariância da estimativa inicial (incerteza)
Q = [1 0; 0 1];    % matriz de covariância do modelo (incerteza)
R = [1];           % variância da medição (incerteza)

%% Loop de Simulação 
iter = 1000; % nº de iterações da simulação
for j=1:iter
    
    %% simulação do circuito (planta)
    % vamos adicionar disturbio (w) ao modelo e ruido (v) à medicao
    % w = normrnd(mu,sigma) ---> mu = media ; sigma = desv.pad
    w = normrnd(0,0.05,[2,1]);
    v = normrnd(0,0.1);
    xk = F*xk + G*u;
    yk = H*xk;
    x1_w(j) = xk(1) + w(1); % estado x1 com ruido
    x2_w(j) = xk(2) + w(2); % estado x2 com ruido
    x1(j) = xk(1);          % estado x1 sem ruido
    x2(j) = xk(2);          % estado x2 sem ruido
    y(j) = yk + v;          % medicao com ruido
    z_n  = yk + v;
    %% Filtro de Kalman
    % 1ª Etapa: Extrapolação do odelo
    x_n = F*x_n + G*u;
    % 2ª Etapa:  Extrapolação da incerteza
    P_n = F*P_n*F' + Q;
    % 3ª Etapa: Calculo do Ganho de Kalman
    K_n = P_n*H'*inv(H*P_n*H' + R);
    % 4ª Etapa: Equação de atualização de Estado
    x_n = x_n + K_n*(z_n - H*x_n);
    % 5ª Etapa: Atualização da incerteza da estimativa
    P_n = (eye(2) - K_n*H)*P_n*(eye(2) - K_n*H)' + K_n*R*K_n';
    
    % armazena as estimativas do Filtro de Kalman
    x_FK (:,j) = x_n; % estados estimados
    
    
end

figure(1)
hold on
grid on
plot(y,'b:','LineWidth',1.5) % medição
plot(x_FK(1,:),'k','LineWidth',1.5) % estimativa de x1 via FK
plot(x1,'r-.','LineWidth',1.5) % estado sem disturbio
xlabel('Iterações')
ylabel('Tensão [V]')
legend('medicao','x_1 estimado (FK)','x_1 real')


figure(2)
hold on
grid on
plot(x_FK(2,:),'k','LineWidth',1.5) % estimativa de x2 via FK
plot(x2,'r-.','LineWidth',1.5) % estado sem disturbio
xlabel('Iterações')
ylabel('Corrente [A]')
legend('x_2 estimado (FK)','x_2 real')
