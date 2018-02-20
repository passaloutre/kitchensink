%% Script for importing adcp ASCII files and calculating shear velocity

% set project_velocity = 1 for dat(j)a WITH SALT WEDGE PRESENT

% Use Winriver II "Classic ASCII Output" backscatter option
% M. Ramirez 2017/03/03
disp('initialize');tic
clear;
close('all') % close existing figures

% path and file names for adcp ASC files
year = '2015';
fprintf('%s...',year)
meta = loadxls_struct('E:\Projects\SaltWedge\lms_ssc_ctd.xlsx',year);
% pn = 'E:\Projects\SaltWedge\2016\ADCP';
% fn = 'SW_068_ASC.TXT';
[stations,ia,ic]  = unique(meta.station,'stable');
fprintf('%d stations...',length(stations))
% options, variables, constants
filter_by_dist = 1; % filter out ensembles greater than 1 sd from mean lat/long
filter_by_depth = 1; % filter out ensembles greater than 1 sd from mean depth
project_velocity = 1; % reproject velocity to streamwise direction

dh = 0.5; % bin increment for binning and interpolation
ddh = 0.5; % interpolation interval for binning and interpolation step

k = 0.4; % von karman constant
%
% ctd = struct([]);
% dat = struct([]);
% out = struct([]);
toc

%% import data
fprintf('\nimport\n');tic
for j=1:length(stations)
    fprintf('%d...',j)
    ctd(j).name = stations{j};
    ctd(j).depth = meta.depth_m(ic == j);
    ctd(j).sal = meta.sal_psu(ic ==j);
    ctd(j).temp = meta.temp_C(ic == j);
    ctd(j).conc = meta.ssc_mgL(ic == j);
    ctd(j).dens = denfun(ctd(j).temp,ctd(j).sal);
    ctd(j).kvis = kvisfun(ctd(j).temp);
    ctd(j).dvis = dvisfun(ctd(j).temp,ctd(j).sal);

    fn = strcat(strtok(meta.adcp_file{ia(j)},'r.'),'_ASC.TXT');
    pn = meta.adcp_path{ia(j)};
    dat(j) = adcp_ascii(fullfile(pn,fn));
end
toc

