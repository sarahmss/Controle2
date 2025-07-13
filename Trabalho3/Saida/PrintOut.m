% Lê o arquivo CSV
data = readtable('./Saida/saidas-limite-inf6.csv');
% data2 = readtable('./Saida/saidas-Rmaior_Lk.csv');

ref2 = 670;
ref3 = 570;

ref1 = 620;

t8ms = 1:length(data.Tempo);
t8ms = t8ms * 8e-3;
% Extrai os vetores das colunas
t   = t8ms; % Conversão se Tempo estiver em índices

%% 
% Figura com 4 subplots
f = figure;

subplot(2,2,1);
hold on; 
plot(t, data.Uk, 'b-', 'LineWidth', 1.5);
% plot(t, data2.Uk, 'r:', 'LineWidth', 1.5);
hold off;
title('Saida estimada: $u[k]$', 'Interpreter', 'latex');
xlabel('Iteração [k]');
ylabel('$u[k]$', 'Interpreter', 'latex');
grid on;

% 2. Estado x vs x_hat (1ª componente)
subplot(2,2,2);
hold on;
plot(t, data.xhat, 'b-', 'LineWidth', 1.5);
% plot(t, data2.xhat, 'r:', 'LineWidth', 1.5);hold off;
title('Estado estimado: $\hat{x}[k]$', 'Interpreter', 'latex');
xlabel('Iteração [k]');
ylabel('$\hat{x}[k]$', 'Interpreter', 'latex');
grid on;

% 3. Erro de rastreamento e = r - y
subplot(2,2,3);
hold on;
plot(t, data.Erro, 'b-', 'LineWidth', 1.5);
% plot(t, data2.Erro, 'r:', 'LineWidth', 1.5);
hold off;
title('Erro de rastreamento: $e[k] = r[k] - y[k]$', 'Interpreter', 'latex');
xlabel('Iteração [k]');
ylabel('$e[k]$', 'Interpreter', 'latex');
grid on;

% 4. Erro de estimação ê = x - x̂ (1ª componente)
subplot(2,2,4);
hold on;
plot(t, data.Saida, 'b-', 'LineWidth', 1.5);
% plot(t, data2.Saida, 'r:', 'LineWidth', 1.5);
yline(ref1, '--','Color','#F92412', 'LineWidth', 1, 'DisplayName',num2str(ref1));
yline(ref2, '--', 'Color', '#FA6800' ,'LineWidth', 1, 'DisplayName',num2str(ref2));
yline(ref3, '--', 'Color', '#E4FA00','LineWidth', 1, 'DisplayName',num2str(ref3));
hold off;
title('Saida: $y[k]$', 'Interpreter', 'latex');
xlabel('Iteração [k]');
ylabel('$y[k]$', 'Interpreter', 'latex');
grid on;

% % Legenda global abaixo da figura
% lgd = legend({'$L_o = 0.028$; $L_k = 0.021$'}, ...
%     'Orientation', 'horizontal', ...
%     'Location', 'best', ...
%     'Interpreter', 'latex');

% Título geral
sgtitle('Analise do sistema ($Q_c=0.1$, $R_c=6$)', 'Interpreter', 'latex');

% Exporta para PDF vetorial
exportgraphics(f, './Resultados/Rmaior/AnaliseOK6.pdf', 'ContentType', 'vector');



%% 
% Cria a figura com 4 subplots verticais
f = figure('Name', 'Resposta do Sistema com Controle', 'NumberTitle', 'off');


% Subplot 4 - Saída
%subplot(4,1,4);
hold on;
plot(t, data.Saida, 'b-', 'LineWidth', 1.5, 'DisplayName', 'L_k = 0.039');
% plot(t, data2.Saida, 'r-', 'LineWidth', 1.5, 'DisplayName', 'L_k = 0.021');
legend off;
ylim([400 800]);
xlabel('$Tempo [s]$', 'Interpreter', 'latex');
ylabel('$y(t)$', 'Interpreter', 'latex');
title('Saida $y(t)$, $R_c=20$; $Q_c=0.1$; $L_k=0.039$', 'Interpreter', 'latex');
yline(ref1, '--','Color','#F92412', 'LineWidth', 1, 'DisplayName',num2str(ref1));
yline(ref2, '--', 'Color', '#FA6800' ,'LineWidth', 1, 'DisplayName',num2str(ref2));
yline(ref3, '--', 'Color', '#E4FA00','LineWidth', 1, 'DisplayName',num2str(ref3));
legend;
grid on;


exportgraphics(f, './Resultados/Rmaior/SaidaOK6.pdf', 'ContentType', 'vector');