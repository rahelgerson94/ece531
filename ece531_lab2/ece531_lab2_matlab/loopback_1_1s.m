
% Setup Receiver
rx=sdrrx('Pluto','OutputDataType','double','SamplesPerFrame',2^15,...
    'GainSource','Manual','Gain',30);
% Setup Transmitter
tx = sdrtx('Pluto','Gain',-30);
% Transmit sinewave
    
sineObj = dsp.SineWave('Frequency',300000,...
                    'SampleRate',rx.BasebandSampleRate,...
                    'SamplesPerFrame', rx.SamplesPerFrame,...
                    'ComplexOutput', true,...
                    'Amplitude',.7);
sig = sineObj();
noise = zeros(1, length(sig));
sigPlusNoise = [noise'; sig];
tx.transmitRepeat(sigPlusNoise); % Transmit continuously

% Setup Scope
samplesPerStep = rx.SamplesPerFrame/rx.BasebandSampleRate;
steps = 1;

% ts = dsp.TimeScope('SampleRate', rx.BasebandSampleRate,...
%                    'TimeSpan', samplesPerStep*steps,...
%                    'BufferLength', rx.SamplesPerFrame*steps);
% %to show in timescope
% for i = 1:steps
%     ts(rx());
% end 

%plot the data in the buffer 
ts_sink = dsp.SignalSink;
for i = 1:steps
    ts_sink(rx());
end 
hold on
plot(real(ts_sink.Buffer))
hold on
plot(imag(ts_sink.Buffer))

%obtain the noise power 
noisePower = 0;
for i = 1: 1000
    curr = ts_sink.Buffer(i);
    magn = sqrt(((real(curr))^2 + (imag(curr))^2 ));
    noisePower = noisePower + magn;
end
noisePower =  noisePower  / 1000;

%obtain the signal power 

%first, we need to obtain the starting index
idx = 0;
for i = 1: length(ts_sink.Buffer)
    curr = ts_sink.Buffer(i);
    if (abs(real(curr)) < .001)
        continue;
    else    
        idx = i;
        break;
    end 
end


%now, obtain the signal power
sigPower = 0;
for i = idx: idx+ 1000
    curr = ts_sink.Buffer(i);
    magn = sqrt(((real(curr))^2 + (imag(curr))^2 ));
    sigPower = sigPower + magn;
end
sigPower =  sigPower  / 1000;

sprintf("sigPower = %f", sigPower)
sprintf("noisePower = %f", noisePower)
