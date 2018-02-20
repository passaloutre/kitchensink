%script to evaluate good/bad PIV
%% Parameters
pnresults='Results1';
MxVel=5; %Max frame-averaged velocity magnitude (mm/s)
fnxls='ptvpiv_LowerMSRV_SaltWedge.xlsx';
[~,sheets]=xlsfinfo(fnxls);


%% Load ptvpiv structs from xls
for J=1:length(sheets)
    s(J)=loadxls_struct(fnxls,sheets{J});
end

flds=fieldnames(s);
xls.xlsfile=s(1).xlsfile;
for J=1:length(flds);
    switch class(s(1).(flds{J}))
        case 'char'
        case {'cell','double'}
            xls.(flds{J})=cat(1,s.(flds{J}));
    end
end
xls.sheet=cat(1,{sheets{xls.cast_id}})';

%% Analysis loop
for J=1:length(xls.file_ptv) %loop on files within dataset
    % Load PIV and PTV datasets
    load(fullfile(pnresults,xls.sheet{J},xls.file_ptv{J})) %ptv
    load(fullfile(pnresults,xls.sheet{J},xls.file_piv{J})) %piv
    %
    dt=1/ptv.fps;
    % run im_piv_correct
    piv2=im_piv_correct(piv);
    %collect statistics
    sz=size(piv2.in);
    %1. fraction of outliers
    N=sum(piv2.in(:))-prod(sz(1:2)); %total outliers (excluding first frame)
    out(J).ftot=N/prod(sz-[0,0,1]);
    %2. max outlier fraction per frame
    out(J).fpeak=squeeze(sum(sum(piv2.in,1),2))/prod(sz(1:2));
    %3. max velocity
    %estimate velocity for each frame
    zz=ones(numel(piv2.X),1); %dummy array
    szx=size(piv2.X);
    piv2.Ux=nan(size(piv2.u)); %prealloc
    piv2.Vx=nan(size(piv2.v)); %prealloc
    P0=[piv2.Y(:),piv2.X(:),zz];
    P0x=P0*ptv.post.A;
    for k=1:sz(3)
        Xp=piv2.X+piv2.u(:,:,k);
        Yp=piv2.Y+piv2.v(:,:,k);
        P1=[Yp(:),Xp(:),zz];
        P1x=P1*ptv.post.A;
        dp=P1x-P0x;
        u=dp(:,2)/dt;
        v=dp(:,1)/dt;
        piv2.Ux(:,:,k)=reshape(u,szx);
        piv2.Vx(:,:,k)=reshape(v,szx);
    end
    [~,piv2.Vmag]=cart2pol(piv2.Ux,piv2.Vx);
    out(J).Vmag=squeeze(mean(mean(piv2.Vmag,1),2));
    
    %4. remaining outliers
    piv3=im_piv_correct(piv2);
    N2=sum(piv3.in(:))-prod(sz(1:2)); %total outliers (excluding first frame)
    out(J).ftot2=N2/prod(sz-[0,0,1]);
    out(J).fpeak2=squeeze(sum(sum(piv3.in,1),2))/prod(sz(1:2));
    
end

%% Additional processing
b.in=logical(xls.flag1); %indicates good/bad piv from manual assessment
%DEFINITIONS
% ftot  = fraction of outliers in the raw piv
% ftot2 = fraction fo outliers after piv outlier correction
% f90   = 90 percentile of outlier fraction per frame
% f95   = 95 percentile of outlier fraction per frame
% f90r  = 90th perc. outlier fraction per frame after correction
% f95r  = 95th perc. outlier fraction per frame after correction

%additional processing
b.ftot=cat(1,out.ftot);
b.ftot2=cat(1,out.ftot2);
b.f90=nan(length(out),1); %prealloc
b.f95=nan(length(out),1); %prealloc
b.f90r=nan(length(out),1); %prealloc
b.f95r=nan(length(out),1); %prealloc
b.Vmean=nan(length(out),1); %prealloc
b.V50=nan(length(out),1); %prealloc
b.V90=nan(length(out),1); %prealloc
b.V95=nan(length(out),1); %prealloc

for k=1:length(out);
    %cdf of outliers (exclude frames 1&2, b/c end effects)
    [cdf,edges]=histcounts(out(k).fpeak(3:end),'Normalization','cdf');
    [cdf2,edges2]=histcounts(out(k).fpeak2(3:end),'Normalization','cdf');
    %piv - first pass
    [cdfu,ia]=unique(cdf);
    edgesu=edges(ia+1);
    f=interp1(cdfu,edgesu,[0.90,0.95]);
    b.f90(k)=f(1);
    b.f95(k)=f(2);
    %piv with corrected outliers
    [cdfu,ia]=unique(cdf2);
    edgesu=edges2(ia+1);
    f=interp1(cdfu,edgesu,[0.90,0.95]);
    b.f90r(k)=f(1);
    b.f95r(k)=f(2);
    %velocity assessment
    b.Vmean(k)=mean(out(k).Vmag);
    %V50,90,95
    [cdf,edges]=histcounts(out(k).Vmag,'Normalization','cdf');
    [cdfu,ia]=unique(cdf);
    edgesu=edges(ia+1);
    f=interp1(cdfu,edgesu,[0.50,0.90,0.95]);
    b.V50(k)=f(1);
    b.V90(k)=f(2);
    b.V95(k)=f(3);
end


%% Plotting
figure(77);
indx=1:length(b.in);
%Total Fractions
subplot(3,1,1)
h1=plot(indx,b.ftot,'k-',...  %raw piv
    indx,b.ftot2,'b-',...      %with replacement
    indx(~b.in),b.ftot(~b.in),'ko',... %bad raw
    indx(~b.in),b.ftot2(~b.in),'bo');  %bad replacement
grid on
ylabel('fraction of outliers')
xlabel('file index')
legend(h1([1,2,3]),'raw','w/replace','flagd bad')

%Frame Fractions 
subplot(3,1,2)
h2=plot(indx,b.f90,'k-',...  %raw 90%
    indx,b.f95,'k--',...      %raw 95%
    indx,b.f90r,'b-',...    %repl 90%
    indx,b.f95r,'b--',...   %repl 95%
    indx(~b.in),b.f90(~b.in),'ko',... %bad raw
    indx(~b.in),b.f95(~b.in),'ko',... %bad raw
    indx(~b.in),b.f90r(~b.in),'bo',... %bad repl
    indx(~b.in),b.f95r(~b.in),'bo');  %bad repl
grid on
ylabel('frac outliers per frame')
xlabel('file index')
legend(h2(1:5),'raw90','raw95','repl90','repl95','flagd bad')

%Velocities 
subplot(3,1,3)
h3=semilogy(indx,b.Vmean,'k-',...  
    indx,b.V50,'b-',...     
    indx,b.V90,'g-',...   
    indx,b.V95,'r-',...   
    indx(~b.in),b.Vmean(~b.in),'ko',... %bad raw
    indx(~b.in),b.V50(~b.in),'bo',... %bad raw
    indx(~b.in),b.V90(~b.in),'go',... %bad repl
    indx(~b.in),b.V95(~b.in),'ro');  %bad repl
grid on
ylabel('Fluid Velocity [mm/s]')
xlabel('file index')
legend(h3(1:4),'Vmean','V50','V90','V95')
