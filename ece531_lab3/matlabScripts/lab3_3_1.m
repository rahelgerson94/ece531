% Setup Receiver
fc = 314.95e6; %frequency of my keyFob
rx = sdrrx('Pluto', 'GainSource','Manual', 'Gain', 20, 'CenterFrequency', fc);
tx = sdrrx('Pluto');

tx.BasebandSampleRate = 70e3;
rx.BasebandSampleRate = 70e3;
% view some spectrum
rx.SamplesPerFrame = 2^11;
frameSize = rx.SamplesPerFrame; %frame size specifies the number of samples for frame
framesToCollect = 5;
data = [];
%data = zeros(frameSize *framesToCollect,1);
%collect all frames continuously for current frequency
dataStartIdx = frame;
for frame = 1:framesToCollect
    [d, valid, of] = rx();
    dataEndIdx = frame * frameSize;
    data = [data;d];
    %data(dataStartIdx : length(d)) = d;
    if ~valid
        warning('data  invalid')
    elseif of
        warning('overflow occured')
    end
    dataStartIdx = dataEndIdx+1;
    rx.release();
end 

%save data for processing
fName = 'keFobFreqRecording.bb' ;
bfw = comm.BasebandFileWriter(fName, ...
    rx.BasebandSampleRate, fc);
%save the  data
bfw(data(:));
bfw.release();

%load data and perform processing
sa = dsp.SpectrumAnalyzer(ChannelNames = {append(string(rx.CenterFrequency/1000000), "MHz")}, ...
    ShowLegend = true, ...
    SampleRate = rx.BasebandSampleRate, ...
    ShowLegend = true, ...
    ViewType = "Spectrum and spectrogram");

bfr = comm.BasebandFileReader(fName, 'SamplesPerFrame', frameSize);
sa(bfr());


