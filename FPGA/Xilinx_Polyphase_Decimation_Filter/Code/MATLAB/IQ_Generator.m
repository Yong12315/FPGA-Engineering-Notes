clc; clear; close all;

%% 参数设置
fs = 122.88e6;     % 采样率 122.88 MHz
f1 = 5e6;         % 第一个复数单音 10 MHz
f2 = 10e6;         % 第二个复数单音 20 MHz

Scale = 1000;
N = 20000;          % 采样点数
n = 0:N-1;
t = n / fs;

%% 生成两个复数单音信号
sig_10M = exp(1j * 2*pi*f1*t);
sig_20M = exp(1j * 2*pi*f2*t);

%% 两个复数信号直接相加
iq_signal = int16((sig_10M + sig_20M)*Scale);

I = real(iq_signal);
Q = imag(iq_signal);

I_u16 = typecast(I(:), 'uint16');
Q_u16 = typecast(Q(:), 'uint16');

packed_data = bitor(uint32(I_u16),bitshift(uint32(Q_u16), 16));

packed_hex = dec2hex(packed_data, 8);

%% 输出文件

% 1) 输出32bit十六进制，每行一个样点
fid = fopen('IQ_Data.mem', 'w');
for k = 1:length(packed_hex)
    fprintf(fid, '%08X\n', packed_hex(k));
end
fclose(fid);

fprintf('已生成文件：IQ_Data.mem\n');
fprintf('总输出点数 = %d\n', length(packed_hex));
%% 时域波形
figure;
plot(t(1:300)*1e6, I(1:300), 'LineWidth', 1.2);
hold on;
plot(t(1:300)*1e6, Q(1:300), 'LineWidth', 1.2);
grid on;
xlabel('Time / us');
ylabel('Amplitude');
legend('I', 'Q');
title('IQ Signal: 10 MHz + 20 MHz Complex Tones');

%% 频谱分析
Nfft = 8192;
f = (-Nfft/2:Nfft/2-1) * fs / Nfft;

X = fftshift(fft(iq_signal, Nfft));
X_dB = 20*log10(abs(X)/max(abs(X)) + eps);

figure;
plot(f/1e6, X_dB, 'LineWidth', 1.2);
grid on;
xlabel('Frequency / MHz');
ylabel('Magnitude / dB');
title('Spectrum of IQ Signal');
xlim([-60 60]);
ylim([-100 5]);