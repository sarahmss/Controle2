% Lê todos os arquivos que seguem o padrão de nome
arquivos = dir('./Saida/saidas-limite-inf*.csv');

% Extrai os valores de 'lim' dos nomes dos arquivos
lim = zeros(1, length(arquivos));
for i = 1:length(arquivos)
    lim(i) = sscanf(arquivos(i).name, 'saidas-limite-inf%d.csv');
end

% Ordena os arquivos com base nos valores extraídos
[~, idx_ordenado] = sort(lim);
arquivos_ordenados = arquivos(idx_ordenado);

% Referências para linhas horizontais
ref1 = 620;
ref2 = 670;
ref3 = 570;

% Figura principal
f = figure('Name', 'Resposta do Sistema com Controle', 'NumberTitle', 'off');
hold on;

% Plota todas as saídas dos arquivos CSV
cores = turbo(length(arquivos));  % paleta de cores automática
for i = 1:length(arquivos_ordenados)
    caminho = fullfile(arquivos_ordenados(i).folder, arquivos_ordenados(i).name);
    dados = readtable(caminho);
    
    % Garante que a saída tenha mesmo tamanho do vetor tempo
    saida = dados.Saida;
    t = (1:length(saida)) * 8e-3;

    % Nome para legenda (ex: 'lim = 50')
    legenda = sprintf('R_c = %d', lim(idx_ordenado(i)));
    plot(t, saida, 'Color', cores(i,:), 'LineWidth', 1.2, 'DisplayName', legenda);
end

% Linhas de referência
yline(ref1, '--', 'Color', '#F92412', 'LineWidth', 1.2, 'DisplayName', sprintf('ref = %d', ref1));
yline(ref2, '--', 'Color', '#FA6800', 'LineWidth', 1.2, 'DisplayName', sprintf('ref = %d', ref2));
yline(ref3, '--', 'Color', '#E4FA00', 'LineWidth', 1.2, 'DisplayName', sprintf('ref = %d', ref3));

% Ajustes finais do gráfico
xlabel('$Tempo\ [s]$', 'Interpreter', 'latex');
ylabel('$y(t)$', 'Interpreter', 'latex');
title('Testando limite inferior de sintonia de $R_c$', 'Interpreter', 'latex');
legend('show', 'Location', 'best');
grid on;
ylim([400 800]);

% Exporta como PDF
exportgraphics(f, './Resultados/Rmaior/Limites.pdf', 'ContentType', 'vector');
