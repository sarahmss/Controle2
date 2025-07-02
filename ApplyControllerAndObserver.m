function [y_log, y_hat_log, u_log, x_log, x_hat_log] = ApplyControllerAndObserver(sys, K, Ki, L, N, R, Ts, metodo)
% Aplica simultaneamente o controlador com ação integral e o observador
% sys       : sistema em espaço de estados (discretizado)
% K         : ganho da realimentação de estados
% Ki        : ganho integrativo
% L         : ganhos do observador
% N         : número de passos de simulação
% R         : referência (escalar)
% Ts        : período de amostragem

    % Inicializações
    nx = size(sys.A, 1);      % número de estados

    % Logs
    x_log      = zeros(N, nx);
    x_hat_log  = zeros(N, nx);
    y_log      = zeros(N, 1);
    y_hat_log  = zeros(N, 1);
    u_log      = zeros(N, 1);
    e_log     = zeros(N, 1);
    e_hat_log = zeros(N, 1);

    ek        = R - 0;
    e_hat_k   = 0;
    x_k       = 0;  % estado real
    x_hat_k   = 0;  % estado estimado
    xn_k      = 0;
    y_k       = 0;
    u_k       = 0;
    for k = 1:N
        % Atualiza integrador
        xn_k = xn_k + Ts * ek;

        % Estimação da saída
        y_hat_k = sys.C * x_hat_k + sys.D * u_k;
        
        % Atualiza o estado estimado pelo observador
        % x_hat_k = sys.A * x_hat_k + sys.B * u_k + L * (y_k - y_hat_k);
        x_hat_k = ((sys.A - L * sys.C) * x_hat_k) + (sys.B * u_k) + (L * y_k);

        % Lei de controle com estado estimado
        u_k = -K * x_hat_k + Ki * xn_k; 

        % Armazena
        x_log(k, :)     = x_k';
        x_hat_log(k, :) = x_hat_k';
        y_log(k)        = y_k;
        y_hat_log(k)    = y_hat_k;
        u_log(k)        = u_k; 
        e_log(k)        = ek; 
        e_hat_log(k)    = e_hat_k; 

        % Evolução do sistema
        x_k = sys.A * x_k + sys.B * u_k;
        y_k = sys.C * x_k + sys.D * u_k;


        % Atualiza o erro 
        ek = R - y_k;
        e_hat_k = x_k - x_hat_k;
    end

    % Vetor de tempo
    t = (0:N-1) * Ts;

    % Figura com 4 subplots
    f = figure('Name', sprintf('Comparação entre sistema e observador (%s)', metodo), 'NumberTitle','off');

    % 1. Saída y vs y_hat
    subplot(2,2,1);
    plot(t, y_log, 'b', 'LineWidth', 1.5); hold on;
    plot(t, y_hat_log, 'r--', 'LineWidth', 1.5);
    title('Saída: y vs ŷ');
    xlabel('Tempo (s)'); ylabel('Saída');
    legend('y real', 'ŷ estimado');
    grid on;

    % 2. Estado x vs x_hat (1ª componente)
    subplot(2,2,2);
    plot(t, x_log(:,1), 'b', 'LineWidth', 1.5); hold on;
    plot(t, x_hat_log(:,1), 'r--', 'LineWidth', 1.5);
    title('Estado: x₁ vs x̂₁');
    xlabel('Tempo (s)'); ylabel('Estado');
    legend('x₁ real', 'x̂₁ estimado');
    grid on;

    % 3. Erro de rastreamento e = r - y
    subplot(2,2,3);
    plot(t, e_log, 'k', 'LineWidth', 1.5);
    title('Erro de rastreamento: e = r - y');
    xlabel('Tempo (s)'); ylabel('Erro');
    grid on;

    % 4. Erro de estimação ê = x - x̂ (1ª componente)
    subplot(2,2,4);
    plot(t, e_hat_log(:,1), 'm', 'LineWidth', 1.5);
    title('Erro de estimação: ê₁ = x₁ - x̂₁');
    xlabel('Tempo (s)'); ylabel('Erro de estimação');
    grid on;

    sgtitle(sprintf('Comparação entre sistema e observador (%s)', metodo), 'Interpreter', 'latex');
    exportgraphics(f, sprintf('./Resultados/ControllerAndObserver{%s}.pdf', metodo), 'ContentType', 'vector');
end