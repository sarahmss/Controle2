function [y_log, u_log, x_log] = ApplyController(sys, K, Ki, N, a, Ts)
% Aplica o controlador por realimentação de estados discretizado
% sys    : sistema em espaço de estados discretizado (ss)
% K_hat  : vetor linha de ganhos (pode ser [K  -Ki] se for sistema aumentado)
% N      : número de passos de simulação

    % Inicializações
    y_log = zeros(N, 1);
    u_log = zeros(N, 1);
    x_log = zeros(N, 1);

    R = 600; 
    deg = 156;

    y_k = 0;
    x_k = 0;
    ek = R - y_k;
    xn = 0;
    for k = 1:N
        xn = xn + Ts * ek;

        u_k = -K * x_k + Ki * xn;  % Lei de controle
        y_k = sys.C * x_k + sys.D * u_k;

        % Armazenamento
        x_log(k,:) = x_k';
        y_log(k) = y_k;
        u_log(k) = u_k;

        % Evolução do sistema
        x_k = sys.A * x_k + sys.B * u_k;
        ek = R - y_k;
    end
end