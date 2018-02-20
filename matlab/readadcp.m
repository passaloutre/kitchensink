% for loading stationary adcp files and storing in .mat file for backscatter processing
% the excel file contains a list of stations, adcp files, and file paths

%%
% [fn,pn] = uigetfile('*.xlsx','Select file for loading.');
fn = 'adcp_files.xlsx';
pn = 'E:\Projects\SaltWedge\';
[~,sheets] = xlsfinfo(fullfile(pn, fn));

for i = 2:length(sheets) % loop through sheets
    s = loadxls_struct(fn, sheets{i});
    stations = unique(s.RM,'stable'); % get station list, don't sort
    files = unique([s.L2R, s.R2L],'stable'); % get file list, don't sort
    paths = repmat(unique(s.Path,'stable'),length(files),1); % get paths
    for j = 1:length(files) % loop through file list
        infile = sprintf('%s\\%s',paths{j},files{j});
        adcp = rdradcp_MTR(infile,1); % read adcp data
        outfile = sprintf('%s.mat',strtok(files{j},'.'));
        save(outfile, '-struct', 'adcp'); % save data
    end
end