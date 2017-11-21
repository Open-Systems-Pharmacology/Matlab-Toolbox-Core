function parameterStatus=storeParameterStatus(simulationIndex,varargin)
%STOREPARAMETERSTATUS This function is obsolete, please use
% getParameterStatus instead.
%
% see also GETPARAMETERSTATUS

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org
% Date: 15-Nov-2012

if isempty(varargin)
    parameterStatus = getParameterStatus(simulationIndex);
else
    parameterStatus = getParameterStatus(simulationIndex,varargin);
end
return 
