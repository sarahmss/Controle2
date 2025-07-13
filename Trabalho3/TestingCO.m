close all
clear all
clc
%% Definição do sistema
a = 7.8125;
s = tf('s');
Kp = 621;
Ts = 0.008; % Período de amostragem (Ts = 8ms)
Gp = a * Kp /(s+a);
Gp_zpk = zpk(Gp);
[num, den] = tfdata(Gp, 'v'); 
[Ac, Bc, Cc, Dc] = tf2ss(num, den);
sys = ss(Ac, Bc, Cc, Dc); % Sistema tempo contínuo
dados = readtable('./Remodelando/saida-156.csv');

t8ms = 1:(length(dados.Tempo)/2.5);
t8ms = t8ms * 8e-3;
%% Discretização do sistema 
n = size(Ac);
Aeuler =  eye(n) + Ts * sys.A; 
Beuler =  Ts * sys.B;
Ceuler = sys.C;
Deuler = sys.D;
sys_euler = ss(Aeuler, Beuler, Ceuler, Deuler, Ts);

sistemas_list = {sys, sys_euler};
nomes_sistemas = {'Contínuo', 'Euler'};  % nomes para exibição
n = numel(sistemas_list);

% Inicializa células para os dados da tabela
SistemaCell = cell(n,1);
ACell = cell(n,1);
BCell = cell(n,1);
CCell = cell(n,1);
DCell = cell(n,1);

for i = 1:n
    s = sistemas_list{i};
    SistemaCell{i} = nomes_sistemas{i};
    ACell{i} = mat2str(s.A, 4);
    BCell{i} = mat2str(s.B, 4);
    CCell{i} = mat2str(s.C, 4);
    DCell{i} = mat2str(s.D, 4);
end

% Cria a tabela
T = table(SistemaCell, ACell, BCell, CCell, DCell, ...
    'VariableNames', {'Sistema', 'A', 'B', 'C', 'D'});

% Exporta para CSV
writetable(T, 'sistemas.csv');

disp(T);

%% Sintonia Q e R: variando Q e R 

% C_r_values = [0.1, 0.1, 0.1, 0.1]; 
% C_q_values = [0.5, 1, 2, 3];  
% 
% K_r_values = [0.1, 0.1, 0.1, 0.1]; 
% K_q_values = [5, 10, 20, 30];  

%% Sintonia de Q e R: variando R e Q fixo
% C_q_values = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; 
% C_r_values = [5, 6, 7, 8, 9, 10, 20, 30, 40, ];  
% 
% K_q_values = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; 
% K_r_values = [50, 60, 70, 80, 90, 100, 200, 300, 400]; 


C_q_values = [0.1]; 
C_r_values = [6];  

K_q_values = [0.1]; 
K_r_values = [60]; 


%%

T_total = table();

for i = 1:length(C_q_values)
%% LQI    
    C_q = C_q_values(i);
    C_r = C_r_values(i);

    Q_c = C_q * eye(1); % Aumentar Q em relação a R: x(t)->0 mais rapidamente esforço de controle u(t) maior
    R_c = C_r * eye(1); % Aumentar R em relação a Q: u(t) é menor e x(t) tende a uma resposta superamortecida 
    
    % Encontrando os ganhos
    
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
    % Discretização do sisteman
    N = length(t8ms);
    R = 595;
    
    t = t8ms;
    u = ones(size(t)); % Degrau unitário
    
    % Respostas em malha fechada dos sistemas
    [y_cl, time_cl, x_cl] = lsim(sys_cl, u, t);       
    [y_euler, u_euler, x_euler, e_euler, xn_euler] = ApplyController(sys_euler, K, Ki, N, Ts, R);

