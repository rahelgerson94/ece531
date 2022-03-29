%find the filename containing the spectrum corresponding to desiredFreq, 
%where desiredFreq is in MHz
function freqFile, Freq = findNameAndFreq(desiredFreq, startFreq, endFreq, sampleRate)
if ~exist('startFreq','var') || isempty(startFreq)
        startFreq = 70e6;
end
if ~exist('endFreq','var') || isempty(endFreq)
    endFreq = 6e9;
end
if ~exist('sampleRate','var') || isempty(sampleRate)
    sampleRate = 56e6;
end
lowFreq = startFreq; highFreq = startFreq + sampleRate;
    for freq = startFreq: sampleRate: endFreq
        if desiredFreq < highFreq && desiredFreq >= lowFreq 
            freqFile = append("f", string(lowFreq/1000000), "MHz.bb");
            Freq = lowFreq;
        end 
        lowFreq = highFreq;
        highFreq = lowFreq + sampleRate;
    end
    
end 
