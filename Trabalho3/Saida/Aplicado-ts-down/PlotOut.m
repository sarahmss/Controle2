% Caminho dos arquivos
arquivos = dir('./Saida/Aplicado-ts-down/saidas-*.csv');

% Mapeamento de estilo para cada método (agora como strings)
estilos = struct( ...
    'zoh',    'r--', ...
    'tustin', 'b-.', ...
    'euler',  'g:' ...
);

% Cria a figura com 4 subplots em 2 linhas x 2 colunas
f = figure('Name', 'Comparação entre Métodos de Discretização (stairs)', 'NumberTitle', 'off');

% Inicializa as legendas
legendas = strings(1, length(arquivos));

fprintf('Métricas da Resposta ao Degrau (Ts Up):\n');
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
    subplot(2,2,1); hold on; grid on;
    stairs(tempo, entrada, estilo, 'LineWidth', 1.5);

    % Subplot 2 - xhat
    subplot(2,2,2); hold on; grid on;
    stairs(tempo, xhat, estilo, 'LineWidth', 1.5);

    % Subplot 3 - erro
    subplot(2,2,3); hold on; grid on;
    stairs(tempo, erro, estilo, 'LineWidth', 1.5);

    % Subplot 4 - saída
    subplot(2,2,4); hold on; grid on;
    stairs(tempo, saida, estilo, 'LineWidth', 1.5);

    % Calcula métricas da resposta usando stepinfo
    info = stepinfo(saida, tempo);
    fprintf('%-10s\t%.4f\t\t%.4f\t\t\t%.2f\n', upper(metodo), info.RiseTime, info.SettlingTime, info.Overshoot);
end

% Títulos e eixos
subplot(2,2,1);
xlabel('Tempo [s]');
ylabel('u[k]');
title('Sinal de Controle $u[k]$', 'Interpreter', 'latex');

subplot(2,2,2);
xlabel('Tempo [s]');
ylabel('$\hat{x}[k]$', 'Interpreter', 'latex');
title('Estado observado $\hat{x}[k]$', 'Interpreter', 'latex');

subplot(2,2,3);
xlabel('Tempo [s]');
ylabel('$e[k]$', 'Interpreter', 'latex');
title('Erro de rastreamento $e[k]$', 'Interpreter', 'latex');

subplot(2,2,4);
xlabel('Tempo [s]');
ylabel('$y[k]$', 'Interpreter', 'latex');
title('Saida y[k]', 'Interpreter', 'latex');

% Sincroniza eixos
linkaxes(findall(gcf, 'Type', 'axes'), 'x');

% Legenda global
h = legend(legendas, ...
    'Orientation', 'horizontal', ...
    'Interpreter', 'latex', ...
    'Location', 'best');

% Exporta para PDF
exportgraphics(f, './Resultados/AplicandoTsDown.pdf', 'ContentType', 'vector');
