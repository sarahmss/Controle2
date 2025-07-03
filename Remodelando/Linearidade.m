% Lista de arquivos
arquivos = dir('saida-*.csv');

% Cria nova figura
f = figure('Name', 'Resposta ao Degrau - Teste de Linearidade', 'NumberTitle', 'off');

% Subplot 1 - Resposta ao Degrau
subplot(2, 1, 1);
hold on; grid on;
title('Resposta ao Degrau - Teste de Linearidade');
xlabel('Tempo (s)');
ylabel('Resposta');

% Inicializa vetores para segundo gráfico
valores_R = [];
respostas_finais = [];

% Loop pelos arquivos
for i = 1:length(arquivos)
    nome_arquivo = arquivos(i).name;
    dados = readtable(nome_arquivo);

    tempo = dados.Tempo;
    saida = dados.Saida;

    % Extrai valor de R do nome do arquivo (ex: saida-125.csv → R = 125)
    R = sscanf(nome_arquivo, 'saida-%d.csv');

    % Plota no primeiro subplot
    plot(tempo, saida, 'DisplayName', sprintf('R = %d', R));

    % Armazena valor de R e saída final (último ponto)
    valores_R(end+1) = R;
    respostas_finais(end+1) = saida(end);
end
[valores_R, idx] = sort(valores_R);
respostas_finais = respostas_finais(idx);

legend('show');

% Subplot 2 - Resposta Final vs Entrada
subplot(2, 1, 2);
plot(valores_R, respostas_finais, '*-', 'LineWidth', 2, 'MarkerFaceColor', 'cyan');
grid on;
xlabel('R Aplicado (0-255)');
ylabel('Resposta Final');
title('Resposta Final vs Entrada');
exportgraphics(f, '../Resultados/Lineariedade.pdf', 'ContentType', 'vector');

% figure;
% R_interp = linspace(min(valores_R), max(valores_R), 500);
% resposta_interp = interp1(valores_R, respostas_finais, R_interp, 'spline');
% plot(R_interp, resposta_interp, 'b-', 'LineWidth', 2, 'DisplayName', 'Interpolação');
% xlabel('R Aplicado (0-255)');
% ylabel('Resposta Final');
% title('Resposta Final vs Entrada');
% legend('show');
