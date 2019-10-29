clear all
addpath('/Users/mplome/Desktop/eeglab14_1_2b')
addpath('tools');
eeglab
close
table_old = readtable("/Users/mplome/Downloads/old.xlsx");
table_young =readtable("/Users/mplome/Downloads/young.xlsx");
oldIDsA = table_old{3:end,1};
oldIDsB= table_old{3:end,2};
all_oldIDs = [oldIDsA; oldIDsB];
youngIDsA = table_young{3:end,1};
youngIDsB= table_young{3:end,2};
all_youngIDs = [youngIDsA; youngIDsB];

%tak bylo w starrym
%raw= '/Users/mplome/Desktop/HOPE/EEG_prep_ica_blocks_1_results'; % path to preprocessed eeg files
%etfolder='/Users/mplome/Desktop/HOPE/ET'; %MO

raw= '/Users/mplome/Desktop/balanced/EEG_preprocessed'; % path to preprocessed eeg files
etfolder='/Users/mplome/Desktop/balanced/ET'; %MO

d=dir(raw) %what folders are in there (each folder = one subject)

d(1:3)=[] % get rid of the . and .. folders as well as .DS_Store on mac

OLD_OR_YOUNG = {'old', 'yng'};
%data_pro_old = {};
%data_pro_yng = {};
data_pro_right_old = {};
data_pro_right_yng = {};
data_anti_left_old = {};
data_anti_left_yng = {};
data_pro_left_old = {};
data_pro_left_yng = {};
data_anti_right_old = {};
data_anti_right_yng = {};


x = [0.1, 0.2, 0.3];
for k=1:length(x)
    %eval(['data2_pro_old_' num2str(x(k)*1000) ' = {}']);
    %eval(['data2_pro_yng_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_pro_right_old_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_pro_right_yng_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_anti_left_old_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_anti_left_yng_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_pro_left_old_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_pro_left_yng_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_anti_right_old_' num2str(x(k)*1000) ' = {}']);
    eval(['data2_anti_right_yng_' num2str(x(k)*1000) ' = {}']);
end

