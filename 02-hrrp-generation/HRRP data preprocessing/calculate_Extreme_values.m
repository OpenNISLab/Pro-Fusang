%%% Code function:
%%%     For IF signal filtered by svmd algorithm, the column number
%%%     corresponding to local maximum and local maximum are extracted 
%%%     from rangefft sequence.


clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data parameter setting  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%To avoid zero frequency, start from the tenth column of the fft sequence
give_up_colNum = 10;

%Signal parameter
Fs = 3e6; % Sampling rate
slope = 20e12; % chirp slope
c = 3e8; % Speed of light
numADCSamples = 512; % number of ADC samples per chirp
rangefft_samples = numADCSamples;

%Maximum distance of experimental environment
Distance_range = 7;
Distance_range = ceil( (Distance_range / (c / 2/slope) ) / (Fs / rangefft_samples) );

%Angle parameter
numfilePreAngle = 1;%The number of files received per Angle
angle_num = 2;%The number of angles per object
angle = [0,20,40,60,90,120,140,160,180];%All possible angles

%List of experimental object names
file_path_name = '';%This is the file path for the list of experimental object names
T = readtable(file_path_name);
thing_name_list = T.object_name;

%File path of IF signal data filtered by svmd algorithm
original_data_file_path = '\';

%The path to save the extracted local maximum and column number data
generateModel_save_file_path = '\';%Training data

ztest_system_save_file_path  = '\';%Test data

%The first half of the file name to be saved
generateModel_part_save_file_name = '';%Training data name

ztest_system_part_save_file_name = '';%Test data name

%Part of the name of the file to be saved. Distance between target and radar
Distance_experiment = '_1meter_';

%The number of frames used to generate test data
frame_num_oneFile_Test_system = 1;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       Extract the local maximum and column number used to train the HRRP model          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for thing_id = 1:size(thing_name_list,1)
    %%
    %%%Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'mat';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);
   
    %%
    for angle_id = 1:angle_num
        Extreme_values_oneThing_oneAngle = {};
        column_num_oneThing_oneAngle = {};

        for file_id = 1:numfilePreAngle
            %Import filtered IF signal
            file_name_WithType = fileNameList_WithType{file_id + (angle_id-1)*numfilePreAngle , 1};
            load([file_path file_name_WithType]);%The name of the imported variable is svmd_alldata
            alldata = svmd_alldata;
            
            %Determine the scope of data processing
            generateModel_Frame_num_select = size(alldata,4) - frame_num_oneFile_Test_system;
            Rx_num_select = 1;
            IF_num_select = size(alldata,2);

            IF_order = 1;%The sequence number of the IF signal being processed
            Extreme_values_onefile = {};%Storage extremum
            column_num_onefile = {};%Store column number

            for frame_id = 1:generateModel_Frame_num_select
                for Rx_id =1:Rx_num_select
                    for IF_id = 1:IF_num_select          
                        temp_OneIF = alldata(:,IF_id,Rx_id,frame_id);
                        temp_OneIF_rangefft = rangefft(temp_OneIF.' , rangefft_samples);
                        [pks,locs] = zfindpeaks(temp_OneIF_rangefft , give_up_colNum , Distance_range);
                        
                        Extreme_values_onefile{IF_order,1} = pks;
                        column_num_onefile{IF_order,1} = locs;
                        IF_order = IF_order + 1;
                    end
                end    
            end%end of one file
            
            Extreme_values_oneThing_oneAngle = [Extreme_values_oneThing_oneAngle ; Extreme_values_onefile];
            column_num_oneThing_oneAngle = [column_num_oneThing_oneAngle ; column_num_onefile];
        end%end of one angle
        
        Folder_name = [num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg'];

        %%%Save the local maximum data
        save_file_path = [generateModel_save_file_path , 'ExtremeValues\' , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end        
        save_file_name = [thing_name_list{thing_id,1} , '_' , num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg' , Distance_experiment , generateModel_part_save_file_name , 'ExtremeValues'];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'Extreme_values_oneThing_oneAngle');
    
        %%%Save column number data
        save_file_path = [generateModel_save_file_path , 'columnNumber\' , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end 
        save_file_name = [thing_name_list{thing_id,1} , '_' , num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg' , Distance_experiment , generateModel_part_save_file_name , 'columnNumber'];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'column_num_oneThing_oneAngle');
    end%end of one thing
    
end%end of one train data




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       Extract the local maximum and column number used to test the system          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for thing_id = 1:size(thing_name_list,1)
    %%
    %%%Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'mat';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);
   
    %%
    for angle_id = 1:angle_num
        Extreme_values_oneThing_oneAngle = {};
        column_num_oneThing_oneAngle = {};

        for file_id = 1:numfilePreAngle
            %Import filtered IF signal
            file_name_WithType = fileNameList_WithType{file_id + (angle_id-1)*numfilePreAngle , 1};
            load([file_path file_name_WithType]);%The name of the imported variable is svmd_alldata
            alldata = svmd_alldata;
               
            %Determine the scope of data processing
            Frame_num_select_start = generateModel_Frame_num_select + 1;
            Frame_num_select_end = size(alldata,4);
            Rx_num_select = 1;
            IF_num_select = size(alldata,2);

            IF_order = 1;%The sequence number of the IF signal being processed
            Extreme_values_oneThing_oneAngle_onefile = {};%Storage extremum
            column_num_oneThing_oneAngle_onefile = {};%Store column number

            for frame_id = Frame_num_select_start:Frame_num_select_end
                for Rx_id =1:Rx_num_select
                    for IF_id = 1:IF_num_select           
                        temp_OneIF = alldata(:,IF_id,Rx_id,frame_id);
                        temp_OneIF_rangefft = rangefft(temp_OneIF.' , rangefft_samples);
                        [pks,locs] = zfindpeaks(temp_OneIF_rangefft , give_up_colNum , Distance_range);
                        
                        Extreme_values_oneThing_oneAngle_onefile{IF_order,1} = pks;
                        column_num_oneThing_oneAngle_onefile{IF_order,1} = locs;
                        IF_order = IF_order + 1;
                    end
                end    
            end%end of one file
            
            Extreme_values_oneThing_oneAngle = [Extreme_values_oneThing_oneAngle ; Extreme_values_oneThing_oneAngle_onefile];%存放极值
            column_num_oneThing_oneAngle = [column_num_oneThing_oneAngle ; column_num_oneThing_oneAngle_onefile];%存放极值在原fft序列里的列号
        end%end of one angle
        
        Folder_name = [num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg'];
        %%
        %%%Save the local maximum data
        save_file_path = [ztest_system_save_file_path , 'ExtremeValues\' , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end
        save_file_name = [thing_name_list{thing_id,1} , '_' , num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg' , Distance_experiment , ztest_system_part_save_file_name , 'ExtremeValues'];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'Extreme_values_oneThing_oneAngle');
        
        %%%Save column number data
        save_file_path = [ztest_system_save_file_path , 'columnNumber\' , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end
        save_file_name = [thing_name_list{thing_id,1} , '_' , num2str(angle_id) , '_' , num2str(angle(1,angle_id)) , 'deg' , Distance_experiment , ztest_system_part_save_file_name , 'columnNumber'];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'column_num_oneThing_oneAngle');

    end%end of one thing
    
end%end of one test data


