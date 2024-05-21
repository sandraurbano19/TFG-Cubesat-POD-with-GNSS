function [allAz, allEl, satIDs] = skyplot_data(spirent,Type)

    % SPIRENT
    idx_gps = strcmp(spirent.satData.Sat_type, Type);
    spirent.satData = structfun(@(x) x(idx_gps, :), spirent.satData, 'UniformOutput', false);

   % Determine unique PRNs and time points
    unique_prns = unique(spirent.satData.Sat_PRN);
    unique_times = unique(spirent.satData.Time_ms);

    num_prns = length(unique_prns);
    num_times = length(unique_times);

    allAz = nan(num_times,num_prns);
    allEl = nan(num_times,num_prns);

     for i = 1:num_prns
        idx_PRN = spirent.satData.Sat_PRN == unique_prns(i);
        sat_data = structfun(@(x) x(idx_PRN, :), spirent.satData, 'UniformOutput', false);

        % Find the indices of unique_times that correspond to sat_data.Time_ms
        idx_time = ismember(unique_times, sat_data.Time_ms);
    
        % Assign sat_data.Azimuth and sat_data.Elevation to the corresponding indices
        allAz(idx_time, i) = sat_data.Azimuth;
        allEl(idx_time, i) = sat_data.Elevation;

        % Find the last valid index
        last_valid_idx = find(idx_time, 1, 'last');
        
        % Extend the last valid value to the end
        if ~isempty(last_valid_idx)
            allAz(last_valid_idx+1:end, i) = allAz(last_valid_idx, i);
            allEl(last_valid_idx+1:end, i) = allEl(last_valid_idx, i);
        end
    end

    allAz = rad2deg(allAz);
    allEl = rad2deg(allEl);

    allAz(allAz < 0) = allAz(allAz < 0) + 360;
    allEl(allEl < 0) = allEl(allEl < 0) + 360;
    allEl(allEl > 90) =  missing;
    satIDs = unique_prns;

end