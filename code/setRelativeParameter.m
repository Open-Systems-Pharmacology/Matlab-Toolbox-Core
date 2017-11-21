function rowIndex = setRelativeParameter(value,path_id,simulationIndex,varargin)
%SETRELATIVEPARAMETER Sets the value of a variable parameter relative to reference.
%   
%
%   SETRELATIVEPARAMETER(value,path_id,simulationIndex)
%   	value (double): parameter value relative to reference value
%           If the variable 'value' has only one entry, value is set to all 
%               parameters to which path_id or rowIndex corresponds.
%           If the variable �value� has more than one entry, the number of entries 
%               must correspond to the number of entries of the variable path_id or rowIndex. 
%               path_id must be in this case numerical (vector of IDs).
%               The first entry of the vector value is set to the parameter
%               corresponding to first entry of path_id or rowIndex, and so on.
%       path_id (string/double):
%           if it is numerical, it is interpreted as ID. Input of a vector of IDs is possible.
%           if path_id is a string it is interpreted as path. The wildcard �*� can be used.
%               It substitutes for any zero or more characters.
%       simulationIndex (integer)
%           index of the simulation (see initSimulation option 'addFile')
%
%   [rowIndex] = SETRELATIVEPARAMETER(value,path_id,simulationIndex)
%       rowIndex: Identifying a parameter by path_id can be time consuming, 
%           especially if it is a string with wildcards. To avoid a repeated time 
%           consuming search for the path_id, this index can be used to identify 
%           the parameter instead of the path_id. It makes only sense in
%           complex and demanding code.
%
%   Options:
%
%   SETRELATIVEPARAMETER(value,path_id,simulationIndex,'rowIndex',value_rowIndex )
%       value_rowIndex (double): specifies the line number
%           nan (default): parameter is identified by path_id
%           (double vector): vector with line numbers. The time consuming search 
%               for the line numbers is already done. 
%               Path_id is ignored (see description to Output rowIndex).
%
% Option for fast processing
%   SETRELATIVEPARAMETER(value,path_id,simulationIndex,'speedy',value_parameterType,value_rowIndex)
%   If the first parameter after the simulationIndex is 'speedy' the function starts in the  "SpeedyMode".
%   All checks for sensible inputs are skipped. The order of varargin
%   input parameter is fixed. 
%       value_rowIndex (double): specifies the line number
%       value_parameterType (string) specifiy the type of parameter
%
% Example Call:
% setRelativeParameter(10,'No/AbsTol',1);
%
% see also INITSIMULATION

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org
% Date: 22-Sep-2010

global DCI_INFO;

%% check Inputs --------------------------------------------------------------

% start SpeedyMode. No checks, order of varargin input parameter is fixed
if ~isempty(varargin) && strcmp(varargin{1},'speedy')
    parameterType=varargin{2};
    rowIndex=varargin{3};
    
    % secure Mode with check for sensible inputs
else
    % check mandatory inputs
    if ~exist('value','var')
        error('input "value" is missing');
    else
        if size(value,2)>1
            value=value';
        end
    end
    
    if ~exist('path_id','var')
        error('input "path_id" is missing');
    end
    
    % simulation Index
    if ~exist('simulationIndex','var')
        checkInputSimulationIndex(0);
        simulationIndex=1;
    else
        checkInputSimulationIndex(simulationIndex);
    end
    
     % Check input options
    [parameterType,rowIndex] = ...
        checkInputOptions(varargin,{...
        'parameterType',{'reference','variable'},'variable',...
        'rowIndex',nan,nan
        });
    
    % check if number of entries of value correpond to rowIndex/path_id
    if length(value)>1
        if all(isnan(rowIndex)) && ~isnumeric(path_id)
            error(['The variable "value" has more than one entry, '...
                'in this case "path_id" must be numeric (vector of IDs) '...
                'or use the option rowIndex!']);
        elseif all(isnan(rowIndex)) && length(value)~=length(path_id)
            error(['The variable "value" has more than one entry, '...
                'but the number of entries does not correspond to the '...
                'number of entries of the variable "path_id".']);
        elseif all(~isnan(rowIndex)) && length(value)~=length(rowIndex)
            error(['The variable "value" has more than one entry, '...
                'but the number of entries does not correspond to the '...
                'number of entries of the option variable "rowIndex".']);
        end
    end
end
%% Evaluation

% get Table identifier
iTab=2;
switch parameterType
    case 'variable'
        TableName='InputTab';
        isReference=false;
    case 'reference'
        TableName='ReferenceTab';
        isReference=true;
end

% get the rowIndex, if not set by option
if isnan(rowIndex)        
    rowIndex=findTableIndex(path_id, iTab, simulationIndex);
end

if isempty(rowIndex)
    if isnumeric(path_id)
        path_id=num2str(path_id);
    end
    error('Parameter with path_id "%s" does not exist!',path_id);
end

% search for table parameters and ignore them
jColP=strcmp('ParameterType',{DCI_INFO{simulationIndex}.(TableName)(iTab).Variables.Name});
valueType=DCI_INFO{simulationIndex}.(TableName)(iTab).Variables(jColP).Values(rowIndex);
jj_Table=strcmp(valueType,'Table');

if any(jj_Table) 
    warning('MoBiToolbox:Basis:TableParameterGet',...
                            'Parameters of type table have been ignored!');
    rowIndex = rowIndex(~jj_Table);
end

% column indices
jCol=strcmp('Value',{DCI_INFO{simulationIndex}.InputTab(iTab).Variables.Name});

% set the value:
DCI_INFO{simulationIndex}.InputTab(iTab).Variables(jCol).Values(rowIndex)=...
    value.*DCI_INFO{simulationIndex}.ReferenceTab(iTab).Variables(jCol).Values(rowIndex);

return

