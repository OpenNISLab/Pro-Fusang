%%% Code function:
%%%     rangefft on the input signal

function [datafft] = rangefft(retVal , rangefft_samples)
data = retVal;
datafft = fft(data , rangefft_samples);
end