%% processing
fprintf('\nprocess\n');tic
for j=1:length(stations)
    fprintf('%d...',j)
    % getting horizontal velocity from east/north
    
    enmag = sqrt(dat(j).east.^2+dat(j).north.^2);
    endir = mod(90 - (rad2deg(atan2(dat(j).north,dat(j).east))),360);
    % convert velocity magnitude from cm/s to m/s
    % dat(j).u = dat(j).u ./ 100;
    dat(j).u = enmag ./100;
        dat(j).w = dat(j).up ./100;
        
    % projecting velocity
    if project_velocity == 1
        % get direction of top layer
        top5east = nanmean(nanmean(dat(j).east(1:5,:)));
        top5north = nanmean(nanmean(dat(j).north(1:5,:)));
        top5mag = sqrt(top5east^2+top5north^2);
        top5dir = mod(90 - (rad2deg(atan2(top5north,top5east))),360);
        
        %     top_dir = dat(j).dir(1:5,:);
        %     top_dir = nanmean(top_dir(:));
        top_dir = top5dir;
        proj_dir = dat(j).dir - top_dir;
        
        cos_dir = cos(deg2rad(proj_dir));
        sin_dir = sin(deg2rad(proj_dir));
        
        proj_u = dat(j).u .* cos_dir;
        proj_v = dat(j).u .* sin_dir;
        
        dat(j).u = proj_u;
        dat(j).v = proj_v;
        
    end
    

    
    % get some statistics from the adcp dat(j)a
    depth_avg(j) = nanmedian(dat(j).depth(:));
    depth_std(j) = 1.4826*mad(dat(j).depth(~isnan(dat(j).depth)));
    spd_avg(j) = nanmean(dat(j).u(:))/100;
    spd_std(j) = nanstd(dat(j).u(:))/100;
    lat_avg(j) = nanmean(dat(j).lat(:));
    lat_std(j) = nanstd(dat(j).lat(:));
    lon_avg(j) = nanmean(dat(j).lon(:));
    lon_std(j) = nanstd(dat(j).lon(:));
    north_avg(j) = nanmedian(dat(j).distnorth(:));
    % north_std(j) = nanstd(dat(j).distnorth(:));
    north_std(j) = 1.4826*mad(dat(j).distnorth(~isnan(dat(j).distnorth)));
    east_avg(j) = nanmedian(dat(j).disteast(:));
    % east_std(j) = nanstd(dat(j).disteast(:));
    east_std(j) = 1.4826*mad(dat(j).disteast(~isnan(dat(j).disteast)));
    
    dat(j).riverdepth = nanmean(dat(j).depth,1); % average bed depth from beams
    dat(j).height = dat(j).riverdepth - dat(j).z; % heights of bins above bed
    
    abs_dist = sqrt((dat(j).disteast-east_avg(j)).^2 + (dat(j).distnorth-north_avg(j)).^2);
    
    % dist_avg = nanmean(abs_dist(:));
    dist_avg = nanmedian(abs_dist(:));
    % dist_std = nanstd(abs_dist(:));
    dist_std = 1.4826*mad(abs_dist(~isnan(abs_dist)));
    
    
    % cleaning dat(j)a
    
    % get rid of dat(j)a outside one sd of avg lat/long and depth
    dist_filt = true(size(dat(j).ensnum));
    depth_filt = true(size(dat(j).ensnum));
    
    for i = 1:length(dat(j).ensnum)
        if filter_by_dist == 1
            if abs(abs_dist(i) - dist_avg) > dist_std
                dist_filt(i) = false;
            end
        end
        if filter_by_depth == 1
            if abs(dat(j).riverdepth(i) - depth_avg(j)) > depth_std(j)
                depth_filt(i) = false;
            end
        end
    end
    
    filt_mask = dist_filt & depth_filt;
    
    dat(j).height(:,~filt_mask) = nan;
    dat(j).u(:,~filt_mask) = nan;
    dat(j).v(:,~filt_mask) = nan;
    dat(j).w(:,~filt_mask) = nan;
    dat(j).height(isnan(dat(j).u)) = nan;
    
    % time averaging, binning, interpolating
    
    % flatten (single row) velocity and height matrices
    flat(j).u = dat(j).u(:);
    flat(j).v = dat(j).v(:);
    flat(j).w = dat(j).w(:);
    flat(j).h = dat(j).height(:);
    
    % get velocity cell indices within height bins
    hedges = 0:dh:nanmax(flat(j).h)+dh;
    [~,~,bin] = histcounts(flat(j).h,hedges);
    [~,~,bin2] = histcounts(dat(j).height,hedges);
    hb = nan(max(bin),1); %prealloc
    ub = hb; %prealloc
    vb = hb;
    wb = hb;

    
    % average dat(j)a within each bin
    for i = 1:length(hb) % for each bin
        in = bin==i; % find indices for velocity cells in that bin
        hb(i)=nanmean(flat(j).h(in)); % average heights within bin
        ub(i)=nanmean(flat(j).u(in)); % average velocities within bin
        vb(i)=nanmean(flat(j).v(in));
        wb(i)=nanmean(flat(j).w(in));
        
    end
    
    % clear empty/invalid bins
    in=isnan(hb);
    hb(in)=[];
    ub(in)=[];
    vb(in)=[];
    wb(in)=[];
    
    % interpolate between bins
    dat(j).hh = min(hb):ddh:(max(flat(j).h));
    dat(j).uu = pchip(hb,ub,dat(j).hh); % interpolation
    dat(j).vv = pchip(hb,vb,dat(j).hh);
    dat(j).ww = pchip(hb,wb,dat(j).hh);
    
    % bin ctd data
    dat(j).ssal = pchip(depth_avg(j) - ctd(j).depth,ctd(j).sal,dat(j).hh);
    dat(j).ttemp = pchip(depth_avg(j) - ctd(j).depth,ctd(j).temp,dat(j).hh);
