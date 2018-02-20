%strip all punctuation and spaces from field names

pn = 'E:\Projects\LISST\LISST2015';
dirinfo = dir(sprintf('%s\\*.csv',pn));

% i = 1;

for i=1:length(dirinfo)
    dat = readtable(sprintf('%s\\%s',pn,dirinfo(i).name));
    
    outfile = strcat(pn,'\for_lissting\',strtok(dirinfo(i).name,'.'),'.xlsx');
%     writetable(dat,outfile);
% xlswrite(outfile,dat);
end