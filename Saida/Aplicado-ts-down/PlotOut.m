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


fprintf('Métricas da Resposta ao Degrau (Ts Up):\n');
fprintf('Método\t (s)\tSettlingTime (s)\tOvershoot (%%)\n');

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

     % Calcula métricas da resposta usando stepinfo
    info = stepinfo(saida, tempo);
    fprintf('%-10s\t%.4f\t\t%.4f\t\t\t%.2f\n', upper(metodo), info.RiseTime, info.SettlingTime, info.Overshoot);
end

% Títulos e legendas
subplot(4,1,1);
xlabel('Iteração [k]');
ylabel('u[k]');
title('Sinal de Controle u[k]');
legend(legendas, 'Location', 'best');

subplot(4,1,2);
xlabel('Iteração [k]');
ylabel('$\hat{x}[k]$', 'Interpreter', 'latex');
title('Estado observado');
legend(legendas, 'Location', 'best');

subplot(4,1,3);
xlabel('Iteração [k]');
ylabel('e[k]', 'Interpreter', 'latex');
title('Erro e[k]');
legend(legendas, 'Location', 'best');

subplot(4,1,4);
xlabel('Iteração [k]');
ylabel('y[k]');
title('Saída y[k]');
legend(legendas, 'Location', 'best');

% Sincroniza zoom horizontal
linkaxes(findall(gcf, 'Type', 'axes'), 'x');

% Exporta para PDF
exportgraphics(f, './Resultados/AplicandoTsDown.pdf', 'ContentType', 'vector');
