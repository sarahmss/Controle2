% Lê o arquivo CSV
dados = readtable('./Saida/saidas-R=600.csv')
% dados = readtable('./Saida/saidas-R=156d.csv')
% dados = readtable('./Saida/saidas.csv');

% Extrai os vetores das colunas
tempo   = dados.Tempo * 0.008;
entrada = dados.Entrada;
erro    = dados.Erro;
saida   = dados.Saida;

% Cria a figura com 3 subplots
figure('Name', 'Resposta do Sistema com Controle', 'NumberTitle', 'off');

% Subplot 1 - Entrada
subplot(3,1,1);
plot(tempo, entrada, 'b', 'LineWidth', 1.5);
ylabel('Entrada');
title('Entrada vs Tempo');
grid on;

% Subplot 2 - Erro
subplot(3,1,2);
plot(tempo, erro, 'k', 'LineWidth', 1.5);
ylabel('Erro');
title('Erro vs Tempo');
grid on;

% Subplot 3 - Saída
subplot(3,1,3);
plot(tempo, saida, 'r', 'LineWidth', 1.5);
xlabel('Tempo (s)');
ylabel('Saída');
title('Saída vs Tempo');
grid on;
