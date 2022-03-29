% Setup Receiver
rx=sdrrx('Pluto','OutputDataType','double','SamplesPerFrame',2^15,...
    'GainSource','Manual','Gain', 30);
% Setup Transmitter
tx = sdrtx('Pluto','Gain',-30);
% Transmit sinewave

sineObj = dsp.SineWave('Frequency',10000,...
                    'SampleRate', 10*rx.BasebandSampleRate,...
                    'SamplesPerFrame', rx.SamplesPerFrame,...
                    'ComplexOutput', true,...
                    'Amplitude',0.1);
sig = sineObj();
noise = zeros(1, length(sineObj()));
sigPlusNoise = [sig' , noise];
%noisy_sine = reshape(newSine,1,[]);
tx.transmitRepeat(sigPlusNoise'); % Transmit continuously
% Setup Scope
samplesPerStep = rx.SamplesPerFrame/rx.BasebandSampleRate;

fs = dsp.SpectrumAnalyzer('SampleRate', 10*rx.BasebandSampleRate, 'YLimits',[-80, 40],'ShowLegend',true);
fs.PeakFinder.Enable = true;



%view sine  in freq domain
data = [];
for Iter = 1:100
    fs(rx());
     if fs.isNewDataReady
        data = [data;getMeasurementsData(fs)];
        peaks = data.PeakFinder(end).Value;
        freqsKHz = data.PeakFinder(end).Frequency/1000;
     end
end