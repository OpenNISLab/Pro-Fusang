%%% Code function:
%%%     The distribution characteristics of IF signals in IQ domain are
%%%     constructed into training data of curvature neural network and
%%%     testing data of the system.

clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data parameter setting  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Angle parameter
numfilePreAngle = 1;%The number of files received per Angle
angle_num = 2;%The number of angles per object
angle = [0,20,40,60,90,120,140,160,180];%All possible angles

%List of experimental object names
file_path_name = '';%This is the file path for the list of experimental object names
T = readtable(file_path_name);
thing_name_list = T.object_name;
thing_num = size(thing_name_list , 1);

%Curvature label
curvature_label_list = get_curvature_label(thing_name_list);

%File path of IF signal distribution characteristics in IQ domain 
original_data_file_path = '\';

%File path to save the data of the training curvature model and test system 
generateModel_save_file_path = '\';
ztest_system_save_file_path  = generateModel_save_file_path;

%The first half of the file name to be saved 
generateModel_part_save_file_name = '';%Trained curvature model
ztest_system_part_save_file_name = '';%To test the system

%The number of frames used to generate test data 
frame_num_oneFile_Test_system = 1;

%Part of the name of the file to be saved. Distance between target and radar 
Distance_experiment = '_1meter_';

%The number of angles input to the curvature model 
sample_length = 2;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       Construct data for training curvature model          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ztrain_system_PDV_allAngle_allThing = [];

for thing_id = 1:size(thing_name_list,1)
    %%
    %%%Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'mat';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);

    %%
    point_density_allAngle = [];
    for angle_id = 1:angle_num
        point_density_oneAngle = [];
        for file_id = 1:numfilePreAngle
            point_density_onefile = [];
            file_name_WithType = fileNameList_WithType{file_id + (angle_id-1)*numfilePreAngle , 1};
            load([file_path file_name_WithType]);%The name of the variable being imported is Point_density_AllFrame

            %Determine the scope of data processing
            generateModel_Frame_num_select = size(Point_density_AllFrame,2) - frame_num_oneFile_Test_system;
            Rx_num_select = 1;

            for frame_id = 1:generateModel_Frame_num_select
                temp_frame = Point_density_AllFrame{1,frame_id}(Rx_num_select,:);
                point_density_onefile = [point_density_onefile , temp_frame];
            end
            point_density_oneAngle = [point_density_oneAngle ; point_density_onefile.'];
        end

        point_density_allAngle = [point_density_allAngle , point_density_oneAngle];
    end
    
    %%
    %%%Construct curvature label
    num_dataSample = size(point_density_allAngle , 1);
    data_label = ones(num_dataSample,1) .* curvature_label_list(thing_id,1);
    point_density_allAngle = [point_density_allAngle , data_label];
    
    %%
    ztrain_system_PDV_allAngle_allThing = [ztrain_system_PDV_allAngle_allThing ; point_density_allAngle];
end


%%%Save the constructed data in angles
for angle_id = 1:angle_num
    temp_oneAngle_allThing = [];
    
    if angle(1,angle_id) == 180
        temp_oneAngle_allThing = ztrain_system_PDV_allAngle_allThing( : , angle_id-sample_length+1:angle_id );
        temp_oneAngle_allThing = [temp_oneAngle_allThing , ztrain_system_PDV_allAngle_allThing(:,end) ];
    else
        temp_oneAngle_allThing = ztrain_system_PDV_allAngle_allThing( : , angle_id:angle_id+sample_length-1 );
        temp_oneAngle_allThing = [temp_oneAngle_allThing , ztrain_system_PDV_allAngle_allThing(:,end) ];
    end

    %%
    %%%save
    save_file_name = [generateModel_part_save_file_name , num2str(angle_id) , '_' , num2str(angle(angle_id)) , 'deg_allThing_rx' , num2str(Rx_num_select) , Distance_experiment , num2str(generateModel_Frame_num_select) ,'frame_sampleLength' , num2str(sample_length)];
    save_file_type = 'mat';
    save( [generateModel_save_file_path , save_file_name , '.' , save_file_type] , 'temp_oneAngle_allThing');
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       Construct the data used to test the system          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ztest_system_PDV_allAngle_allThing = [];

for thing_id = 1:size(thing_name_list,1)
    %%
    %%%Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'mat';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);

    %%
    point_density_allAngle = [];
    for angle_id = 1:angle_num
        point_density_oneAngle = [];
        for file_id = 1:numfilePreAngle
            point_density_onefile = [];
            file_name_WithType = fileNameList_WithType{file_id + (angle_id-1)*numfilePreAngle , 1};
            load([file_path file_name_WithType]);%The name of the variable being imported is Point_density_AllFrame

            %Determine the scope of data processing
            Frame_num_select_start = generateModel_Frame_num_select + 1;
            Frame_num_select_end = size(Point_density_AllFrame,2);
            Rx_num_select = 1;

            for frame_id = Frame_num_select_start:Frame_num_select_end
                temp_frame = Point_density_AllFrame{1,frame_id}(Rx_num_select,:);
                point_density_onefile = [point_density_onefile , temp_frame];
            end
            point_density_oneAngle = [point_density_oneAngle ; point_density_onefile.'];
        end

        point_density_allAngle = [point_density_allAngle , point_density_oneAngle];
    end
    
    %%
    %%%Construct curvature label
    num_dataSample = size(point_density_allAngle , 1);
    data_label = ones(num_dataSample,1) .* curvature_label_list(thing_id,1);
    point_density_allAngle = [point_density_allAngle , data_label];
    
    %%
    ztest_system_PDV_allAngle_allThing = [ztest_system_PDV_allAngle_allThing ; point_density_allAngle];
end



%%%Save the constructed data in angles
for angle_id = 1:angle_num
    temp_oneAngle_allThing = [];
    
    if angle(1,angle_id) == 180
        temp_oneAngle_allThing = ztest_system_PDV_allAngle_allThing( : , angle_id-sample_length+1:angle_id );
        temp_oneAngle_allThing = [temp_oneAngle_allThing , ztest_system_PDV_allAngle_allThing(:,end) ];
    else
        temp_oneAngle_allThing = ztest_system_PDV_allAngle_allThing( : , angle_id:angle_id+sample_length-1 );
        temp_oneAngle_allThing = [temp_oneAngle_allThing , ztest_system_PDV_allAngle_allThing(:,end) ];
    end


    %%
    %%%save
    save_file_name = [ztest_system_part_save_file_name , num2str(angle_id) , '_' , num2str(angle(angle_id)) , 'deg_allThing_rx' , num2str(Rx_num_select) , Distance_experiment , num2str(frame_num_oneFile_Test_system) ,'frame_sampleLength' , num2str(sample_length)];
    save_file_type = 'mat';
    save( [ztest_system_save_file_path , save_file_name , '.' , save_file_type] , 'temp_oneAngle_allThing');
end
