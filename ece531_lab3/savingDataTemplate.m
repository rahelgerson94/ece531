rx = sdrrx('Pluto', 'GainSource','Manual', 'Gain', 20, 'CenterFrequency', 2.412e9);
tx = sdrrx('Pluto');

tx.BasebandSampleRate = 70e3;
rx.BasebandSampleRate = 70e3;
% view some spectrum
rx.SamplesPerFrame = 2^11;
frameSize = rx.SamplesPerFrame; %number of samples for frame
framesToCollect =10; 

%record the data for offline processing
data = zeros(frameSize,framesToCollect);
%collect all frames continuously
for frame = 1:framesToCollect
    [d, valid, of] = rx();
    if ~valid
        warning('data  invalid')
    elseif of 
        warning('overflow occured')
    else
        data(:,frame) = d;
    end
end

% %process new live data
% sa1 = dsp.SpectrumAnalyzer;
% for frame = 1:framesToCollect
%     sa1(data(:, frame));
% end

%save data for processing
bfw = comm.BasebandFileWriter('lab3_2_1.bb', ...
    rx.BasebandSampleRate, rx.CenterFrequency);
%save data as a column
bfw(data(:));
bfw.release();

%load data and perform processing
bfr = comm.BasebandFileReader(bfw.Filename, 'SamplesPerFrame', frameSize);
sa2 = dsp.SpectrumAnalyzer;
for frame = 1:framesToCollect
    sa2(bfr());
end


