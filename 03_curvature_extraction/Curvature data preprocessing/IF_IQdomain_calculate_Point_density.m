%%% Code function:
%%%     The distribution features of IF signals filtered by svmd algorithm
%%%     in IQ domain are extracted.

clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data parameter setting  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numADCSamples = 512; % number of ADC samples per chirp

%List of experimental object names
file_path_name = '';%This is the file path for the list of experimental object names
T = readtable(file_path_name);
thing_name_list = T.object_name;
thing_num = size(thing_name_list , 1);

%File path of IF signal data filtered by svmd algorithm
original_data_file_path = '\';

%The path to save the extracted distribution feature data
svmd_save_file_path = '\';


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Extract the distribution characteristics in IQ domain    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for thing_id = 1:thing_num

    thing_id
    %%
    %%%Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'mat';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);
    
    for file_id = 1:file_num
        % Import filtered IF signal
        file_name_WithType = fileNameList_WithType{file_id , 1};
        Absolute_file_path = [file_path , file_name_WithType];
        load(Absolute_file_path);%The name of the imported variable is svmd_alldata
        alldata = svmd_alldata;
        
        % Calculate the distribution characteristics in the IQ domain
        box_bin = 20;%unit area parameter
        
        frame_num_select = 7;%Determine the scope of data processing
        Rx_num_select = 1;
        IF_num_select = 128;
    
        Point_density_AllFrame = {};
        for frame_id = 1:frame_num_select
            Point_density_AllFrame{1,frame_id} = zeros(Rx_num_select,IF_num_select);
            for Rx_id =1:Rx_num_select
                for IF_id = 1:IF_num_select           
                    temp_OneIF = alldata(:,IF_id,Rx_id,frame_id);
                    Point_density_AllFrame{1,frame_id}(Rx_id,IF_id) = calculate_Point_density(temp_OneIF , numADCSamples , box_bin);
                end
            end    
        end
        
        %%
        %%%Save distribution feature data
        Folder_name = thing_name_list{thing_id,1};
        save_file_path = [svmd_save_file_path , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end
        save_file_name = [ 'PDValue_' , file_name_WithType(1,1:end-size(file_type,2)-1)];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'Point_density_AllFrame');
    end
    
end
