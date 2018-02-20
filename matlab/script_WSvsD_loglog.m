%script to evaluate ws6 data

%% Parameters & Data
pn='Results2/Sand2/MAT';
files=dir(fullfile(pn,'ws6*.mat'));
for k=1:length(files);
    a(k)=load(fullfile(pn,files(k).name));
end
rhos=[1010,1150,1800,2650];
T=21;
d=logspace(-2,0)';
for k=1:length(rhos)
    ws_stokes(:,k)=vfall_stokesSchiller(d,T,0,'rhos',rhos(k));
end
%% Plot the distributions
figure(4)
nrow=2;ncol=3;
ax(prod(nrow,ncol))=nan;
ax=zeros(size(a));
for k=1:length(a)
    ax(k)=subplot(nrow,ncol,k);
    loglog(1e3*a(k).dthr3,a(k).ws3,'.',d*1e3,ws_stokes*1e3,'-')
    grid on
    xlabel('d [\mum]')
    ylabel('Ws [mm/s]')
    title(sprintf('%s (%s)',a(k).filename,a(k).id),'Interpreter','none')
    if k==1
        legend(cat(1,{'data'},cellstr(num2str(rhos(:),'%g kg/m3'))),...
    'Location','nw')
    end
end

%%Merged dataset
D=1e3*cat(1,a.dthr3);
WS=cat(1,a.ws3);
dbins=logspace(1,3);
wbins=logspace(-4,3,100);
I=discretize(D,dbins);
J=discretize(WS,wbins);
N=zeros(length(dbins)-1,length(wbins)-1); %prealloc
for i=1:size(N,1)
    in1=I==i;
    for j=1:size(N,2)
        N(i,j)=sum(in1 & J==j);
    end
end
N=N/sum(N(:)); %normalize
%%Plot Merged
ax(k+1)=subplot(nrow,ncol,6);
loglog(D,WS,'.',d*1e3,ws_stokes*1e3,'-')
hold on
dbinmp=10.^midpoint(log10(dbins));
wbinmp=10.^midpoint(log10(wbins));
[Wm,Dm]=meshgrid(wbinmp,dbinmp);
[C,h]=contour(Dm,Wm,N);
hold off
grid on
xlabel('d [\mum]')
ylabel('Ws [mm/s]')
title('Pooled Data')

set(ax,'XLim',[1e1,1e3],'YLim',[1e-4,1e3])
