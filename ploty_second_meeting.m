%tutaj  sobie porobie ploty starzy with mlodzi razem

%YNG
%pro right
for i=1:length(data_pro_right_yng)%bierze wszysykich mlodych
    erp_pro_right_yng_bin(i,:,:) = mean(data_pro_right_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_pro_right_yng_bin = squeeze(mean(mean(erp_pro_right_yng_bin(:,[19,9,102],:),2),1));

shaded_erp_pro_right_yng_bin = shadedErrorBar(1:size(erp_pro_right_yng_bin,3), groupaverage_erp_pro_right_yng_bin,std(mean(erp_pro_right_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');


%pro left
for i=1:length(data_pro_left_yng)%bierze wszysykich mlodych
    erp_pro_left_yng_bin(i,:,:) = mean(data_pro_left_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_pro_left_yng_bin = squeeze(mean(mean(erp_pro_left_yng_bin(:,[19,9,102],:),2),1));
shaded_erp_pro_left_yng_bin = shadedErrorBar(1:size(erp_pro_left_yng_bin,3), groupaverage_erp_pro_left_yng_bin,std(mean(erp_pro_left_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');


%anti right
for i=1:length(data_anti_right_yng)%bierze wszysykich mlodych
    erp_anti_right_yng_bin(i,:,:) = mean(data_anti_right_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_anti_right_yng_bin = squeeze(mean(mean(erp_anti_right_yng_bin(:,[19,9,102],:),2),1));
shaded_erp_anti_right_yng_bin = shadedErrorBar(1:size(erp_anti_right_yng_bin,3), groupaverage_erp_anti_right_yng_bin,std(mean(erp_anti_right_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

%anti left
for i=1:length(data_anti_left_yng)%bierze wszysykich mlodych
    erp_anti_left_yng_bin(i,:,:) = mean(data_anti_left_yng{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_yng,2);
groupaverage_erp_anti_left_yng_bin = squeeze(mean(mean(erp_anti_left_yng_bin(:,[19,9,102],:),2),1));
shaded_erp_anti_left_yng_bin = shadedErrorBar(1:size(erp_anti_left_yng_bin,3), groupaverage_erp_anti_left_yng_bin,std(mean(erp_anti_left_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');

%OLD

%pro right
for i=1:length(data_pro_right_old)%bierze wszysykich mlodych
    erp_pro_right_old_bin(i,:,:) = mean(data_pro_right_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_pro_right_old_bin = squeeze(mean(mean(erp_pro_right_old_bin(:,[19,9,102],:),2),1));
shaded_erp_pro_right_old_bin = shadedErrorBar(1:size(erp_pro_right_old_bin,3), groupaverage_erp_pro_right_old_bin,std(mean(erp_pro_right_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');


%pro left
for i=1:length(data_pro_left_old)%bierze wszysykich mlodych
    erp_pro_left_old_bin(i,:,:) = mean(data_pro_left_old{i}.binned_data, 3);
end
nsubj_yng=size(data_anti_left_old,2);
groupaverage_erp_pro_left_old_bin = squeeze(mean(mean(erp_pro_left_old_bin(:,[19,9,102],:),2),1));
shaded_erp_pro_left_old_bin = shadedErrorBar(1:size(erp_pro_left_old_bin,3), groupaverage_erp_pro_left_old_bin,std(mean(erp_pro_left_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');


%anti right
for i=1:length(data_anti_right_old)%bierze wszysykich mlodych
    erp_anti_right_old_bin(i,:,:) = mean(data_anti_right_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_anti_right_old_bin = squeeze(mean(mean(erp_anti_right_old_bin(:,[19,9,102],:),2),1));
shaded_erp_anti_right_old_bin = shadedErrorBar(1:size(erp_anti_right_old_bin,3), groupaverage_erp_anti_right_old_bin,std(mean(erp_anti_right_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');

%anti left
for i=1:length(data_anti_left_old)%bierze wszysykich mlodych
    erp_anti_left_old_bin(i,:,:) = mean(data_anti_left_old{i}.binned_data, 3);
end
nsubj_old=size(data_anti_left_old,2);
groupaverage_erp_anti_left_old_bin = squeeze(mean(mean(erp_anti_left_old_bin(:,[19,9,102],:),2),1));
shaded_erp_anti_left_old_bin = shadedErrorBar(1:size(erp_anti_left_old_bin,3), groupaverage_erp_anti_left_old_bin,std(mean(erp_anti_left_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');


%plots
%% 

figure
subplot(2,2,1)
shaded_erp_pro_right_old_bin = shadedErrorBar(1:size(erp_pro_right_old_bin,3), groupaverage_erp_pro_right_old_bin,std(mean(erp_pro_right_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
shaded_erp_pro_right_yng_bin = shadedErrorBar(1:size(erp_pro_right_yng_bin,3), groupaverage_erp_pro_right_yng_bin,std(mean(erp_pro_right_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'c');
legend({'old', 'yng'})
title ('PRO RIGHT')
hold off



subplot(2,2,2)
shaded_erp_pro_left_old_bin = shadedErrorBar(1:size(erp_pro_left_old_bin,3), groupaverage_erp_pro_left_old_bin,std(mean(erp_pro_left_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
shaded_erp_pro_left_yng_bin = shadedErrorBar(1:size(erp_pro_left_yng_bin,3), groupaverage_erp_pro_left_yng_bin,std(mean(erp_pro_left_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'c');
legend({'old', 'yng'})
title ('PRO LEFT')
hold off



subplot(2,2,3)
shaded_erp_anti_left_old_bin = shadedErrorBar(1:size(erp_anti_left_old_bin,3), groupaverage_erp_anti_left_old_bin,std(mean(erp_anti_left_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
shaded_erp_anti_left_yng_bin = shadedErrorBar(1:size(erp_anti_left_yng_bin,3), groupaverage_erp_anti_left_yng_bin,std(mean(erp_anti_left_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'm');
legend({'old', 'yng'})
title ('ANTI LEFT')
hold off


subplot(2,2,4)
shaded_erp_anti_right_old_bin = shadedErrorBar(1:size(erp_anti_right_old_bin,3), groupaverage_erp_anti_right_old_bin,std(mean(erp_anti_right_old_bin(:,[19,9,102],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
shaded_erp_anti_right_yng_bin = shadedErrorBar(1:size(erp_anti_right_yng_bin,3), groupaverage_erp_anti_right_yng_bin,std(mean(erp_anti_right_yng_bin(:,[19,9,102],:),2))/sqrt(nsubj_yng) ,'lineprops', 'm');
legend({'old', 'yng'})
title ('ANTI RIGHT')
hold off


% %old
% shaded_erp_anti_left_old_bin = shadedErrorBar(1:size(erp_anti_left_old_bin,3), groupaverage_erp_anti_left_old_bin,std(mean(erp_anti_left_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
% shaded_erp_anti_right_old_bin = shadedErrorBar(1:size(erp_anti_right_old_bin,3), groupaverage_erp_anti_right_old_bin,std(mean(erp_anti_right_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'r');
% shaded_erp_pro_left_old_bin = shadedErrorBar(1:size(erp_pro_left_old_bin,3), groupaverage_erp_pro_left_old_bin,std(mean(erp_pro_left_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
% shaded_erp_pro_right_old_bin = shadedErrorBar(1:size(erp_pro_right_old_bin,3), groupaverage_erp_pro_right_old_bin,std(mean(erp_pro_right_old_bin(:,[19,9,104],:),2))/sqrt(nsubj_old) ,'lineprops', 'b');
% 
% %yng
% shaded_erp_anti_left_yng_bin = shadedErrorBar(1:size(erp_anti_left_yng_bin,3), groupaverage_erp_anti_left_yng_bin,std(mean(erp_anti_left_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
% shaded_erp_anti_right_yng_bin = shadedErrorBar(1:size(erp_anti_right_yng_bin,3), groupaverage_erp_anti_right_yng_bin,std(mean(erp_anti_right_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'r');
% shaded_erp_pro_right_yng_bin = shadedErrorBar(1:size(erp_pro_right_yng_bin,3), groupaverage_erp_pro_right_yng_bin,std(mean(erp_pro_right_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');
% shaded_erp_pro_left_yng_bin = shadedErrorBar(1:size(erp_pro_left_yng_bin,3), groupaverage_erp_pro_left_yng_bin,std(mean(erp_pro_left_yng_bin(:,[19,9,104],:),2))/sqrt(nsubj_yng) ,'lineprops', 'b');