%     dat(j).rrho = pchip(depth_avg(j) - ctd(j).depth,ctd(j).dens,dat(j).hh);
dat(j).rrho = interp1(depth_avg(j) - ctd(j).depth,ctd(j).dens,dat(j).hh,'pchip',nan);
    dat(j).kkvis = pchip(depth_avg(j) - ctd(j).depth,ctd(j).kvis,dat(j).hh);
    dat(j).ddvis = pchip(depth_avg(j) - ctd(j).depth,ctd(j).dvis,dat(j).hh);

    % transpose matrices, i'm not sure why they have to be like this, but it works
    dat(j).uu = dat(j).uu';
    dat(j).vv = dat(j).vv';
    dat(j).ww = dat(j).ww';
    dat(j).hh = dat(j).hh';
    dat(j).ssal = dat(j).ssal';
    dat(j).ttemp = dat(j).ttemp';
    dat(j).rrho = dat(j).rrho';
    dat(j).kkvis = dat(j).kkvis';
    dat(j).ddvis = dat(j).ddvis';
    dat(j).dudz = vertcat((diff(dat(j).uu))./(diff(dat(j).hh)),[0]);
    dat(j).tau = abs(dat(j).ddvis .* dat(j).dudz);
    dat(j).ustar = sqrt(dat(j).tau./dat(j).rrho);
    dat(j).eps = dat(j).ustar .^3 ./ (0.4 .* dat(j).hh);
    dat(j).G = sqrt(dat(j).eps ./ dat(j).kkvis);
    dat(j).lamb = (dat(j).kkvis.^3 ./ dat(j).eps) .^ (1/4);
    dat(j).lamb(end) = 0;
    dat(j).s_sq = dat(j).dudz .^2;
    dat(j).drhodz = vertcat((diff(dat(j).rrho))./(diff(dat(j).hh)),[0]);
    dat(j).n_sq = -9.8 /1000 .* dat(j).drhodz;
    dat(j).Ri_g = dat(j).n_sq ./ dat(j).s_sq;
    

    % curve fitting / law of the wall
    % using binned/interpolated values
    

    
    % get linear coefficients
    X = [ones(length(dat(j).uu),1) dat(j).uu];
    Y = log(dat(j).hh); % must be linear fit, so pack up log here
    b = X\Y;
    
    % unpacking coefficients
    zo = exp(b(1));
    
    u_star = k * 1 / b(2);
    tau_bed = u_star^2 * 1000;
    % reg_fit = zo * exp(b(2)*dat(j).uu);
    
    % calculate law of the wall profile and r-squared
    u = (u_star/k) * log(dat(j).hh/zo);
    R = corrcoef(dat(j).uu,u);
    rsq = R(2)^2;
    
    % make time vector
    
    for i =1:length(dat(j).ensnum)
        datestring = sprintf('20%02d-%02d-%02d %02d:%02d:%02d.%02d0',[dat(j).year(i),dat(j).month(i),dat(j).day(i),dat(j).hour(i),dat(j).minute(i),dat(j).second(i),dat(j).hunsec(i)]);
        dat(j).mtime(i) = (datenum(datestring,'yyyy-mm-dd hh:MM:SS'));
    end
end
toc
%% testing loop
close('all')
[~,sort_idx] = sort(stations);
figure('position',[10 50 length(stations)*200 600])
for j = 1:length(stations)
    q = sort_idx(j);
    
    ax67 = subplot(3, length(stations), j);
    plot(dat(q).rrho,dat(q).hh,'DisplayName',sprintf('%s \rho',stations{q}))
    title(sprintf('%s',stations{q}))
    xlabel('\rho, kg/m^3')
    ylabel('{\ith}, m')
    xlim([990 inf])
    ylim([0 30])
    grid on
    
    ax68 = subplot(3, length(stations), length(stations) + j);
    plot(dat(q).uu,dat(q).hh,'DisplayName',sprintf('%s u',stations{q}))
    xlabel('{\itu}, m/s')
    ylabel('{\ith}, m')
    xlim([-2 2])
    ylim([0 30])
    grid on
    
    ax69 = subplot(3, length(stations), 2*length(stations) + j);
    plot(dat(q).Ri_g,dat(q).hh,'DisplayName',sprintf('%s Ri_g',stations{q}))
    xlabel('Ri_g')
    ylabel('{\ith}, m')
    xlim([0 inf])
    ylim([0 30])
    grid on
end


%% output data
fprintf('\noutput\n');tic
outfile = [year,'velctd.xlsx'];
for j=1:length(stations)
        fprintf('%d...',j)
    % out(j) = struct('year',year,'station',stations{j},'file',fn,'h',dat(j).hh,'u',dat(j).uu,'sal',dat(j).ssal,'temp',dat(j).ttemp,'density',dat(j).rrho,'kvisc',dat(j).kkvis,'dvisc',dat(j).ddvis);
    outarray(j) = struct('h',dat(j).hh,'u',dat(j).uu,'v',dat(j).vv,'ww',dat(j).ww,'sal',dat(j).ssal,'temp',dat(j).ttemp,'density',dat(j).rrho,'kvisc',dat(j).kkvis,'dvisc',dat(j).ddvis,'dudz',dat(j).dudz,'tau',dat(j).tau,'ustar',dat(j).ustar,'eps',dat(j).eps,'G',dat(j).G,'lamb',dat(j).lamb);

    outsheet{j} = [stations{j},'_',strtok(meta.adcp_file{ia(j)},'r.')];
    
    warning('off','all');
    exportXLS(outarray(j),outfile,outsheet{j});
    warning('on','all');

%     writetable(outarray(j),outfile,outsheet{j})
end
    deleteSheet(outfile)
toc

