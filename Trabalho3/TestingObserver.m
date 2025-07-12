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

%% 
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

    t = t8ms;
    u = ones(size(t)); % Degrau unitário
    
    % Respostas em malha fechada dos sistemas
    [y_cl, time_cl, x_cl] = lsim(sys_cl, u, t);    

    % Discretização do sistema
    n = size(Ac);
    N = length(t8ms);
    R = 595;
    
    Aeuler =  eye(n) + Ts * sys.A; 
    Beuler =  Ts * sys.B;
    Ceuler = sys.C;
    Deuler = sys.D;
    sys_d = ss(Aeuler, Beuler, Ceuler, Deuler, Ts);

    t = t8ms;          
    [y, ~, x, e, xn] = ApplyController(sys_d, K, Ki, N, Ts, R);    

%%  Projeto do Observador sem filtro de kallman

info = stepinfo(y, t);
ts = info.SettlingTime;
up = info.Overshoot;

qsi = (-log(up/100))/(sqrt(pi^2+log(up/100)^2));
Ts_obs = (ts / 10);
wn_obs = 4/(qsi*Ts_obs); % Calcula a frequência natural
polo_o = qsi*wn_obs
L_o = -place(Ac', Cc', polo_o)';


[y_log, e_log, e_hat, u, y_hat, x_hat, x_log] = ApplyControllerAndObserver(sys_d, K, Ki, L_o*Ts, N, Ts, R);

 f = figure;

    % --- Subplot 1: Sinal de Controle u[k]
    subplot(2,2,1);
    hold on;
    plot(t, u, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('u[k]');
    title('Sinal de Controle $u[k]$', 'Interpreter', 'latex');
    legend({'$u[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 2: Saida
    subplot(2,2,2);
    hold on;
    plot(t, y_log, 'b-', 'LineWidth', 1.5);
    plot(t, y_hat, 'g:', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('y[k]');
    title('Saida $y[k]$', 'Interpreter', 'latex');
    legend({'$y[k]$', '$\hat{y}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 3: Estado observado xk
    subplot(2,3,4);
    hold on;
    plot(t, x_log, 'b-', 'LineWidth', 1.5);
    plot(t, x_hat, 'g:', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$\hat{x}[k]$, $x[k]$', 'Interpreter', 'latex');
    title('$\hat{x}[k]$ vs $x[k]$', 'Interpreter', 'latex');
    legend({'$x[k]$', '$\hat{x}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 4: Erro de estimativa
    subplot(2,3,5);
    hold on;
    plot(t, e_hat, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$\hat{e}[k]$', 'Interpreter', 'latex');
    title('Erro de estimativa: $\hat{e}[k]$', 'Interpreter', 'latex');
    legend({'$\hat{e}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 5: Erro real
    subplot(2,3,6);
    hold on;
    plot(t, e, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$e[k]$', 'Interpreter', 'latex');
    title('Erro $e[k]$', 'Interpreter', 'latex');
    legend({'$e[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;

sgtitle(sprintf('Analise do Observador: ($L_o = %g$ $Q_c = %g$, $R_c = %g$)', round(L_o, 3), Q_c, R_c), 'Interpreter', 'latex');

% Exporta tudo em um único PDF
exportgraphics(f, './Resultados/Observador.pdf', 'ContentType', 'vector');

%% Projeto do Observador com filtro de kallman

Q_k = 0.1 * eye(1); % Aumentar Q em relação a R: 
R_k = 200 * eye(1); % Aumentar R em relação a Q: 

[kalmf, L_k, P] = kalman(sys, Q_k, R_k);

[y_log, e_log, e_hat, u, y_hat, x_hat, x_log] = ApplyControllerAndObserver(sys_d, K, Ki, L_k*Ts, N, Ts, R);

 f = figure;

    % --- Subplot 1: Sinal de Controle u[k]
    subplot(2,2,1);
    hold on;
    plot(t, u, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('u[k]');
    title('Sinal de Controle $u[k]$', 'Interpreter', 'latex');
    legend({'$u[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 2: Saida
    subplot(2,2,2);
    hold on;
    plot(t, y_log, 'b-', 'LineWidth', 1.5);
    plot(t, y_hat, 'g:', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('y[k]');
    title('Saida $y[k]$', 'Interpreter', 'latex');
    legend({'$y[k]$', '$\hat{y}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 3: Estado observado xk
    subplot(2,3,4);
    hold on;
    plot(t, x_log, 'b-', 'LineWidth', 1.5);
    plot(t, x_hat, 'g:', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$\hat{x}[k]$, $x[k]$', 'Interpreter', 'latex');
    title('$\hat{x}[k]$ vs $x[k]$', 'Interpreter', 'latex');
    legend({'$x[k]$', '$\hat{x}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 4: Erro de estimativa
    subplot(2,3,5);
    hold on;
    plot(t, e_hat, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$\hat{e}[k]$', 'Interpreter', 'latex');
    title('Erro de estimativa: $\hat{e}[k]$', 'Interpreter', 'latex');
    legend({'$\hat{e}[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;
    
    % --- Subplot 5: Erro real
    subplot(2,3,6);
    hold on;
    plot(t, e, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('$e[k]$', 'Interpreter', 'latex');
    title('Erro $e[k]$', 'Interpreter', 'latex');
    legend({'$e[k]$'}, 'Interpreter', 'latex', 'Location', 'best');
    grid on;

sgtitle(sprintf('Analise do Observador (Kalman): ($L_k = %g$, $Q_k = %g$, $R_k = %g$)', round(L_k, 3), Q_k, R_k), 'Interpreter', 'latex');

% Exporta tudo em um único PDF
exportgraphics(f, './Resultados/ObservadorKalman.pdf', 'ContentType', 'vector');