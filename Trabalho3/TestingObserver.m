%% Definição do sistema
a = 10.4167;
s = tf('s');
Kp = 595;
Ts = 0.008; % Período de amostragem (Ts = 8ms)
Gp = a * Kp /(s+a);
Gp_zpk = zpk(Gp);
[num, den] = tfdata(Gp, 'v'); 
[Ac, Bc, Cc, Dc] = tf2ss(num, den);
sys = ss(Ac, Bc, Cc, Dc); % Sistema tempo contínuo
dados = readtable('./Remodelando/saida-156.csv');

t8ms = 1:(length(dados.Tempo));
t8ms = t8ms * 8e-3;

%% 
Q_c = 1.2 * eye(1); % Aumentar Q em relação a R: x(t)->0 mais rapidamente esforço de controle u(t) maior
R_c = 2.0 * eye(1); % Aumentar R em relação a Q: u(t) é menor e x(t) tende a uma resposta superamortecida 

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
    sys_euler = ss(Aeuler, Beuler, Ceuler, Deuler, Ts);
    

%%  Projeto do Observador

info = stepinfo(y_euler, t);
ts = info.SettlingTime;
up = info.Overshoot;

qsi = (-log(up/100))/(sqrt(pi^2+log(up/100)^2));
Ts_obs = (ts / 10);
wn_obs = 4/(qsi*Ts_obs); % Calcula a frequência natural
polo_o = qsi*wn_obs
L = -place(Ac', Cc', polo_o)'

[y_euler_cl, e_log_euler, e_hat_euler, u_euler, y_hat_euler, x_hat_euler, x_log] = ApplyControllerAndObserver(sys_euler, K, Ki, L*Ts, N, Ts, R);


 f = figure;
    % --- Subplot 1: Sinal de Controle u[k]
    subplot(2,2,1);
    hold on;
    plot(t, u_euler, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('u[k]');
    title('Sinal de Controle $u[k]$', 'Interpreter', 'latex');
    grid on;
    
    % --- Subplot 1: Estado observado xk
    subplot(2,3,4);
    hold on;
    plot(t, x_cl * R, 'k-', 'LineWidth', 1.5);
    plot(t, x_log, 'y:', 'LineWidth', 1.5);
    plot(t, x_hat_euler, 'b:', 'LineWidth', 1.5);

    hold off;
    title('Estado estimado: $\hat{x}[k]$', 'Interpreter', 'latex');
    xlabel('Iteração [k]');
    ylabel('$\hat{x}[k]$', 'Interpreter', 'latex');
    grid on;
    
    % --- Subplot 2: Estado xn
    subplot(2,3,5);
    hold on;
    plot(t, e_hat_euler, 'b-', 'LineWidth', 1.5);
    hold off;
    title('Erro de estimativa: $\hat{e}[k]$', 'Interpreter', 'latex');
    xlabel('Iteração [k]');
    ylabel('$\hat{e}[k]$', 'Interpreter', 'latex');
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
    plot(t, y_euler_cl, 'y:', 'LineWidth', 1.5);
    plot(t, y_hat_euler, 'b-', 'LineWidth', 1.5);
    xlabel('Iteração [k]');
    ylabel('y[k]');
    title('Saida $y[k]$', 'Interpreter', 'latex');
    grid on;

% Legenda global abaixo da figura
legend({'Continuo', 'Euler'}, ...
    'Orientation', 'horizontal', ...
    'Location', 'best', ...
    'Interpreter', 'latex');

sgtitle('Analise do Observador', 'Interpreter', 'latex');

% Exporta tudo em um único PDF
exportgraphics(f, './Resultados/Observador.pdf', 'ContentType', 'vector');