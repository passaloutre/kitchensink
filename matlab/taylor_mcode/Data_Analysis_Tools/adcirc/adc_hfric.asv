function adc_hfric
%ADC_HFRIC function to plot values of Cf 
%from the hybrid friction approach in ADCIRC
%
% Cf=Cfmin(1+(Hbreak/H)^th)^(gam/th)
% Cfmin = g n^2/Hbreak^gam
%

%Line Specification
clr='brgcmk';

g=9.81;
gam=1/3;
th=10;

%independent variables
h=0.5:.5:30;
n=[0.015,0.020,0.025];
Hb=[1,2,5,10,30];
nh=length(h);
nhb=length(Hb);
nn=length(n);
%preallocate Cf
Cf=zeros(nn,nh,nhb);
%calculate Cf
for kk=1:nhb,
    for k=1:nn,
        Cfmin=g*n(k)^2/Hb(kk)^gam;
        Cf(k,:,kk)=Cfmin*(1+(Hb(kk)./h).^th).^(gam/th);
    end
end

%plot Cf vs depth
figure(10),cla
for kk=1:nhb
    for k=1:nn,
        line(h,Cf(k,:,kk),'Color',clr(k),'LineWidth',2);
        if kk==1,
            text(h(end),Cf(k,end,kk),sprintf('n=%5.3f',n(k)),...
                'HorizontalAlignment','right',...
                'VerticalAlignment','bottom',...
                'Color',clr(k));
        end
    end
end
ytc=get(gca,'YTick');
set(gca,'YTickLabel',num2str(ytc','%5.3f'))
grid on
xlabel('h [m]')
ylabel('C_f')
title(['ADCIRC Hybrid Friction: ',...
        sprintf('\\gamma = %6.4f, \\theta = %5.3f',gam,th)]);
