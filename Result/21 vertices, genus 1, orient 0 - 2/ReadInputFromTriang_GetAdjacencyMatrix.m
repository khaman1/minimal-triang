%function AdjacencyMatrix = ReadInputFromTriang(input)
clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The code needs the input file "Input.txt" in which there are the
% neighbor lists of all triangulations got from the modified Sulanke's
% code. We can find some examples in the folder RESULT that I have made.
% Then this code will build the adjacency matrix for each triang and
% another one for the union. 

filename = 'Input.txt';
fid  = fopen( filename, 'r' ) ;

Mathematica_EdgesString = '';
CNT=0;
while true
    line = fgetl( fid );
    if line == -1
        break;
    end;
    
    Data = strsplit(line, ':');
    
    if ~cellfun('isempty', Data)
        if numel(Data) == 1

            CNT = CNT+1;
            Mathematica_EdgesString{CNT}='';
        else
            CURRENT_VERTEX = str2double(Data{1})+1;
            LIST = strsplit(Data{2}, ' ');
            LIST = str2double(LIST(2:end))+ 1;


            for i=1:numel(LIST)
                if(CURRENT_VERTEX < LIST(i))
                    Mathematica_EdgesString{CNT}=[Mathematica_EdgesString{CNT} num2str(CURRENT_VERTEX) '<->' num2str(LIST(i)) ', '];
                    
                    AdjacencyMatrix(CURRENT_VERTEX,LIST(i),CNT)=1;
                    AdjacencyMatrix(LIST(i),CURRENT_VERTEX,CNT)=1;
                end;
            end; 
        end;
    end;
    
end;

fclose( fid ) ;

for i=1:numel(AdjacencyMatrix(:,1,1))
    for j=1:numel(AdjacencyMatrix(:,1,1))
        if AdjacencyMatrix(i,j,1) == 1 || AdjacencyMatrix(i,j,2) == 1
            AdjacencyMatrixUNION(i,j)=1;
        end;
    end;
end;

DSATUR_INPUT(1,1) = numel(AdjacencyMatrixUNION(:,1));
START=1;
for i=1:numel(AdjacencyMatrixUNION(:,1))-1
    for j=i+1:numel(AdjacencyMatrixUNION(:,1))
        if AdjacencyMatrixUNION(i,j) ~=0
            START = START + 1;
            DSATUR_INPUT(START,1:2) = [i j];
        end;
    end;
end;
DSATUR_INPUT(1,2) = numel(DSATUR_INPUT(:,1));

Mathematica_Header = '=System`Graph[{';
Mathematica_Tail   = '}, GraphLayout -> "PlanarEmbedding", VertexLabels -> "Name", VertexSize -> 0.4, VertexLabelStyle -> Directive[Black, 20],  EdgeStyle -> {{Thickness[0.004], Black}}]';

for i=1:numel(Mathematica_EdgesString)
    NUM = num2str(i);
    Mathematica_FinalString{i} = ['G', NUM, Mathematica_Header, Mathematica_EdgesString{i}(1:end-2), Mathematica_Tail];
    %%%
    %% Mathematica_FinalString will be the code that you can use to visualize it in Mathematica. 
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In this part, MATLAB will generate a file "Color Input.txt" as the input of the coloring program "dsatur.exe".
%% The outcome from dsatur.exe would be the list of proper colors used for coloring the vertices.
fid=fopen('ColorInput.txt','w');
for i=1:numel(DSATUR_INPUT(:,1))
    fprintf(fid, '%d %d\n', [DSATUR_INPUT(i,1) DSATUR_INPUT(i,2)]');
end;
fclose(fid);

[status,cmdout] = dos('dsatur.exe ColorInput.txt');
cmdout
mvc = str2double(strsplit(cmdout,','));

for i=2:DSATUR_INPUT(:,1)
    if mvc(DSATUR_INPUT(i,1)) == mvc(DSATUR_INPUT(i,2))
        disp('FAILED');
        return
    end;
end;

disp('CORRECT!!!');
OUTPUT = ['mvc = {' num2str(mvc(1))];

for i=2:numel(mvc)
    OUTPUT = [OUTPUT ',' num2str(mvc(i))];
end;

OUTPUT = [OUTPUT '};'];
clipboard('copy',OUTPUT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate File.csv to generate table in Latex
fileID = fopen('FILE.csv','w');
fprintf(fileID,'Triang 1, Triang 2\n');

for i=1:numel(AdjacencyMatrix(:,1,1))
    for k=1:numel(AdjacencyMatrix(1,1,:))
        fprintf(fileID,'%d:', i);
        for j=1:numel(AdjacencyMatrix(1,:,1))
            if AdjacencyMatrix(i,j,k) == 1
                fprintf(fileID,' %d', j);
            end;
        end;
        
        if k ~= numel(AdjacencyMatrix(1,1,:))
            fprintf(fileID,',');
        else
            fprintf(fileID,'\n');
        end;
    end;
end;

fclose(fileID);