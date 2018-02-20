%script to extract filenames for PICS analysis

%% 
dirs=dir(pwd);
names={dirs.name}';
in=cat(1,dirs.isdir) & ~cellfun(@isempty,regexp(names,'\w','once'));
dirs=dirs(in);

for k=1:length(dirs)
    files=dir(fullfile(dirs(k).name,'ptv_*.mat'));
    fid=fopen(sprintf('files_%s.csv',dirs(k).name),'wt');
    for n=1:length(files)
        ptvfile=files(n).name;
        pivfile=strrep(ptvfile,'ptv_','piv_');
        fprintf(fid,'%s,%s,%s\n',ptvfile,pivfile,[dirs(k).name,char(96+n)]);
    end
    fclose(fid);
end
