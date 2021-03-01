function [EEG] = doLoadMUSEfromEDF(fileName)

    % by Olav Krigolson, April 2019
    % load PEER CSV data into MATLAB in EEGLAB format
    % note this code reorders the channels into logical order of AF7, AF8,
    % TP9, and TP10 and not the MUSE order of TP9, AF7, AF8, TP10. The data
    % is also detrended to remove the DC offset in the signal - the so
    % called MUSE unit conversion
    % set targetMarkers = {'N'} if there are no markers in the data
    
    % display current filename
    disp('Loading Filename: ');
    fileName
        
    % load the data, MUST BE PEER format
    try
        tempData = edfread(fileName);
    catch
        error('DATA WAS AN UNREADABLE FORMAT OR FILE WAS NOT FOUND: TRY DATA CONVERSION TO PEER FORMAT OR CHECK FILENAME');
    end
       
    % setup the EEGLAB format
    EEG = eeg_emptyset;
    
    % default sampling rate for MUSE
    EEG.srate = 256;
    
    % extract the EEG data from the PEER format
    ch1 = [];
    ch2 = [];
    ch3 = [];
    ch4 = [];

    for i = 1:size(tempData,1)

        ch1 = [ch1 tempData.eeg_ch1{i}'];
        ch2 = [ch2 tempData.eeg_ch2{i}'];
        ch3 = [ch3 tempData.eeg_ch3{i}'];
        ch4 = [ch4 tempData.eeg_ch4{i}'];

    end      

    % put the data into EEGLAB format and reorder to logical order of AF7, AF8,
    % TP9, TP10 - also use detrend to remove the mean and any DC trends
    EEG.data(1,:) = detrend(ch1);
    EEG.data(2,:) = detrend(ch2);
    EEG.data(3,:) = detrend(ch3);
    EEG.data(4,:) = detrend(ch4);
    
    EEG.pnts = length(EEG.data);

    % create an EEGLAB event variable
    EEG.event = [];
    EEG.urevent = EEG.event;

    %correct time stamps for EEGLAB format
    EEG.times = [];
    EEG.times(1) = 0;
    for counter = 2:size(EEG.data,2)
        EEG.times(counter) = EEG.times(counter-1) + (1/EEG.srate*1000);
    end
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end)/1000;
    
    EEG.nbchan = 4;
    
    EEG.chanlocs(1).labels = 'AF7';
    EEG.chanlocs(1).type = [];
    EEG.chanlocs(1).theta = -38;
    EEG.chanlocs(1).radius = 0.5111;
    EEG.chanlocs(1).X = 0.7875;
    EEG.chanlocs(1).Y = 0.6153;
    EEG.chanlocs(1).Z = -0.0349;
    EEG.chanlocs(1).sph_theta = 38;
    EEG.chanlocs(1).sph_phi = -2.0;
    EEG.chanlocs(1).sph_radius = 1.0;
    EEG.chanlocs(1).urchan = 1;
    EEG.chanlocs(1).ref = [];

    EEG.chanlocs(2).labels = 'AF8';
    EEG.chanlocs(2).type = [];
    EEG.chanlocs(2).theta = 38;
    EEG.chanlocs(2).radius = 0.5111;
    EEG.chanlocs(2).X = 0.7875;
    EEG.chanlocs(2).Y = -0.6153;
    EEG.chanlocs(2).Z = -0.0349;
    EEG.chanlocs(2).sph_theta = -38;
    EEG.chanlocs(2).sph_phi = -2.0;
    EEG.chanlocs(2).sph_radius = 1.0;
    EEG.chanlocs(2).urchan = 2;
    EEG.chanlocs(2).ref = [];

    EEG.chanlocs(3).labels = 'TP9';
    EEG.chanlocs(3).type = [];
    EEG.chanlocs(3).theta = -108;
    EEG.chanlocs(3).radius = 0.6389;
    EEG.chanlocs(3).X = -0.2801;
    EEG.chanlocs(3).Y = 108;
    EEG.chanlocs(3).Z = -0.4226;
    EEG.chanlocs(3).sph_theta = 108;
    EEG.chanlocs(3).sph_phi = -25.0;
    EEG.chanlocs(3).sph_radius = 1.0;
    EEG.chanlocs(3).urchan = 3;
    
    EEG.chanlocs(4).labels = 'TP10';
    EEG.chanlocs(4).type = [];
    EEG.chanlocs(4).theta = 108;
    EEG.chanlocs(4).radius = 0.6389;
    EEG.chanlocs(4).X = -0.2801;
    EEG.chanlocs(4).Y = 0.0;
    EEG.chanlocs(4).Z = -0.4226;
    EEG.chanlocs(4).sph_theta = -108;
    EEG.chanlocs(4).sph_phi = -25.0;
    EEG.chanlocs(4).sph_radius = 1.0;
    EEG.chanlocs(4).urchan = 4;
    
end