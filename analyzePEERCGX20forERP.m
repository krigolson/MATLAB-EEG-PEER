clear all;
close all;
clc;

% VARIABLES

% filter parameters
filterOrder = 2;
filterLow = 0.1;                        % always keep at 0.1
filterHigh = 15;                        % set to 15 for ERP analyses, set to 30 or higher for FFT
filterNotch = 60;                       % unless in Europe use 60

% epoch parameters
epochMarkers = {'S211','S212'};               % the markers 5 is control 6 is oddball
currentEpoch = [-200 798];             % the time window

% baseline window
baseline = [-200 0];                    % the baseline, recommended -200 to 0

% artifact criteria
typeOfArtifactRejction = 'Difference';  % max - min difference
artifactCriteria = 100;                  % recommend maxmin of 75
individualChannelAveraging = 0;         % set to one for individual channel averaging

% internal consistency
computeInternalConsistency = 0;         % set to 1 to do odd even averaging to allow computation of internal consistency

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMANDS
   
EEG = doLoadCGXDevKit('test.xdf');

EEG.data(3:8,:) = [];
EEG.nbchan = 2;

% filter the data
EEG = doFilter(EEG,filterLow,filterHigh,filterOrder,filterNotch,EEG.srate);

% epoch data
EEG = doSegmentData(EEG,epochMarkers,currentEpoch);

% baseline correction
EEG = doBaseline(EEG,baseline);
    
% identify artifacts
EEG = doArtifactRejection(EEG,typeOfArtifactRejction,artifactCriteria);

% remove bad trials
EEG = doRemoveEpochs(EEG,EEG.artifactPresent,individualChannelAveraging);

% make ERPs
ERP = doERP(EEG,epochMarkers,computeInternalConsistency);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT THE OUTPUT

% plot the results
subplot(2,2,1);
plot(ERP.times,ERP.data(1,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(1,:,2),'LineWidth',3);
hold off;
title('Channel TP9');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

subplot(2,2,2);
plot(ERP.times,ERP.data(2,:,1),'LineWidth',3);
hold on;
plot(ERP.times,ERP.data(2,:,2),'LineWidth',3);
hold off;
title('Channel TP10');
ylabel('Voltage (uV)');
xlabel('Time (ms)');

dw1 = squeeze(ERP.data(1,:,2) - ERP.data(1,:,1));
dw2 = squeeze(ERP.data(2,:,2) - ERP.data(2,:,1));

subplot(2,2,3);
plot(ERP.times,dw1,'LineWidth',3);
title('TP9 Difference Wave');
ylabel('Voltage (uV)');
xlabel('Time (ms): Click on the N200 and P300');

subplot(2,2,4);
plot(ERP.times,dw2,'LineWidth',3);
title('TP9 Difference Wave');
ylabel('Voltage (uV)');
xlabel('Time (ms): Click on the N200 and P300');