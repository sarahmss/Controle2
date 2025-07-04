% Lista de arquivos
arquivos = dir('./Remodelando/saida-*.csv');

% Extrai os valores de R dos nomes dos arquivos para ordenação
valores_R_ordenacao = zeros(1, length(arquivos));
for i = 1:length(arquivos)
    valores_R_ordenacao(i) = sscanf(arquivos(i).name, 'saida-%d.csv');
end

% Ordena os arquivos com base nos valores de R extraídos
[~, idx_ordenado] = sort(valores_R_ordenacao);
arquivos = arquivos(idx_ordenado);

% Cria nova figura
f = figure('Name', 'Resposta ao Degrau - Teste de Linearidade', 'NumberTitle', 'off');

% Subplot 1 - Resposta ao Degrau
subplot(2, 1, 1);
hold on; grid on;
title('Resposta ao Degrau - Teste de Linearidade', 'Interpreter', 'latex');
xlabel('Tempo (s)', 'Interpreter', 'latex');
ylabel('Resposta', 'Interpreter', 'latex');

% Inicializa vetores para segundo gráfico
valores_R = [];
respostas_finais = [];

% Loop pelos arquivos já ordenados
for i = 1:length(arquivos)
    nome_arquivo = arquivos(i).name;
    dados = readtable(fullfile(arquivos(i).folder, nome_arquivo));

    t8ms = 1:length(dados.Tempo);
    t8ms = t8ms * 8e-3;
    saida = dados.Saida;

    % Extrai valor de R
    R = sscanf(nome_arquivo, 'saida-%d.csv');

    % Plota no primeiro subplot
    plot(t8ms, saida, 'DisplayName', sprintf('R = %d', R));

    % Armazena para segundo subplot
    valores_R(end+1) = R;
    respostas_finais(end+1) = saida(end);
end

legend('show');
axis tight; % Ajuste automático dos eixos

% Subplot 2 - Resposta Final vs Entrada
subplot(2, 1, 2);
plot(valores_R, respostas_finais, '*-', 'LineWidth', 2, 'MarkerFaceColor', 'cyan');
grid on;
xlabel('R Aplicado (0-255)', 'Interpreter', 'latex');
ylabel('Resposta Final', 'Interpreter', 'latex');
title('Resposta Final vs Entrada', 'Interpreter', 'latex');

% Exporta gráfico
exportgraphics(f, './Resultados/Lineariedade.pdf', 'ContentType', 'vector');
