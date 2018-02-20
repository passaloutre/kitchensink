% script for plotting ctd profiles

% user input file
[fnxls,pnxls]=uigetfile('*.xls*','Select XLS file log.');
[~,sheets]=xlsfinfo(fullfile(pnxls,fnxls));
%%

% initialize figure and subplots
close('all')
fig1 = figure('Position', [100 100 1240 600]);
salsub = gobjects(length(sheets));
temsub = gobjects(length(sheets));

for j=1:length(sheets)
    g=loadxls_struct(fullfile(pnxls,fnxls),sheets{j}); % load data
    [x,i] = max(g.Depth_M); % use only first half of cast (downcast)
    [tmp,ind] = sort(g.Depth_M); % get indices of sorted-by depth
    depsort = g.Depth_M(ind); % sort depth by depth
    salsort = g.Sal_PPT(ind); % sort salinity by depth
    temsort = g.Temp_C(ind); % sort temp by depth
    
    salsub(j) = subplot(1,length(sheets),j); % new subplot
    salplot = plot(g.Sal_PPT(1:i),g.Depth_M(1:i),'-'); hold on % plot salinity
    %     salplot = plot(salsort,depsort,'b-'); % uncomment to plot all sal data (downcast and upcast)
    set(salsub(j),'Ydir','reverse') % flip y axis
    if j == ceil(length(sheets)/2); xlabel('Salinity [PSU]'); % label x only middle subplot
    else xlabel('     '); end
    if j == 1; ylabel('Depth [m]'); end % label y only first subplot
    
    temsub(j) = axes('Position',salsub(j).Position); % temp subplot on top of salinity
    blankplot = plot(0, 0, '-','Parent',temsub(j)); hold on
    templot = plot(g.Temp_C(1:i),g.Depth_M(1:i),'-','Parent',temsub(j)); % plot temperature
    %     templot = plot(temsort,depsort,'r-','Parent',temsub(j)); uncomment to plot all temp data (downcast and upcast)
    set(temsub(j),'Ydir','reverse','Color','None',...
        'XAxisLocation','top','YAxisLocation','right',...
        'YTickLabel',''); % various properties
    
    if j == ceil(length(sheets)/2); xlabel('Temperature [°C]'); % label x only middle subplot
    else xlabel('     '); end
    
    title_string = strsplit(g.sheet,'_'); % get title text from data
    title(title_string{1}) % show title
    h = legend([salplot;templot],{'Sal','Temp'},'Location','south');
    
    % these lines make room at the top for the title because the xaxis
    % label pushes it out of the way
    subpos = get(temsub(j),'Position');
    newpos = subpos .*[1 1 1 0.9]; % setting the subplot height to 90% of what it was
    set(salsub(j),'Position',newpos)
    set(temsub(j),'Position',newpos)
    
    grid
end

linkaxes([salsub temsub],'xy') % make all axis limits the same

