load('E:\Projects\SaltWedge\testing.mat')

ddh = 0.1;

j = 1;

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
depth_avg = nanmedian(dat(j).depth(:));
depth_std = 1.4826*mad(dat(j).depth(~isnan(dat(j).depth)));
spd_avg = nanmean(dat(j).u(:))/100;
spd_std = nanstd(dat(j).u(:))/100;
lat_avg = nanmean(dat(j).lat(:));
lat_std = nanstd(dat(j).lat(:));
lon_avg = nanmean(dat(j).lon(:));
lon_std = nanstd(dat(j).lon(:));
north_avg = nanmedian(dat(j).distnorth(:));
% north_std = nanstd(dat(j).distnorth(:));
north_std = 1.4826*mad(dat(j).distnorth(~isnan(dat(j).distnorth)));
east_avg = nanmedian(dat(j).disteast(:));
% east_std = nanstd(dat(j).disteast(:));
east_std = 1.4826*mad(dat(j).disteast(~isnan(dat(j).disteast)));

dat(j).riverdepth = nanmean(dat(j).depth,1); % average bed depth from beams
dat(j).height = dat(j).riverdepth - dat(j).z; % heights of bins above bed

abs_dist = sqrt((dat(j).disteast-east_avg).^2 + (dat(j).distnorth-north_avg).^2);

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
        if abs(dat(j).riverdepth(i) - depth_avg) > depth_std
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
flatu = dat(j).u(:);
flatv = dat(j).v(:);
flatw = dat(j).w(:);
flath = dat(j).height(:);

% get velocity cell indices within height bins
hedges = 0:dh:nanmax(flath)+dh;
[~,~,bin] = histcounts(flath,hedges);
[~,~,bin2] = histcounts(dat(j).height,hedges);
hbar = nan(max(bin),1); %prealloc
ubar = hbar; %prealloc
vbar = hbar;
wbar = hbar;

hinst = nan(max(bin),length(dat(j).year));
hprime = hinst;
uinst = hinst;
uprime = uinst;
vinst = uinst;
vprime = uinst;
winst = uinst;
wprime = winst;

% average dat(j)a within each bin
for i = 1:length(hbar) % for each bin
    in = bin==i; % find indices for velocity cells in that bin
    in2 = bin2==i;
    hbar(i)=nanmean(flath(in)); % average heights within bin
    ubar(i)=nanmean(flatu(in)); % average velocities within bin
    vbar(i)=nanmean(flatv(in));
    wbar(i)=nanmean(flatw(in));
    
    for k = 1:length(dat(j).year)
        hinst(i,k) = nanmean(dat(j).height(in2(:,k),k));
        hprime(i,k) = hinst(i,k) - hbar(i);
        uinst(i,k) = nanmean(dat(j).u(in2(:,k),k));
        uprime(i,k) = uinst(i,k) - ubar(i);
        vinst(i,k) = nanmean(dat(j).v(in2(:,k),k));
        vprime(i,k) = vinst(i,k) - vbar(i);
        winst(i,k) = nanmean(dat(j).w(in2(:,k),k));
        wprime(i,k) = winst(i,k) - wbar(i);
    end
    hline(i,'k-'); hold on
    plot(dat.ensnum,i+uprime(i,:),'-','DisplayName',sprintf('%d',i));hold on
    
end
%%

upr_sq = uprime .^ 2;
vpr_sq = vprime .^ 2;
wpr_sq = wprime .^ 2;

upr_vpr = uprime .* vprime;
upr_wpr = uprime .* wprime;
vpr_wpr = vprime .* wprime;

upr_sq_bar = nanmean(upr_sq,2);
vpr_sq_bar = nanmean(vpr_sq,2);
wpr_sq_bar = nanmean(wpr_sq,2);
upr_vpr_bar = nanmean(upr_vpr,2);
upr_wpr_bar = nanmean(upr_wpr,2);
vpr_wpr_bar = nanmean(vpr_wpr,2);

figure()
plot(upr_sq_bar,hbar,'DisplayName','$\overline{u''u''}$');hold on
plot(vpr_sq_bar,hbar,'DisplayName','$\overline{v''v''}$')
plot(wpr_sq_bar,hbar,'DisplayName','$\overline{w''w''}$')
plot(upr_vpr_bar,hbar,'DisplayName','$\overline{u''v''}$')
plot(upr_wpr_bar,hbar,'DisplayName','$\overline{u''w''}$')
plot(vpr_wpr_bar,hbar,'DisplayName','$\overline{v''w''}$')
% plot(ww_depth,-z,'DisplayName','ww');
% plot(vv_depth,-z,'DisplayName','vv')
% plot(uw_depth,-z,'DisplayName','uw')
leg = legend('show');
set(leg,'interpreter','Latex','FontSize',14)
xlabel('Reynolds Stress velocity component, $m^{2}/s^{2}$','interpreter','Latex','FontSize',14)
ylabel('height, m','interpreter','Latex','FontSize',14)

%%

% clear empty/invalid bins
in=isnan(hbar);
hbar(in)=[];
ubar(in)=[];
vbar(in)=[];
wbar(in)=[];


% interpolate between bins
dat(j).hh = min(hbar):ddh:(max(flath));
dat(j).uu = pchip(hbar,ubar,dat(j).hh); % interpolation
dat(j).vv = pchip(hbar,vbar,dat(j).hh);
dat(j).ww = pchip(hbar,wbar,dat(j).hh);

% interpolate stress tensors
dat(j).upruprbar = pchip(hbar,upr_sq_bar,dat(j).hh);
dat(j).vprvprbar = pchip(hbar,vpr_sq_bar,dat(j).hh);
dat(j).wprwprbar = pchip(hbar,wpr_sq_bar,dat(j).hh);
dat(j).uprvprbar = pchip(hbar,upr_vpr_bar,dat(j).hh);
dat(j).uprwprbar = pchip(hbar,upr_wpr_bar,dat(j).hh);
dat(j).vprwprbar = pchip(hbar,vpr_wpr_bar,dat(j).hh);

% bin ctd data
dat(j).ssal = pchip(depth_avg - ctd(j).depth,ctd(j).sal,dat(j).hh);
dat(j).ttemp = pchip(depth_avg - ctd(j).depth,ctd(j).temp,dat(j).hh);
dat(j).rrho = pchip(depth_avg - ctd(j).depth,ctd(j).dens,dat(j).hh);
dat(j).kkvis = pchip(depth_avg - ctd(j).depth,ctd(j).kvis,dat(j).hh);
dat(j).ddvis = pchip(depth_avg - ctd(j).depth,ctd(j).dvis,dat(j).hh);

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