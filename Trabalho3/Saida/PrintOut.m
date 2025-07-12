% Lê o arquivo CSV
dadosEuler = readtable('./Saida/saidas-limite-inf10.csv');

c = 1;

if c==1
    ref2 = 670;
    ref3 = 570;
elseif c==2
    ref2 = 650;
    ref3 = 550;
elseif c==3
    ref2 = 671;
    ref3 = 500;
end

ref1 = 620;

t8ms = 1:length(dadosEuler.Tempo);
t8ms = t8ms * 8e-3;
% Extrai os vetores das colunas
tempo   = t8ms; % Conversão se Tempo estiver em índices
% entrada = dados.Uk;
% xhat    = dados.xhat;           % Caso exista essa coluna
% erro    = dados.Erro;
saidaEuler   = dadosEuler.Saida;

% Cria a figura com 4 subplots verticais
f = figure('Name', 'Resposta do Sistema com Controle', 'NumberTitle', 'off');

% % Subplot 1 - Entrada de Controle (Uk)
% subplot(4,1,1);
% plot(tempo, entrada, 'b', 'LineWidth', 1.5);
% ylabel('Uk');
% title('Sinal de Controle vs Tempo');
% grid on;
% 
% % Subplot 2 - Estado observado
% subplot(4,1,2);
% plot(tempo, xhat, 'm', 'LineWidth', 1.5);
% ylabel('x_{obs}');
% title('Estado observado vs Tempo');
% grid on;
% 
% % Subplot 3 - Erro
% subplot(4,1,3);
% plot(tempo, erro, 'k', 'LineWidth', 1.5);
% ylabel('Erro');
% title('Erro vs Tempo');
% grid on;

% Subplot 4 - Saída
%subplot(4,1,4);
hold on;
plot(tempo, saidaEuler, 'r', 'LineWidth', 1,'DisplayName','Euler');
legend off;
ylim([400 800]);
xlabel('$Tempo [s]$', 'Interpreter', 'latex');
ylabel('$y(t)$', 'Interpreter', 'latex');
title('Saida $y(t)$, $R_c=6$; $Q_c=0.1$; $L_k=0.039$', 'Interpreter', 'latex');
yline(ref1, '--','Color','#F92412', 'LineWidth', 1, 'DisplayName',num2str(ref1));
yline(ref2, '--', 'Color', '#FA6800' ,'LineWidth', 1, 'DisplayName',num2str(ref2));
yline(ref3, '--', 'Color', '#E4FA00','LineWidth', 1, 'DisplayName',num2str(ref3));
legend;
grid on;

exportgraphics(f, './Resultados/Rmaior/saida_limite-inf-10.pdf', 'ContentType', 'vector');