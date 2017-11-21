function [indx] = findTableIndex(path_id, iTab, simulationIndex, isReference)
%FINDTABLEINDEX Support function: Finds the row index of an input table for a parameter specified by path_id
% 
%   indx = FINDTABLEINDEX(path_id, iTab, simulationIndex)
%       path_id (string/double):
%           if it is numerical, it is interpreted as ID. Input of a vector of IDs is possible.
%           if path_id is a string it is interpreted as path. The wildcard ‘*’ can be used.
%               It substitutes for any zero or more characters. 
%       iTab (double) : Number of the input table
%       simulationIndex (double): index of the simulation 
%       indx (double vector): row index of an input table for the parameters
%           specified by path_id
%
%   indx = FINDTABLEINDEX(path_id, iTab, simulationIndex,isReference)
%       isReference (boolean): 
%           - false: (default) DCI_INFO{simulationIndex}. InputTab is searched
%           - true: DCI_INFO{simulationIndex}.ReferenceTab is searched
 
% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org
% Date: 19-Sep-2010

global DCI_INFO;

%% check inputs
if ~exist('isReference','var')
    isReference=false;
end
if isReference
    TableArray=DCI_INFO{simulationIndex}.ReferenceTab(iTab);
else
    TableArray=DCI_INFO{simulationIndex}.InputTab(iTab);
end
% define output
indx=[];


% path id is numerical: ID
if isnumeric(path_id)

    jCol= strcmp('ID',{TableArray.Variables.Name});
    
    for iPar=1:length(path_id)
        indx_tmp=find(TableArray.Variables(jCol).Values==path_id(iPar));
        indx=[indx indx_tmp]; %#ok<*AGROW>
    end
    
% path id is string: Path
else

    jCol=strcmp('Path',{TableArray.Variables.Name});
    nPar=length(TableArray.Variables(jCol).Values);
    
    % check for wildcards
    ij_wildcards=strfind(path_id,'*');
    % no wild card used:
    if isempty(ij_wildcards)
        indx=find(strcmp(path_id,TableArray.Variables(jCol).Values));
    % all (path id = wildcard)
    elseif strcmp(path_id,'*')
        indx=1:nPar;
    else
        % search for string before the first wildcard
       if ij_wildcards(1)>1
           [indx,paths]=findIndxForKeyStart(path_id(1:ij_wildcards(1)-1),TableArray.Variables(jCol).Values);
       else
           indx=1:nPar;
           paths=TableArray.Variables(jCol).Values;
       end
        
        % search for string between 2 wildcard
       if ~isempty(paths)
           for iWildcard=1:length(ij_wildcards)-1
               key=path_id(ij_wildcards(iWildcard)+1:ij_wildcards(iWildcard+1)-1);
               [indx,paths]=findIndxForKeyInBetween(indx,key,paths);
           end
       end
       
        % search for string after the last wildcard
       if ~isempty(paths)
           if ij_wildcards(end)<length(path_id)
               key=path_id(ij_wildcards(end)+1:end);
               [indx]=findIndxForKeyEnd(indx,key,paths);
           end
       end
    end
end

return

function [indx,paths]=findIndxForKeyInBetween(indx,key,paths)


firstOccurence = strfind(paths,key);
jj = ~cellfun(@isempty,firstOccurence);
paths = paths(jj);
firstOccurence = firstOccurence(jj);
indx = indx(jj);

for iP = 1:length(paths)
    paths{iP} = paths{iP}(firstOccurence{iP}(1)+length(key):end);
end

return

function [indx]=findIndxForKeyEnd(indx,key,paths)

jj = ~cellfun(@isempty,strfind(paths,key));
paths = paths(jj);
indx = indx(jj);
jj = cellfun(@(x) strcmp(x((end-length(key)+1):end),key),paths);
indx = indx(jj);

return
           


function [indx,paths]=findIndxForKeyStart(key,paths)


jj = strncmp(key,paths,length(key));

paths = paths(jj);
indx = find(jj);

for iP = 1:length(paths)
    paths{iP} = paths{iP}(length(key):end);
end

return
           

        
