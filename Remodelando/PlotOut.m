% Lê o arquivo CSV
dados = readtable('saida-156.csv');

% Extrai os vetores das colunas
tempo   = dados.Tempo;
saida   = dados.Saida;

figure('Name', 'Resposta do sistema em malha aberta', 'NumberTitle', 'off');

plot(tempo, saida, 'r', 'LineWidth', 1.5);
xlabel('Tempo (s)');
ylabel('Saída');
title('Saída vs Tempo');
grid on;
