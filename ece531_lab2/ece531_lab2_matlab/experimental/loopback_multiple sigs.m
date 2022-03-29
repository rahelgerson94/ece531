% Setup Receiver
rx=sdrrx('Pluto','OutputDataType','double','SamplesPerFrame',2^15,...
    'GainSource','Manual','Gain',30);
% Setup Transmitter
tx = sdrtx('Pluto','Gain',-30);
% Transmit sinewave
amplitudes = [.1, .4, .7, 1];
sigs = [];
noise = zeros(1, 1026);
for i = 1: length(amplitudes)
    sineObj = dsp.SineWave('Frequency',300,...
                    'SampleRate',rx.BasebandSampleRate,...
                    'SamplesPerFrame', rx.SamplesPerFrame,...
                    'ComplexOutput', true,...
                    'Amplitude',amplitudes(i));
    sig = sineObj();
    sigPlusNoise = [noise'; sig];
    sigs  = [sigs; sigPlusNoise];
end 
%now that we have an array of different signals, let's transmit each one 
%and calculate the power. 
data = [];
for i = 1: length(amplitudes)
    tx.transmitRepeat(sigs(i)); % Transmit continuously
    % Setup Scope
    samplesPerStep = rx.SamplesPerFrame/rx.BasebandSampleRate;
    steps = 1;
    data = [data; dsp.SignalSink;]

% Setup Scope
samplesPerStep = rx.SamplesPerFrame/rx.BasebandSampleRate;
steps = 1;
ts = dsp.TimeScope('SampleRate', rx.BasebandSampleRate,...
                   'TimeSpan', samplesPerStep*steps,...
                   'BufferLength', rx.SamplesPerFrame*steps);
%to show in timescope
for i = 1:steps
    ts(rx());
end 

%plot the data in the buffer 
ts_sink = dsp.SignalSink;
for i = 1:steps
    ts_sink(rx());
end 
hold on
plot(real(ts_sink.Buffer))
hold on
plot(imag(ts_sink.Buffer))

%obtain the power 