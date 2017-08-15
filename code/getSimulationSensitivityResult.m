function [sim_time,sim_values,rowIndex] = getSimulationSensitivityResult(path_id_O,path_id_P,simulationIndex,varargin)
%GETSIMULATIONSENSITIVITYRESULT Gets the time profile of the sensitivity of one output vs one parameter.
%
%   [sim_time,sim_values]=getSimulationSensitivityResult(path_id_O,path_id_P,simulationIndex)
%       path_id_O (string/double) identifier of output
%       path_id_P (string/double) identifier of parameter
%           if it is numerical, it is interpreted as ID. Input of a vector of IDs is possible.
%           if path_id is a string it is interpreted as path. The wildcard ‘*’ can be used.
%               It substitutes for any zero or more characters.
%       simulationIndex (integer)
%           index of the simulation (see initSimulation option 'addFile')
%       sim_time: time vector 
%       sim_values: sensitivity profile [n x m double] ( m = number of matching Species)
%
%   [sim_time,sim_values,rowIndex]=getSimulationSensitivityResult(path_id_O,path_id_P,simulationIndex)
%       rowIndex: Identifying a species by path_id can be time consuming, 
%           especially if it is a string with wildcards. To avoid a repeated time 
%           consuming search for the path_id, this index can be used to identify 
%           the species instead of the path_id. It makes only sense in
%           complex and demanding code.
%
%   Options:
%
%   [sim_time,sim_values,rowIndex]=getSimulationSensitivityResult(path_id_O,path_id_P,simulationIndex,'rowIndex',value_rowIndex)
%       value_rowIndex (double): specifies the line number
%           nan (default): parameter is identified by path_id
%           (double vector): vector with line numbers. The time consuming search 
%               for the line numbers is already done. 
%               Path_id is ignored (see description to Output rowIndex).


% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org

global DCI_INFO;

%% check Inputs --------------------------------------------------------------
% check mandatory inputs
if ~exist('path_id_O','var')
    error('input identifier for output "path_id_O" is missing');
end
if ~exist('path_id_P','var')
    error('input identifier for parameter "path_id_P" is missing');
end

% simulation Index
if ~exist('simulationIndex','var')
    checkInputSimulationIndex(0);
    simulationIndex=1;
else
    checkInputSimulationIndex(simulationIndex);
end

% Check input options
[rowIndex] = ...
    checkInputOptions(varargin,{...
    'rowIndex',nan,nan,...
    });

%% Evaluation
% check if process is done
if ~isfield(DCI_INFO{simulationIndex},'OutputTab')
    error('Outputs not yet generated for simulationIndex %d. Please use processSimulation',simulationIndex);
elseif isempty(DCI_INFO{simulationIndex}.OutputTab)
    error('Outputs are empty for simulationIndex %d. Probably the last processSimulation was interrupted by an error.',simulationIndex); 
elseif length(DCI_INFO{simulationIndex}.OutputTab)<3
    error('There exist no sensitivity output for simulationIndex %d.',simulationIndex); 
end

% Initialize outputs
path_id_list={};


% get the rowIndex, if not set by option
if isnan(rowIndex)
    if ~isnumeric(path_id_P)
        IdP = getParameter(path_id_P,simulationIndex,'parameterType','readOnly','property','ID');
    else
        IdP = path_id_P;
    end
    if ~isnumeric(path_id_O)
        IdO=[];
        [isexisting,description]=existsSpeciesInitialValue(path_id_O,simulationIndex,'parameterType','readOnly');
        if isexisting
            jj=strcmp(description(1,:),'ID');
            IdO=cell2mat(description(2:end,jj));
        end
            [isexisting,description]=existsObserver(path_id_O,simulationIndex);
            if isexisting
                jj=strcmp(description(1,:),'ID');
                IdO=[IdO;cell2mat(description(2:end,jj))];
            end
        if isempty(IdO)
            error('output not found: %s,',path_id_O);
        end
    else
        IdO=path_id_O;
    end
    
    % get rowindices
    rowIndex=find(ismember(DCI_INFO{simulationIndex}.SensitivityTabID(:,1),IdO) & ismember(DCI_INFO{simulationIndex}.SensitivityTabID(:,2),IdP));
    %     rowIndex=[];
    %     for iCol=1:length(DCI_INFO{simulationIndex}.OutputTab(2).Variables)
    %         if any(ID==str2double(DCI_INFO{simulationIndex}.OutputTab(2).Variables(iCol).Attributes(1).Value))
    %             rowIndex(end+1)=iCol; %#ok<AGROW>
    %         end
    %     end
end

if isempty(rowIndex)
    if isnumeric(path_id_P)
        path_id_P=num2str(path_id_P);
    end
    if isnumeric(path_id_O)
        path_id_O=num2str(path_id_O);
    end
    error('Result with parameter path_id_P "%s" and output path_id_O "%s" does not exist!',path_id_P,path_id_O);
end



% get Ouput
% time
rowIndex_time=1;
sim_time = DCI_INFO{simulationIndex}.OutputTab(1).Variables(rowIndex_time).Values';

% values
sim_values=nan(length(rowIndex),length(sim_time));
for iIndx=1:length(rowIndex)
    rowIndex_i=rowIndex(iIndx);
    sim_values(iIndx,:) = DCI_INFO{simulationIndex}.OutputTab(3).Variables(rowIndex_i).Values;
end

return