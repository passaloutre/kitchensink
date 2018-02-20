%% soileau model
clear;close all

% from soileau
rkm_tra0 = [0 16 32 48 64 80 97 113 129 145 161 177 186];
rkm_tra1 = [0 16 32 48 64 80 97 100 ]; % with sill in place
cms_tra0 = [8240 7079 6272 5607 5069 4658 4318 4021 3738 3469 3214 3002 2888];
cms_tra1 = [8240 7079 6272 5607 5069 4658 4318 4248]; % with sill

rkm_reg0 = [186 185 184 177 165 161 145 129 113 97 80 64 48 32 16 0];
rkm_reg1 = [100 99 98 91 80 64 48 32 16 0]; % with sill
cms_reg0 = [2888 4248 5663 6485 7079 7192 7532 7815 8014 8099 8141 8155 8184 8212 8226 8240];
cms_reg1 = [4248 5663 7079 7900 8141 8155 8184 8212 8226 8240]; % with sill

% interpolating
cms_mas = 2888:1:8240;
cms_mas_s = 4248:1:8240;

rkm_tra = interp1(cms_tra0,rkm_tra0,cms_mas);
rkm_tra_s = interp1(cms_tra1,rkm_tra1,cms_mas_s);
rkm_reg = interp1(cms_reg0,rkm_reg0,cms_mas);
rkm_reg_s = interp1(cms_reg1,rkm_reg1,cms_mas_s);

%% hydrograph

bc = loadxls_struct('hydrograph_bc_mod.xlsx',1);
bc.date = datetime(bc.date);
bc.q = round(bc.q);

ind = (bc.date >= datetime(2012,01,01) & bc.date < datetime(2016,01,01)); % full series
% ind = (bc.date >= datetime(2015,09,07) & bc.date < datetime(2015,11,12)); % subseries
datelist = [datetime(2012,12,20),datetime(2013,11,26),datetime(2014,12,06),datetime(2015,11,08)];
date = bc.date(ind);
q = bc.q(ind);
dq = vertcat(0,diff(q));

rk_head = zeros(length(q),1);
cum_sed = zeros(length(q),1);
path = zeros(length(q),1);

for i = 2:length(date)
    if q(i) >= max(cms_mas_s) % salt wedge is downstream of HOP
        rk_head(i) = 0  ;

    elseif q(i) < max(cms_mas_s) && q(i) >= min(cms_mas_s) % discharge within curve range
        rk_head(i) = rkm_tra_s(cms_mas_s==q(i)); % head of salt wedge along transgressive curve
        if rk_head(i) < rk_head(i-1) % if regressing
            [~,ind_qtobeat] = min(abs(rkm_reg_s - rk_head(i))); % find index along regressive curve for current river km
            test_q = cms_mas_s(ind_qtobeat);
            if q(i) > test_q
                rk_head(i) = rkm_reg_s(cms_mas_s==q(i));
                path(i) = 1;
            else
%                 if sign(dq(i)) == 1
                    rk_head(i) = rk_head(i-1) - 0.005 *dq(i);
                    path(i) = 2;
%                 elseif sign(dq
%                     rk_head(i) = rk_head(i-1);
%                 end
            end
        end
        
    elseif bc.q(i) < min(cms_mas_s)
        rk_head(i) = 100 ;
    end
    cum_sed(i) =  cum_sed(i-1) + rk_head(i)*168.2;
    if any(date(i) == datelist)
        cum_sed(i) = 0;
    end
end
rk_head(rk_head<0)=0;
%%
figure('position',[10 50 1067 600]); hold on
plot(cms_mas, rkm_tra,'r-','DisplayName','Progression')
plot(cms_mas, rkm_reg,'b-','DisplayName','Regression')
% plot(cms_mas, rkm_tra_s,'r--')
plot(cms_mas_s, rkm_reg_s,'b--','DisplayName','Sill in Place')

legend('location','best')
plot(min(cms_mas_s),max(rkm_reg_s),'k.','MarkerSize',20)
text(min(cms_mas_s),max(rkm_reg_s)+5,'Maximum Extent of Salt Wedge with Sill in Place','FontSize',12)
xlabel('Discharge, m^3/s')
ylabel('River Kilometer')
set(gca,'FontSize',16)
grid on

figure('position',[10 50 1067 600]); 

yyaxis right
aplot = plot(date,rk_head);
grid on
xlabel('Date')
ylabel('River Kilometer')
set(gca,'FontSize',16)
yyaxis left
qplot = plot(date,q);
ylabel('Discharge, m^3/s')
hline(8240,'k--')
% hline(4248,'k--')
