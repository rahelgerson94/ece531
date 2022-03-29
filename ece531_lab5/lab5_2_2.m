Fs = 10; %Sampling frequency
T = 1/Fs; %Symbol period
L = 1000; %Number of points
t = (0:L-1)*T; %Time vector
phi1 = srrc_pulse(1, 1/10, 4, 0); %SRRC pulse
figure
plot(Fs*t(1:50), phi1(1:50));
title("impulse response");
NFFT = 2^nextpow2(L);
Y = fftshift(fft(phi1, NFFT));
f = Fs/2 * linspace(0,1,NFFT/2+1);
f2 = ((0:NFFT-1) -ceil((NFFT-1)/2))/NFFT/T;
figure
plot(f, 2*abs(Y(1:NFFT/2+1)));
title("one sided freq response"); %one sided
figure
plot(f2, 2*abs(Y)); %two sided
title("two sided freq response"); %one sided
function [phi, t] = srrc_pulse(T, Ts, A, a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% phi = srrc_pulse(T, Ts, A, a)                                                 %
% OUTPUT                                                                        %    
%      phi: truncated SRRC pulse, with parameter T,                             %
%                 roll-off factor a, and duration 2*A*T                         %
%      t:   time axis of the truncated pulse                                    %
% INPUT                                                                         %      
%      T:  Nyquist parameter or symbol period  (real number)                    %       
%      Ts: sampling period  (Ts=T/over)                                         %      
%                where over is a positive INTEGER called oversampling factor    %      
%      A:  half duration of the pulse in symbol periods (positive INTEGER)      %        
%      a:  roll-off factor (real number between 0 and 1)                        %
%                                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = [-A*T:Ts:A*T] + 10^(-8); % in order to avoid division by zero problems at t=0.
if (a>0 && a<=1)
   num = cos((1+a)*pi*t/T) + sin((1-a)*pi*t/T) ./ (4*a*t/T);
   denom = 1-(4*a*t./T).^2;
   phi = 4*a/(pi*sqrt(T)) * num ./ denom;
elseif (a==0)
   phi = 1/(sqrt(T)) * sin(pi*t/T)./(pi*t/T);
else
    phi = zeros(length(t),1);
    disp('Illegal value of roll-off factor')
    return
end
end
