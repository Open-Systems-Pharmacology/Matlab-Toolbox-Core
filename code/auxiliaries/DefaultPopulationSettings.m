function populationSettings = DefaultPopulationSettings
%DEFAULTPOPULATIONSETTINGS Creates set default description for a population generation
%
%   populationSettings = DefaultPopulationSettings
%
%       is used in function PKSimCreatePopulation   

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org 
% Date: 30-apr-2018

    populationSettings=[];
    
try
    
    isCanceled = loadPKSimMatlabDLL;
    if isCanceled
        return
    end
    
    gestationalAgeRange = PKSim.Core.CoreConstants.PretermRange;

    populationSettings.Species             ='Human';
    populationSettings.Population          ='European_ICRP_2002';
    
    populationSettings.MinAge              = NaN;
    populationSettings.MaxAge              = NaN;
    populationSettings.AgeUnit             = 'year(s)';
    
    populationSettings.MinGestationalAge   = System.Linq.Enumerable.Min(gestationalAgeRange);
    populationSettings.MaxGestationalAge   = System.Linq.Enumerable.Max(gestationalAgeRange);
    populationSettings.GestationalAgeUnit  = 'week(s)';
    
    populationSettings.MinWeight           = NaN;
    populationSettings.MaxWeight           = NaN;
    populationSettings.WeightUnit          = 'kg';
    
    populationSettings.MinHeight           = NaN;
    populationSettings.MaxHeight           = NaN;
    populationSettings.HeightUnit          = 'dm';
    
    populationSettings.MinBMI              = NaN;
    populationSettings.MaxBMI              = NaN;
    populationSettings.BMIUnit             = 'kg/dm²';
    
    populationSettings.NumberOfIndividuals = 10;
    populationSettings.ProportionOfFemales = 50;
    
catch e
    if(isa(e, 'NET.NetException'))
        eObj = e.ExceptionObject;
        error(char(eObj.ToString));
    else
        rethrow(e);
    end
end
        
