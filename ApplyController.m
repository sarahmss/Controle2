function [y_log, u_log, x_log] = ApplyController(sys, K, Ki, N, R, Ts)
% Aplica o controlador por realimentação de estados discretizado
% sys    : sistema em espaço de estados discretizado (ss)
% K_hat  : vetor linha de ganhos (pode ser [K  -Ki] se for sistema aumentado)
% N      : número de passos de simulação

    % Inicializações
    y_log = zeros(N, 1);
    u_log = zeros(N, 1);
    x_log = zeros(N, 1);

    y_k = 0;
    x_k = 0;
    xn_1 = 0;
    ek_1 = R - y_k;
    for k = 1:N
        xn = xn_1 + Ts * ek_1;

        u_k = -K * x_k + Ki * xn;  % Lei de controle
        y_k = sys.C * x_k + sys.D * u_k;

        % Armazenamento
        x_log(k,:) = x_k';
        y_log(k) = y_k;
        u_log(k) = u_k;

        % Evolução do sistema
        x_k = sys.A * x_k + sys.B * u_k;
        ek_1 = R - y_k;
        xn_1 = xn;
    end
end