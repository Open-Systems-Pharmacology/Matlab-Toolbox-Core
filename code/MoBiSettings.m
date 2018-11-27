 function MoBiSettings(simModelSchemaPath, simModelCompConfigPath, eventsAssemblyPath)
%MOBISETTINGS Sets the necessary paths.
% 
%   MOBISETTINGS  the default paths are used
%
%   MOBISETTINGS(simModelSchemaPath, simModelCompConfigPath, eventsAssemblyPath)
%       simModelSchemaPath (string, optional): path to SimModel xml schema (OSPSuite.SimModel.xsd).
%       simModelCompConfigPath (string, optional): path to SimModelComp configuration file (OSPSuite_SimModelComp.xml)
%       eventsAssemblyPath (string, optional):     path to .NET assembly intended for providing "events" if called from .NET application

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org  

% SimModel Schema
global MOBI_SETTINGS;

% get path of libraries
if ~isdeployed && ~isunix
    filename =mfilename('fullpath');
    fpath=fileparts(filename);
    libpath=[fpath filesep '..' filesep '..' filesep 'lib' filesep];
    addpath(genpath(libpath));
    
    systemPath = getenv('path');
    
    if isempty(strfind(systemPath,libpath)) %#ok<STREMP> 
        setenv('path', [libpath ';' systemPath]);
    end

    
elseif ~exist('simModelSchemaPath','var') || isempty(simModelSchemaPath)
    error('Within deployed applications, MoBi Settings must be called with simModelSchemaPath');
end

if isdeployed && ~isunix  
    sCopy = 'Copy';
else
    sCopy = '';
end

%set shema path
if ~exist('simModelSchemaPath','var') || isempty(simModelSchemaPath)
      simModelSchemaPath=which('OSPSuite.SimModel.xsd');
      if isempty(simModelSchemaPath)
          error('SimModel schema file OSPSuite.SimModel.xsd not found');
      end
end
MOBI_SETTINGS.SimModelSchema = simModelSchemaPath; 

if exist('simModelCompConfigPath','var') && ~isempty(simModelCompConfigPath)
    SimModelComp = simModelCompConfigPath;
else
    SimModelComp=[libpath SimModelCompName];
      if isempty(SimModelComp)
          error([SimModelCompName ' was not found']);
      end
end
MOBI_SETTINGS.SimModelComp = SimModelComp;

% check for 32 or 64 bit computer
c = computer('arch');
switch c
    case {'win32','glnx86'}
        MOBI_SETTINGS.MatlabInterface = ['DCIMatlabR2013b6_1',sCopy];
    case {'win64','glnxa64','maci64'}
        MOBI_SETTINGS.MatlabInterface = ['DCIMatlabR2017b6_1',sCopy];
    otherwise
        error('unknown type of computer');
end
if ~exist(MOBI_SETTINGS.MatlabInterface,'file')
    error(['It was not possible to find the matlab interface %s. Please check if it is installed.'...
        ' If you have another version of the matlab interface installed, it may be you are working with the wrong matlab version.'...
        ' Use a 32bit platform for DCIMatlabR2013b6_1 and  a 64bit platform for DCIMatlabR2017b6_1'],MOBI_SETTINGS.MatlabInterface);
end
warning('off','MATLAB:mex:deprecatedExtension');


%check if SimModelSchema exists
if ~exist(MOBI_SETTINGS.SimModelSchema, 'file')
    error('SimModel schema file "%s" not found', MOBI_SETTINGS.SimModelSchema);
end
%check if SimModelComp exists
if ~exist(MOBI_SETTINGS.SimModelComp, 'file')
	if ~isdeployed
		error('SimModelComp file "%s" not found', MOBI_SETTINGS.SimModelComp);
	end
end
if ~exist(strrep(MOBI_SETTINGS.SimModelComp,'xml','dll'))  && ~isunix
	if ~isdeployed
		error('SimModelComp file "%s" not found', strrep(MOBI_SETTINGS.SimModelComp,'xml','dll'));
	end
