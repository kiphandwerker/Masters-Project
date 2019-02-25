function [DLS] = DailyLoadStim(data, m)
    % DailyLoadStim is a function that estimates compressive bone force
    % based on:
    % SIGMA - the effective stress(peak loads from accelerations),
    % n - the number of loading cycles,
    % m - the weighting factor
    %
    % INPUTS:
        % DATA - n x 2 column matrix with SIGMA as row 1 and n as row 2
        %
        % m - weighting factor
    %    
    %   
    % Created by Kip Handwerker (2019)
for i = 1:length(data)
   sigman(i) = ((data(i,1)^m) * data(i,2));
   sigmansum = sum(sigman);
   DLS = sigmansum^(1/m);
end