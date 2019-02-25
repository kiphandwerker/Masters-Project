%% Clear House
clc
clearvars
close all

%% Read in numeric data using dlmread
[filename,pathname] = uigetfile('*.csv','Pick a file to process');
%check if user presses cancel on the dialog
if isequal(filename,0) || isequal(pathname,0)
    disp('File not selected.');
    return
else
    disp(['Processing file ','''',filename,'''', ' ... This may take a minute.']);
    disp(' ');
    data1 = dlmread([pathname filename] ,',',1,0);
    Leg1 = questdlg('What leg is this?',...
        'Leg Box',...
        'Left Leg','Right Leg','Cancel','Cancel');
    if isequal(Leg1, 'Cancel') || isequal(Leg1, 0)
        uiwait(warndlg('A leg must be selected to continue!','Warning!'))
        Leg1 = questdlg('Please choose a leg to continue',...
        'Leg Box',...
        'Left Leg','Right Leg','Cancel','Cancel');
        return
    end
end
%% Read in Second File
cd(pathname);
Ans = questdlg('Do you want to read in another file?');

if isequal(Ans, 'No') || isequal(Ans, 'Cancel')
    disp('Processing one file.');
    disp(' ');
else
    [filename2,pathname2] = uigetfile('*.csv', 'Pick another file to process');
    if isequal(filename,0) || isequal(pathname,0)
        disp('Second file not selected.');
        return
    else
        disp(['Processing second file ','''',filename2,'''', ' ... This may also take a minute.']);
        disp(' ');
        data2 = dlmread([pathname2 filename2] ,',',1,0);
            if isequal(Leg1, 'Left Leg')
                Leg2 = 'Right Leg';
                    if isequal(Leg1, 'Right Leg')
                         Leg2 = 'Left Leg';
                    end
            end
        % Filter each X Y Z acceleration and get resultant acceleration for
        % data 2
        time2 = data2(:,1);
        BW_Filt_Accel2 = (bw_filter(data2(:,2:4),1000,100,"low",4))/9.81;
        res_acc2 = ((BW_Filt_Accel2(:,1).^2) + (BW_Filt_Accel2(:,2).^2) + (BW_Filt_Accel2(:,3).^2)).^0.5;
    end
end

%% Filter each X Y Z acceleration and get resultant acceleration
time = data1(:,1);
prompt = {'Enter Cut Off Frequency:','Enter Frequency Order:'};
titleBW = 'Low Pass Butterworth';
dims = [1 50];
definput = {'100','6'};
BWF = inputdlg(prompt,titleBW,dims,definput);

if isempty(BWF)
    disp('Filtering Frequency is Undefined')
    return
else
    b1 = str2double(char(BWF(1)));
    d1 = str2double(char(BWF(2)));
end

BW_Filt_Accel = (bw_filter(data1(:,2:4),1000,b1,"low",d1))/9.81;
res_acc1 = ((BW_Filt_Accel(:,1).^2) + (BW_Filt_Accel(:,2).^2) + (BW_Filt_Accel(:,3).^2)).^0.5;

%Data 2
if isequal(Ans,'Yes')
    b2 = str2double(char(BWF(1)));
    d2 = str2double(char(BWF(2)));
    time2 = data2(:,1);
    BW_Filt_Accel2 = (bw_filter(data2(:,2:4),1000,b2,"low",d2))/9.81;
    res_acc2 = ((BW_Filt_Accel2(:,1).^2) + (BW_Filt_Accel2(:,2).^2) + (BW_Filt_Accel2(:,3).^2)).^0.5;
end

%% Choose Activity
list = {'Walking','Jogging','Running','Athletic'};
[indx,tf] = listdlg('PromptString','Please select your activity',...
                    'ListString',list,...
                    'Name','Activity',...
                    'SelectionMode','single',...
                    'ListSize',[200,100],...
                    'OkString','Apply',...
                    'CancelString','Custom');
                
if isequal(tf,0)
    %uiwait(msgbox('Threshold set to the default of 3.'))
    %thresh = 3;
        prompt2 = {'Enter Custom Threshold: '};
        Cust = 'Threshold';
        dims2 = [1 40];
        definput2 = {''};
        custthresh = inputdlg(prompt2,Cust,dims2,definput2);
        thresh = str2double(char(custthresh));
            if isnan(thresh)
                disp('Threshold not defined')
                return
            end
else
    switch indx
        case 1
            thresh = 3;
        case 2
            thresh = 4;
        case 3
            thresh = 5;
        case 4
            thresh = 6;
    end
end
%% Message Box
uiwait(warndlg('You will now be prompted to check the peaks for your graphs. Simply click on the peak you do not want to count and press ''ENTER'' when done.','Peak Checker'))
%% Plot
x = 1:length(res_acc1);
[pk,lc] = findpeaks(res_acc1,'MinPeakHeight',thresh,'MinPeakDistance',100);
peakstuff = [pk, lc];
f1 = figure;
plot(x,res_acc1,peakstuff(:,2),peakstuff(:,1),'*r')
steps = num2str(length((peakstuff)));
refline([0 thresh]);
set(f1,'Name',([Leg1,' Steps Detected']));
title([Leg1,' Steps Detected = ',steps,'.']);

[coord] = ginput;
for i = 1:length(coord)
    dist = sqrt(sum(bsxfun(@minus,peakstuff,coord(i)).^2,2));
    closest = peakstuff(find(dist==min(dist)),:);
    del = find(peakstuff(:,1) == closest(:,1));
    peakstuff(del ,:) = [];
end



%%
% d = diff(lc);
% meanspeed = mean(d);

%% If second file is loaded in
if isequal(Ans, 'Yes')
    x2 = 1:length(res_acc2);
    f3 = figure;
    [pk2,lc2] = findpeaks(res_acc2,'MinPeakHeight',thresh,'MinPeakDistance',100);
    peakstuff2 = [pk2,lc2];
    plot(x2,res_acc2,peakstuff2(:,2),peakstuff2(:,1),'*r')
    refline([0 thresh]);
    steps2 = num2str(length(peakstuff2));
    set(f3,'Name',([Leg2, ' Steps Detected']));
    title([Leg2, ' Steps detected = ',steps2]);
    
    [coord2] = ginput;
    for i = 1:length(coord2)
        dist = sqrt(sum(bsxfun(@minus,peakstuff2,coord2(i)).^2,2));
        closest = peakstuff2(find(dist==min(dist)),:);
        del = find(peakstuff2(:,1) == closest(:,1));
        peakstuff2(del ,:) = [];
    end

end

close all
%%
if isequal(Ans, 'Yes')
    xx1 = round((length(x)*.25)/1000);
    xxx1 = round((length(x)*.5)/1000);
    xxxx1 = round((length(x)*.75)/1000);
    xxxxx1 = round((length(x))/1000);
    
    f1a = subplot(2,2,1);
    plot(x,res_acc1,peakstuff(:,2),peakstuff(:,1),'*r')
    steps = num2str(length((peakstuff)));
    refline([0 thresh]);
    xlabel('Seconds');
    title([Leg1,' Steps Detected = ',steps,'.']);
    box off
    
    f2a = subplot(2,2,2);
    rpk =round(peakstuff(:,1));
    srpk = sort(rpk);
    histogram(srpk)
    xlabel('Step Forces');
    title([Leg1,' Peak Step Accelerations from ',steps,'.']);
    box off
    
    xx2 = round((length(x2)*.25)/1000);
    xxx2 = round((length(x2)*.5)/1000);
    xxxx2 = round((length(x2)*.75)/1000);
    xxxxx2 = round((length(x2))/1000);
    
    f3a = subplot(2,2,3);
    plot(x2,res_acc2,peakstuff2(:,2),peakstuff2(:,1),'*r')
    steps2 = num2str(length((peakstuff2)));
    refline([0 thresh]);
    xlabel('Seconds');
    title([Leg2,' Steps Detected = ',steps2,'.']);
    box off
    
    f4a = subplot(2,2,4);
    rpk2 = round(peakstuff2(:,1));
    srpk2 = sort(rpk2);
    histogram(srpk2)
    xlabel('Step Forces');
    title([Leg2,' Peak Step Accelerations from ',steps2,'.']);
    
    set(gcf,'Position',[100 75 1000 600]);
    set(f1a,'Xlim',[0 length(res_acc1)],...
        'Xticklabels',[0 xx1 xxx1 xxxx1 xxxxx1]);
    set(f3a,'Xlim',[0 length(res_acc2)],...
        'Xticklabels',[0 xx2 xxx2 xxxx2 xxxxx2]);
    box off
    uiwait(gcf)
else
    xx1 = round((length(x)*.25)/1000);
    xxx1 = round((length(x)*.5)/1000);
    xxxx1 = round((length(x)*.75)/1000);
    xxxxx1 = round((length(x))/1000);
    
    f1a = subplot(1,2,1);
    plot(x,res_acc1,peakstuff(:,2),peakstuff(:,1),'*r')
    steps = num2str(length((peakstuff)));
    refline([0 thresh]);
    xlabel('Seconds');
    title([Leg1,' Steps Detected = ',steps,'.']);
    box off
    
    f2a = subplot(1,2,2);
    rpk =round(peakstuff(:,1));
    srpk = sort(rpk);
    histogram(srpk)
    xlabel('Step Forces');
    title([Leg1,' Peak Step Accelerations from ',steps,'.']);
    box off
    
    set(gcf,'Position',([100 75 1000 600]));
    set(f1a,'Xlim',[0 length(res_acc1)],...
        'Xticklabels',[0 xx1 xxx1 xxxx1 xxxx1]);
end
clear xx1 xx2 xxx1 xxx2 xxxx1 xxxx1 xxxxx1 xxxxx2 
%%
%---Leg1
[L1Peaks L1I] = hist(srpk, unique(srpk));

L1Peaks = L1Peaks';

Leg1Peaks = [L1I L1Peaks];

%---Leg2
[L2Peaks L2I] = hist(srpk2, unique(srpk2));

L2Peaks = L2Peaks';

Leg2Peaks = [L2I L2Peaks];

%% Calculate Compressive bone force
Leg1DLS = DailyLoadStim(Leg1Peaks, 4);
Leg2DLS = DailyLoadStim(Leg2Peaks, 4);

%%
prompt = {'Max for low intensity:','Max for moderate intensity:'};
IntRan = 'Intensity Ranges';
dims = [1 50];
defIR = {'10','20'};
IntRange = inputdlg(prompt,IntRan,dims,defIR);
if isempty(IntRange)
    LB = 10;
    MB = 20;
else
    LB = str2double(char(IntRange(1,1)));
    MB = str2double(char(IntRange(2,1)));
    Lower = find(Leg1Peaks(:,1)== LB);
    Moder = find(Leg1Peaks(:,1)== MB);
end
% Lower = find(Leg1Peaks(:,1)== LB);
% Moder = find(Leg1Peaks(:,1)== MB);

%% Leg 1
TC = sum(Leg1Peaks(:,2));
LowLeg1 = round(sum(Leg1Peaks(1:Lower,2))/TC * 100,2);
ModLeg1 = round(sum(Leg1Peaks(Lower + 1:Moder,2))* 100/TC,2);
HighLeg1 = round(sum(Leg1Peaks(Moder + 1:end,2))* 100/TC,2);

% Leg 2
TC2 = sum(Leg2Peaks(:,2));
LowLeg2 = round(sum(Leg2Peaks(1:Lower,2))* 100/TC2,2);
ModLeg2 = round(sum(Leg2Peaks(Lower + 1:Moder,2))* 100/TC2,2);
HighLeg2 = round(sum(Leg2Peaks(Moder + 1:end,2))* 100/TC2,2);
%% Create table
Leg = {Leg1;Leg2};
Low = [LowLeg1;LowLeg2];
Moderate = [ModLeg1;ModLeg2];
High = [HighLeg1;HighLeg2];
DLS = [Leg1DLS;Leg2DLS];

T = table(Leg,Low,Moderate,High,DLS)

%%
dlgTitle    = 'Save option';
dlgQuestion = 'Would you like to save this table?';
choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if isequal(choice,'No') || isempty(choice)
    disp('Intensity table not saved')
else
    [tabfilename, tabpathname] = uiputfile('*.xlsx','Save intensity table');
    if isequal(tabfilename,0) || isequal(tabpathname,0)
        uiwait(warndlg({'File not saved.';'Click OK to continue.'},'Warning!'));
    else
        writetable(T,[tabpathname tabfilename])
    end
end
%%
name1 = Leg1 + " Stress Bins";
name2 = Leg1 + " Loading Cycles";
name3 = Leg2 + " Stress Bins";
name4 = Leg2 + " Loading Cycles";
names = [name1, name2, name3, name4];
vals = [Leg1Peaks(:,1),Leg1Peaks(:,2),Leg2Peaks(:,1),Leg2Peaks(:,2)];
out = [names;num2cell(vals)];
OutT = table(out);

dlgTitle    = 'Save option';
dlgQuestion = 'Would you like to save the Stress Bins and Loading Cycle table?';
binsave = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');

if isequal(binsave,'No') || isempty(binsave)
    disp(' ')
    disp('Stress Bins and Loading Cycle table not saved')
    disp(' ')
    disp('Thank you for playing!')
else
    [binfilename, binpathname] = uiputfile('*.xlsx','Save table');
    if isequal(binfilename,0) || isequal(binpathname,0)
        uiwait(warndlg({'File not saved.';'Click OK to continue.'},'Warning!'));
    else
        writetable(OutT,[binpathname binfilename],'WriteVariableNames',false);
    end
end






