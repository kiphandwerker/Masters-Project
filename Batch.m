clc
clearvars
close all
%% 
mainFolder = fullfile('F:\LMU Project\LMU_Participants\LMU');
topLevelFolder = uigetdir(mainFolder);

allSubFolders = genpath(topLevelFolder);
remain = allSubFolders;

listofFolderNames = {};
    [singleSubFolder,matches] = strsplit(remain, ';');
    if isempty(singleSubFolder)
        disp('There ain''t'' nothin'' in there fool!)')
    end
listofFolderNames = [listofFolderNames singleSubFolder];

numberOfFolders = length(listofFolderNames);
  

%%
for k = 2:numberOfFolders -1
    thisFolder = listofFolderNames{k};
    fprintf('Processing folder %s\n', thisFolder)
    
    % Load Data
    
    Lname = dir([thisFolder '\*_L.csv']);
    Ldata = dlmread([thisFolder '\' Lname.name] ,',' ,1, 0);
    
    Rname = dir([thisFolder '\*_R.csv']);
    Rdata = dlmread([thisFolder '\' Rname.name] ,',' ,1, 0);
    
    GetName = string(strsplit(Lname.name, '_'));
    fprintf('SAVING...%s''s data\n',GetName(1))
    name = GetName(1);
    
    % Filter data and get Resultant Acceleration
    LdataFilter = (bw_filter(Ldata(:,2:4),1000,100,"low",6))/9.81;
    LLeg = ((LdataFilter(:,1).^2) + (LdataFilter(:,2).^2) + (LdataFilter(:,3).^2)).^0.5;
    
    RdataFilter = (bw_filter(Rdata(:,2:4),1000,100,"low",6))/9.81;
    RLeg = ((RdataFilter(:,1).^2) + (RdataFilter(:,2).^2) + (RdataFilter(:,3).^2)).^0.5;
    % Set Threshold
    Lx = 1:length(LLeg);
    [Lpk,Llc] = findpeaks(LLeg,'MinPeakHeight',6,'MinPeakDistance',100);
    LLegPeaks = [Lpk, Llc];
    
    Rx = 1:length(RLeg);
    [Rpk,Rlc] = findpeaks(RLeg,'MinPeakHeight',6,'MinPeakDistance',100);
    RLegPeaks = [Rpk, Rlc];
    
    % Bins
    Lrpk =round(LLegPeaks(:,1));
    Lsrpk = sort(Lrpk);
    
    Rrpk =round(RLegPeaks(:,1));
    Rsrpk = sort(Rrpk);
    
    [LPeaks LI] = hist(Lsrpk, unique(Lsrpk));
    LPeaks = LPeaks';
    LPeaksVI = [LI LPeaks];
    
    [RPeaks RI] = hist(Rsrpk, unique(Rsrpk));
    RPeaks = RPeaks';
    RPeaksVI = [RI RPeaks];
    
    % DLS
    LeftDLS(k,:) = DailyLoadStim(LPeaksVI, 4);
    RightDLS(k,:) = DailyLoadStim(RPeaksVI, 4);
    
    data(k,:) = [name LeftDLS(k) RightDLS(k)];
    
end
%%
data(1,:) = [];
T = table(data(:,1),str2double(data(:,2)),str2double(data(:,3)),'VariableNames',{'Subjects','Left_Leg_DLS','Right_Leg_DLS'})
%%
dlgTitle    = 'Save option';
dlgQuestion = 'Would you like to save this table?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if isequal(choice,'No') || isempty(choice)
    disp('DLS table not saved.')
else
    [tabfilename, tabpathname] = uiputfile('*.xlsx','Save DLS table');
    if isequal(tabfilename,0) || isequal(tabpathname,0)
        uiwait(warndlg({'File not saved.';'Click OK to continue.'},'Warning!'));
    else
        writetable(T,[tabpathname tabfilename])
    end
end
