rx = sdrrx('Pluto', 'GainSource','Manual', 'Gain', 20, 'CenterFrequency', 2.412e9);
tx = sdrrx('Pluto');

tx.BasebandSampleRate = 56e6;
rx.BasebandSampleRate = 56e6;
% view some spectrum
%rx.SamplesPerFrame = 2^11; 
frameSize = rx.SamplesPerFrame; %number of samples for frame


startFreq = 70e6; %Hz
endFreq = 6e9; %Hz
fs = rx.BasebandSampleRate;
framesToCollect = 10;
%commenting out this function becuause we already swept the spectrum.
%fileList = freqSweep(startFreq, endFreq, fs, framesToCollect);

%load data and perform processing
desiredFreqs = [99.5e6, 257.8e6, 600e6, 1985e6] ; %enter the desired freq you want to view 
namesAndFreqs = [];
for i = 1:length(desiredFreqs)
    [name, Freq] = findNameAndFreq(desiredFreqs(i));
    namesAndFreqs = [namesAndFreqs; [name, Freq]];
end

desiredFreq = desiredFreqs(3); % the signal we wanna view
freqFile = namesAndFreqs(3, 1); %the file containing it
startFreqOfDesiredFreq = str2double(namesAndFreqs(3,2)); %the numeric form of freq file

bfr = comm.BasebandFileReader(freqFile, 'SamplesPerFrame', frameSize);
samples = bfr();
bfr.release();
sa2 = dsp.SpectrumAnalyzer(ChannelNames = {append(string(desiredFreq/1000000), "MHz")}, ...
    ShowLegend = true,...
    SampleRate = fs, ...
    FrequencyOffset = startFreqOfDesiredFreq);
    
%PlotMaxHoldTrace = true);
%sa2.AxesScaling = "Auto";
%s2.YLimits = [-10,40];


% sa2.CursorMeasurements.Enable = true;
% sa2.CursorMeasurements.Type = 'Screen cursors';
% sa2.CursorMeasurements.ShowVertical = true;
% sa2.CursorMeasurements.XLocation = [desiredFreq - 100, desiredFreq+100];
% sa2.CursorMeasurements.SnapToData = true;

%sa2.PlotMaxHoldTrace = true;

for frame = 1:framesToCollect
    sa2(samples);
end
sa2.release();
