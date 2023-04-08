%%% Code function:
%%%     To calculate the distribution characteristics of the signal in the
%%%     IQ domain.

function [Point_density] = calculate_Point_density(temp_OneIF , numADCSamples , box_bin)
%Keep the input data as row vectors
if size(temp_OneIF,1) ~= 1
    temp_OneIF = temp_OneIF.';
end

%%
% Data preparation

%Calculate a move value (multiple of unit area parameter), move both the
%real and imaginary parts of the current IF signal the same distance along
%the positive direction of the coordinate axis, ensure that the scatter
%distribution of the IQ domain of the IF signal is unchanged, and the
%coordinates of all points are positive.
map_move = abs(min( [real(temp_OneIF),imag(temp_OneIF)] )) + 1;
map_move = ceil(map_move/box_bin) * box_bin;
max_label = map_move + max( [real(temp_OneIF),imag(temp_OneIF)] );
map_Array = zeros(ceil(max_label/box_bin) , ceil(max_label/box_bin));

%%
% Computational distribution characteristics
point_area = 0;
for point_id = 1:numADCSamples
    real_OnePoint = real(temp_OneIF(1,point_id)) + map_move;
    imag_OnePoint = imag(temp_OneIF(1,point_id)) + map_move;
    
    real_OnePoint_InNewbox_bin = ceil(real_OnePoint/box_bin);
    imag_OnePoint_InNewbox_bin = ceil(imag_OnePoint/box_bin);
    if map_Array(real_OnePoint_InNewbox_bin , imag_OnePoint_InNewbox_bin) ~= 1
        map_Array(real_OnePoint_InNewbox_bin , imag_OnePoint_InNewbox_bin) = 1;
        point_area = point_area + 1;
    end
end

Point_density = numADCSamples / point_area;
end