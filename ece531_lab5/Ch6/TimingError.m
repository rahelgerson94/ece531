
%% General system details
fs = 1e6; samplesPerSymbol = 8;
frameSize = 2^10; numFrames = 200;
numSamples = numFrames*frameSize; % Samples to simulate
modulationOrder = 2; filterSymbolSpan = 4;
%% Visuals
cdPre = comm.ConstellationDiagram('ReferenceConstellation', [-1 1],...
    'Name','Baseband');
cdPost = comm.ConstellationDiagram('ReferenceConstellation', [-1 1],...
    'Name','Baseband with Timing Offset');
cdPre.Position(1) = 50;
cdPost.Position(1) = cdPre.Position(1)+cdPre.Position(3)+10;% Place side by side
%% Impairments
snr = 15; timingOffset = samplesPerSymbol*0.01; % Samples
%% Generate symbols
data = randi([0 modulationOrder-1], numSamples*2, 1);
mod = comm.DBPSKModulator(); modulatedData = mod(data);
%% Add TX/RX Filters
TxFlt = comm.RaisedCosineTransmitFilter(...
    'OutputSamplesPerSymbol', samplesPerSymbol,...
    'FilterSpanInSymbols', filterSymbolSpan);
RxFlt = comm.RaisedCosineReceiveFilter(...
    'InputSamplesPerSymbol', samplesPerSymbol,...
    'FilterSpanInSymbols', filterSymbolSpan,...
    'DecimationFactor', samplesPerSymbol);
RxFltRef = clone(RxFlt);
%% Add noise source
chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',snr, ...
    'SignalPower',1,'RandomStream', 'mt19937ar with seed');
%% Add delay
varDelay = dsp.VariableFractionalDelay;
%% Model of error
% Add timing offset to baseband signal
filteredData = [];
for k=1:frameSize:(numSamples - frameSize)
    timeIndex = (k:k+frameSize-1).';
    % Filter signal
    filteredTXData = TxFlt(modulatedData(timeIndex));
    % Pass through channel
    noisyData = chan(filteredTXData);
    % Time delay signal
    offsetData = varDelay(noisyData, k/frameSize*timingOffset);
    % Filter signal
    filteredData = RxFlt(offsetData);filteredDataRef = RxFltRef(noisyData);
    % Visualize Error
    e = ZC(filteredData, 1/fs, k/frameSize*timingOffset);
    cdPre(filteredDataRef);cdPost(filteredData);pause(0.1); %#ok<*UNRCH>
    plot(e);
end

function e = ZC(x, fs, tau)
Ts = 1/fs;
e = zeros(size(x));
    for k = 1:length(x)
        if k==1024
            break
        end
        %display(k)
        x1 = x(k); x2 = x(k+1); xhalf = interp1([k, k+1], [x1,x2], [k + 0.5]);
        e(k) = real(xhalf*Ts + tau)*(sign(real( x(k)*Ts + tau) ) - sign(real(x(k+1)*Ts + tau))) + ...
            imag(xhalf*Ts + tau)*(sign(imag(x(k)*Ts + tau) ) - sign(imag(x(k+1)*Ts + tau))) ;
    end 
end 

function y
