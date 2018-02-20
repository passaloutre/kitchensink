close('all')
clear
pn = 'E:\Projects\SaltWedge';
fn = '2015velctd.xlsx';

[~,sheets] = xlsfinfo(fullfile(pn,fn));

for i = 1:length(sheets)

dat(i) = loadxls_struct(fullfile(pn,fn),sheets{i});
figure('position',[50 50 1200 600]);

ax1 = subplot(1,3,1);
plot(dat(i).sal,dat(i).h);
xlabel('Salinity, ppt')
ylabel('z, m')
title([strtok(sheets{i},'_'),': Salinity']);

ax2 = subplot(1,3,2);
plot(dat(i).u,dat(i).h);
xlabel('Velocity, m/s')
ylabel('z, m')
title([strtok(sheets{i},'_'),': Velocity'])
xlim([-1 1])

ax3 = subplot(1,3,3);
plot([dat(i).u(1)/dat(i).h(1);diff(dat(i).u)./0.5],dat(i).h);

end

% miles2015 = [36 26 16 9 4.5 0];
% miles2016 = [26 16 13 9 6 0];
% 
% temp2015 = [ ];
% temp
% 
% dudz2015 = [0.0513 0.1979 0.2271 0.2779 0.3019 0.2105];
% dudz2016 = [0.0482 0.2337 0.2181 0.1492 0.2168 0.2617];
% tauh2015 = dudz2015 .* 1e-3; % dudz times mu (dynamic viscosity) equals tau
% tauh2016 = dudz2016 .* 1e-3;
% ustarh2015 = sqrt(tauh2015./1000);
% ustarh2016 = sqrt(tauh2016./1000);
% 
% ustarb2015 = [nan nan 0.073 0.0535 0.22 0.153];
% ustarb2016 = [nan nan nan 0.0527 0.15245 0.1001 ];
% taub2015 = ustarb2015.^2 .* 1000;
% taub2016 = ustarb2016.^2 .* 1000;
% 
% fig1 = figure();
% plot(miles2015,ustarh2015,'DisplayName','u*_h 2015')
% hold on
% plot(miles2016,ustarh2016,'DisplayName','u*_h 2016')
% plot(miles2015,ustarb2015,'DisplayName','u*_b 2015')
% plot(miles2016,ustarb2016,'DisplayName','u*_b 2016')
% xlabel('river mile')
% ylabel('shear velocity m/s')
% set(gca,'yscale','log')
% grid on
% legend('show')
% 
% fig2 = figure();
% plot(miles2015,tauh2015,'DisplayName','\tau_h 2015')
% hold on
% plot(miles2016,tauh2016,'DisplayName','\tau_h 2016')
% plot(miles2015,taub2015,'DisplayName','\tau_b 2015')
% plot(miles2016,taub2016,'DisplayName','\tau_b 2016')
% xlabel('river mile')
% ylabel('shear stress Pa')
% set(gca,'yscale','log')
% grid on
% legend('show')