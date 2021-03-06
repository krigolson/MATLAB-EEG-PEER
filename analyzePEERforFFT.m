clear all;
close all;
clc;

% analyze a single PEER subject and generates the average power for the
% recording for each channel

% VARIABLES

fileName = '002 Outdoor Post Ride 08-09-2019';
markers = {'N'};

% filter parameters
filterOrder = 2;
filterLow = 0.1;                        % always keep at 0.1
filterHigh = 30;                        % set to 15 for ERP analyses, set to 30 or higher for FFT
filterNotch = 60;                       % unless in Europe use 60

% artifact criteria
typeOfArtifactRejction = 'Difference';  % max - min difference
artifactCriteria = 60;                  % recommend maxmin of 75
individualChannelAveraging = 0;         % set to one for individual channel averaging

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMANDS
   
% load the data
EEG = doLoadPEER(fileName,markers);

% filter the data
EEG = doFilter(EEG,filterLow,filterHigh,filterOrder,filterNotch,EEG.srate);

% epoch data
[EEG] = doTemporalEpochs(EEG,1000,500);

% identify artifacts
EEG = doArtifactRejection(EEG,typeOfArtifactRejction,artifactCriteria);

% remove bad trials
EEG = doRemoveEpochs(EEG,EEG.artifactPresent,individualChannelAveraging);

% make FFTs
FFT = doFFT(EEG,{'1'});

% compute power in each band for each channel
powerDeltaAF7 = mean(FFT.data(1,1:3));
powerThetaAF7 = mean(FFT.data(1,4:7));
powerAlphaAF7 = mean(FFT.data(1,8:12));
powerBetaAF7 = mean(FFT.data(1,13:30));

powerDeltaAF8 = mean(FFT.data(2,1:3));
powerThetaAF8 = mean(FFT.data(2,4:7));
powerAlphaAF8 = mean(FFT.data(2,8:12));
powerBetaAF8 = mean(FFT.data(2,13:30));

powerDeltaTP9 = mean(FFT.data(3,1:3));
powerThetaTP9 = mean(FFT.data(3,4:7));
powerAlphaTP9 = mean(FFT.data(3,8:12));
powerBetaTP9 = mean(FFT.data(3,13:30));

powerDeltaTP10 = mean(FFT.data(4,1:3));
powerThetaTP10 = mean(FFT.data(4,4:7));
powerAlphaTP10 = mean(FFT.data(4,8:12));
powerBetaTP10 = mean(FFT.data(4,13:30));

% plot full power range for each channel

subplot(2,2,1);
bar(FFT.data(1,1:30));
ylabel('Power uV^2');
xlabel('Frequency (Hz)');
title('Channel AF7');

subplot(2,2,2);
bar(FFT.data(2,1:30));
ylabel('Power uV^2');
xlabel('Frequency (Hz)');
title('Channel AF8');

subplot(2,2,3);
bar(FFT.data(3,1:30));
ylabel('Power uV^2');
xlabel('Frequency (Hz)');
title('Channel TP9');

subplot(2,2,4);
bar(FFT.data(4,1:30));
ylabel('Power uV^2');
xlabel('Frequency (Hz)');
title('Channel TP10');