end    
%check if MatlabInterface exists
if ~exist(MOBI_SETTINGS.MatlabInterface, 'file')  && ~isunix
	if ~isdeployed
		error('MatlabInterface file "%s" not found', MOBI_SETTINGS.MatlabInterface);
	end
end

if exist('eventsAssemblyPath', 'var')
    MOBI_SETTINGS.EventsForNET = eventsAssemblyPath;
else
    MOBI_SETTINGS.EventsForNET = '';
end

%  additional paths 
if ~isdeployed && ~isunix
    appPath=[fileparts(which('MoBiSettings.m')) filesep];
    addpath([appPath 'auxiliaries']);
    if exist([appPath '../Examples'],'dir')
        addpath([appPath '../Examples']);
    end
    if exist([appPath '../Icons'],'dir')
        addpath([appPath '../Icons']);
    end
end

% add User Settings Path
MOBI_SETTINGS.application_path=[getenv('APPDATA') filesep SuiteInstallationSubfolder filesep 'MoBiToolboxForMatlab' filesep];
if ~isdeployed && ~isunix
    addpath(MOBI_SETTINGS.application_path);
end

% add Ghost View Path of Miktex Installation if installed
if ~isfield(MOBI_SETTINGS, 'gsSettings')
    gsSettings = [];
else
    gsSettings=MOBI_SETTINGS.gsSettings;
end

if isempty(gsSettings) || ~isfield(gsSettings,'gscommand') || isempty(gsSettings.gscommand)
    pathToMikTexInstallDir = getpathToMikTexInstallDirFromRegistry;
    if ~isempty(pathToMikTexInstallDir)
        gs_path = fullfile(pathToMikTexInstallDir, 'miktex', 'bin');
        gs_exe='mgs.exe';
        gsSettings.gscommand=fullfile(gs_path,gs_exe);
        % fontpath
        gs_fontpath=fullfile(pathToMikTexInstallDir, 'fonts');
        if exist(gs_fontpath,'dir')
            gsSettings.gsfontpath=gs_fontpath;
        end
        % libpath
        gs_libpath=gs_path;
        if exist(gs_libpath,'dir')
            gsSettings.gslibpath=gs_libpath;
        end
        MOBI_SETTINGS.gsSettings=gsSettings;
    end
end

if isempty(gsSettings) || ~isfield(gsSettings,'gscommand') || isempty(gsSettings.gscommand)
    pathToMikTexInstallDir = getpathToMikTexInstallDirFromRegistry;
    if ~isempty(pathToMikTexInstallDir)
        gs_path = fullfile(pathToMikTexInstallDir, 'miktex', 'bin');
        gs_exe='mgs.exe';
        gsSettings.gscommand=fullfile(gs_path,gs_exe);
        % fontpath
        gs_fontpath=fullfile(pathToMikTexInstallDir, 'fonts');
        if exist(gs_fontpath,'dir')
            gsSettings.gsfontpath=gs_fontpath;
        end
        % libpath
        gs_libpath=gs_path;
        if exist(gs_libpath,'dir')
            gsSettings.gslibpath=gs_libpath;
        end
    end
    MOBI_SETTINGS.gsSettings=gsSettings;
end

return

function pathToMikTexInstallDir = getpathToMikTexInstallDirFromRegistry
	
    pathToMikTexInstallDir = '';
	try
        pathToMikTexInstallDir = winqueryreg('HKEY_LOCAL_MACHINE',sprintf('SOFTWARE\\Open Systems Pharmacology\\MikTeX'), 'InstallDir');
        return;
    catch
    end
    
    %default registry key not found - try another one
    try
        pathToMikTexInstallDir = winqueryreg('HKEY_LOCAL_MACHINE',sprintf('SOFTWARE\\Wow6432Node\\Open Systems Pharmacology\\MikTex'), 'InstallDir');
        return;
    catch
    end

    % registry calls failed. Try default installation location
    pathToMikTexInstallDir=[getenv('ProgramFiles(x86)') filesep 'Open Systems Pharmacology' filesep 'MikTex 2.9.3' filesep];
    if ~exist(pathToMikTexInstallDir, 'dir')
        pathToMikTexInstallDir='';
    end
return
