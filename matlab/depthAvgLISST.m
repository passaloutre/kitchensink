function [vdAvg, varargout]= depthAvgLISST(depth,depthAvg, vd, plusminus,varargin)
%
%Calls
%[vdAvg]= depthAvgLISST(depth,depthAvg, vd, plusminus): returns only the
%depth averaged volume concentration distribution
%
%[vdAvg, rg]= depthAvgLISST(depth,depthAvg, vd, plusminus):
%in addition to the averaged volume distribution, returns the range of the 
%of the values used in the average to provide an estimate of the
%variability of the volume distribution
%
%[vdAvg, rg, ind]= depthAvgLISST(depth,depthAvg, vd, plusminus):
%in addition to the averaged volume distribution and range, returns the 
%indexes of vd used to do the averaging; can be used to average other
%parameters as needed 
%
%[vdAvg, rg, ind, stdev]= depthAvgLISST(depth,depthAvg, vd, plusminus): in 
%addition to each of the above mentioned outputs, returns the standard 
%deviation of the values used in the average volume distribution; use only 
%when large numbers of depths are used to calculate the average; ie. a standard
%deviation of 2 or 3 points has little meaning
%
%[vdAvg, rg, ind, stdev, otherAvg]= depthAvgLISST(depth,depthAvg, vd,
%plusminus,other): in addition to each of the above mentioned outputs,
%reutns the averages of other data
%
%
%Input
%depth: vector of the depths of the data
%depthAvg: vector of depths at which you want the averages; this will be
%   the approximate center point of the average data; must be FRACTIONAL
%   depths
%vd: the data to be averaged
%plusminus: the amount to go above and below the values of the depthsAvg
%   vetor
%   eg: depthAvg = [0.3, 0.7]; 
%       plusminus = 0.1;
%       The averages will be from 0.2 to 0.4 and from 0.6 to 0.8.
%other: any other variables that you want to average; as a matrix; optional
%
%Output
%vdAvg: The averaged data
%rg: The range of the of the values used in the average of the volume
%   concentrations
%ind: the indexes used to do the averaging; can be used to average other
%   parameters as needed
%stdev: the standard deviation of the values used in the average of the
%   volume concentration
%otherAvg: the averages of the other data; optional
%
%
%Diana Di Leonardo
%9/22/15


if ~isempty(varargin)
    other = varargin{:};
else
    other = NaN*zeros(size(vd));
end

%Calculate fraction depth
fd = depth/max(depth);
    
%find depths between which to average
upper = depthAvg + plusminus;
lower = depthAvg - plusminus;

%find bracketing indices (inclusive at upper end and exclusive at lower
%end)
ind = cell(size(depthAvg));
for ii =1:length(depthAvg)
    ind{ii} = find(fd<=upper(ii) & fd>lower(ii));
    %Check that all the distributions to be averaged actually look good
    [newind] = checkdistrib(vd, ind(ii));
    ind{ii} = newind;
end


%Average everything within 
vdAvg = NaN*zeros(length(depthAvg),32);
rg = NaN*zeros(size(vdAvg));
stdev = NaN*zeros(size(vdAvg));
[~,n] = size(other);
otherAvg = NaN*zeros(length(depthAvg),n);
for ii = 1:length(depthAvg)
    
    if length(ind{ii})-sum(isnan(vd(ind{ii}))) ==2
        warning(['The average for fractional depth ' num2str(depthAvg(ii)) ' only has 2 points.']);
    elseif length(ind{ii})-sum(isnan(vd(ind{ii}))) ==1
        warning(['The average for fractional depth ' num2str(depthAvg(ii)) ' only has 1 point.']);
    
    elseif sum(isnan(vd(ind{ii},1))) > length(ind{ii})/2
        
        allInd = ind{ii};
        goodInd = allInd(~isnan(vd(ind{ii},1)));
        
        avgFD = mean(depth(goodInd)/max(depth));
        
        warning(['The points for fractional depth ' num2str(depthAvg(ii)) ' are more than half NaN. '...
            num2str(sum(isnan(vd(ind{ii})))) ' out of ' num2str(length(ind{ii})) ' are NaN. '...
            'The average fractional depth is ' num2str(avgFD) ' or ' num2str((depthAvg(ii)-avgFD)*max(depth)) ' meters.']);
        
        
    end
    
    vdAvg(ii,:) = nanmean(vd(ind{ii},:));
    rg(ii,:) = range(vd(ind{ii},:));
    stdev(ii,:) = std(vd(ind{ii},:));
    otherAvg(ii,:) = nanmean(other(ind{ii},:));
end
    


varargout{1} = rg;
varargout{2} = ind;
varargout{3} = stdev; 
varargout{4} = otherAvg;









