% Caminho dos arquivos
arquivos = dir('./Saida/Aplicado-ts-down/saidas-*.csv');

% Mapeamento de estilo para cada método (agora como strings)
estilos = struct( ...
    'zoh',    'r--', ...
    'tustin', 'b-.', ...
    'euler',  'g:' ...
);

% Cria a figura com 4 subplots
f = figure('Name', 'Comparação entre Métodos de Discretização (stairs)', 'NumberTitle', 'off');

% Inicializa as legendas
legendas = strings(1, length(arquivos));


fprintf('Métricas da Resposta ao Degrau (StepInfo):\n');
fprintf('Método\t\tRiseTime (s)\tSettlingTime (s)\tOvershoot (%%)\n');

for i = 1:length(arquivos)
    nome_arquivo = arquivos(i).name;
    metodo = erase(erase(nome_arquivo, 'saidas-'), '.csv'); % ex: 'zoh'
    estilo = estilos.(metodo);  % cor + linha como string
    legendas(i) = upper(metodo);

    % Lê o arquivo
    dados = readtable(fullfile(arquivos(i).folder, nome_arquivo));
    
    % Eixo de tempo (assumindo índice com 8 ms por passo)
    tempo = (1:height(dados)) * 8e-3;
    
    % Extrai variáveis
    entrada = dados.Uk;
    xhat    = dados.xhat;
    erro    = dados.Erro;
    saida   = dados.Saida;

    % Subplot 1 - Uk
    subplot(4,1,1); hold on; grid on;
    stairs(tempo, entrada, estilo, 'LineWidth', 1.5);

    % Subplot 2 - xhat
    subplot(4,1,2); hold on; grid on;
    stairs(tempo, xhat, estilo, 'LineWidth', 1.5);

    % Subplot 3 - erro
    subplot(4,1,3); hold on; grid on;
    stairs(tempo, erro, estilo, 'LineWidth', 1.5);

    % Subplot 4 - saída
    subplot(4,1,4); hold on; grid on;
    stairs(tempo, saida, estilo, 'LineWidth', 1.5);
end

% Títulos e legendas
subplot(4,1,1);
ylabel('Uk');
title('Sinal de Controle vs Tempo');
legend(legendas, 'Location', 'best');

subplot(4,1,2);
ylabel('x_{obs}');
title('Estado Observado vs Tempo');
legend(legendas, 'Location', 'best');

subplot(4,1,3);
ylabel('Erro');
title('Erro vs Tempo');
legend(legendas, 'Location', 'best');

subplot(4,1,4);
xlabel('Tempo (s)');
ylabel('Saída');
title('Saída vs Tempo');
legend(legendas, 'Location', 'best');

% Sincroniza zoom horizontal
linkaxes(findall(gcf, 'Type', 'axes'), 'x');

% Exporta para PDF
exportgraphics(f, '../Resultados/AplicandoTsDown.pdf', 'ContentType', 'vector');
