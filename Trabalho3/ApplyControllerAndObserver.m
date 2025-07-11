function [y_log, e_log, e_hat_log, u_log, y_hat_log, x_hat_log] = ApplyControllerAndObserver(sys, K, Ki, L, N,  Ts, R)
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

end