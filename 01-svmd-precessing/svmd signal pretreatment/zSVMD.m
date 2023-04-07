function [zsignal2] = zSVMD(signal , target_distance , target_Distance_range , Detection_range , Fs , slope , numADCSamples)
%Code function:
%   This function calls the svmd function from 
%   Mojtaba Nazari and Sayed Mahmoud Sakhaei. 2020. Successive variational 
%   mode decomposition. Signal Processing 174 (2020), 107610.
%   
%   The input signals are decomposed by svmd function to obtain multiple
%   imf sub-signals.Combined with the distance between the target and the
%   radar, the imf sub-signals belonging to the target object are selected 
%   to synthesize the signal returned by the target.

%%
%Keep the input data as row vectors
if size(signal,1) ~= 1
    signal = signal.';
end

%%
%Call the svmd function to decompose the signal
%----------------- Initialization
maxAlpha=1000; %compactness of mode
tau=0;%time-step of the dual ascent
tol=1e-6; %tolerance of convergence criterion;
stopc=3;%the type of stopping criteria

%-------------- SVMD function
[u,uhat]=svmd(signal,maxAlpha,tau,tol,stopc);


%%
%%% Screening imf sub-signals
c = 3e8; % Speed of light
give_up_colNum = 10;%To avoid zero frequency, start from the tenth column of the fft sequence
Detection_range = ceil( (Detection_range / (c/2/slope) ) / (Fs/numADCSamples) );
target_Distance_range = ceil( (target_Distance_range / (c/2/slope) ) / (Fs/numADCSamples) );

index = 1:numADCSamples;
freq_bin = (index - 1) * Fs / numADCSamples;
range_bin = freq_bin * c / 2 / slope;

mra = [];%Deposit the selected imf
num_generateIMF = size(u,1);


for target_Distance_range_id = 1:size(target_Distance_range,2)

    for imf_id = 1:num_generateIMF
        temp_imf = u(imf_id,:);
        temp_fft = fft(temp_imf);
        temp_fft = temp_fft(1 , 1:Detection_range);
        temp_absfft = abs(temp_fft);
        
        %Judge whether the current imf is zero frequency component
        [x,y] = find(temp_absfft == max(temp_absfft) );
        if y(1,1) < give_up_colNum
            continue;
        end
    
        %Extract the distance range corresponding to the current imf signal
        col_num = 1:1:Detection_range;
        sort_array = [temp_absfft.' , col_num.'];%The first is the peak energy and the second is the column number of that peak energy in rangefft's energy sequence.
        sort_array = sortrows(sort_array,-1);
        sort_array = sort_array(1:target_Distance_range(1,target_Distance_range_id) , :);
        range_min = range_bin(1 , min(sort_array(:,2)) ); 
        range_max = range_bin(1 , max(sort_array(:,2)) ); 
        
        %Decide whether to choose the imf
        if target_distance > range_min
            if target_distance < range_max
                mra = [ mra ; u(imf_id,:) ];
            end
        end
    end
    
    if size(mra,1) ~= 0
        break;
    end
end

% Sum down the rows of the selected multiresolution signals
levelForReconstruction = ones(1,size(mra,1));
levelForReconstruction = logical(levelForReconstruction);
zsignal2 = sum(mra(levelForReconstruction,:),1);
end