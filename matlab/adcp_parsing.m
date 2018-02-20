path = 'E:\Projects\SaltWedge\ADCP\cross\';
% cd (path)
filelist = dir([path, '*ASC*']);

for i = 1:length({filelist.name})
    inputfile = [path filelist(i).name];
    g(i) = adcp_ascii(inputfile);
end

%%

close('all')
i = 5
fig1 = figure();
ax1 = axis();
[plot1 plot1] = contourf(g(i).elapdist, g(i).z(:,1), g(i).dir);
set(plot1,'LineStyle','none')
axis ij
shading interp
title(filelist(5).name)

%%
[g(i).distsort g(i).sortind] = sort(g(i).distmadegood);

