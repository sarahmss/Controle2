function Fs = BuildFFT(T, Resp)
    Fs = 1 / T;  % Frequência de amostragem
    L = length(Resp);  % Comprimento do sinal
    
    R = fft(Resp);  % FFT
    f = Fs / L * (0:L-1);  % Eixo de frequência
    figure;
    plot(f, abs(R))
    title(['FFT - ', num2str(T), ' (s)'])
    xlabel('Frequência')
    ylabel('Resposta')
end
