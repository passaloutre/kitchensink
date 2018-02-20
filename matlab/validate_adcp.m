function in=validate_adcp(adcp,varargin)
%VALIDATE_ADCP performs checks to ensure good quality adcp data.
%Flags are saved to ADCP struct to indicate valid bins.
%SYNTAX:
%   in=adcpclean(adcp);
%   in=adcpclean(adcp,params);
% where
%        s = struct var containing logical matrices indicating adcp data
%             that meets specified criteria
%   params = struct array containing processing parameters and operational
%            flags.  List of parameter fields below:
%      .dici     = confidence interval outside of which to treat relative
%                  change in echo intensity (di/i) an outlier
%                  {default: 0.99, 99% CI}
%      .f_di = fraction (upper) of water column to determine std(di/i)
%                 {default: 0.75}
%      .corr = correlation criterion {default: 72}
%
%      in = output struct containing fields with logical masks for the
%      various validation criteria.
%           .btrange = bins less than 0.94* bottom track range
%           .di      = bins meeting the dicrit
%

%%Algorithm
%Determine good ADCP data
%   -Methods
%   1. bins < bottom-track depth
%   2. change in echo intensities > threshold
%   3. velocity correlation 
%TODO:   4. velocity gradients (vertical and time)

%% Parameters (default)
di_CI=0.99; %confidence interval for determining outliers
f_di=0.75; %determine s from upper f_dicrit of water column
corr_crit=72;
%% Input checking
narginchk(1,2);
if nargin==2
   params=varargin{1};
   if ~isstruct(params)
      error('Second argument must be a struct with parameter information.')
   end
   fld=getfield(params);
   for k=1:length(fld);
      f=fld{k};
      switch f
         case 'f_di'
            f_di=params.f_di;
         case 'dici'
            di_CI=params.dici;
          case 'corr'
            corr_crit=params.corr;
         otherwise
            warning('%s is not a supported parameter option.\n',f);
      end
   end
end

%% Develop t-test lookup table
tt.df=[2:10,logspace(log10(12),log10(100),20)];
tt.score=nan(size(tt.df));
for k=1:length(tt.df)
    tt.score(k)=ttest_sjs(di_CI,tt.df(k),2);
end

%% Main Loop
nJ=length(adcp); %number of ADCP records in adcp struct
fprintf(1,'\nProcessing %g records.\nRecord: ',nJ);
nbyte=fprintf(1,'%g',0);
in=struct([]); %prealloc
for J=1:length(adcp) %set adcp transect number
   bspc=repmat('\b',1,nbyte);
   nbyte=fprintf([bspc,'%g'],J)-nbyte;
   nens=length(adcp(J).mtime);
   nbin=adcp(J).config.n_cells;
   nbeam=adcp(J).config.n_beams;
   %%Extract ADCP intensity and ranges
   intens=adcp(J).intens(:,1:nbeam,1:nens);
   range=repmat(adcp(J).config.ranges,1,nbeam);
   corr=adcp(J).corr(:,1:nbeam,1:nens);
   %%Apply criteria to ensembles
   [in1,in2]=deal(true(size(intens)));
   for k=1:nens  %loop through ensembles
       %1a) bins < bottom-track depth
       btrange=repmat(adcp(J).bt_range(1:nbeam,k),1,nbin)';
       in1(:,:,k)= range < 0.94*btrange; % 0.06 side-lobe criterion from RDI
       in1a= range < f_di*btrange;
       %TODO: cases with no btdata (which is the case for HADCP)
       intest=all(~in1a,1);
       in1a(1:floor(nbin/4),intest)=true;
       %2) filter based on change in echo intensity
       i=squeeze(intens(:,:,k));
       [~,di]=gradient(i);
       din=di./i; %normalized to echo intensity
       dintmp=din;
       dintmp(~in1a)=nan;
       s_di=nanstd(dintmp,1);
       for n=1:nbeam
           df=sum(in1a(:,n))-1; %degrees of freedom
           if df < 2
               in2(:,n,k)=false;
           else
               dicrit=interp1(tt.df,tt.score,df); %lookup score from predef table
               intmp=din(:,n) > dicrit*s_di(n);
               I=find(intmp,1,'first')-1;
               if ~isempty(I),
                   in2((I+1):end,n,k)=false;
               end
           end
       end
   end
   %3) filter based on correlation criterion
   in3= corr >= corr_crit;
   
   %Prepare data for function output
   in(J).btrange=in1;
   in(J).di=in2;
   in(J).corr=in3;
end %main loop on J
fprintf(1,'\n');


