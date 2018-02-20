%script to generate WS6 plots from PICS image processing

%% Parameters
xlsfile='ptvpiv_WhiteRiverWA.xlsx';
sheet='1130WR2';
pn_analysis='Results1\WhiteRiver2'; %contains the piv & ptv analysis
pn_results='Results2\WhiteRiver2'; %contains the merged results
%set options for PTV/PIV adjustments
opts.method_inpaint=1;
opts.fdv=[3,3]; %this is for improved interpolation of the piv results

%% File Preparation
if ~exist(fullfile(pn_results,'MAT'),'file')
    mkdir(fullfile(pn_results,'MAT'));
end
if ~exist(fullfile(pn_results,'PNG'),'file')
    mkdir(fullfile(pn_results,'PNG'));
end
if ~exist(fullfile(pn_results,'PDF'),'file')
    mkdir(fullfile(pn_results,'PDF'));
end

%% Load data
s=loadxls_struct(xlsfile,sheet);
nstart=1;
nfinish=length(s.id);
% nfinish=1; %testing

%% Assemble data and call WS6plot
for k=nstart:nfinish
    %determine whether to analyze
    %if any flag is false, go to next iteration of for loop
    if ~(s.flag1(k) && s.flag2(k) && s.flag3(k))
        continue
    end
    %load piv & ptv data
    load(fullfile(pn_analysis,s.file_piv{k})) %loads piv
    load(fullfile(pn_analysis,s.file_ptv{k})) %loads ptv
    
    %ptv correction (w PIV)
    ptv=im_pics_PTVpiv_corr(ptv,piv,opts);
    
    %assemble additonal data (from XLS file)
    ptv.rhow=denfun(s.temp(k),s.salinity(k));
    ptv.temperature=s.temp(k);
    ptv.salinity=s.salinity(k);
    ptv.depth_m=s.depth_m(k);
    ptv.id=s.id{k};
    
    %call function to generate ws6
    a=plot_ws6(ptv);
    
    %Save Results
    %%mat file
    [~,tmp]=fileparts(ptv.file);
    fnbase=['ws6_',tmp];
    save(fullfile(pn_results,'MAT',fnbase),'-struct','a');
    %%fig file
    hgsave(fullfile(pn_results,'MAT',fnbase));
    %%png file
    print('-dpng',fullfile(pn_results,'PNG',fnbase));
    %%pdf file
    print('-dpdf',fullfile(pn_results,'PDF',fnbase));
end    
