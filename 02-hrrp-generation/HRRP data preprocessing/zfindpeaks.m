%%% Code function:
%%%     In the rangefft sequence of the signal, the local maximum and column numbers 
%%%     belonging to both the main energy part and the local maximum are extracted.

function [EVP_peaks_value,EVP_peaks_colNum] = zfindpeaks(OneIF_rangefft , give_up_colNum , Distance_range)
%Keep the input data as row vectors
if size(OneIF_rangefft,1) ~= 1
    OneIF_rangefft = OneIF_rangefft.';
end

OneIF_rangefft = abs(OneIF_rangefft);
OneIF_rangefft(1 , 1:give_up_colNum-1) = 0;
OneIF_rangefft(1 , Distance_range+1:end) = 0;

%%
%%%Extract the column number corresponding to the major energy part
all_power = sum(OneIF_rangefft);

col_num = 1:1:size(OneIF_rangefft,2);
sort_array = [OneIF_rangefft.' , col_num.'];
sort_array = sortrows(sort_array,-1);
temp_power_sum = 0;
main_peaks_colNum = [];
for col_id = 1:size(OneIF_rangefft,2)
    temp_power_sum = temp_power_sum + sort_array(col_id , 1);
    main_peaks_colNum = [main_peaks_colNum , sort_array(col_id , 2)];
    if temp_power_sum/all_power >= 0.99
        break;
    end
end

%%
%%%Extract the column number of the local maximum
[pks,locs] = findpeaks(OneIF_rangefft,'minpeakheight',1);

%%
%%%Extract the local maximum and column number that belong to both the main energy part and the local maximum
EVP_peaks_colNum = intersect(main_peaks_colNum , locs);%column number
EVP_peaks_value = OneIF_rangefft(1 , EVP_peaks_colNum);%local maximum
end


