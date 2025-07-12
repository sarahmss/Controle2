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

t8ms = 1:(length(dados.Tempo)/2.5);
t8ms = t8ms * 8e-3;

%% LQI

K_q_values = [0.1, 1, 0.75, 1.2];  % Ex: menor -> mais devagar; maior -> mais agressivo
K_c_values = [0.5, 1, 0.5, 2];  % Ex: menor -> menos penalização do controle; maior -> mais economia no esforço de controle

for i = 1:length(K_q_values)
    K_q = K_q_values(i);
    K_c = K_c_values(i);

    Q_c = K_q * eye(1); % Aumentar Q em relação a R: x(t)->0 mais rapidamente esforço de controle u(t) maior
    R_c = K_c * eye(1); % Aumentar R em relação a Q: u(t) é menor e x(t) tende a uma resposta superamortecida 
    
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
    n = size(Ac);
    N = length(t8ms);
    R = 595;
    
    Aeuler =  eye(n) + Ts * sys.A; 
    Beuler =  Ts * sys.B;
    Ceuler = sys.C;
    Deuler = sys.D;
    sys_euler = ss(Aeuler, Beuler, Ceuler, Deuler, Ts);
    
    t = t8ms;
    u = ones(size(t)); % Degrau unitário
    
    % Respostas em malha fechada dos sistemas
    [y_cl, time_cl, x_cl] = lsim(sys_cl, u, t);       
    [y_euler, u_euler, x_euler, e_euler, xn_euler] = ApplyController(sys_euler, K, Ki, N, Ts, R);
    % Resultados
    
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