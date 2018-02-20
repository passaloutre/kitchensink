%script to assist in merging ADCP/CTD/LISST datastreams

%% CTD data with SSC samples
pnbase='C:\Users\PICS\Documents\active_jobs\NavyPropwash\PearlHarbor';
fnxls=fullfile(pnbase,'SSC','PearlHarbor_SSC');
sheet='Aug 29';
s=loadxls_struct(fnxls,sheet);
s.temp=nan(size(s.ssc_mgL));
s.sal=nan(size(s.ssc_mgL));
s.mtime=datenum(s.date)+s.time;
%CTD data
fnctd=fullfile(pnbase,'YSI-CTD','CTD_0829.mat');
ctd=load(fnctd);
%Loop through the CTD data and get T,S from the CTD record
dt=(30)/3600/24; %range of time (sec)->day
for k=1:length(s.temp)
    in=ctd.mtime>=s.mtime(k) & ctd.mtime <= s.mtime(k)+dt;
    s.temp(k)=mean(ctd.Temp(in));
    s.sal(k)=mean(ctd.Sal(in));
end

