%%% Code function:
%%%     Combined with the distance between the target and the radar obtained by the classical radar positioning method, 
%%%     the original IF signal is filtered by SVMD algorithm to complete the target signal extraction. 
%%%     
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data parameter setting  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
%%%Signal parameter
framenum = 32; %Frame number
numADCSamples = 512; % number of ADC samples per chirp
numRX = 4; % number of receivers
numADCBits = 16;%number of ADC bits per sample
numchirpPreframe = 128;%chirp number per frame
Fs = 3e6; % Sampling rate
slope = 20e12; % chirp slope

%%%Set experimental target parameters
%Distance between target and radar
target_distance = 1.0;
%Target width range
temp_target_Distance_range = 0:0.1:6 ;
target_Distance_range = 1 + temp_target_Distance_range;

%%%Maximum distance of experimental environment
Detection_range = 7;

%List of experimental object names
file_path_name = '';%This is the file path for the list of experimental object names
T = readtable(file_path_name);
thing_name_list = T.object_name;
thing_num = size(thing_name_list , 1);

%File path of the original bin file of the IF signal acquired by radar
original_data_file_path = '\';

%Saved path of data processed by svmd algorithm
svmd_save_file_path = '\';

%The first half of the file name to be saved
part_save_file_name = '';


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   If signal filtering    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for thing_id = 1:thing_num
    
    thing_id
    
    %Gets the name of the file to be processed
    file_path = [original_data_file_path , thing_name_list{thing_id,1} ,'\'];
    file_type = 'bin';
    fileInformation_list = dir(fullfile(file_path,['*.' , file_type]));
    fileNameList_WithType = {fileInformation_list.name}.';
    file_num = size(fileNameList_WithType,1);

    for file_id = 1:file_num
    
        file_id
    
        %% read bin file 
        file_name_WithType = fileNameList_WithType{file_id , 1};
        Absolute_file_path = [file_path , file_name_WithType];
        retVal = readDCA1000(Absolute_file_path , numADCSamples , numADCBits , numRX);
        
        %%
        %Reorganized data format:(numADCSamples,numchirpPreframe,numRX,framenum)
        alldata = zeros(numADCSamples,numchirpPreframe,numRX,framenum);
        for frame_id = 1:framenum 
            temp_frame_4Rx = retVal(:,(numADCSamples*numchirpPreframe)*(frame_id-1)+1:(numADCSamples*numchirpPreframe)*frame_id);
        
            for Rx_id =1:numRX
                for IF_id = 1:numchirpPreframe
                    alldata(:,IF_id,Rx_id,frame_id) = temp_frame_4Rx(Rx_id,numADCSamples*(IF_id-1)+1:numADCSamples*IF_id);
                end
            end    
        end
        
        %%
        %%%If signal is processed by SVMD filtering

        %Determine the scope of data processing
        Frame_num_select = 7;
        Rx_num_select = 1;
        IF_num_select = 128;
    
        svmd_alldata = zeros(numADCSamples,IF_num_select,Rx_num_select,Frame_num_select);
        for frame_id = 1:Frame_num_select
            for Rx_id =1:Rx_num_select
                for IF_id = 1:IF_num_select
    
                    temp_IF = alldata(:,IF_id,Rx_id,frame_id).';%Nonconjugate transpose, making temp_IF a row vector
                    real_temp_IF = real(temp_IF);
                    imag_temp_IF = imag(temp_IF);
                    
                    svmd_real_temp_IF = zSVMD(real_temp_IF , target_distance , target_Distance_range , Detection_range , Fs , slope , numADCSamples);
                    svmd_imag_temp_IF = zSVMD(imag_temp_IF , target_distance , target_Distance_range , Detection_range , Fs , slope , numADCSamples);
    
                    svmd_alldata(:,IF_id,Rx_id,frame_id) = complex(svmd_real_temp_IF , svmd_imag_temp_IF);
    
                end
            end
        end
        
        %%
        %%%Store the svmd processed IF signal
        Folder_name = thing_name_list{thing_id,1};
        save_file_path = [svmd_save_file_path , Folder_name];
        if not(isfolder(save_file_path))
            mkdir( save_file_path )
        end
        save_file_name = [ part_save_file_name , file_name_WithType(1,1:end-size(file_type,2)-1)];
        save_file_type = 'mat';
        
        save( [save_file_path , '\' , save_file_name , '.' , save_file_type] , 'svmd_alldata');
    end

end