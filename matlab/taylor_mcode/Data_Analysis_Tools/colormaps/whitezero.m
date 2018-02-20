function whitezero
cm=colormap;
clim=caxis;
mzero=interp1(clim,[1,length(cm)],0);
if mod(mzero,1)==0,
    cm(mzero,:)=1;
else,
    cm(floor(mzero):ceil(mzero),:)=1;
end
colormap(cm)