%script demonstrating CH3D I/O functions

%CODE CELLS:
%The double percent signs (%%) indicate the start of a code cell.  Code
%cells allow you to execute single portions of code at once.  We'll make
%use of this later.  When you position the cursor within a code cell, the
%code cell should be highlighted yellow.  If you don't see this, go to the
%cell menu (at the top of the Matlab interface) and enable cell mode.  
%For more help on CODE CELLS, go to "rapid development" in the index of the
%help navigator.

%CODE CELL TOOLBAR
%With cell mode enabled, you should have the cell toolbar in your editor.
%To check this, right click on the title bar of the Matlab editor.  If not
%enabled, turn on the Editor Cell Mode Toolbar.

%STRUCTS
%structured arrays or structs are a convienient way to group related data
%that may have different types, and/or sizes.  Structs are used throughout
%this example and are easy to deal with once you understand the
%fundamentals.  Instead of containing a single dataset or having a single 
%datatype, structs contain fields, which may be of mixed datatypes and sizes.
%
%For example, say we have struct, s, with fields x,y, and z.  Say we want
%to access field x.  You will then type:
%s.x
%

%% Load the grid
fgrd='grid-blk01.inp';
grd=load_ch3dgrid(fgrd);
%show the loaded struct
grd
%You'll see that grd contains many fields including header, ni, nj, etc...
%Field descriptions are found in the help for the generating function.
help load_ch3dgrid
%or
doc load_ch3dgrid
%get a field from the grd struct
grd.header
grd.ni

%% Display the Grid
hgrd=pcolor(grd.x,grd.y,grd.z);
%Notice here that I use the cell corners.
%hgrd is the handle to the graphics object created.  We can use this handle
%later to change properties of the graphics object.

%force axis scaling to be equal
axis equal

%display the colorbar and add a title
hcb=colorbar;  %hcb is the axis handle for the colorbar
hcb_title=get(hcb,'Title'); %hcb_title is the handle to the title string
set(hcb_title,'String','depth (m)') %this changes the string in the title
%NOTES:
%1) use the zoom and pan tools on the figure window to inspect the grid.
%2) use the select tool to graphically change object attributes, such as
%turning off the cell boundaries.

%turn cell boundaries on/off with code
%boundaries off:
set(hgrd,'EdgeColor','none')
%boundaries back on
set(hgrd,'EdgeColor','k') %'k' means black.

%Change the shading to interpolated
set(hgrd,'EdgeColor','none')
set(hgrd,'FaceColor','interp') 

%Change the settings back
set(hgrd,'EdgeColor','k','FaceColor','flat')

%You can also display the grid as a wireframe.  Getting the rotation and
%positioning in 3D is a bit tricky.  See POA_wireframe.png as an example.
%Here's some code if you'd like to try:
hmesh=mesh(grd.x,grd.y,-grd.z);
set(gca,'DataAspectRatio',[1,1,0.1]) %gives 10x vertical exaggeration
set(hmesh,'EdgeColor',0.7*[1,1,1]); %gray mesh
campos=[498.6e3,801.7e3,300];
set(gca,'CameraPosition',campos,...
    'CameraTarget',[506e3,808e3,0],...
    'CameraViewAngle',25)

%% Display the cell centers on the grid
%Note using cell corners with pcolor
hgrd=pcolor(grd.x,grd.y,grd.z);
hold on %this keeps the next plotting actions from overwriting the previous
%Now we can plot the cell centers
plot(grd.xc,grd.yc,'k.') %This plots the centers as black dots
hold off 
%Now you can zoom in and look at the results.

%% Create DA file from wse.dat and velocity.dat
%The code mk_ch3dda.m converts the ascii datasets to binary
%There are two options for the time reference
%1) Time indicated as elapsed time from start of simulation
%2) Time indicated as date/time in Matlab's datenum format

%1) Convert the ascii files to DA with elapsed time reference
grd=load_ch3dgrid(fgrd);
mk_ch3dda(grd,'wse.dat','velocity.dat','poa_et.da');

%2) Convert ascii files to DA with datenum reference
%The only difference is the last argument, which is the start time of the
%simulation.
grd=load_ch3dgrid(fgrd);
mk_ch3dda(grd,'wse.dat','velocity.dat','poa_dn.da','8/1/2006 0:00');

%% Load a snapshot from the DA file
%The code load_ch3dda.m loads data from the DA file
%Here we will load the 100th snapshot into the struct, ch3
ch3=load_ch3dda('poa_dn.da',100);
%display the struct
ch3
%what is the associated time?
datestr(ch3.time)
%what is the maximum u velocity?
max(ch3.u(:))
%what is the range of v velocities?
minmax(ch3.v)

%% Display ETA on the grid
%We want to display the results from the cell centers on the grid defined
%by the corners.  Because we have an extra set of corners, we need to
%adjust the eta dataset to conform to the grid defined by corners.
eta=nan(size(grd.x)); %Here I create a dummy dataset, same size as corners
%now replace all but the extra set of corners with the eta data
eta(1:end-1,1:end-1)=ch3.eta;
heta=pcolor(grd.x,grd.y,eta);
%now display the colorbar (as before)
hcb=colorbar;  %hcb is the axis handle for the colorbar
hcb_title=get(hcb,'Title'); %hcb_title is the handle to the title string
set(hcb_title,'String','wse (cm?)') %this changes the string in the title

%% Cycle through the eta results
%Here we start really using the power of code cells.  Highlight this code
%cell and change the value of k by selecting the number on the right hand
%side.  Then increase or decrease the value of k by toggling the (-) or (+)
%buttons on the Code cell toolbar.  The value of k will change and the rest
%of the code cell will run.
%Make sure you run the previous cell once.  I will reuse some of the
%graphics handles for efficiency.
k=1; %This is the timestamp
dafile='poa_dn.da'; %filename of the binary, DA file
set(gca,'CLim',[-500,500]) %This sets the color limits to the values given.
ch3=load_ch3dda(dafile,k);
eta(1:end-1,1:end-1)=ch3.eta;
%Here I am "pushing" the new eta data into the previously created graphics
%object, heta
set(heta,'CData',eta);
%Let's add a title with the timestamp
title(sprintf('Time: %s',datestr(ch3.time,'dd-mmm-yyyy HH:MM')))
%Don't forget, you can change the display properties of the patch object.
%That's what the graphical object that holds the grid and coloring
%Here are some suggested options
set(heta,...
    'EdgeColor',0.5*[1,1,1],... %options: 'k','none', or 0.5*[1,1,1] {dk.gray}
    'FaceColor','flat') %options: 'flat','interp'

%% Plot Velocity results on grid
%I'll present a simple example here.  
%Display the grid
hgrd=pcolor(grd.x,grd.y,zeros(size(grd.x)));
set(hgrd,'FaceColor',0.5*[1,1,1],...
    'EdgeColor','none')
hold on
%Load some data
ch3=load_ch3dda(dafile,500);
%Display the velocity vectors at cell centers.
%We will be presenting velocity data in length space, so must come up with
%some scaling parameter to represent velocity in length space.
Sv=1; %so 1 cm/s (?) scales to 1 m on the grid
hq=quiver(grd.xc,grd.yc,Sv*ch3.u,Sv*ch3.v,0,'r');
hold off
%You can zoom in and pan around to look at the velocity field.

%% Cycle through the VEL results
%Run the previous cell first
k=400; %timestamp
Sv=1; % 1 velocity unit scales to Sv length units in display
%Load the data
ch3=load_ch3dda(dafile,k);
set(hq,'UData',Sv*ch3.u,'VData',Sv*ch3.v)
