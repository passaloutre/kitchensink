clear;
close('all');
data = readtable('/mnt/data/Projects/diss/belle_chasse/bc_cms.txt',...
    'Format','%{yyyy-MM-dd}D %f');

dates = table2array(data(:,1));
cms = table2array(data(:,2));


hydro = struct('dt',dates,'q',cms);