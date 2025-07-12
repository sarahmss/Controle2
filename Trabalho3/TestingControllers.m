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

%% LQI

K_q_values = [0.1, 0.1, 2, 0.825]; 
K_r_values = [20, 0.1, 0.1, 38];  

T_total = table();

for i = 1:length(K_q_values)
    K_q = K_q_values(i);
    K_r = K_r_values(i);

    Q_c = K_q * eye(1); % Aumentar Q em relação a R: x(t)->0 mais rapidamente esforço de controle u(t) maior
    R_c = K_r * eye(1); % Aumentar R em relação a Q: u(t) é menor e x(t) tende a uma resposta superamortecida 
    
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
    % Resultados
    
    % === Cálculo das especificações de desempenho ===
    info_euler  = stepinfo(y_euler, t);
    
    overshoot = info_euler.Overshoot;
    settlingTime = info_euler.SettlingTime;
    
    % String para exibir Q e R
    QR_label = sprintf('Q=%.2f; R=%.2f', Q_c, R_c);
    
    % Criação da Tabela
    T = table({QR_label}, K, Ki,overshoot, settlingTime, ...
        'VariableNames', {'Q_R', 'K', 'Ki', 'Ultrapassagem(%)', 'TempoAcomodacao(s)'});
    T_total = [T_total; T];  % Concatenar na vertical

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
    
    
    sgtitle(sprintf('Analise do controlador ($Q = %g$, $R = %g$)', Q_c, R_c), 'Interpreter', 'latex');
    
    % Legenda global abaixo da figura
    legend({'Continuo', 'Euler'}, ...
        'Orientation', 'vertical', ...
        'Location', 'best', ...
        'Interpreter', 'latex'); 
    
    
    % Exporta tudo em um único PDF
    exportgraphics(f, sprintf('./Resultados/AnaliseDoControlador_Q%g_R%g.pdf', Q_c, R_c), 'ContentType', 'vector');
end



% Exibição no console
disp('== Comparação de Desempenho ==');
disp(T_total);