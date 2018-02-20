% read sontek castaway data into matlab struct named dat
% ramirez 20161213

% uncomment next two lines for manual path and file entry
% pn = 'E:\Projects\SaltWedge\CastAway\';
% fn = 'CC1533011_20161206_140716.csv';

[fn, pn] = uigetfile('*.csv','Select Castaway Data File');
pnfn = [pn fn]

fid = fopen(pnfn); % open the file

first_char = true; % expect first character to be %

while first_char
    raw = fgetl(fid); % read line by line to variable named raw
    if length(raw) < 3 % test for blank line at end of header
        continue
    end
    if strcmp(raw(1), '%') % still in header, extract name and value
        % generate header names, make them legal
        tmp(1:2) = strsplit(raw,','); % split line at comma
        tmp{1}(1:2) = ''; % remove first two characters: '% '
        % remove parentheses, change space to underscore
        tmp{1}((tmp{1} == '(') | (tmp{1} == ')')) = ''; tmp{1}(tmp{1} == ' ') = '_';
        
        % see if value is a date
        isdate = false;
        try datetime(tmp{2}); isdate = true; end
        
        % see if value is a double
        if ~isnan(str2double(tmp{2}))
            % if double, record it as double
            dat.hdr.(tmp{1}) = str2double(tmp{2});
            
        elseif isdate
            % if date, record it as date
            dat.hdr.(tmp{1}) = datetime(tmp{2});
        else
            % the rest will be char arrays
            dat.hdr.(tmp{1}) = tmp{2};
        end
        
    else % no longer in header, in variable names
        raw(raw=='(' | raw==')')=''; raw(raw==' ')='_'; %making legal variable names
        var_names = strsplit(raw,',');
        first_char = false;
    end
end

% now that we're out of the header, read the rest of the file as csv
raw_body = textscan(fid,repmat('%f',size(var_names)),'Delimiter',',');
fclose(fid);

% record variable columns as arrays of doubles
for i= 1:length(var_names)
    dat.(var_names{i}) =  raw_body{i};
end
