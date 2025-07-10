function a = GetStepInfo(Resp_orig, Resp_filt, temp)
    % Obtém informações da resposta ao degrau
    % Sistema sem filtro
    info_orig = stepinfo(Resp_orig, temp);
    
    % Sistema com filtro
    info_filter = stepinfo(Resp_filt, temp);
    
    % Tempo de acomodação a 2%
    Ts_orig = info_orig.SettlingTime;
    Ts_filter = info_filter.SettlingTime;
    Erro_ts = ((Ts_orig - Ts_filter) / Ts_orig) * 100;
    
    % Tempo de subida 
    Tr_orig = info_orig.RiseTime;
    Tr_filter = info_filter.RiseTime;
    Erro_tr = ((Tr_orig - Tr_filter) / Tr_orig) * 100;
    
    fprintf('Tempo de subida (original): %.4f s\n', Tr_orig);
    fprintf('Tempo de subida (filtrado): %.4f s\n', Tr_filter);
    fprintf('Erro relativo tempo de subida: %.4f\n\n', Erro_tr);
    
    fprintf('Tempo de acomodação (original): %.4f s\n', Ts_orig);
    fprintf('Tempo de acomodação (filtrado): %.4f s\n', Ts_filter);
    fprintf('Erro relativo tempo de acomodação: %.4f\n\n', Erro_ts);
    
    % Critério para cálculo do parâmetro 'a'
    if Erro_tr < Erro_ts
        a = 2.2 / (Tr_filter);
    else
        a = 4 / (Ts_filter);
    end
end
