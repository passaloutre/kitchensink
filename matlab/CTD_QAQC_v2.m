%CTD QAQC
%
%ATTENTION: Before running this code, you must have a list of the ctd filenames  
%matched to the station names. See CTD_matchCast.m
%
%ATTENTION: This code contains while loops. If it seems to hang for a long
%period of time (>~1mintue), you may have encountered an infinite while
%loop. Press ctrl+c in the matlab command window. Report the issue and send
%the file to Diana.
%
%ATTENTION: After each plot, there is a pause. After reviewing the figure, 
%press any key to continue.
%
%This code should be used to QAQC CTD data. It will do the following:
%   1- Read a CTD ascii file*: the file must have the following format:
%       -	Time, hh:mm:ss:ss (date will be extracted from the cnv during
%       this processing)
%       -	Depth (salt water m) lat 30
%       -	Salinity (PSU)
%       -	Temperature (ITS-90, deg C)
%       -	OBS, backscatterance (D&A) (NTU)
%       -	Beam transmissions, Chelsea Seatech
%       -	Sound Velocity (Chen-Millero m/s)
%   *The ascii file should be made from a cnv file that was converted from
%   a hex file using the option to convert the upcast AND downcast. This
%   setting is important for #2. Follow the CTD SOP. 
%   
%   2- Remove the top 50 cm of each cast (provides noise reduction and junk
%   data removal).
%
%   3- Check for and split multiple casts in one file (ie someone forgot to turn off
%   the ctd between casts. 
%
%   4- Isolate the downcast. 
%
%   5- Plot original data with the downcast data to visually verifythe
%   number of downcasts in each file.
%
%   6- Plot each of the parameters from the ctd. View these for basic QAQC.
%   Each parameter should show expected patterns. Check for irregularities.
%
%   7- Write and save files of post-QAQC data.
%
%This code will output the following files: 
%
%   1- Write a csv file with the format: 
%   DD MMM YYYY HH:MM:SS,Depth (m),Salinity (PSU),Temperature (C),OBS (NTU),Transmission (%)
%
%   2- Save the variables from #1 in a mat file. 
%
%   3- Save the figure generated for QAQC as a png and a matlab fig.
%
%   4- Write a csv file containing a list of all the ctd files that have
%   been processed with this code. The format is:
%   Start Time,End Time,Station,Original Filename,Processed Filename,Processing Date
%
%To improve:
%   1- Line 153 - section to find the first cast is redundant with the
%   while loop.
%   2- Renaming with station name is highly dependent on the number of
%   characters in the original filename
%   3- All the naming is highly dependent on the number of characters in
%   the filenames -- try using slashes and dashes as the delimiter to
%   locate names
%
%Diana Di Leonardo
%02/17/2017

clear; clc; close all;


%Choose files
[filelist, pathname]= uigetfile('*.asc','Select ctd asc file','MultiSelect','on');


%Open file for saving a list of all the files and stations and
%times to write the header fr that file
%Only if the file hasn't been created already
if ~exist([pathname 'CTD_filelist_' pathname(end-6:end-1) '.csv'],'file')
    fid2 = fopen([pathname 'CTD_filelist_' pathname(end-6:end-1) '.csv'],'a');
    %Write header line
    %start time, end time, station, original filename, new filename,
            %processing date and time
    metahdr = 'Start Time,End Time,Station,Original Filename,Processed Filename,Processing Date';
    fprintf(fid2,'%s\n',metahdr);

    fclose(fid2);
end


%How many files were chosen?
if iscell(filelist)
    repeat = length(filelist);
else
    repeat=1;
end

%Loop through each ctd asc file
for n = 1:repeat
    
    %Get filename
    if iscell(filelist)
        filename = cell2mat(filelist(n));
    else
        filename = filelist;
    end
    
    fid = fopen([pathname filename]); %open ctd ascii file

    %read data
    dum = textscan(fid,'%s%f%f%f%f%f%f%f','headerlines',1,'delimiter',',');
    
    fclose(fid); %close ctd asii file
    
    
    timedum = dum{1};  %make matrix out of cell array of time data
    
    %Extract data data from cnv file
    cnvfile = [filename(1:end-3) 'cnv']; %cnv filename built from ascii filename
    cnvid = fopen([pathname cnvfile]); %open cnv file (text file)
    cdum = textscan(cnvid,'%s','delimiter','','endofline', ''); %read cnv file 
    fclose(cnvid); %close cnv file
    cnvtext = cdum{1}{1}; %turn cell into a single string
    
    ind = regexp(cnvtext,'cast '); %look for the date in cnv file as indicated by the word cast
    ddate = cnvtext(ind+9:ind+20); %indices of the date in the cinv file relative to the word cast
    
    
    datetimei = NaN*ones(size(timedum));
    for ii = 1:length(timedum)
        dtstr = [ddate cell2mat(timedum(ii))]; %String with date and time
        datetimei(ii,1) = datenum(dtstr); %convert to date number for ease of use
    end
    
    %Make matrix out of cell arrays of data
    %initial values (before split, before remove first 50cm)
    depthi = dum{2};
    sali = dum{3};
    tempi = dum{4};
    obsi = dum{5};
    xmissi = dum{6};
 
    
    %Replace 1st 50 cm of cast with NaN
    %This will split any multiple casts with NaN as the marker
    datetimei(depthi<0.5)=NaN;
    depthi(depthi<0.5)=NaN;
    
    %Using NaN as marker split out multiple casts in a single file
    %Begin to look for and split multiple casts in one file
    nn = find(~isnan(depthi),1,'first'); %first non NaN value
    a = 0; %counter for cell matrix to hold downcasts
    
    %Initialize cell arrays to hold intermediate processing step
    depthm = {};
    datetimem = {};
    salm = {};
    tempm = {};
    obsm = {};
    xmissm = {};
    
    while ~isempty(nn)

        %%%%
        %Find the first cast
        %%%%
        %First cast will be the first long section of values
        %Short snippents are not casts. Make them NaN
        %Repeat this section until first cast is found
        beg = 1; endd = 2;
        while length(beg:endd)<=20 %call a cast any section of longer than 20 values
            
            %Make any short snippets found in the last search NaN
            %Initialize with first 2 points of cast which will already be
            %NaN
            depthi(beg:endd) = NaN;
  
            %Find the indices of the cast
            beg = find(~isnan(depthi),1,'first'); %first non NaN value (first point in cast)
            jj = find(isnan(depthi(beg:end)),1,'first'); %next NaN(comes right after last point in cast)
            endd = beg+jj-2; %index of last value in original matrix (last point in cast)
            
           if isempty(beg) || isempty(endd) %this prevents an infinite while loop in the case of a downcast only file 
              break  %exit the loop
           end
        
        end
   
    %%%%
    %After finding the first cast:
    %%%%
    
    %Find index of first point and last point in cast*
    c1 = find(~isnan(depthi),1,'first'); %first non NaN value
    jj = find(isnan(depthi(c1:end)),1,'first'); %next NaN 
    c3 = c1+jj-2; %index of last non Nan value in original matrix
    
    %Find index of max point
    if ~isempty(c3)
        [~,I] = max(depthi(c1:c3));  
        c2 = c1 + I;
    else %if the cast has already been clipped for the downcast by the 
            %seabird software there will be no NaN marker at the end and c3
            %will be empty
        [~,I] = max(depthi(c1:end)); 
        c2 = c1 + I;
    end

    %*This is redundant with the above while loop. This is an area of
    %improvement for the future.
    %%%%
     
     
    %Isolate downcast for every variable of interest in a cell matrix
    a = a +1; %increment a, the counter for the cell array to hold the downcasts
    
    %variables for multiple casts (m)
    depthm(a) = {depthi(c1:c2)};
    datetimem(a) = {datetimei(c1:c2)};
    salm(a) = {sali(c1:c2)};
    tempm(a) = {tempi(c1:c2)};
    obsm(a) = {obsi(c1:c2)};
    xmissm(a) = {xmissi(c1:c2)};
    
    %NaN the first cast and look for the second
    depthi(c1:c3) = NaN;
  
    %exit condition
    nn = find(~isnan(depthi),1,'first'); %If there are no more casts this
    %will return an empty matrix which will exit the loop
       
    if isempty(c3)  %If your file is downcast only this is needed to prevent an infinite loop
        nn = [];
        depthm = {depthi(c1:c2)};
        datetimem = {datetimei(c1:c2)};
        salm = {sali(c1:c2)};
        tempm = {tempi(c1:c2)};
        obsm = {obsi(c1:c2)};
        xmissm = {xmissi(c1:c2)};
    end
    
    end
    
    h1 = figure('color','w');
    hold on
    plot(datetimei,dum{2})
    for b = 1:a
        plot(datetimem{b}, depthm{b},'g')
    end
    set(gca,'ydir','reverse')
    ylabel('depth (m)')
    xlabel('datenumber')
    title(filename(15:end-4))
    
    pause
    close(h1)
    
    clear ii jj b
    %Loop through the all the casts contained in the last ascii file
    for ii = 1:a

        %Convert the cell arrays to matrices
        depth = depthm{ii};
        datetime = datetimem{ii};
        sal = salm{ii};
        temp = tempm{ii};
        obs = obsm{ii};
        xmiss = xmissm{ii};
        
        %For each cast, QAQC the parameters with a plot
        h = figure('color','w');
        
        subplot(3,2,1)
        plot(datetime,depth)
        ylabel('depth (m)')
        xlabel('time')
        
        %Make good time label on x-axis (beginning and end of cast)
        xlimits = get(gca,'xlim');
        newxlab = datestr(xlimits,'HH:MM:SS');
        set(gca,'xtick',xlimits,'ydir','reverse','xticklabel',newxlab)

        subplot(3,2,2)
        plot(sal,depth)
        ylabel('depth (m)')
        xlabel('salinity (psu)')
        set(gca,'ydir','reverse','xlim',[0 35])
        
        subplot(3,2,3)
        plot(temp,depth)
        ylabel('depth (m)')
        xlabel('temperature (C)')
        set(gca,'ydir','reverse','xlim',[10 30])
        
        subplot(3,2,4)
        plot(obs,depth)
        ylabel('depth (m)')
        xlabel('obscuration (NTU)')
        set(gca,'ydir','reverse')
        
        subplot(3,2,5)
        plot(xmiss,depth)
        xlabel('transmission (%)')
        ylabel('depth (m)')
        set(gca,'ydir','reverse','xlim',[0 50])
        
        pause

               
        %Name a new file with the station name and save new csv*
        %*Make the renaming less dependent on the number of characters in
        %the original name
        sta = input(['Enter Station Name for ' filename(15:end-4) ' in single quotes.\n']); %Ask for station name
        newFilename = [filename(1:8) sta filename(15:end-4) '.csv']; 
        
        %Format header for new csv
        hdr = 'DD MMM YYYY HH:MM:SS,Depth (m),Salinity (PSU),Temperature (C),OBS (NTU),Transmission (%)';
        
        %Make datetime string
        datetimestr = datestr(datetime,'dd-mmm-yyyy HH:MM:SS.FFF');
        
        %Write csv file
        fid = fopen([pathname newFilename],'w');
        fprintf(fid,'%s\n',hdr);
        
        for jj = 1:length(depth)

            fprintf(fid,'%s,',datetimestr(jj,:));
            fprintf(fid,'%.2f,',depth(jj));
            fprintf(fid,'%.2f,',sal(jj));
            fprintf(fid,'%.2f,',temp(jj));
            fprintf(fid,'%.2f,',obs(jj));
            fprintf(fid,'%.2f\n',xmiss(jj));
            
        end
        
        fclose(fid);
        
        
        %Save mat file
        save([pathname newFilename(1:end-3) 'mat'], 'datetime','depth','sal','temp','obs','xmiss')
        
        %Save fig
        savefig(h,[pathname newFilename(1:end-3) 'fig'])
        
        %save jpg
        print(h,'-dpng', '-r300',[pathname newFilename(1:end-3) 'png'])
        
        close(h)
        
        
        %Open file for saving a list of all the files and stations and
        %times
        fid2 = fopen([pathname 'CTD_filelist_' pathname(end-6:end-1) '.csv'],'a');

        %Write file for saving a list of all the files and stations and
        %times
        %start time, end time, station, original filename, new filename,
        %processing date and time
        fprintf(fid2,'%s,',datetimestr(1,:));
        fprintf(fid2,'%s,',datetimestr(end,:)) ;
        fprintf(fid2,'%s,',sta);
        fprintf(fid2,'%s,',filename);
        fprintf(fid2,'%s,',newFilename(1:end));
        fprintf(fid2,'%s\n',datestr(now));
        
        fclose(fid2);
        
    end
    
    
    
end

