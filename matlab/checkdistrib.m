function [newind] = checkdistrib(vd, ind)

%Input
%vd: volume distribution
%ind: indexes of the volume distribution to check

%Output
%newind: the indexes of the volume distribution to keep

%Check the grain size distributions that are going into the average
distribs = cell2mat(ind);
grainsize = [2.06398812667888;2.43564720232950;2.87423033957137;3.39178844826598;...
    4.00254242654267;4.72327390715194;5.57378636489627;6.57744925494624;...
    7.76184013328219;9.15950240274753;10.8088395052348;12.7551701296437;...
    15.0519734294659;17.7623584647298;20.9607982440317;24.7351760127696;...
    29.1892000132631;34.4452530669046;40.6477552760606;47.9671322423814;...
    56.6044978359036;66.7971801829723;78.8252427100654;93.0191794216579;...
    109.768995854595;129.534925225545;152.860074218172;180.385345877184;...
    212.867049644301;251.197682405535;296.430451548758;349.808213849445];
    %the medians of the grain size bins for a LISST 100X Type C, random
    %particle shape

newind = distribs; %initialize new ind to original ind

    
h1 = figure('color','w');
hold on
    
for jj= 1:length(distribs)
    plot(grainsize,vd(distribs(jj),:))
    
    m = find(max(vd(distribs(jj),:))== vd(distribs(jj),:));
    text(grainsize(m),vd(distribs(jj),m),num2str(distribs(jj)));
    text(grainsize(end),vd(distribs(jj),end),num2str(distribs(jj)));
end

avg = nanmean(vd(distribs,:),1); %avg of the distribution
stdev = nanstd(vd(distribs,:),1); %standard deviation of the distribution

plot(grainsize, avg,'k','linewidth',2)
plot(grainsize, avg+2*stdev,'r','linewidth',2)
plot(grainsize, avg-2*stdev,'r','linewidth',2)


bad = input('Enter the indices of any bad distributions. Enter 0 if all are good. \n Input Multiple values in []\n');

for n = 1:length(bad)
    newind = newind(newind ~= bad(n));
end

if any(bad)>0
    hbad = figure('color','w');
    hold on
    plot(grainsize, vd(newind,:))
    pause
end


close(h1)

if exist('hbad','var')
    close(hbad)
end





