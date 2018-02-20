%script to run image Processing

%% Select "Paths" files to run
[FN,PN]=uigetfile('*.txt','Select IP files.','Multiselect','on');
if ~iscell(FN)
    FN=cellstr(FN);
end

parfor k=1:length(FN)
    pathfile=fullfile(PN,FN{k});
    PICS_imageProcessing(pathfile);
end
