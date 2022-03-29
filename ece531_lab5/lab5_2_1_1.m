betas = [0.1:0.2:0.9];
Fs = 10;
L = 2^10;
f = Fs/2 * linspace(-1, 1, L);
span = 16;
sps = 30;
for beta = betas
    h = rcosdesign(beta ,span, sps,'sqrt');
    H = fftshift(fft(h, L));
    figure(1);
    hold on;
    plot(f, abs(H));
    hold off;
end

figure(1);
legend("show");
xlabel("frequency");
ylabel("magnitude");
