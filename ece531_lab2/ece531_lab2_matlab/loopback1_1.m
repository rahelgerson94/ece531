
% Setup Receiver
rx=sdrrx('Pluto','OutputDataType','double','SamplesPerFrame',2^15,...
    'GainSource','Manual','Gain',30);
% Setup Transmitter
tx = sdrtx('Pluto','Gain',-30);
% Transmit sinewave
Fc  =  300; Fs = 3000; Tc = 1/Fc; Ts = 1/Fs;
N = 3*(Tc/Ts);
sineObj = dsp.SineWave('Frequency',Fc,...
                    'SampleRate',Fs,...
                    'SamplesPerFrame', cast(N, 'int32'),...
                    'ComplexOutput', true,...
                    'Amplitude',.7);
sig = sineObj();

tx.transmitRepeat(sig); % Transmit continuously

% Setup Scope
samplesPerStep = rx.SamplesPerFrame/rx.BasebandSampleRate;
steps = 1;

ts = dsp.TimeScope('SampleRate', rx.BasebandSampleRate,...
                   'TimeSpan', samplesPerStep*steps,...
                   'BufferLength', rx.SamplesPerFrame*steps);
ts.AxesScaling = 'Auto';
%to show in timescope
for i = 1:steps
    ts(rx());
end 



