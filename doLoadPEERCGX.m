function [EEG] = doLoadPEERCGX(pathName,fileName,nbEEGChan,chanNames)

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
        tempData = csvread(fileName);
    catch
        error('DATA WAS AN UNREADABLE FORMAT OR FILE WAS NOT FOUND: TRY DATA CONVERSION TO PEER FORMAT OR CHECK FILENAME');
    end
       
    % setup the EEGLAB format
    EEG = eeg_emptyset;
    
    % default sampling rate for MUSE
    EEG.srate = 500;
    
    % extract the EEG data from the PEER format
    eegData = [];
    eegData = tempData(:,[1 nbEEGChan]); 
    markers = tempData(:,nbEEGChan+1);

    % put the data into EEGLAB format and reorder to logical order of AF7, AF8,
    % TP9, TP10 - also use detrend to remove the mean and any DC trends
    EEG.data = eegData';
    EEG.pnts = length(EEG.data);

    % checks to make sure that markers are single digits and not
    % consecutive replicates
    lastPosition = length(markers);
    currentPosition = 2;
    while 1
        if markers(currentPosition) ~= markers(currentPosition-1)
            zeroPosition = currentPosition + 1;
            if zeroPosition > length(markers)
                break
            end
            currentTarget = markers(currentPosition);
            while 1
                if markers(zeroPosition) == currentTarget
                    markers(zeroPosition) = 0;
                else
                    currentPosition = zeroPosition - 1;
                    break
                end
                zeroPosition = zeroPosition + 1;
                if zeroPosition > length(markers)
                    break
                end
            end
        end
        currentPosition = currentPosition + 1;
        if currentPosition > length(markers)
            break
        end
    end

    % create markers data
    markerCounter = 1;
    for counter = 1:length(markers)
        if markers(counter) ~= 0
            markerData(markerCounter,1) = markers(counter);
            markerData(markerCounter,2) = counter;
            markerCounter = markerCounter + 1;
        end
    end

    % create an EEGLAB event variable
    EEG.event = [];
    for counter = 1:length(markerData)
        EEG.event(counter).latency = markerData(counter,2);
        EEG.event(counter).duration = 1;
        EEG.event(counter).channel = 0;
        EEG.event(counter).bvtime = [];
        EEG.event(counter).bvmknum = counter;
        
        if markerData(counter,1) < 10
            stringMarker = ['S  ' num2str(markerData(counter,1))];
        end
        if markerData(counter,1) > 10 && markerData(counter,1) < 100
            stringMarker = ['S ' num2str(markerData(counter,1))];
        end
        if markerData(counter,1) > 99
            stringMarker = ['S' num2str(markerData(counter,1))];
        end   
        EEG.event(counter).type = stringMarker;
        EEG.event(counter).code = 'Stimulus';
        EEG.event(counter).urevent = counter;
    end
    EEG.urevent = EEG.event;
    EEG.allMarkers = markerData;

    %correct time stamps for EEGLAB format
    EEG.times = [];
    EEG.times(1) = 0;
    for counter = 2:size(EEG.data,2)
        EEG.times(counter) = EEG.times(counter-1) + (1/EEG.srate*1000);
    end
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end)/1000;
    
    EEG.nbchan = nbEEGChan;

    EEG.chanlocs = struct('labels',chanNames);
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    
    EEG.data = EEG.data .* 100000;
    
end