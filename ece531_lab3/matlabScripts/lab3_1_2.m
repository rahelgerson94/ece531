% Setup Receiver
rx = sdrrx('Pluto', 'GainSource','Manual', 'Gain', 20, 'CenterFrequency', 2.412e9);
tx = sdrrx('Pluto');

tx.BasebandSampleRate = 22e6; %with sample 
rx.BasebandSampleRate = 22e6;
% view some spectrum
rx.SamplesPerFrame = 2^15;
sa = dsp.SpectrumAnalyzer(ChannelNames = {append(string(rx.CenterFrequency/1000000), "MHz")}, ShowLegend = true);
sa.PlotMaxHoldTrace = true;
sa.YLimits = [-10,80];
sa.SampleRate = rx.BasebandSampleRate;
sa.ShowLegend = true;
while true
    sa(rx());
end 

