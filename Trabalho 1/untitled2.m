T = 8e-3; % 8 ms
% Leitura da tabela
OutTab = readtable("Saidas.csv")

% Vetor de tempo
tout = 1:length(OutTab.Tempo);
tout = tout * T;

% Criação da figura com subplots
figure;

% Subplot 1 - Entrada
subplot(3,1,1);
plot(tout, OutTab.Entrada, 'b');
title('Entrada');
xlabel('Tempo (s)');
ylabel('Amplitude');

% Subplot 2 - Erro
subplot(3,1,2);
plot(tout, OutTab.Erro, 'r');
title('Erro');
xlabel('Tempo (s)');
ylabel('Erro');

% Subplot 3 - Saída
subplot(3,1,3);
plot(tout, OutTab.Saida, 'g');
title('Saída - Resposta ao Degrau (Malha Fechada, T = 8ms)');
xlabel('Tempo (s)');
ylabel('Resposta');
title('Saída - Resposta ao Degrau  (Malha Fechada, T = 8ms Sinal filtrado)');
xlabel('Tempo (s)');
ylabel('Resposta');

% Ajusta o layout
sgtitle('Resultados da aplicaçao do controlador');
hold off;
info = stepinfo(OutTab.Saida, tout);

% Tempo de acomodação a 2%
Ts = info.SettlingTime
Tr = info.RiseTime
Tp= info.PeakTime
UP= info.Overshoot
