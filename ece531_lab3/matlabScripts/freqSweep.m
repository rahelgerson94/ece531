function listOfFileNames = freqSweep(startFreq, endFreq, sampleRate, framesToCollect) 
    if ~exist('framesToCollect','var') || isempty(framesToCollect)
        framesToCollect = 10;
    end
    if exist('rx', 'var') %if there'es a variable in my workspace called rx
        rx.release();
    end
    fs = sampleRate;
    listOfFileNames = {};
    Spectra = [];
    

    for freq=startFreq:fs:endFreq
        %record the data for offline processing.
        rx = sdrrx('Pluto', 'GainSource','Manual', 'Gain', 20, 'CenterFrequency', freq, 'SamplesPerFrame', 2^11, 'BasebandSampleRate', sampleRate);
        frameSize = rx.SamplesPerFrame; %frame size specifies the number of samples for frame
        data = zeros(frameSize,framesToCollect);
        framesToCollect = 10;
        %collect all frames continuously for current frequency
        for frame = 1:framesToCollect
            [d, valid, of] = rx();
            data(:,frame) = d;
            if ~valid
                warning('data  invalid')
            elseif of
                warning('overflow occured')
                %else
                %  data(:,frame) = d;
            end
        end
        %save data for processing
        fName = append('f', string(freq/1000000), 'MHz.bb') ;
        listOfFileNames{end + 1} = fName;
        display(freq);
        bfw = comm.BasebandFileWriter(fName, ...
            rx.BasebandSampleRate, freq);
        %save the  data
        bfw(data(:));
        %save data as a column
        bfw.release();
    end
end
