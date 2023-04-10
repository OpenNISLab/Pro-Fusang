%%% Code function:
%%%     Returns a list of curvature labels in the corresponding order based
%%%     on the entered list of object names.

function [HRRP_thing_curvature_label_list] = get_curvature_label(HRRP_thing_name_list)

%Import the association table of object names and curvature labels
file_path_name = 'Your local path\Fusang_dataset\object_information\AllThingName_CurvatureLabel.xlsx';%The file path to the association table of object names and curvature labels
T = readtable(file_path_name);
Allthing_name_list = T.object_name;%Object name list
curvature_label_list = T.curvature_label;%Curvature label list

All_thing_num = size(Allthing_name_list , 1);%The number of objects in the project
HRRP_thingNum = size(HRRP_thing_name_list , 1);%Number of objects currently being processed
HRRP_thing_curvature_label_list = [];

for thing_id = 1:HRRP_thingNum
    thing_name = HRRP_thing_name_list{thing_id , 1};
    row = 0;
    
    %Locate the row number of the current object in the object name list
    for j = 1:All_thing_num
        if isequal( Allthing_name_list{j,1} , thing_name )
            row = j;
            break;
        end
    end
    if row == 0
        disp( ['This object name is not in the total object name list : ' , thing_name]);
    end
    
    HRRP_thing_curvature_label_list = [HRRP_thing_curvature_label_list ; curvature_label_list(row,1)];
end

end