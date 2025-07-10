% Lê o arquivo CSV
dados = readtable('./Saida/saidas-R=600d.csv');

t8ms = 1:length(dados.Tempo);
t8ms = t8ms * 8e-3;
% Extrai os vetores das colunas
tempo   = t8ms; % Conversão se Tempo estiver em índices
entrada = dados.Entrada;
erro    = dados.Erro;
saida   = dados.Saida;

% Cria a figura com 3 subplots verticais
figure('Name', 'Resposta do Sistema com Controle', 'NumberTitle', 'off');

% Subplot 1 - Entrada de Controle (Uk)
subplot(3,1,1);
plot(tempo, entrada, 'b', 'LineWidth', 1.5);
ylabel('Uk');
title('Sinal de Controle vs Tempo');
grid on;

% Subplot 3 - Erro
subplot(3,1,2);
plot(tempo, erro, 'k', 'LineWidth', 1.5);
ylabel('Erro');
title('Erro vs Tempo');
grid on;

% Subplot 4 - Saída
subplot(3,1,3);
plot(tempo, saida, 'r', 'LineWidth', 1.5);
xlabel('Tempo (s)');
ylabel('Saída');
title('Saída vs Tempo');
grid on;

