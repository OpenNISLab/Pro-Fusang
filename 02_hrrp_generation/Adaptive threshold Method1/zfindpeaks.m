%%% Code function:
%%%     In the rangefft sequence of the signal, the local maximum and column numbers 
%%%     belonging to both the main energy part and the local maximum are extracted.
%%%     Extract within the object width range.

function [EVP_peaks_value,EVP_peaks_colNum] = zfindpeaks(OneIF_rangefft , target_distance , target_Distance_range , slope , Fs , rangefft_samples , give_up_colNum)


if size(OneIF_rangefft,1) ~= 1
    OneIF_rangefft = OneIF_rangefft.';
end

OneIF_rangefft = abs(OneIF_rangefft);


c = 3e8;
range_start = target_distance - target_Distance_range/2;
range_start = ceil( (range_start / (c / 2/slope) ) / (Fs / rangefft_samples) );
if range_start < give_up_colNum 
    range_start = give_up_colNum;
end

range_end = target_distance + target_Distance_range/2;
range_end = ceil( (range_end / (c / 2/slope) ) / (Fs / rangefft_samples) );

OneIF_rangefft(1 , 1:range_start-1) = 0;
OneIF_rangefft(1 , range_end+1:end) = 0;



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


[pks,locs] = findpeaks(OneIF_rangefft,'minpeakheight',1); 


EVP_peaks_colNum = intersect(main_peaks_colNum , locs);

EVP_peaks_value = OneIF_rangefft(1 , EVP_peaks_colNum);
end