%% Figura do controlador
    f = figure;
    % --- Subplot 1: Sinal de Controle u[k]
    subplot(2,2,1);
    hold on;
    plot(t, u_euler, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('u[k]');
    title('Sinal de Controle $u[k]$', 'Interpreter', 'latex');
    grid on;
    
    % --- Subplot 1: Estado xk
    subplot(2,3,4);
    hold on;
    plot(t, x_cl(:,1) * R, 'k-', 'LineWidth', 1.5); 
    plot(t, x_euler, 'b-', 'LineWidth', 1.5);
    hold off;
    title('Estado: $x[k]$', 'Interpreter', 'latex');
    xlabel('Iteração [k]');
    ylabel('$x[k]$', 'Interpreter', 'latex');
    grid on;
    
    % --- Subplot 2: Estado xn
    subplot(2,3,5);
    hold on;
    plot(t, x_cl(:,2) * R, 'k-', 'LineWidth', 1.5); 
    plot(t, xn_euler, 'b-', 'LineWidth', 1.5);
    hold off;
    title('Estado: $x_n[k]$', 'Interpreter', 'latex');
    xlabel('Iteração [k]');
    ylabel('$x_n[k]$', 'Interpreter', 'latex');
    grid on;
    
    
    % --- Subplot 3: Erro
    subplot(2,3,6);
    hold on;
    plot(t, e_euler, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$e[k]$', 'Interpreter', 'latex');
    title('Erro $e[k]$', 'Interpreter', 'latex');
    grid on;
    
    % --- Subplot 4: Saída
    subplot(2,2,2);
    hold on;
    plot(t, y_cl * R, 'k-', 'LineWidth', 2, 'DisplayName', 'Contínuo');
    plot(t, y_euler, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('y[k]');
    title('Saida $y[k]$', 'Interpreter', 'latex');
    grid on;
    
    
    sgtitle(sprintf('Analise do controlador ($Q_c = %g$, $R_c = %g$)', Q_c, R_c), 'Interpreter', 'latex');
    
    % Legenda global abaixo da figura
    legend({'Continuo', 'Euler'}, ...
        'Orientation', 'vertical', ...
        'Location', 'best', ...
        'Interpreter', 'latex'); 
    
    
    % Exporta tudo em um único PDF
    exportgraphics(f, sprintf('./Resultados/AnaliseDoControlador_Q%g_R%g.pdf', Q_c, R_c), 'ContentType', 'vector');


%% Projeto do observador sem filtro de kalman

info = stepinfo(y_euler, t);
ts = info.SettlingTime;
up = info.Overshoot;

qsi = (-log(up/100))/(sqrt(pi^2+log(up/100)^2));
Ts_obs = (ts / 10);
wn_obs = 4/(qsi*Ts_obs); % Calcula a frequência natural
polo_o = qsi*wn_obs
L_o = -place(Ac', Cc', polo_o)';

[y_log_obs, e_log_obs, e_hat_obs, u_obs, y_hat_obs, x_hat_obs, x_log_obs] =  ApplyControllerAndObserver(sys_euler, K, Ki, L_o*Ts, N, Ts, R);


%% Filtro de kalman
    K_q = K_q_values(i);
    K_r = K_r_values(i);

    Q_k = K_q * eye(1); % Aumentar Q em relação a R: 
    R_k = K_r * eye(1); % Aumentar R em relação a Q: 
    
    [kalmf, L_k, P] = kalman(sys, Q_k, R_k); 

[y_log_kalman, e_log_kalman, e_hat_kalman, u_kalman, y_hat_kalman, x_hat_kalman, x_log_kalman] = ApplyControllerAndObserver(sys_euler, K, Ki, L_k*Ts, N, Ts, R);
%%
f = figure;

% --- 1. Saída y[k] e y_hat
subplot(3,1,1); hold on;
plot(t, y_log_obs, 'k-', 'LineWidth', 1.5);       % Real (referência)
plot(t, y_hat_obs, 'b--', 'LineWidth', 1.5);      % Estimado - observador
plot(t, y_hat_kalman, 'r:', 'LineWidth', 1.5);    % Estimado - Kalman
xlabel('Iteração [k]');
ylabel('$y[k]$', 'Interpreter', 'latex');
title('Saida estimada $\hat{y}[k]$', 'Interpreter', 'latex');
legend({'$y[k]$', '$\hat{y}[k]$ Obs.', '$\hat{y}[k]$ Kalman'}, ...
       'Interpreter', 'latex', 'Location', 'best');
grid on;

% --- 2. Estado x[k] e x_hat
subplot(3,1,2); hold on;
plot(t, x_log_obs, 'k-', 'LineWidth', 1.5);       % Estado real
plot(t, x_hat_obs, 'b--', 'LineWidth', 1.5);      % Estimado - observador
plot(t, x_hat_kalman, 'r:', 'LineWidth', 1.5);    % Estimado - Kalman
xlabel('Iteração [k]');
ylabel('$x[k]$', 'Interpreter', 'latex');
title('Estado estimado $\hat{x}[k]$', 'Interpreter', 'latex');
legend({'$x[k]$', '$\hat{x}[k]$ Obs.', '$\hat{x}[k]$ Kalman'}, ...
       'Interpreter', 'latex', 'Location', 'best');
grid on;

% --- 3. Erro de estimativa
subplot(3,1,3); hold on;
plot(t, e_hat_obs, 'b--', 'LineWidth', 1.5);      % Erro - observador
plot(t, e_hat_kalman, 'r:', 'LineWidth', 1.5);    % Erro - Kalman
xlabel('Iteração [k]');
ylabel('$\hat{e}[k]$', 'Interpreter', 'latex');
title('Erro de estimativa $\hat{e}[k]$', 'Interpreter', 'latex');
legend({'$\hat{e}[k]$ Obs.', '$\hat{e}[k]$ Kalman'}, ...
       'Interpreter', 'latex', 'Location', 'best');
grid on;

% --- Título geral
sgtitle(sprintf('Observador vs Kalman \n($Q_c = %.2f$, $R_c = %.2f$ | $L_o = %.3f$, $L_k = %.3f$)', ...
        Q_c, R_c, L_o, L_k), 'Interpreter', 'latex');

% Exporta como PDF vetorial
exportgraphics(f, sprintf('./Resultados/CompObsKalman_%.2f_%.2f.pdf', Q_c, R_c), 'ContentType', 'vector');

%%  Cálculo das especificações de desempenho 
    info_euler  = stepinfo(y_euler, t);
    
    overshoot = info_euler.Overshoot;
    settlingTime = info_euler.SettlingTime;
%% Criação da Tabela
    T = table(Q_c, R_c, Q_k, R_k, L_o, L_k, K, Ki,overshoot, settlingTime, ...
        'VariableNames', {'Q_c', 'R_c', 'Q_k', 'R_k', 'L_o', 'L_k', 'K', 'Ki', 'Ultrapassagem(%)', 'TempoAcomodacao(s)'});
    T_total = [T_total; T];  % Concatenar na vertical

end

% Exibição no console
disp('== Comparação de Desempenho ==');
disp(T_total);

writetable(T_total, './Resultados/Rmaior/VariandoR_QFixo.csv');
