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
             
             EEG = pop_reref(EEG,[47 83])
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

%% NEW bins! %%

%YNG
%pro right
for i=1:length(data_pro_right_yng)%bierze wszysykich mlodych
    erp_pro_right_yng_bin(i,:,:) = mean(data_pro_right_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_pro_right_yng_bin = squeeze(mean(mean(erp_pro_right_yng_bin(:,[19,9,104],:),2),1));
shaded_erp_pro_right_yng_bin = shadedErrorBar(1:size(erp_pro_right_yng_bin,3), groupaverage_erp_pro_right_yng_bin,std(mean(erp_pro_right_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');


%pro left
for i=1:length(data_pro_left_yng)%bierze wszysykich mlodych
    erp_pro_left_yng_bin(i,:,:) = mean(data_pro_left_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_pro_left_yng_bin = squeeze(mean(mean(erp_pro_left_yng_bin(:,[19,9,104],:),2),1));
shaded_erp_pro_left_yng_bin = shadedErrorBar(1:size(erp_pro_left_yng_bin,3), groupaverage_erp_pro_left_yng_bin,std(mean(erp_pro_left_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');


%anti right
for i=1:length(data_anti_right_yng)%bierze wszysykich mlodych
    erp_anti_right_yng_bin(i,:,:) = mean(data_anti_right_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_anti_right_yng_bin = squeeze(mean(mean(erp_anti_right_yng_bin(:,[19,9,104],:),2),1));
shaded_erp_anti_right_yng_bin = shadedErrorBar(1:size(erp_anti_right_yng_bin,3), groupaverage_erp_anti_right_yng_bin,std(mean(erp_anti_right_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

%anti left
for i=1:length(data_anti_left_yng)%bierze wszysykich mlodych
    erp_anti_left_yng_bin(i,:,:) = mean(data_anti_left_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_anti_left_yng_bin = squeeze(mean(mean(erp_anti_left_yng_bin(:,[19,9,104],:),2),1));
shaded_erp_anti_left_yng_bin = shadedErrorBar(1:size(erp_anti_left_yng_bin,3), groupaverage_erp_anti_left_yng_bin,std(mean(erp_anti_left_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

%OLD

%pro right
for i=1:length(data_pro_right_old)%bierze wszysykich mlodych
    erp_pro_right_old_bin(i,:,:) = mean(data_pro_right_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_pro_right_old_bin = squeeze(mean(mean(erp_pro_right_old_bin(:,[19,9,104],:),2),1));
shaded_erp_pro_right_old_bin = shadedErrorBar(1:size(erp_pro_right_old_bin,3), groupaverage_erp_pro_right_old_bin,std(mean(erp_pro_right_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');


%pro left
for i=1:length(data_pro_left_old)%bierze wszysykich mlodych
    erp_pro_left_old_bin(i,:,:) = mean(data_pro_left_old{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_old,2);
groupaverage_erp_pro_left_old_bin = squeeze(mean(mean(erp_pro_left_old_bin(:,[19,9,104],:),2),1));
shaded_erp_pro_left_old_bin = shadedErrorBar(1:size(erp_pro_left_old_bin,3), groupaverage_erp_pro_left_old_bin,std(mean(erp_pro_left_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');


%anti right
for i=1:length(data_anti_right_old)%bierze wszysykich mlodych
    erp_anti_right_old_bin(i,:,:) = mean(data_anti_right_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_anti_right_old_bin = squeeze(mean(mean(erp_anti_right_old_bin(:,[19,9,104],:),2),1));
shaded_erp_anti_right_old_bin = shadedErrorBar(1:size(erp_anti_right_old_bin,3), groupaverage_erp_anti_right_old_bin,std(mean(erp_anti_right_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

%anti left
for i=1:length(data_anti_left_old)%bierze wszysykich mlodych
    erp_anti_left_old_bin(i,:,:) = mean(data_anti_left_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_anti_left_old_bin = squeeze(mean(mean(erp_anti_left_old_bin(:,[19,9,104],:),2),1));
shaded_erp_anti_left_old_bin = shadedErrorBar(1:size(erp_anti_left_old_bin,3), groupaverage_erp_anti_left_old_bin,std(mean(erp_anti_left_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

%% Koniec %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% young

%anti right
min_len = inf;
for i=1:length(data_anti_right_yng)
    min_len = min(min_len, data_anti_right_yng{i}.min_trial);
end

tab_anti_right_yng = zeros(data_anti_right_yng{1}.nbchan, min_len, 0);
for i=1:length(data_anti_right_yng)%bierze wszysykich mlodych
    tab_anti_right_yng = cat(3, tab_anti_right_yng,data_anti_right_yng{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_anti_right_yng(i,:,:) = mean(data_anti_right_yng{i}.suffix_data(:,end - min_len +1:end,:),3);
    % Zamien "1:min_len" na "min_len+1:end"
end

%anti left
min_len = inf;
for i=1:length(data_anti_left_yng)
    min_len = min(min_len, data_anti_left_yng{i}.min_trial);
end

tab_anti_left_yng = zeros(data_anti_left_yng{1}.nbchan, min_len, 0);
for i=1:length(data_anti_left_yng)%bierze wszysykich mlodych
    tab_anti_left_yng = cat(3, tab_anti_left_yng,data_anti_left_yng{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_anti_left_yng(i,:,:) = mean(data_anti_left_yng{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%pro left
min_len = inf;
for i=1:length(data_pro_left_yng)
    min_len = min(min_len, data_pro_left_yng{i}.min_trial);
end

tab_pro_left_yng = zeros(data_pro_left_yng{1}.nbchan, min_len, 0);
for i=1:length(data_pro_left_yng)%bierze wszysykich mlodych
    tab_pro_left_yng = cat(3, tab_pro_left_yng,data_pro_left_yng{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_pro_left_yng(i,:,:) = mean(data_pro_left_yng{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%pro right
min_len = inf;
for i=1:length(data_pro_right_yng)
    min_len = min(min_len, data_pro_right_yng{i}.min_trial);
end

tab_pro_right_yng= zeros(data_pro_right_yng{1}.nbchan, min_len, 0);
for i=1:length(data_pro_right_yng)%bierze wszysykich mlodych
    tab_pro_right_yng= cat(3, tab_pro_right_yng,data_pro_right_yng{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_pro_right_yng(i,:,:) = mean(data_pro_right_yng{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%old
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%anti right

min_len = inf;
for i=1:length(data_anti_right_old)
    min_len = min(min_len, data_anti_right_old{i}.min_trial);
end

tab_anti_right_old = zeros(data_anti_right_old{1}.nbchan, min_len, 0);
for i=1:length(data_anti_right_old)%bierze wszysykich mlodych
    tab_anti_right_old = cat(3, tab_anti_right_old,data_anti_right_old{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_anti_right_old(i,:,:) = mean(data_anti_right_old{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%anti left
min_len = inf;
for i=1:length(data_anti_left_old)
    min_len = min(min_len, data_anti_left_old{i}.min_trial);
end

tab_anti_left_old = zeros(data_anti_left_old{1}.nbchan, min_len, 0);
for i=1:length(data_anti_left_old)%bierze wszysykich mlodych
    tab_anti_left_old = cat(3, tab_anti_left_old,data_anti_left_old{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_anti_left_old(i,:,:) = mean(data_anti_left_old{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%pro left
min_len = inf;
for i=1:length(data_pro_left_old)
    min_len = min(min_len, data_pro_left_old{i}.min_trial);
end

tab_pro_left_old = zeros(data_pro_left_old{1}.nbchan, min_len, 0);
for i=1:length(data_pro_left_old)%bierze wszysykich mlodych
    tab_pro_left_old = cat(3, tab_pro_left_old,data_pro_left_old{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
    erp_pro_left_old(i,:,:) = mean(data_pro_left_old{i}.suffix_data(:,end - min_len +1:end,:),3);
end

%pro right
min_len = inf;
for i=1:length(data_pro_right_old)
    min_len = min(min_len, data_pro_right_old{i}.min_trial);
end

tab_pro_right_old= zeros(data_pro_right_old{1}.nbchan, min_len, 0);
for i=1:length(data_pro_right_old)%bierze wszysykich mlodych
   tab_pro_right_old= cat(3, tab_pro_right_old,data_pro_right_old{i}.suffix_data(:,end - min_len +1:end,:));%po 3 wymiarzxe laczy- 3 wymiar to sa triale
   erp_pro_right_old(i,:,:) = mean(data_pro_right_old{i}.suffix_data(:,end - min_len +1:end,:),3);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%% średnie po kanałach
mean_channel_activity_pro_left_yng = mean(mean(tab_pro_left_yng([9 94 102], :, :),3),1);

mean_channel_activity_pro_left_old = mean(mean(tab_pro_left_old([9 94 102], :, :),3),1);

mean_channel_activity_anti_left_yng = mean(mean(tab_anti_left_yng([9 94 102], :, :),3),1);

mean_channel_activity_anti_left_old = mean(mean(tab_anti_left_old([9 94 102], :, :),3),1);

mean_channel_activity_pro_right_yng = mean(mean(tab_pro_right_yng([9 94 102], :, :),3),1);

mean_channel_activity_pro_right_old = mean(mean(tab_pro_right_old([9 94 102], :, :),3),1);

mean_channel_activity_anti_right_yng = mean(mean(tab_anti_right_yng([9 94 102], :, :),3),1);

mean_channel_activity_anti_right_old = mean(mean(tab_anti_right_old([9 94 102], :, :),3),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%tutaj jeszcze to shaded gowno
%first do the loop over the subjects, then czalcultate erp for each of
nsubj_old=size(data_anti_left_old,2)
nsubj_yng=size(data_anti_left_yng,2)

%%%%%%%%YOUNG GROUP, group averages
groupaverage_erp_pro_right_yng = squeeze(mean(mean(erp_pro_right_yng(:,[19,9,102],:),2),1));
shaded_erp_pro_right_yng = shadedErrorBar(1:size(erp_pro_right_yng,3), groupaverage_erp_pro_right_yng,std(mean(erp_pro_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

groupaverage_erp_anti_right_yng = squeeze(mean(mean(erp_anti_right_yng(:,[19,9,102],:),2),1));
shaded_erp_anti_right_yng = shadedErrorBar(1:size(erp_anti_right_yng,3), groupaverage_erp_anti_right_yng,std(mean(erp_anti_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

groupaverage_erp_pro_left_yng = squeeze(mean(mean(erp_pro_left_yng(:,[19,9,102],:),2),1));
shaded_erp_pro_left_yng = shadedErrorBar(1:size(erp_pro_left_yng,3), groupaverage_erp_pro_left_yng,std(mean(erp_pro_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

groupaverage_erp_anti_left_yng = squeeze(mean(mean(erp_anti_left_yng(:,[19,9,102],:),2),1));
shaded_erp_anti_left_yng = shadedErrorBar(1:size(erp_anti_left_yng,3), groupaverage_erp_anti_left_yng,std(mean(erp_anti_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
%%%%%%%%%%%%%%%%%%OLD PEOPLE, group averages
groupaverage_erp_pro_right_old = squeeze(mean(mean(erp_pro_right_old(:,[19,9,102],:),2),1));
shadedErrorBar(1:size(erp_pro_right_old,3), groupaverage_erp_pro_right_old,std(mean(erp_pro_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

groupaverage_erp_anti_right_old = squeeze(mean(mean(erp_anti_right_old(:,[19,9,102],:),2),1));
shadedErrorBar(1:size(erp_anti_right_old,3), groupaverage_erp_anti_right_old,std(mean(erp_anti_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

groupaverage_erp_pro_left_old = squeeze(mean(mean(erp_pro_left_old(:,[19,9,102],:),2),1));
shadedErrorBar(1:size(erp_pro_left_old,3), groupaverage_erp_pro_left_old,std(mean(erp_pro_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

groupaverage_erp_anti_left_old = squeeze(mean(mean(erp_anti_left_old(:,[19,9,102],:),2),1));
shadedErrorBar(1:size(erp_anti_left_old,3), groupaverage_erp_anti_left_old,std(mean(erp_anti_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%PLOTS%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(2,2,1)
shadedErrorBar(1:size(erp_pro_right_old,3), groupaverage_erp_pro_right_old,std(mean(erp_pro_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
hold on
shadedErrorBar(1:size(erp_pro_right_yng,3), groupaverage_erp_pro_right_yng,std(mean(erp_pro_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
legend({'old', 'yng'})
title ('PRO RIGHT')
hold off

subplot(2,2,3)
shadedErrorBar(1:size(erp_anti_right_old,3), groupaverage_erp_anti_right_old,std(mean(erp_anti_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
hold on
shadedErrorBar(1:size(erp_anti_right_yng,3), groupaverage_erp_anti_right_yng,std(mean(erp_anti_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
legend({'old', 'yng'})
title ('ANTI RIGHT')
hold off

subplot(2,2,4)
shadedErrorBar(1:size(erp_anti_left_old,3), groupaverage_erp_anti_left_old,std(mean(erp_anti_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
hold on
shadedErrorBar(1:size(erp_anti_left_yng,3), groupaverage_erp_anti_left_yng,std(mean(erp_anti_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
legend({'old', 'yng'})
title ('ANTI LEFT')
hold off


subplot(2,2,2)
shadedErrorBar(1:size(erp_pro_left_old,3), groupaverage_erp_pro_left_old,std(mean(erp_pro_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
hold on
shadedErrorBar(1:size(erp_pro_right_yng,3), groupaverage_erp_pro_left_yng,std(mean(erp_pro_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
legend({'old', 'yng'})
title ('PRO LEFT')
hold off
sgtitle('Old Group vs Young Group')

%%



%%

%yng
group_full_erp_pro_right_yng = squeeze(mean(erp_pro_right_yng,1));
group_full_erp_pro_left_yng = squeeze(mean(erp_pro_left_yng,1));
group_full_erp_anti_right_yng = squeeze(mean(erp_anti_right_yng,1));
group_full_erp_anti_left_yng = squeeze(mean(erp_anti_left_yng,1));

%old
group_full_erp_pro_right_old = squeeze(mean(erp_pro_right_old,1));
group_full_erp_pro_left_old = squeeze(mean(erp_pro_left_old,1));
group_full_erp_anti_right_old = squeeze(mean(erp_anti_right_old,1));
group_full_erp_anti_left_old = squeeze(mean(erp_anti_left_old,1));


timepoint=130

figure
subplot(421)
topoplot(group_full_erp_pro_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO right yng, tp=' num2str(timepoint)] )
subplot(422)
topoplot(group_full_erp_pro_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO left yng, tp=' num2str(timepoint)] )


subplot(425)
topoplot(group_full_erp_anti_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI right yng, tp=' num2str(timepoint)] )
subplot(426)
topoplot(group_full_erp_anti_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI left yng, tp=' num2str(timepoint)] )


subplot(423)
topoplot(group_full_erp_pro_right_old(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO right old, tp=' num2str(timepoint)] )

subplot(424)
topoplot(group_full_erp_pro_left_old(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO left old, tp=' num2str(timepoint)] )


subplot(427)
topoplot(group_full_erp_anti_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI right old, tp=' num2str(timepoint)] )
subplot(428)
topoplot(group_full_erp_anti_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI left old, tp=' num2str(timepoint)] )


%% 

timepoint=130

figure
subplot(421)
topoplot(group_full_erp_pro_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO right yng, tp=' num2str(timepoint)] )
subplot(422)
topoplot(group_full_erp_pro_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO left yng, tp=' num2str(timepoint)] )


subplot(425)
topoplot(group_full_erp_anti_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI right yng, tp=' num2str(timepoint)] )
subplot(426)
topoplot(group_full_erp_anti_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI left yng, tp=' num2str(timepoint)] )


subplot(423)
topoplot(group_full_erp_pro_right_old(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO right old, tp=' num2str(timepoint)] )

subplot(424)
topoplot(group_full_erp_pro_left_old(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['PRO left old, tp=' num2str(timepoint)] )


subplot(427)
topoplot(group_full_erp_anti_right_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI right old, tp=' num2str(timepoint)] )
subplot(428)
topoplot(group_full_erp_anti_left_yng(1:105,timepoint),EEG.chanlocs(1:105),'maplimits',[-3 3])
title (['ANTI left old, tp=' num2str(timepoint)] )
%%

%%
%here an example how to create  an integrative topoplot
figure;
sgtitle('Young, prosaccades left')
timepoint_i = [1:20:200];
for i=1:7
    subplot(3,3,i)
    topoplot(group_full_erp_pro_right_yng(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end

%here an example how to create  an integrative topoplot
figure;
sgtitle('Old, prosaccades left')
timepoint_i = [1:20:200];
for i=1:7
    subplot(3,3,i)
    topoplot(group_full_erp_pro_right_old(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end


figure;
sgtitle('Old, prosaccades right')
timepoint_i = [1:20:200];
for i=1:7
    subplot(3,3,i)
    topoplot(group_full_erp_pro_right_old(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end


%tutaj jest fajna, mocna roznica, musze to pokazac Nicolasowi 
figure;
sgtitle('Old, antisaccades right')
timepoint_i = [1:10:200];
for i=1:12
    subplot(4,3,i)
    topoplot(group_full_erp_anti_right_old(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end

figure;
sgtitle('yng, antisaccades right')
timepoint_i = [1:10:200];
for i=1:12
    subplot(4,3,i)
    topoplot(group_full_erp_anti_right_yng(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end

figure;
sgtitle('Old, antisaccades left')
timepoint_i = [1:10:200];
for i=1:12
    subplot(4,3,i)
    topoplot(group_full_erp_anti_left_old(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end

figure;
sgtitle('yng, antisaccades left')
timepoint_i = [1:10:200];
for i=1:12
    subplot(4,3,i)
    topoplot(group_full_erp_anti_left_yng(1:105,timepoint_i(i)),FullEEG.chanlocs(1:105));colorbar;
    title(timepoint_i(i))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Prosaccades vs Antisaccades%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(2,2,3)
shadedErrorBar(1:size(erp_pro_right_old,3), groupaverage_erp_pro_right_old,std(mean(erp_pro_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_right_old,3), groupaverage_erp_anti_right_old,std(mean(erp_anti_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
legend({'PRO RIGHT', 'ANTI RIGHT'})
title ('PRO RIGHT vs ANTI RIGHT /old group/')
hold off

subplot(2,2,1)
shadedErrorBar(1:size(erp_pro_left_old,3), groupaverage_erp_pro_left_old,std(mean(erp_pro_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_left_old,3), groupaverage_erp_anti_left_old,std(mean(erp_anti_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
legend({'PRO LEFT', 'ANTI LEFT'})
title ('PRO LEFT vs ANTI LEFT  /old group/')
hold off

subplot(2,2,4)
shadedErrorBar(1:size(erp_pro_right_yng,3), groupaverage_erp_pro_right_yng,std(mean(erp_pro_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng),'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_right_yng,3), groupaverage_erp_anti_right_yng,std(mean(erp_anti_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
legend({'PRO RIGHT', 'ANTI RIGHT'})
title ('PRO RIGHT vs ANTI RIGHT /young group/')
hold off


subplot(2,2,2)
shadedErrorBar(1:size(erp_pro_left_yng,3), groupaverage_erp_pro_left_yng,std(mean(erp_pro_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_left_yng,3), groupaverage_erp_anti_left_yng,std(mean(erp_anti_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
legend({'PRO LEFT', 'ANTI LEFT'})
title ('PRO LEFT vs ANTI LEFT /young group/')
hold off
sgtitle('Prosaccades vs Antisaccades')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prosaccades vs Antisaccades  V2 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(2,2,1)
shadedErrorBar(1:size(erp_pro_left_old,3), groupaverage_erp_pro_left_old,std(mean(erp_pro_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_right_old,3), groupaverage_erp_anti_right_old,std(mean(erp_anti_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
legend({'PRO LEFT', 'ANTI RIGHT'})
title ('PRO LEFT vs ANTI RIGHT /old group/')
hold off

subplot(2,2,3)
shadedErrorBar(1:size(erp_pro_right_old,3), groupaverage_erp_pro_right_old,std(mean(erp_pro_right_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_left_old,3), groupaverage_erp_anti_left_old,std(mean(erp_anti_left_old(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
legend({'PRO RIGHT', 'ANTI LEFT'})
title ('PRO RIGHT vs ANTI LEFT  /old group/')
hold off

subplot(2,2,4)
shadedErrorBar(1:size(erp_pro_left_yng,3), groupaverage_erp_pro_left_yng,std(mean(erp_pro_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_right_yng,3), groupaverage_erp_anti_right_yng,std(mean(erp_anti_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
legend({'PRO LEFT', 'ANTI RIGHT'})
title ('PRO LEFT vs ANTI RIGHT /young group/')
hold off

subplot(2,2,2)
shadedErrorBar(1:size(erp_pro_right_yng,3), groupaverage_erp_pro_right_yng,std(mean(erp_pro_right_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
hold on
shadedErrorBar(1:size(erp_anti_left_yng,3), groupaverage_erp_anti_left_yng,std(mean(erp_anti_left_yng(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
legend({'PRO RIGHT', 'ANTI LEFT'})
title ('PRO RIGHT vs ANTI LEFT  /young group/')
hold off
sgtitle('Prosaccades vs Antisaccades')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%END_PLOTS%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%to tak ma byc, NIE RUSZAC
function [min_val] = MinTrial(EEG)
    min_val = inf;
    for t=1:length(EEG.cell_data)
        min_val = min(min_val, size(EEG.cell_data{t}, 2));
    end
end

function [EEG] = TransformData(EEG)
    EEG.min_trial = MinTrial(EEG);
    EEG.suffix_data = zeros(EEG.nbchan, EEG.min_trial, length(EEG.cell_data));
    for t=1:length(EEG.cell_data)
        trial = EEG.cell_data{t};
        mn = mean(trial(:,1:50), 2);
        EEG.trans_data{t} = trial - mn;
        EEG.suffix_data(:,:,t) = EEG.trans_data{t}(:,end-EEG.min_trial+1:end);
    end
end

function [EEG] = BinnedData(EEG, num_bins)
    for t=1:length(EEG.cell_data)
        trial = EEG.cell_data{t};
        bin_size = floor(size(trial, 2)/num_bins);
        for b=1:num_bins
            bin_start = 1 + bin_size * (b-1);
            bin_end = bin_size * b;
            EEG.binned_data(:,b,t) = mean(EEG.cell_data{t}(:,bin_start:bin_end),2);
        end
    end
end