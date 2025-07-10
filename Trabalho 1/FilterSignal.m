function [SinalFiltrado, num, den]  = FilterSignal(n, fc, Resp, Fs, temp, T)
    Wn = fc/(Fs/2);
    [num, den] = butter(n, Wn, 'low');

    SinalFiltrado = filter(num, den, Resp);

    figure;
    hold on;
    plot(temp, SinalFiltrado, 'color', 'r', 'DisplayName', 'Sinal Filtrada');
    plot(temp, Resp, 'color', 'b', 'DisplayName', 'Sinal Original');
    legend('show');
    grid on;
    title(['Resposta ao Degrau - Malha Aberta Sinal Filtrado - ', num2str(T), ' (s)']);
    xlabel('Tempo (s)');
    ylabel('Resposta');
    hold off;
end