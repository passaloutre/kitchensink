% read sontek castaway data into matlab struct named dat

% pn = 'E:\Projects\SaltWedge\CastAway\';
% fn = 'CC1533011_20161206_140716.csv';
[fn, pn] = uigetfile('*.csv','Select Castaway Data File');
pnfn = fullfile(pn, fn);

fid = fopen(pnfn);

first_char = true;

while first_char
    raw = fgetl(fid);
    if length(raw) < 3
        continue
    end        
    if strcmp(raw(1), '%')
        % still in header, extract variable and value
        tmp(1:2) = strsplit(raw,',');
        tmp{1}(1:2) = '';
        tmp{1}((tmp{1} == '(') | (tmp{1} == ')')) = ''; tmp{1}(tmp{1} == ' ') = '_';
        
        isdate = false;
        try datetime(tmp{2}); isdate = true; end
                    
        if ~isnan(str2double(tmp{2}))
            % if double, record it
            dat.hdr.(tmp{1}) = str2double(tmp{2});
        
        elseif isdate
            dat.hdr.(tmp{1}) = datetime(tmp{2});
        else 
            dat.hdr.(tmp{1}) = tmp{2};
            
        end
        
    else
        % no longer in header, in variable names
        raw(raw=='(' | raw==')')=''; raw(raw==' ')='_'; %removing making lega variable names
        var_names = strsplit(raw,',');
        first_char = false;
    end
end

raw_body = textscan(fid,repmat('%f',size(var_names)),'Delimiter',',');
fclose(fid);

% put in loop with all other var names
for i= 1:length(var_names)
    dat.(var_names{i}) =  raw_body{i};
end

% cast = strrep(strsplit(fgetl(fid),','),' ','_');

