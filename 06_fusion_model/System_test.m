%%%Code function:
%%%         By combining the prediction results of the HRRP model and the
%%%     curvature model, the system can predict the object label of the
%%%     target object.
%%%         The object recognition accuracy of the system is obtained by
%%%     combining the real object label of the target object.
%%%
%%%Input data:
%%%     softmax matrix of HRRP model prediction results;
%%%     softmax matrix of curvature model prediction results;
%%%     The target object's real object label.
%%%
%%%Output data:
%%%     Object label of the target object predicted by the system;
%%%     Object recognition accuracy of the system.

clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Data parameter setting      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%List of names of current experimental objects
file_path_name = 'Your local path\Fusang_dataset\object_information\221119_AllThingName.xlsx';%This is the file path for the list of current experimental object names
T = readtable(file_path_name);
thing_name_list = T.object_name;

%Gets the curvature label of the current experimental object
curvature_label_list = get_curvature_label(thing_name_list);
curvature_label_list = curvature_label_list + 1;%The curvature labels used to train the curvature model are numbered from 0, while the softmax matrix row number in matlab starts from 1.  For ease of processing, add 1 to the curvature label of the experimental object.

%Gets the object label of the current experimental object
file_path_name = 'Your local path\Fusang_dataset\object_information\AllThingName_ObjectLabel.xlsx';%File path to the object label list of the current experimental object
T_thing_label = readtable(file_path_name);
thing_label_list = T_thing_label.thing_label;%Object labels are numbered from 1


T.curvature_label = curvature_label_list;
T.thing_label = thing_label_list;

%Threshold setting
Absolutely_right_threshold_value = 1;
Be_about_right_threshold_value = 0.001;

%The file path of the softmax matrix of HRRP model prediction results.
HRRP_softmax_filePath = 'Your local path\Fusang_dataset\trained_models\model_softmax_matrix\target_pred_hrrp.mat';

%File path to the ground truth object label for the target object.
thing_Real_label_filePath ='Your local path\Fusang_dataset\system_result\Fusang_TU_HRRP_graph_labels.txt';

%The file path of the softmax matrix of the curvature model prediction results.
PD_softmax_filePath = 'Your local path\Fusang_dataset\trained_models\model_softmax_matrix\target_pred_iq.mat';

%The file path used to save the system object recognition accuracy and the
%object label predicted by the system.
save_file_path = 'Your local path\Fusang_dataset\system_result\';
 

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   The system predicts object labels      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Import the softmax matrix of the prediction results of the HRRP model.
load(HRRP_softmax_filePath);%The name of the imported variable is target_pred.
target_pred_HRRP = target_pred;

%Import the real object label of the target object.
load(thing_Real_label_filePath);%The name of the imported variable is Fusang_TU_HRRP_graph_labels.
thing_Real_label = Fusang_TU_HRRP_graph_labels;

%Import the softmax matrix of the prediction results of the curvature model.
load(PD_softmax_filePath);%The name of the imported variable is target_pred_iq.
target_pred_PD = target_pred_iq;

[sample_num , thing_label_num] = size(target_pred_HRRP);
[sample_num , curvature_label_num] = size(target_pred_PD);

sample_system_pred_label = [];
for sample_id = 1:sample_num
    sample_softmax_HRRP = target_pred_HRRP( sample_id , : ).';
    sample_softmax_PD = target_pred_PD( sample_id , :).';
    
    %When the HRRP model is sure what object category the current object
    %is, the system directly outputs the recognition result of the HRRP model.
    if max(sample_softmax_HRRP) >= Absolutely_right_threshold_value
        [thing_label , y] = find(sample_softmax_HRRP == max(sample_softmax_HRRP));
        sample_system_pred_label = [ sample_system_pred_label ; thing_label ];
    
    %When the HRRP model is not sure what the current object is, the HRRP
    %model gives the object category that the current object may belong to,
    %and the system calls the curvature model to judge the object category
    %of the current object among these object categories.
    else
        [thing_labels , y] = find( sample_softmax_HRRP >= Be_about_right_threshold_value );%The HRRP model gives the object category that the current object may belong to.

        thing_rows = [];
        for i = 1:size(thing_labels , 1)
            [row,y] = find( thing_label_list == thing_labels(i,1) );
            thing_rows = [ thing_rows ; row ];
        end

        temp_T = T(thing_rows,:);
        
        curvature_labels = temp_T.curvature_label;

        for i = 1:curvature_label_num
            if ismember(i , curvature_labels)
                continue;
            else
                sample_softmax_PD(i,1) = -1;
            end
        end

        [curvature_label , y] = find( sample_softmax_PD == max(sample_softmax_PD));

        if size(curvature_label,1) > 1
            sample_system_pred_label = [ sample_system_pred_label ; -1 ];
        elseif size(curvature_label,1) == 1
            [curvature_row,y] = find(curvature_labels == curvature_label);
            if size(curvature_row,1) > 1
                thing_labels_2 = temp_T.thing_label(curvature_row,1);

                for i = 1:thing_label_num
                    if ismember(i , thing_labels_2)
                        continue;
                    else
                        sample_softmax_HRRP(i,1) = -1;
                    end
                end

                [thing_label , y] = find( sample_softmax_HRRP == max(sample_softmax_HRRP));
                
                if size(thing_label,1) > 1 
                    sample_system_pred_label = [ sample_system_pred_label ; -1 ];
                elseif size(thing_label,1) == 1 
                    sample_system_pred_label = [ sample_system_pred_label ; thing_label ];
                end

            elseif size(curvature_row,1) == 1
                sample_system_pred_label = [ sample_system_pred_label ; temp_T.thing_label(curvature_row,1) ];
            end
        end
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Calculate system object recognition accuracy    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

true_num = 0;
for sample_id = 1:sample_num
    if sample_system_pred_label(sample_id , 1) == thing_Real_label(sample_id , 1)
        true_num = true_num + 1;
    end
end

zSystem_accuracy_rate = true_num/sample_num;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   save result    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Object labels predicted by the system
save_file_name = 'sample_system_pred_label';
save_file_type = 'mat';
save( [save_file_path , save_file_name , '.' , save_file_type] , 'sample_system_pred_label');

%System object recognition accuracy
save_file_name = 'zSystem_accuracy_rate';
save_file_type = 'mat';
save( [save_file_path , save_file_name , '.' , save_file_type] , 'zSystem_accuracy_rate');

