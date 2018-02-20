% SCRIPT FOR PLOTTING LISST ASCII DATA 
close('all')
clear

%% USER INPUTS

% read names and paths of lisst .asc files from excel table
% the excel table has three columns: stationname, filename, filepath
infofile = 'E:\Projects\Saltwedge\lisst_files.xlsx'; % excel table
sheet = '2015hydro_reduced'; % which sheet to load from excel file
info = loadxls_struct(infofile,sheet); % get info

%%
salfile = 'E:\Projects\SaltWedge\ctd\2015_sal.xlsx';
[~, salsheets] = xlsfinfo(salfile);
for i = 1:length(salsheets)
    sal(i) = loadxls_struct(salfile,salsheets{i});
end
%%
lissttype    = 'c'; % b, c, or d
binlimit     = 32;  % cut off particle bins above this limit (1-32)
toplimit     = 0.5; % cut off samples shallower than
vclimit      = 100; % hard limit on volume concentration within bins
normalize_vc = 1;   % normalize vol conc to sum of vc at that depth

dz           = 2.0; % interval for depth binning
dzz          = 0.1; % interval for depth interpolation

%% processing
[b,ind] = sort(info.name); % get order of river miles (not order of files)
deepest = 0; % preallocate
lightest = 1; % preallocate
heaviest = 0; % preallocate

fig11 = figure('position',[10 50 200*length(info.file) 600]);
ax = gobjects(length(info.file)); %preallocate axes objects

for j =1:length(info.name) % j indexes the 1 through the number of files
    i = ind(j); % i indexes the river miles in order
    
    % load data
    fn = info.file{i};
    pn = info.path{i};
    dat = load_lisstasc(fullfile(pn,fn),lissttype);
    
    % binning and averaging
    for k=1:length(dat.d)
        [dat.newz,dat.newvc(:,k)] = binData(dat.pressure,dat.vc(:,k),dz,dzz);
    end
    
    % binning salinity
    [sal(j).newz,sal(j).news] = binData(sal(j).z,sal(j).s,dz,dzz);
    
    % thresholds
    dat.newvc(dat.newvc > vclimit) = vclimit;
    dat.newvc(dat.newvc < 0) = 0;
    dat.newvc(dat.newz < toplimit,:) = 0;
    
    % normalize volume concentrations
    if normalize_vc == 1
        dat.normc = zeros(size(dat.newvc));
        binsize = diff(dat.dbins);
        for k=1:length(dat.newz)
            for l = 1:length(dat.d)
                dat.normc(k,l) = dat.newvc(k,l)/sum(dat.newvc(k,:));
            end
        end
        dat.newvc = dat.normc;
    end
    
    % keep track of statistics from each file
    deepest = max([deepest max(dat.pressure(:))]);
    lightest = min([lightest min(dat.newvc(:))]);
    heaviest = max([heaviest max(dat.newvc(:))]);
    
    %plotting
    ax(j) = subplot(1,length(info.file),j);
    colormap('jet')
    h = pcolor(dat.d(1:binlimit),-dat.newz,dat.newvc(:,1:binlimit));
    set(h,'edgecolor','none')
    ylabel('Depth, m')
    xlabel(sprintf('Diameter, %sm',char(181)))
    title(sprintf('%s) %s',char(j+64),upper(info.name{i})))
    set(gca,'XScale','log')
    set(gca,'XTick',[4 16 64 256])
    hold on

    plot(sal(j).news,-sal(j).newz,'w-','LineWidth',2);
end

% reconfigure all subplots to same axes
for i = 1:length(ax)
    ax(i).YLim = [-deepest 0];
    caxis(ax(i),[lightest 0.5*heaviest]);
end

%% add colorbar
c = colorbar();
% label colorbar
if normalize_vc == 1
    c.Label.String = sprintf('Normalized Concentration',char(181));
elseif normalize_vc == 0
    c.Label.String = sprintf('Volume Conc. %sL/L',char(181));
end
c.Position = [0.92 0.11 .01 0.815];