%% plotting
fprintf('\nplot\n');tic
for j=1:length(stations)
        fprintf('%d...',j)
    % plot velocity time series
    fig1 = figure('position',[50 50 1200 700]);
    ax1 = subplot(2,2,1);
    imagesc(dat(j).mtime,dat(j).z(:,1),dat(j).u)
    datetick('x','keeplimits')
    c = colorbar();
    if project_velocity == 1
        c.Label.String = 'Streamwise Velocity [m/s]';
    elseif project_velocity == 0
        c.Label.String = 'Velocity Magnitude [m/s]';
    end
    colormap('jet')
    ylim([0, nanmax(dat(j).riverdepth(:))])
    title(sprintf('Velocity Time Series: %s',strtok(fn,'.')),'Interpreter','None')
    xlabel('Time')
    ylabel('Depth [m]')
    
    % plot of vessel lat long
    ax2 = subplot(2,2,2);
    % plot(dat(j).lon, dat(j).lat, '.')
    hold on
    % loctext = sprintf(' Mean Coordinates\n  Lat:  %-2.5f\n  Lon: %-2.5f',north_avg(j),east_avg(j));
    % text(lon_avg(j),lat_avg(j),loctext,'BackgroundColor',[1 1 1 0.75])
    % plot(nanmean(dat(j).lon),nanmean(dat(j).lat),'ro')
    % plot(nanmedian(dat(j).lon),nanmedian(dat(j).lat),'bo')
    title(strcat('Vessel Track: ',strtok(fn,'.')),'Interpreter','none');
    xlabel('Dist East [m]');
    ylabel('Dist North [m]');
    
    % fig1 = figure();
    p1 = plot(dat(j).disteast,dat(j).distnorth,'DisplayName','Ship Track');
    if filter_by_dist == 1
        circle = viscircles([east_avg(j),north_avg(j)],dist_avg+dist_std,'linestyle','--');
        legend([p1 circle],{'Ship Track','Filter Radius'})
    end
    % plot(dat(j).disteast(filt_mask),dat(j).distnorth(filt_mask))
    axis equal
    
   % plot of river depth time series
    
    ax3 = subplot(2,2,3);
    plot(dat(j).elaptime, -dat(j).riverdepth,'DisplayName','Time Series')
    hold on
    ylim([-max(dat(j).depth(:)) 0])
    ylabel('Depth [m]')
    xlabel('Elapsed Time [s]');
    plot(dat(j).elaptime, repmat(-depth_avg(j),length(dat(j).elaptime),1),'k-','DisplayName',sprintf('Average Depth: %2.2f',depth_avg(j)))
    legend('show')
    if filter_by_depth ==1
        legend('off')
        plot(dat(j).elaptime, repmat(-depth_avg(j)+depth_std(j),length(dat(j).elaptime),1),'r--','DisplayName','Filter Depths')
        legend('show')
        plot(dat(j).elaptime, repmat(-depth_avg(j)-depth_std(j),length(dat(j).elaptime),1),'r--')
    end
    % hline(-depth_avg(j),'k-','Average Depth')
    % hline(-depth_avg(j)+depth_std(j),'r--')
    % hline(-depth_avg(j)-depth_std(j),'r--')
    title(strcat('River Depth: ',strtok(fn,'.')),'Interpreter','none')
    % text(0,depth_avg(j),sprintf('Average Depth: %2.2f',depth_avg(j)),'BackgroundColor',[1 1 1 0.7])
    
    % plot velocity profile
    
    
    ax4 = subplot(2,2,4);
    
    plot(flat(j).u,flat(j).h, '.', 'Color', [0.7 0.7 0.7])
    hold on
    vline(0,'k--')
    plot(dat(j).uu, (dat(j).hh), 'ko', 'MarkerSize', 10)
    % plot(u, (dat(j).hh),'k', 'LineWidth',2)
    xlim([-2 2])
    ylim([0 30])
    % plottext = sprintf('r^{2} = %1.3f\nu* = %1.3f m/s\nz_{o} = %1.3g m\n\\tau_{b} = %1.3f kg/ms^{2}\n\nu_{ave} = %1.3f m/s\nu_{std} = %1.3f m/s\nd_{ave} = %1.3f m',[rsq,u_star,zo,tau_bed,spd_avg(j),spd_std(j),depth_avg(j)]);
    plottext = sprintf('u_{avg} = %1.3f m/s\nu_{std} = %1.3f m/s\nh_{avg} = %1.3f m',[spd_avg(j),spd_std(j),depth_avg(j)]);
    limits = axis(gca);
    textloc = [limits(1)+(limits(2)-limits(1))*0.1,limits(3)+(limits(4)-limits(3))*0.5];
    text(textloc(1),textloc(2),plottext,'BackgroundColor',[1 1 1 0.75]);
    title(strcat('Velocity Profile: ',strtok(fn,'.')),'Interpreter','none')
    if project_velocity == 0
        xlabel('Velocity Magnitude [m/s]');
    elseif project_velocity == 1
        xlabel('Streamwise Velocity [m/s]');
    end
    ylabel('Height Above Bed [m]');
    
    % ylim([0,inf])
end
toc
