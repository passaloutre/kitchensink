%script for extracting and plotting size distributions
%% Load Data
p=load('L3091926.mat'); %load LISST data
%% Extract & plot
tstr='05-Nov-2015 193228'; %time of PICS sample
tstart=datetime(tstr,'InputFormat','dd-MMM-yyyy HHmmss');
%time selection
in=isbetween(p.dtime,tstart-seconds(30),tstart+seconds(30));
vc=mean(p.vc(in,:),1); %data extraction and averaging 
semilogx(p.d,vc/sum(vc))
set(gca,'XTickLabel',{'1','10','100','1000'})
xlabel('d [\mum]')
ylabel('volume')

