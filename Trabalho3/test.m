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
sysD = c2d(sys_cl, Ts, 'zoh'); % modelo discreto por ZOH
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
plot(x_FK(1,:) * H(1,:),'k','LineWidth',1.5) % estimativa de x1 via FK
plot(y,'b:','LineWidth',1.5) % medição
plot(x1 *  H(1,:),'r-.','LineWidth',1.5) % estado sem disturbio
xlabel('Iterações')
ylabel('Tensão [V]')
legend('medicao','x_1 estimado (FK)','x_1 real')


% figure(2)
% hold on
% grid on
% plot(x_FK(2,:),'k','LineWidth',1.5) % estimativa de x2 via FK
% plot(x2,'r-.','LineWidth',1.5) % estado sem disturbio
% xlabel('Iterações')
% ylabel('Corrente [A]')
% legend('x_2 estimado (FK)','x_2 real')