% for loop to generate data
for i=1:length(d) %loop over all subjects
    if d(i).isdir
        subjectfolder=dir([d(i).folder filesep d(i).name  ]);
        
        deleteindex=[];
        for ii=1:length(subjectfolder)
            if not(endsWith(subjectfolder(ii).name, '_EEG.mat')) || startsWith(subjectfolder(ii).name,'bip') || startsWith(subjectfolder(ii).name,'red')
                deleteindex(end+1)=ii;
            end
        end
        subjectfolder(deleteindex)=[];
        FullEEG=[];
        for ii=1:length(subjectfolder)
            load ([subjectfolder(ii).folder filesep subjectfolder(ii).name]) % gets loaded as EEG
            fileindex=subjectfolder(ii).name(end-8) %here you need to find the index from thefile (end-someting) indexing
            etfile=  [etfolder filesep d(i).name filesep d(i).name '_AS' fileindex '_ET.mat'] %define string of the complete path to the matching ET file.
             
             %EEG = pop_reref(EEG,[47 83])
            EEG = pop_reref(EEG,[]) %tu jest wazna sprawa, to reref
            
            
            %merge ET into EEG
            ev1=94 %first trigger of eeg and ET file
            ev2=50 % end trigger in eeg and ET file
            EEG=pop_importeyetracker(EEG, etfile,[ev1 ev2], [1:4], {'TIME' 'L_GAZE_X' 'L_GAZE_Y' 'L_AREA'},1,1,0,0,4)
            %sprawdz pupil size, w razie czego zmien
            if ii==1
                FullEEG=EEG;
            else
                FullEEG=pop_mergeset(FullEEG,EEG);
            end
        end

        if isempty(FullEEG)
            continue
        end
        
        for e = 1:length(FullEEG.event)
            if contains (FullEEG.event(e).type, '40')
                ee = e+1;
                in_circle = -1; total_time = 0; time_in = 0;
                while (ee < length(FullEEG.event))
                    tmpev = FullEEG.event(ee);
                    if contains(tmpev.type, '10') || contains(tmpev.type, '11')
                        break;
                    end
                    if strcmp(tmpev.type, 'L_saccade')
                        if in_circle == -1 && ...
                                tmpev.sac_startpos_x > 380 && ...
                                tmpev.sac_startpos_x < 420 && ...
                                tmpev.sac_startpos_y > 280 && ...
                                tmpev.sac_startpos_y < 320
                            time_in = total_time;
                        end
                        if tmpev.sac_endpos_x > 380 && ...
                                tmpev.sac_endpos_x < 420 && ...
                                tmpev.sac_endpos_y > 280 && ...
                                tmpev.sac_endpos_y < 320 
                            in_circle = 1;
                        else 
                            in_circle = 0;
                        end          
                    elseif strcmp(tmpev.type, 'L_fixation')
                        if in_circle == 1
                            time_in = time_in + tmpev.duration;
                        end
                        total_time = total_time + tmpev.duration;
                    end
                    ee = ee+1;
                end
                if time_in / total_time < 0.8
                    % Bad trial
                    for inv=e:ee
                        FullEEG.event(inv).type = 'INVALID';
                    end
                end
            end
        end
        
        
        
        
        for e = 1:length(FullEEG.event)
            if contains (FullEEG.event(e).type, '41')
                ee = e+1;
                in_circle = -1; total_time = 0; time_in = 0;
                while (ee < length(FullEEG.event))
                    tmpev = FullEEG.event(ee);
                    if contains(tmpev.type, '13') || contains(tmpev.type, '12')
                        break;
                    end
                    if strcmp(tmpev.type, 'L_saccade')
                        if in_circle == -1 && ...
                                tmpev.sac_startpos_x > 380 && ...
                                tmpev.sac_startpos_x < 420 && ...
                                tmpev.sac_startpos_y > 280 && ...
                                tmpev.sac_startpos_y < 320
                            time_in = total_time;
                        end
                        if tmpev.sac_endpos_x > 380 && ...
                                tmpev.sac_endpos_x < 420 && ...
                                tmpev.sac_endpos_y > 280 && ...
                                tmpev.sac_endpos_y < 320 
                            in_circle = 1;
                        else 
                            in_circle = 0;
                        end          
                    elseif strcmp(tmpev.type, 'L_fixation')
                        if in_circle == 1
                            time_in = time_in + tmpev.duration;
                        end
                        total_time = total_time + tmpev.duration;
                    end
                    ee = ee+1;
                end
                if time_in / total_time < 0.8
                    % Bad trial
                    for inv=e:ee
                        FullEEG.event(inv).type = 'INVALID';
                    end
                end
            end
        end
        
        countblocks = 0;
        previous = '';
        for e = 1:length(FullEEG.event)
            if contains (FullEEG.event(e).type,'94')
                countblocks = countblocks+1;
            end
            if countblocks == 2 || countblocks == 3 || countblocks == 4
                if contains (FullEEG.event(e).type,'10')
                    FullEEG.event(e).type = '12 ';
                elseif contains (FullEEG.event(e).type,'11')
                    FullEEG.event(e).type = '13 ';
               
                end
                if contains (FullEEG.event(e).type,'40') 
                    FullEEG.event(e).type = '41 ';
                end
            end

            if strcmp(FullEEG.event(e).type, 'L_saccade')
                if contains(previous, '10 ')
                    FullEEG.event(e).type = 'L_saccade_10';
                elseif contains(previous, '11 ')
                    FullEEG.event(e).type = 'L_saccade_11';
                elseif contains(previous, '12 ')
                    FullEEG.event(e).type = 'L_saccade_12';
                elseif contains(previous, '13 ')
                    FullEEG.event(e).type = 'L_saccade_13';
                end             
            end
            
            if ~strcmp(FullEEG.event(e).type, 'L_fixation') ...
                    && ~strcmp(FullEEG.event(e).type, 'L_blink')
                previous = FullEEG.event(e).type;
            end
        end
        
        
        id=d(i).name ;
        young=    any(contains(all_youngIDs,id));
        old =     any(contains(all_oldIDs,id));
        
   
        %young means 1, old means 0
        all_ages(i) =    young;
        all_eeg{i} = FullEEG;


        try
        data_pro_right{i} = my_pop_epoch(FullEEG,'11', 'L_saccade_11');
        data_pro_left{i} = my_pop_epoch(FullEEG,'10', 'L_saccade_10');
        data_anti_right{i} = my_pop_epoch(FullEEG,'13', 'L_saccade_13');
        data_anti_left{i} = my_pop_epoch(FullEEG,'12', 'L_saccade_12');

        data_pro_right{i} = TransformData(data_pro_right{i});
        data_pro_left{i} = TransformData(data_pro_left{i});
        data_anti_right{i} = TransformData(data_anti_right{i});
        data_anti_left{i} = TransformData(data_anti_left{i});
        
        data_pro_right{i} = BinnedData(data_pro_right{i}, 10);
        data_pro_left{i} = BinnedData(data_pro_left{i}, 10);
        data_anti_right{i} = BinnedData(data_anti_right{i}, 10);
        data_anti_left{i} = BinnedData(data_anti_left{i}, 10);
        
      
        eval(['data_pro_right_' OLD_OR_YOUNG{young+1} '{end+1} = data_pro_right{i}']);
        eval(['data_pro_left_' OLD_OR_YOUNG{young+1} '{end+1} = data_pro_left{i}'])
        eval(['data_anti_right_' OLD_OR_YOUNG{young+1} '{end+1} = data_anti_right{i}']);
        eval(['data_anti_left_' OLD_OR_YOUNG{young+1} '{end+1} = data_anti_left{i}']);

        for k=1:length(x)
            suffix = num2str(x(k)*1000);
            eval(['data2_pro_right_' suffix '{i} = pop_epoch(FullEEG, {"L_saccade_11"}, [-x(k),0])']);
            eval(['data2_pro_right_' OLD_OR_YOUNG{young+1} '_' suffix '{end+1} = data2_pro_right_' suffix '{i}']);
            
            eval(['data2_pro_left_' suffix '{i} = pop_epoch(FullEEG, {"L_saccade_10"}, [-x(k),0])']);
            eval(['data2_pro_left_' OLD_OR_YOUNG{young+1} '_' suffix '{end+1} = data2_pro_left_' suffix '{i}']);
            
            eval(['data2_anti_right_' suffix '{i} = pop_epoch(FullEEG, {"L_saccade_13"}, [-x(k),0])']);
            eval(['data2_anti_right_' OLD_OR_YOUNG{young+1} '_' suffix '{end+1} = data2_anti_right_' suffix '{i}']);
            
            eval(['data2_anti_left_' suffix '{i} = pop_epoch(FullEEG, {"L_saccade_12"}, [-x(k),0])']);
            eval(['data2_anti_left_' OLD_OR_YOUNG{young+1} '_' suffix '{end+1} = data2_anti_left_' suffix '{i}']);
        end

        catch
        end
        
    end
end