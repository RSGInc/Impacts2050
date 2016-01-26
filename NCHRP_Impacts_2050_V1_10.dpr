program NCHRP_Impacts_2050_V1_10;

{$APPTYPE CONSOLE}

uses SysUtils;

function Dummy(a,b:integer): single;
begin
  if a=b then Dummy:=1.0 else Dummy:=0.0;
end;

function Max(a,b:single): single;
begin
  if a>b then Max:=a else Max:=b;
end;

function Min(a,b:single): single;
begin
  if a<b then Min:=a else Min:=b;
end;

{Control Module}
{constants}
const
StartYear = 2000;
TimeStepLength = 0.5; {years}
NumberOfTimeSteps = 100;
NumberOfRegions = 5;

{global variables}
var
TimeStep:integer = 0;
Year:single = StartYear;

Region:integer = 5;

{Demographic Module}
{constants}
const
NumberOfDemographicDimensions = 6;

NumberOfAgeGroups = 6;
AgeGroupLabels:array[0..NumberOfAgeGroups] of string[29]=
('Total',
 'Age  0-15',
 'Age 16-29',
 'Age 30-44',
 'Age 45-59',
 'Age 60-74',
 'Age 75+up');

  BirthAgeGroup = 1; {new births go into youngest age group}
  AgeGroupDuration:array[1..NumberOfAgeGroups] of single = (16,14,15,15,15,0);

NumberOfHhldTypes = 4;
HhldTypeLabels:array[1..NumberOfHhldTypes] of string[29]=
('Single/No Kids',
 'Couple/No Kids',
 'Single/With Kids',
 'Couple/With Kids');

  BirthHhldType:array[1..NumberOfHhldTypes] of integer=(2,4,2,4); {new births change 0 Ch to 1+ Ch}
  NumberOfAdults  :array[1..NumberOfHhldTypes] of single=(1, 2.2,   1, 2.2);
  NumberOfChildren:array[1..NumberOfHhldTypes] of single=(0,   0, 1.5, 1.5);

  NumberOfEthnicGrs = 12;
EthnicGrLabels:array[1..NumberOfEthnicGrs] of string[29]=
('Hispanic US born',
 'Hispanic >20 yrs',
 'Hispanic <20 yrs',
 'Black US born',
 'Black >20 yrs',
 'Black <20 yrs',
 'Asian US born',
 'Asian >20 yrs',
 'Asian <20 yrs',
 'White US born',
 'White >20 yrs',
 'White <20 yrs');

  EthnicGrDuration:array[1..NumberOfEthnicGrs] of integer=( 0, 0,20, 0, 0,20, 0, 0,20, 0, 0,20);
  NextEthnicGroup:array[1..NumberOfEthnicGrs]  of integer=( 0, 0, 2, 0, 0, 5, 0, 0, 8, 0, 0,11);
  BirthEthnicGroup:array[1..NumberOfEthnicGrs] of integer=( 1, 1, 1, 4, 4, 4, 7, 7, 7,10,10,10);

  OldNumberOfEthnicGrs = 6;
  OldEthnicGroup:array[1..NumberOfEthnicGrs]  of integer=( 3, 1, 2, 4, 1, 2, 5, 1, 2, 6, 1, 2);

NumberOfIncomeGrs = 3;
IncomeGrLabels:array[1..NumberOfIncomeGrs] of string[29]=
('Lower Income',
 'Middle Income',
 'Upper Income');
 LowIncomeDummy:array[1..NumberOfIncomeGrs] of integer = (1,0,0);
 MiddleIncomeDummy:array[1..NumberOfIncomeGrs] of integer = (0,1,0);
 HighIncomeDummy:array[1..NumberOfIncomeGrs] of integer = (0,0,1);

NumberOfWorkerGrs = 2;
WorkerGrLabels:array[1..NumberOfWorkerGrs] of string[29]=
('In Workforce',
 'Not in Workforce');

  BirthWorkerGr = 2; {new births are non-workers}

NumberOfAreaTypes = 3;
AreaTypeLabels:array[1..NumberOfAreaTypes] of string[29]=
('Urban Area',
 'Suburban Area',
 'Rural Area');

NumberOfMigrationTypes = 3;
MigrationTypeLabels:array[1..NumberOfMigrationTypes] of string[29]=
('Foreign Migration',
 'Domestic Migration',
 'Local Migration  ');

NumberOfEmploymentTypes = 3;
EmploymentTypeLabels:array[1..NumberOfEmploymentTypes] of string[29]=
('Retail Jobs','Service Jobs','Other Jobs');

NumberOfLandUseTypes = 4;
LandUseTypeLabels:array[1..NumberOfLandUseTypes] of string[29]=
('Non-resid. Land','Residential Land','Developable Land','Protected Land');

NumberOfRoadTypes = 3;
RoadTypeLabels:array[1..NumberOfRoadTypes] of string[29]=
('Freeways','Arterials','Local Roads');

NumberOfTransitTypes = 2;
TransitTypeLabels:array[1..NumberOfTransitTypes] of string[29]=
('Rail Transit','Bus Transit');

NumberOfTravelModelVariables = 26;
NumberOfTravelModelEquations = 15;
CarOwnership_CarCompetition = 1;
CarOwnership_NoCar = 2;
NonWorkTrip_Generation = 3;
WorkTrip_Generation = 4;
NonWorkTrip_CarPassengerMode = 5;
NonWorkTrip_TransitMode = 6;
NonWorkTrip_WalkBikeMode = 7;
WorkTrip_CarPassengerMode = 8;
WorkTrip_TransitMode = 9;
WorkTrip_WalkBikeMode = 10;
ChildTrip_TransitMode = 11;
ChildTrip_WalkBikeMode = 12;
CarDriverTrip_Distance = 13;
CarPassengerTrip_Distance = 14;
TransitTrip_Distance = 15;

EffectCurveIntervals=20;

 {global variables}

type
TimeStepArray = array[0..NumberOfTimeSteps] of single;

AreaTypeArray = array[1..NumberOfAreaTypes] of TimeStepArray;

EmploymentArray = array
[1..NumberOfAreaTypes,
 1..NumberOfEmploymentTypes] of TimeStepArray;

LandUseArray = array
[1..NumberOfAreaTypes,
 1..NumberOfLandUseTypes] of TimeStepArray;

RoadSupplyArray = array
[1..NumberOfAreaTypes,
 1..NumberOfRoadTypes] of TimeStepArray;

TransitSupplyArray = array
[1..NumberOfAreaTypes,
 1..NumberOfTransitTypes] of TimeStepArray;

DemographicArray = array
[1..NumberOfAreaTypes,
 1..NumberOfAgeGroups,
 1..NumberOfHhldTypes,
 1..NumberOfEthnicGrs,
 1..NumberOfIncomeGrs,
 1..NumberOfWorkerGrs] of TimeStepArray;

EffectCurveArray = array[-2..EffectCurveIntervals] of single;

function EffectCurve(curvePoints:EffectCurveArray; arg:single):single;
var low,high,pointOnCurve:single; lowerPoint,higherPoint:integer;
begin
  low:=curvePoints[-2];
  high:=curvePoints[-1];
  if low>=high then begin
    writeln('Invalid endpoint arguments for effect curve ...',low:3:2,' and ',high:3:2,' Press Enter');
    EffectCurve:=curvePoints[0];
    readln;
  end else
  if (arg<= low) then EffectCurve:=curvePoints[0] else
  if (arg>=high) then EffectCurve:=curvePoints[EffectCurveIntervals] else begin
  {interpolate linearly between points}
    pointOnCurve:= ((arg-low) / (high-low)) * EffectCurveIntervals;
    lowerPoint:= trunc(pointOnCurve);
    higherPoint:=lowerPoint+1;
    EffectCurve:= curvePoints[lowerPoint]
      + (pointOnCurve-lowerPoint) * (curvePoints[higherPoint]-curvePoints[lowerPoint]);
  end;
end;


var

C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness,
C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness,
C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness,

C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness,
C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness,
C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness

 :EffectCurveArray;




TravelModelParameter: array
[1..NumberOfTravelModelEquations,
 1..NumberOfTravelModelVariables] of single;

Jobs,
JobsCreated,
JobsLost,
JobsMovedOut,
JobsMovedIn : EmploymentArray;

Land,
ChangeInLandUseOut,
ChangeInLandUseIn : LandUseArray;

RoadLaneMiles,
RoadLaneMilesAdded,
RoadLaneMilesLost : RoadSupplyArray;

TransitRouteMiles,
TransitRouteMilesAdded,
TransitRouteMilesLost : TransitSupplyArray;

WorkplaceDistribution : array
[1..NumberOfAreaTypes,
 1..NumberOfAreaTypes] of TimeStepArray;

Population,
AgeingOut,
AgeingIn,
DeathsOut,
BirthsFrom,
BirthsIn,
MarriagesOut,
MarriagesIn,
DivorcesOut,
DivorcesIn,
FirstChildOut,
FirstChildIn,
EmptyNestOut,
EmptyNestIn,
LeaveNestOut,
LeaveNestIn,
WorkerStatusOut,
WorkerStatusIn,
IncomeGroupOut,
IncomeGroupIn,
AcculturationOut,
AcculturationIn,
RegionalOutmigration,
RegionalInmigration,
DomesticOutmigration,
DomesticInmigration,
ForeignOutmigration,
ForeignInmigration,
OwnCar,
ShareCar,
NoCar,
WorkTrips,
NonWorkTrips,
CarDriverWorkTrips,
CarPassengerWorkTrips,
TransitWorkTrips,
WalkBikeWorkTrips,
CarDriverWorkMiles,
CarPassengerWorkMiles,
TransitWorkMiles,
WalkBikeWorkMiles,
CarDriverNonWorkTrips,
CarPassengerNonWorkTrips,
TransitNonWorkTrips,
WalkBikeNonWorkTrips,
CarDriverNonWorkMiles,
CarPassengerNonWorkMiles,
TransitNonWorkMiles,
WalkBikeNonWorkMiles
:DemographicArray;


const
 NumberOfDemographicVariables = 47;
 DemographicVariableLabels:array[1..NumberOfDemographicVariables] of string=
 ('Population',
  'Ageing',
  'Deaths',
  'Births',
  'Marriages',
  'Divorces',
  'FirstChild',
  'EmptyNest',
  'LeaveNest',
  'ChangeStatus',
  'ChangeIncome',
  '20YearsInU',
  'AgeingIn',
  'BirthsIn',
  'MarriagesIn',
  'DivorcesIn',
  'FirstChildIn',
  'EmptyNestIn',
  'LeaveNestIn',
  'WorkforceIn',
  'IncomeGroupIn',
  '20YearsInUSIn',
  'ForeignInmigration',
  'ForeignOutmigration',
  'DomesticInmigration',
  'DomesticOutmigration',
  'RegionalInmigration',
  'RegionalOutmigration',
  'OwnCar',
  'ShareCar',
  'NoCar',
  'WorkTrips',
  'NonWorkTrips',
  'CarDriverWorkTrips',
  'CarPassengerWorkTrips',
  'TransitWorkTrips',
  'WalkBikeWorkTrips',
  'CarDriverWorkMiles',
  'CarPassengerWorkMiles',
  'TransitWorkMiles' ,                                                                                                                               
  'CarDriverNonWorkTrips',
  'CarPassengerNonWorkTrips',
  'TransitNonWorkTrips',
  'WalkBikeNonWorkTrips',
  'CarDriverNonWorkMiles',
  'CarPassengerNonWorkMiles',
  'TransitNonWorkMiles'   );

  var
 {current demographic marginals}
 AgeGroupMarginals:array[1..NumberOfDemographicVariables,0..NumberOfAgeGroups] of TimeStepArray;
 HhldTypeMarginals:array[1..NumberOfDemographicVariables,1..NumberOfHhldTypes] of TimeStepArray;
 EthnicGrMarginals:array[1..NumberOfDemographicVariables,1..NumberOfEthnicGrs] of TimeStepArray;
 IncomeGrMarginals:array[1..NumberOfDemographicVariables,1..NumberOfIncomeGrs] of TimeStepArray;
 WorkerGrMarginals:array[1..NumberOfDemographicVariables,1..NumberOfWorkerGrs] of TimeStepArray;
 AreaTypeMarginals:array[1..NumberOfDemographicVariables,1..NumberOfAreaTypes] of TimeStepArray;

 {target demographic marginals}
 AgeGroupTargetMarginals:array[1..NumberOfAgeGroups] of single;
 HhldTypeTargetMarginals:array[1..NumberOfHhldTypes] of single;
 EthnicGrTargetMarginals:array[1..NumberOfEthnicGrs] of single;
 IncomeGrTargetMarginals:array[1..NumberOfIncomeGrs] of single;
 WorkerGrTargetMarginals:array[1..NumberOfWorkerGrs] of single;
 AreaTypeTargetMarginals:array[1..NumberOfAreaTypes] of single;

BaseAverageHouseholdSize,
BaseMortalityRate,
BaseFertilityRate,
BaseMarriageRate,
BaseDivorceRate,
BaseEmptyNestRate,
BaseLeaveNestSingleRate,
BaseLeaveNestCoupleRate,
BaseEnterWorkforceRate,
BaseLeaveWorkforceRate,
BaseEnterLowIncomeRate,
BaseLeaveLowIncomeRate,
BaseEnterHighIncomeRate,
BaseLeaveHighIncomeRate:array
[1..NumberOfAgeGroups,
 1..NumberOfHhldTypes,
 1..NumberOfEthnicGrs] of single;

MarryNoChildren_ChildrenFraction,
MarryHasChildren_ChildrenFraction,
DivorceNoChildren_ChildrenFraction,
DivorceHasChildren_ChildrenFraction,
LeaveNestSingle_ChildrenFraction,
LeaveNestCouple_ChildrenFraction: single;

BaseForeignInmigrationRate,
BaseForeignOutmigrationRate,
BaseDomesticMigrationRate,
BaseRegionalMigrationRate:single;


var
ExogenousEffectOnMortalityRate,
ExogenousEffectOnFertilityRate,
ExogenousEffectOnMarriageRate,
ExogenousEffectOnDivorceRate,
ExogenousEffectOnEmptyNestRate,
ExogenousEffectOnLeaveWorkforceRate,
ExogenousEffectOnEnterWorkforceRate,
ExogenousEffectOnLeaveLowIncomeRate,
ExogenousEffectOnEnterLowIncomeRate,
ExogenousEffectOnLeaveHighIncomeRate,
ExogenousEffectOnEnterHighIncomeRate,
ExogenousEffectOnForeignInmigrationRate,
ExogenousEffectOnForeignOutmigrationRate,
ExogenousEffectOnDomesticMigrationRate,
ExogenousEffectOnRegionalMigrationRate,
LowIncomeEffectOnMortalityRate,
HighIncomeEffectOnMortalityRate,
LowIncomeEffectOnFertilityRate,
HighIncomeEffectOnFertilityRate,
LowIncomeEffectOnMarriageRate,
HighIncomeEffectOnMarriageRate,
LowIncomeEffectOnDivorceRate,
HighIncomeEffectOnDivorceRate,
LowIncomeEffectOnEmptyNestRate,
HighIncomeEffectOnEmptyNestRate,
LowIncomeEffectOnSpacePerHousehold,
HighIncomeEffectOnSpacePerHousehold,
WorkforceChangeDelay,
IncomeChangeDelay,
ForeignInmigrationDelay,
ForeignOutmigrationDelay,
DomesticMigrationDelay,
RegionalMigrationDelay,

ExogenousEffectOnGasolinePrice,
ExogenousEffectOnSharedCarFraction,
ExogenousEffectOnNoCarFraction,
ExogenousEffectOnWorkTripRate,
ExogenousEffectOnNonworkTripRate,
ExogenousEffectOnCarPassengerModeFraction,
ExogenousEffectOnTransitModeFraction,
ExogenousEffectOnWalkBikeModeFraction,
ExogenousEffectOnCarTripDistance,

ExogenousEffectOnJobCreationRate,
ExogenousEffectOnJobLossRate,
ExogenousEffectOnJobMoveRate,
JobCreationDelay,
JobLossDelay,
JobMoveDelay,

ExogenousEffectOnResidentialSpacePerHousehold,
ExogenousEffectOnCommercialSpacePerJob,
ExogenousEffectOnLandProtection,
ResidentialSpaceDevelopmentDelay,
ResidentialSpaceReleaseDelay,
CommercialSpaceDevelopmentDelay,
CommercialSpaceReleaseDelay,
LandProtectionProcessDelay,

ExogenousEffectOnRoadCapacityAddition,
ExogenousEffectOnTransitCapacityAddition,
ExogenousEffectOnRoadCapacityPerLane,
ExogenousEffectOnTransitCapacityPerRoute,
RoadCapacityAdditionDelay,
RoadCapacityRetirementDelay,
TransitCapacityAdditionDelay,
TransitCapacityRetirementDelay,

ExternalJobDemandSupplyIndex,
ExternalCommercialSpaceDemandSupplyIndex,
ExternalResidentialSpaceDemandSupplyIndex,
ExternalRoadMileDemandSupplyIndex

:TimeStepArray;

JobDemand,
JobSupply,
JobDemandSupplyIndex,
ResidentialSpaceDemand,
ResidentialSpaceSupply,
ResidentialSpaceDemandSupplyIndex,
CommercialSpaceDemand,
CommercialSpaceSupply,
CommercialSpaceDemandSupplyIndex,
DevelopableSpaceDemand,
DevelopableSpaceSupply,
DevelopableSpaceDemandSupplyIndex,
RoadVehicleCapacityDemandSupplyIndex,
WorkTripTransitMileDemand,
NonWorkTripTransitMileDemand,
TransitPassengerCapacityDemand,
TransitPassengerCapacitySupply,
TransitPassengerCapacityDemandSupplyIndex
:AreaTypeArray;

WorkTripRoadMileDemand,
NonWorkTripRoadMileDemand,
RoadVehicleCapacityDemand,
RoadVehicleCapacitySupply:RoadSupplyArray;

BaseResidentialSpacePerHousehold:array[1..NumberOfAreaTypes,1..NumberOfHhldTypes] of single;
BaseCommercialSpacePerJob:array[1..NumberOfAreaTypes,1..NumberOfEmploymentTypes] of single;
BaseRoadLaneCapacityPerHour:array[1..NumberOfAreaTypes,1..NumberOfRoadTypes] of single;
BaseTransitRouteCapacityPerHour:array[1..NumberOfAreaTypes,1..NumberOfTransitTypes] of single;

FractionOfDevelopableLandAllowedForResidential:array[1..NumberOfAreaTypes] of single;
FractionOfDevelopableLandAllowedForCommercial:array[1..NumberOfAreaTypes] of single;

WeightOfJobDemandSupplyIndexInEmployerAttractiveness,
WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness,
WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness
:array[1..NumberOfAreaTypes,1..NumberOfEmploymentTypes] of single;

WeightOfJobDemandSupplyIndexInResidentAttractiveness,
WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness,
WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness
:array[1..NumberOfAreaTypes,1..NumberOfHhldTypes] of single;

WorkTripPeakHourFraction,NonWorkTripPeakHourFraction:single;

AreaTypeWorkTripDistanceFraction: array[1..NumberOfAreaTypes,1..NumberOfAreaTypes,1..NumberOfAreaTypes,1..NumberOfRoadTypes] of single;
AreaTypeNonWorkTripDistanceFraction: array[1..NumberOfAreaTypes,1..NumberOfAreaTypes,1..NumberOfRoadTypes] of single;

BaseyearWorkplaceDistribution:array[1..NumberOfAreaTypes,1..NumberOfAreaTypes] of single;


Const
BaseGasolinePrice = 3.00;

var
RunLabel,InputDirectory,OutputDirectory:string;

procedure ReadUserInputData;
const
 ScenarioUserInputsFilename = 'ScenarioUserInputs.dat';
 DemographicInitialValuesFilename  = 'DemographicInitialValues.dat';
 EmploymentInitialValuesFilename = 'EmploymentInitialValues.dat';
 LandUseInitialValuesFilename = 'LandUseInitialValues.dat';
 TransportationSupplyInitialValuesFilename = 'TransportationSupplyInitialValues.dat';
 TravelModelParameterFilename = 'TravelModelParameters.dat';
 DemographicSeedMatrixFilename = 'DemographicSeedMatrix.dat';
 DemographicTransitionRatesFilename = 'DemographicTransitionRates.dat';

 var inf:text;
    prefix:string[6]; x:string[1]; inString:string[80]; ctlFileName:string;
{indices}
ResAreaType,
WorkAreaType,
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
OldEthnicGr,
HhldType,
AgeGroup,
EmploymentType,
LandUseType,
RoadType,
TransitType,
TripType,
MigrationType,
TravelModelVariable,
TravelModelEquation,
point,
rate
: byte;
xval:single;
tempRate:array[1..14] of single;


procedure readTimeArray(var inf:text; var scenVar:TimeStepArray; tFirst,tLast:integer);
var t,ts,s,timeStepsPerValue:integer; value,previousValue:single;
begin
 if tFirst=tLast then begin
  readln(inf,value);
  for ts:=0 to NumberOfTimeSteps do scenVar[ts]:=value;
 end else begin
  timeStepsPerValue:= round(NumberOfTimeSteps * 1.0 / (tLast-TFirst));
  ts:=0;
  for t:=tFirst to tLast do begin
    read(inf,value);
    if t=0 then scenVar[ts]:=value else
    {do straight line interpolation between user input values for each time step}
    for s:=1 to timeStepsPerValue do begin
      ts:=ts+1;
      scenVar[ts]:=previousValue + s*1.0/timeStepsPerValue * (value - previousValue);
    end;
    previousValue:=value;
  end;
  readln(inf);
 end;
end;

var ii:integer;
begin
{read control file}
  if paramCount>0 then ctlFileName:= paramStr(1) else ctlFileName:='SeattleMom.ctl';
  {write(ctlFileName); readln;}
  assign(inf,ctlFileName); reset(inf);
  repeat
    readln(inf,prefix,x,inString);
    while inString[1]=' ' do inString:= copy(inString,2,length(inString)-1);
    while inString[length(inString)]=' ' do inString:= copy(inString,1,length(inString)-1);
    for ii:=1 to length(inString) do if inString[ii]=Chr(34) then inString[ii]:=Chr(32);

    if prefix='RUNLAB' then RunLabel:=inString else
    if prefix='INPDIR' then InputDirectory:=inString else
    if prefix='OUTDIR' then OutputDirectory:=inString else
    if prefix='REGION' then Region:=StrToInt(inString);
  until eof(inf);
  if InputDirectory[length(InputDirectory)]<>'\' then InputDirectory:=InputDirectory+'\';
  if OutputDirectory[length(OutputDirectory)]<>'\' then OutputDirectory:=OutputDirectory+'\';

{read demographic seed matrix}
  assign(inf,InputDirectory+DemographicSeedMatrixFilename); reset(inf);
  for AreaType:=1 to NumberOfAreaTypes do
  for WorkerGr:=1 to NumberOfWorkerGrs do
  for IncomeGr:=1 to NumberOfIncomeGrs do
  for EthnicGr:=1 to NumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes + 1 do
  if HhldType>NumberOfHhldTypes then readln(inf,x) {totals row from SPSS, left in for convenience}
  else begin
    for AgeGroup:=1 to NumberOfAgeGroups do
      read(inf,Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][0]);
    readln(inf);
  end;
  close(inf);

{read demographic sector initial values}
  assign(inf,InputDirectory+DemographicInitialValuesFilename); reset(inf);

  for AgeGroup:=1 to NumberOfAgeGroups do readln(inf,AgeGroupTargetMarginals[AgeGroup]);
  for HhldType:=1 to NumberOfHhldTypes do readln(inf,HhldTypeTargetMarginals[HhldType]);
  for EthnicGr:=1 to NumberOfEthnicGrs do readln(inf,EthnicGrTargetMarginals[EthnicGr]);
  for IncomeGr:=1 to NumberOfIncomeGrs do readln(inf,IncomeGrTargetMarginals[IncomeGr]);
  for WorkerGr:=1 to NumberOfWorkerGrs do readln(inf,WorkerGrTargetMarginals[WorkerGr]);
  for AreaType:=1 to NumberOfAreaTypes do readln(inf,AreaTypeTargetMarginals[areaType]);

  close(inf);

{read employment sector initial values}
  assign(inf,InputDirectory+EmploymentInitialValuesFilename); reset(inf);

  for AreaType:=1 to NumberOfAreaTypes do
  for EmploymentType:=1 to NumberOfEmploymentTypes do begin
      readln(inf,Jobs[AreaType][EmploymentType][0]);
  end;

  for ResAreaType:=1 to NumberOfAreaTypes do
  for AreaType:=1 to NumberOfAreaTypes do begin
    readln(inf,BaseyearWorkplaceDistribution[ResAreaType][AreaType]);
    WorkplaceDistribution[ResAreaType][AreaType][0]:=BaseyearWorkplaceDistribution[ResAreaType][AreaType];
  end;

  readTimeArray(inf,JobCreationDelay,0,0);
  readTimeArray(inf,JobLossDelay,0,0);
  readTimeArray(inf,JobMoveDelay,0,0);

  for AreaType:=1 to NumberOfAreaTypes do
  for EmploymentType:=1 to NumberOfEmploymentTypes do begin
      readln(inf,
      WeightOfJobDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType],
      WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType],
      WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]);
  end;

  for point:=0 to EffectCurveIntervals do begin
       readln(inf, xval,
       C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness[point],
       C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness[point],
       C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness[point]);
       if point=0 then begin
         C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness[-2]:=xval;
         C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness[-2]:=xval;
         C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness[-2]:=xval;
       end else
       if point=EffectCurveIntervals then begin
         C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness[-1]:=xval;
         C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness[-1]:=xval;
         C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness[-1]:=xval;
       end;
  end;

  close(inf);

{read land use sector initial values}
  assign(inf,InputDirectory+LandUseInitialValuesFilename); reset(inf);

  for AreaType:=1 to NumberOfAreaTypes do
  for LandUseType:=1 to NumberOfLandUseTypes do begin
    readln(inf,Land[AreaType][LandUseType][0]);
  end;

  readTimeArray(inf,ResidentialSpaceDevelopmentDelay,0,0);
  readTimeArray(inf,ResidentialSpaceReleaseDelay,0,0);
  readTimeArray(inf,CommercialSpaceDevelopmentDelay,0,0);
  readTimeArray(inf,CommercialSpaceReleaseDelay,0,0);
  readTimeArray(inf,LandProtectionProcessDelay,0,0);

  for AreaType:=1 to NumberOfAreaTypes do begin
    for HhldType:=1 to NumberOfHhldTypes do
    read(inf,BaseResidentialSpacePerHousehold[AreaType][HhldType]);
    readln(inf);
  end;

  for AreaType:=1 to NumberOfAreaTypes do begin
    for EmploymentType:=1 to NumberOfEmploymentTypes do
    read(inf,BaseCommercialSpacePerJob[AreaType][EmploymentType]);
    readln(inf);
  end;

  for AreaType:=1 to NumberOfAreaTypes do begin
     readln(inf,
      FractionOfDevelopableLandAllowedForCommercial[AreaType],
      FractionOfDevelopableLandAllowedForResidential[AreaType]);
  end;

  close(inf);


{read transportation supply sector initial values}
  assign(inf,InputDirectory+TransportationSupplyInitialValuesFilename); reset(inf);

  for AreaType:=1 to NumberOfAreaTypes do
  for RoadType:=1 to NumberOfRoadTypes do
    readln(inf,RoadLaneMiles[AreaType][RoadType][0]);

  for TransitType:=1 to NumberOfTransitTypes do
    readln(inf,TransitRouteMiles[1][TransitType][0]); { all transit miles in urban, for now }

  readTimeArray(inf,RoadCapacityAdditionDelay,0,0);
  readTimeArray(inf,RoadCapacityRetirementDelay,0,0);
  readTimeArray(inf,TransitCapacityAdditionDelay,0,0);
  readTimeArray(inf,TransitCapacityRetirementDelay,0,0);

  for AreaType:=1 to NumberOfAreaTypes do begin
    for RoadType:=1 to NumberOfRoadTypes do
      read(inf,BaseRoadLaneCapacityPerHour[AreaType][RoadType]);
    readln(inf);
  end;

  for AreaType:=1 to NumberOfAreaTypes do begin
    for TransitType:=1 to NumberOfTransitTypes do
      read(inf,BaseTransitRouteCapacityPerHour[AreaType][TransitType]);
    readln(inf);
  end;

  readln(inf,WorkTripPeakHourFraction);
  readln(inf,NonWorkTripPeakHourFraction);

  for ResAreaType:=1 to NumberOfAreaTypes do
  for WorkAreaType:=1 to NumberOfAreaTypes do begin
    for AreaType:=1 to NumberOfAreaTypes do
    for RoadType:=1 to NumberOfRoadTypes do read(inf,AreaTypeWorkTripDistanceFraction[ResAreaType,WorkAreaType,AreaType,RoadType]);
    readln(inf);
  end;

  for ResAreaType:=1 to NumberOfAreaTypes do begin
    for AreaType:=1 to NumberOfAreaTypes do
    for RoadType:=1 to NumberOfRoadTypes do read(inf,AreaTypeNonWorkTripDistanceFraction[ResAreaType,AreaType,RoadType]);
    readln(inf);
  end;

  close(inf);

  {read demographic base demographic transition rates}
  assign(inf,InputDirectory+DemographicTransitionRatesFilename); reset(inf);

  for AgeGroup:=1 to NumberOfAgeGroups do
  for OldEthnicGr:=1 to OldNumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes do begin
     for rate:=1 to 14 do read(inf,tempRate[rate]);
     readln(inf);

     for EthnicGr:=1 to NumberOfEthnicGrs do if OldEthnicGroup[EthnicGr]=OldEthnicGr then begin
       BaseAverageHouseholdSize[AgeGroup][HHldType][EthnicGr]:=tempRate[1];
       BaseMortalityRate[AgeGroup][HHldType][EthnicGr]:=tempRate[2];
       BaseFertilityRate[AgeGroup][HHldType][EthnicGr]:=tempRate[3];
       BaseMarriageRate[AgeGroup][HHldType][EthnicGr]:=tempRate[4];
       BaseDivorceRate[AgeGroup][HHldType][EthnicGr]:=tempRate[5];
       BaseLeaveNestSingleRate[AgeGroup][HHldType][EthnicGr]:=tempRate[6];
       BaseLeaveNestCoupleRate[AgeGroup][HHldType][EthnicGr]:=tempRate[7];
       BaseEmptyNestRate[AgeGroup][HHldType][EthnicGr]:=tempRate[8];
       BaseEnterLowIncomeRate[AgeGroup][HHldType][EthnicGr]:=tempRate[9];
       BaseLeaveLowIncomeRate[AgeGroup][HHldType][EthnicGr]:=tempRate[10];
       BaseEnterHighIncomeRate[AgeGroup][HHldType][EthnicGr]:=tempRate[11];
       BaseLeaveHighIncomeRate[AgeGroup][HHldType][EthnicGr]:=tempRate[12];
       BaseEnterWorkforceRate[AgeGroup][HHldType][EthnicGr]:=tempRate[13];
       BaseLeaveWorkforceRate[AgeGroup][HHldType][EthnicGr]:=tempRate[14];
     end;
  end;

  readTimeArray(inf,WorkforceChangeDelay,0,0);
  readTimeArray(inf,IncomeChangeDelay,0,0);
  readTimeArray(inf,ForeignInmigrationDelay,0,0);
  readTimeArray(inf,ForeignOutmigrationDelay,0,0);
  readTimeArray(inf,DomesticMigrationDelay,0,0);
  readTimeArray(inf,RegionalMigrationDelay,0,0);

  readln(inf,MarryNoChildren_ChildrenFraction);
  readln(inf,MarryHasChildren_ChildrenFraction);
  readln(inf,DivorceNoChildren_ChildrenFraction);
  readln(inf,DivorceHasChildren_ChildrenFraction);
  readln(inf,LeaveNestSingle_ChildrenFraction);
  readln(inf,LeaveNestCouple_ChildrenFraction);

  readln(inf,BaseForeignInmigrationRate);
  readln(inf,BaseForeignOutmigrationRate);
  readln(inf,BaseDomesticMigrationRate);
  readln(inf,BaseRegionalMigrationRate);

  for AreaType:=1 to NumberOfAreaTypes do
  for MigrationType:=1 to NumberOfMigrationTypes do begin
      readln(inf,
      WeightOfJobDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType],
      WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType],
      WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]);
  end;

  for point:=0 to EffectCurveIntervals do begin
       readln(inf, xval,
       C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness[point],
       C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness[point],
       C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness[point]);
       if point=0 then begin
         C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness[-2]:=xval;
         C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness[-2]:=xval;
         C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness[-2]:=xval;
       end else
       if point=EffectCurveIntervals then begin
         C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness[-1]:=xval;
         C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness[-1]:=xval;
         C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness[-1]:=xval;
       end;
  end;

  close(inf);

{ read travel demand model parameters}
  assign(inf,InputDirectory+TravelModelParameterFilename); reset(inf);

  for TravelModelVariable:=1 to NumberOfTravelModelVariables do begin
    for TravelModelEquation:=1 to NumberOfTravelModelEquations do
      readln(inf,TravelModelParameter[TravelModelEquation][TravelModelVariable]);
  end;
  close(inf);


{read Exogenous user inputs}
  assign(inf,InputDirectory+ScenarioUserInputsFilename); reset(inf);
{demographic sector}
  readTimeArray(inf,ExogenousEffectOnMortalityRate,0,10);
  readTimeArray(inf,ExogenousEffectOnFertilityRate,0,10);
  readTimeArray(inf,ExogenousEffectOnMarriageRate,0,10);
  readTimeArray(inf,ExogenousEffectOnDivorceRate,0,10);
  readTimeArray(inf,ExogenousEffectOnEmptyNestRate,0,10);
  readTimeArray(inf,ExogenousEffectOnLeaveWorkforceRate,0,10);
  readTimeArray(inf,ExogenousEffectOnEnterWorkforceRate,0,10);
  readTimeArray(inf,ExogenousEffectOnLeaveLowIncomeRate,0,10);
  readTimeArray(inf,ExogenousEffectOnEnterLowIncomeRate,0,10);
  readTimeArray(inf,ExogenousEffectOnLeaveHighIncomeRate,0,10);
  readTimeArray(inf,ExogenousEffectOnEnterHighIncomeRate,0,10);
  readTimeArray(inf,ExogenousEffectOnForeignInmigrationRate,0,10);
  readTimeArray(inf,ExogenousEffectOnForeignOutmigrationRate,0,10);
  readTimeArray(inf,ExogenousEffectOnDomesticMigrationRate,0,10);
  readTimeArray(inf,ExogenousEffectOnRegionalMigrationRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnMortalityRate,0,10);
  readTimeArray(inf,HighIncomeEffectOnMortalityRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnFertilityRate,0,10);
  readTimeArray(inf,HighIncomeEffectOnFertilityRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnMarriageRate,0,10);
  readTimeArray(inf,HighIncomeEffectOnMarriageRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnDivorceRate,0,10);
  readTimeArray(inf,HighIncomeEffectOnDivorceRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnEmptyNestRate,0,10);
  readTimeArray(inf,HighIncomeEffectOnEmptyNestRate,0,10);
  readTimeArray(inf,LowIncomeEffectOnSpacePerHousehold,0,10);
  readTimeArray(inf,HighIncomeEffectOnSpacePerHousehold,0,10);
  {travel behavior subsector}
  readTimeArray(inf,ExogenousEffectOnGasolinePrice,0,10);
  readTimeArray(inf,ExogenousEffectOnSharedCarFraction,0,10);
  readTimeArray(inf,ExogenousEffectOnNoCarFraction,0,10);
  readTimeArray(inf,ExogenousEffectOnWorkTripRate,0,10);
  readTimeArray(inf,ExogenousEffectOnNonworkTripRate,0,10);
  readTimeArray(inf,ExogenousEffectOnCarPassengerModeFraction,0,10);
  readTimeArray(inf,ExogenousEffectOnTransitModeFraction,0,10);
  readTimeArray(inf,ExogenousEffectOnWalkBikeModeFraction,0,10);
  readTimeArray(inf,ExogenousEffectOnCarTripDistance,0,10);
  {employment sector}
  readTimeArray(inf,ExogenousEffectOnJobCreationRate,0,10);
  readTimeArray(inf,ExogenousEffectOnJobLossRate,0,10);
  readTimeArray(inf,ExogenousEffectOnJobMoveRate,0,10);
  {land use sector}
  readTimeArray(inf,ExogenousEffectOnResidentialSpacePerHousehold,0,10);
  readTimeArray(inf,ExogenousEffectOnCommercialSpacePerJob,0,10);
  readTimeArray(inf,ExogenousEffectOnLandProtection,0,10);
  {transport supply sector}
  readTimeArray(inf,ExogenousEffectOnRoadCapacityAddition,0,10);
  readTimeArray(inf,ExogenousEffectOnTransitCapacityAddition,0,10);
  readTimeArray(inf,ExogenousEffectOnRoadCapacityPerLane,0,10);
  readTimeArray(inf,ExogenousEffectOnTransitCapacityPerRoute,0,10);
  {external indices}
  readTimeArray(inf,ExternalJobDemandSupplyIndex,0,10);
  readTimeArray(inf,ExternalCommercialSpaceDemandSupplyIndex,0,10);
  readTimeArray(inf,ExternalResidentialSpaceDemandSupplyIndex,0,10);
  readTimeArray(inf,ExternalRoadMileDemandSupplyIndex,0,10);

  close(inf);

end;


procedure CalculateDemographicMarginals (demVar:integer; timeStep:integer);
var cellValue:single;
{indices}
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup: byte;
{subprocedure to recalculate the marginals}
begin
  {empty the marginals}
  for AgeGroup:=0 to NumberOfAgeGroups do AgeGroupMarginals[demVar][AgeGroup][timeStep]:=0;
  for HhldType:=1 to NumberOfHhldTypes do HhldTypeMarginals[demVar][HhldType][timeStep]:=0;
  for EthnicGr:=1 to NumberOfEthnicGrs do EthnicGrMarginals[demVar][EthnicGr][timeStep]:=0;
  for IncomeGr:=1 to NumberOfIncomeGrs do IncomeGrMarginals[demVar][IncomeGr][timeStep]:=0;
  for WorkerGr:=1 to NumberOfWorkerGrs do WorkerGrMarginals[demVar][WorkerGr][timeStep]:=0;
  for AreaType:=1 to NumberOfAreaTypes do AreaTypeMarginals[demVar][AreaType][timeStep]:=0;

  {loop on all cells and accumulate marginals}
  for AreaType:=1 to NumberOfAreaTypes do
  for WorkerGr:=1 to NumberOfWorkerGrs do
  for IncomeGr:=1 to NumberOfIncomeGrs do
  for EthnicGr:=1 to NumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes do
  for AgeGroup:=1 to NumberOfAgeGroups do begin
    if demVar=1 then cellValue:=Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=2 then cellValue:=AgeingOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=3 then cellValue:=DeathsOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=4 then cellValue:=BirthsFrom[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=5 then cellValue:=MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=6 then cellValue:=DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=7 then cellValue:=FirstChildOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=8 then cellValue:=EmptyNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=9 then cellValue:=LeaveNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=10 then cellValue:=WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=11 then cellValue:=IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=12 then cellValue:=AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=13 then cellValue:=AgeingIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=14 then cellValue:=BirthsIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=15 then cellValue:=MarriagesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=16 then cellValue:=DivorcesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=17 then cellValue:=FirstChildIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=18 then cellValue:=EmptyNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=19 then cellValue:=LeaveNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=20 then cellValue:=WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=21 then cellValue:=IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=22 then cellValue:=AcculturationIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
    if demVar=23 then cellValue:=ForeignInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=24 then cellValue:=ForeignOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=25 then cellValue:=DomesticInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=26 then cellValue:=DomesticOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=27 then cellValue:=RegionalInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=28 then cellValue:=RegionalOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=29 then cellValue:=OwnCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=30 then cellValue:=ShareCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=31 then cellValue:=NoCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=32 then cellValue:=WorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=33 then cellValue:=NonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=34 then cellValue:=CarDriverWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=35 then cellValue:=CarPassengerWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=36 then cellValue:=TransitWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=37 then cellValue:=WalkBikeWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=38 then cellValue:=CarDriverWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=39 then cellValue:=CarPassengerWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=40 then cellValue:=TransitWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=41 then cellValue:=CarDriverNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=42 then cellValue:=CarPassengerNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=43 then cellValue:=TransitNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=44 then cellValue:=WalkBikeNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=45 then cellValue:=CarDriverNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=46 then cellValue:=CarPassengerNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    if demVar=47 then cellValue:=TransitNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] else
    begin end;

    AgeGroupMarginals[demVar][   0    ][timeStep]:=AgeGroupMarginals[demVar][   0    ][timeStep] + cellValue;
    AgeGroupMarginals[demVar][AgeGroup][timeStep]:=AgeGroupMarginals[demVar][AgeGroup][timeStep] + cellValue;
    HhldTypeMarginals[demVar][HhldType][timeStep]:=HhldTypeMarginals[demVar][HhldType][timeStep] + cellValue;
    EthnicGrMarginals[demVar][EthnicGr][timeStep]:=EthnicGrMarginals[demVar][EthnicGr][timeStep] + cellValue;
    IncomeGrMarginals[demVar][IncomeGr][timeStep]:=IncomeGrMarginals[demVar][IncomeGr][timeStep] + cellValue;
    WorkerGrMarginals[demVar][WorkerGr][timeStep]:=WorkerGrMarginals[demVar][WorkerGr][timeStep] + cellValue;
    AreaTypeMarginals[demVar][AreaType][timeStep]:=AreaTypeMarginals[demVar][AreaType][timeStep] + cellValue;
  end; {cells}
end; {CalculateDemographicMarginals}


{Procedure to initialize the Population for the region}
procedure InitializePopulation;
const
 IPFIterations = 15;
var
 iteration,dimension:integer;
 current,target:double;

{indices}
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup: byte;

const demVar = 1; {population}

begin {InitializePopulation}
  {perform IPF to get the marginals to match the target marginals for the region}
  {perform the specified number of iterations}
  for iteration:=1 to IPFIterations do begin
    {loop on each marginal dimension}
    for dimension:=1 to NumberOfDemographicDimensions do begin
      {(re)calculate the current population marginals}
      CalculateDemographicMarginals(demVar,0);

      {loop on all the cells and adjust the current cell values to match the target marginal on the dimension}
      for AreaType:=1 to NumberOfAreaTypes do
      for WorkerGr:=1 to NumberOfWorkerGrs do
      for IncomeGr:=1 to NumberOfIncomeGrs do
      for EthnicGr:=1 to NumberOfEthnicGrs do
      for HhldType:=1 to NumberOfHhldTypes do
      for AgeGroup:=1 to NumberOfAgeGroups do begin

        if dimension=1 then begin current:=AreaTypeMarginals[demVar][AreaType][0]; target:=AreaTypeTargetMarginals[AreaType]; end else
        if dimension=2 then begin current:=AgeGroupMarginals[demVar][AgeGroup][0]; target:=AgeGroupTargetMarginals[AgeGroup]; end else
        if dimension=3 then begin current:=HhldTypeMarginals[demVar][HhldType][0]; target:=HhldTypeTargetMarginals[HhldType]; end else
        if dimension=4 then begin current:=EthnicGrMarginals[demVar][EthnicGr][0]; target:=EthnicGrTargetMarginals[EthnicGr]; end else
        if dimension=5 then begin current:=IncomeGrMarginals[demVar][IncomeGr][0]; target:=IncomeGrTargetMarginals[IncomeGr]; end else
        if dimension=6 then begin current:=WorkerGrMarginals[demVar][WorkerGr][0]; target:=WorkerGrTargetMarginals[WorkerGr]; end;

        if current>0 then Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][0]:=
                          Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][0] * target/current;


      end; {cells}
    end; {dimensions}
  end; {iterations}
end; {InitializePopulation}

procedure CalculateDemographicFeedbacks(timeStep:integer);
var
{indices}

WorkAreaType,
RoadAreaType,
RoadType,
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup: byte;
SpacePerHousehold, residents, commuters: single;
begin
  for AreaType:=1 to NumberOfAreaTypes do begin
      JobDemand[AreaType][timeStep]:=0;
      ResidentialSpaceDemand[AreaType][timeStep]:=0;
      for RoadType:=1 to NumberOfRoadTypes do begin
        WorkTripRoadMileDemand[AreaType][RoadType][timeStep]:=0;
        NonWorkTripRoadMileDemand[AreaType][RoadType][timeStep]:=0;
      end;
      WorkTripTransitMileDemand[AreaType][timeStep]:=0;
      NonWorkTripTransitMileDemand[AreaType][timeStep]:=0;

      for WorkAreaType:=1 to NumberOfAreaTypes do
        WorkplaceDistribution[AreaType][WorkAreaType][timeStep]:=
        WorkplaceDistribution[AreaType][WorkAreaType][timeStep-1];
  end;

  for AreaType:=1 to NumberOfAreaTypes do
  for WorkerGr:=1 to NumberOfWorkerGrs do
  for IncomeGr:=1 to NumberOfIncomeGrs do
  for EthnicGr:=1 to NumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes do
  for AgeGroup:=1 to NumberOfAgeGroups do begin

    residents:=Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1];

    if residents>0 then begin

      SpacePerHousehold:=
           BaseResidentialSpacePerHousehold[AreaType][HHldType]/(5280.0*5280) {sq feet to sq miles}
        * (Dummy(IncomeGr,1)*LowIncomeEffectOnSpacePerHousehold[timeStep]
          +Dummy(IncomeGr,2)* 1
          +Dummy(IncomeGr,3)*HighIncomeEffectOnSpacePerHousehold[timeStep])
        * ExogenousEffectOnResidentialSpacePerHousehold[timeStep];

      ResidentialSpaceDemand[AreaType][timeStep]:=ResidentialSpaceDemand[AreaType][timeStep]
        + (residents / Max(1.0,BaseAverageHouseholdSize[AgeGroup][HhldType][EthnicGr]))
        * SpacePerHousehold;

      if (WorkerGr=1) {worker} then begin

        for WorkAreaType:=1 to NumberOfAreaTypes do begin

          commuters := residents * WorkplaceDistribution[AreaType][WorkAreaType][timeStep];

          JobDemand[WorkAreaType][timeStep]:=JobDemand[WorkAreaType][timeStep]
            + commuters;

          {miles by road area - work trips}
          for RoadAreaType:=1 to NumberOfAreaTypes do
          for RoadType:=1 to NumberOfRoadTypes do begin

            WorkTripRoadMileDemand[RoadAreaType][RoadType][timeStep]:=WorkTripRoadMileDemand[RoadAreaType][RoadType][timeStep]
             + commuters/residents
             * CarDriverWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1]
             * AreaTypeWorkTripDistanceFraction[AreaType][WorkAreaType][RoadAreaType][RoadType];

            WorkTripTransitMileDemand[AreaType][timeStep]:=WorkTripTransitMileDemand[AreaType][timeStep]
             + commuters/residents
             * TransitWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1]
             * AreaTypeWorkTripDistanceFraction[AreaType][WorkAreaType][RoadAreaType][RoadType];
          end;
        end;
      end;

      {miles by road area - non work trips}
      for RoadAreaType:=1 to NumberOfAreaTypes do 
      for RoadType:=1 to NumberOfRoadTypes do begin

        NonWorkTripRoadMileDemand[RoadAreaType][RoadType][timeStep]:=NonWorkTripRoadMileDemand[RoadAreaType][RoadType][timeStep]
             + CarDriverNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1]
             * AreaTypeNonWorkTripDistanceFraction[AreaType][RoadAreaType][RoadType];

        NonWorkTripTransitMileDemand[AreaType][timeStep]:=NonWorkTripTransitMileDemand[AreaType][timeStep]
             + TransitNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1]
             * AreaTypeNonWorkTripDistanceFraction[AreaType][RoadAreaType][RoadType];
      end;
    end;
  end;
end;

procedure CalculateEmploymentFeedbacks(timeStep:integer);
var AreaType, EmploymentType: byte;
begin

 {get ratio of jobs to labor force in each area type from the previous time step}
  for AreaType:=1 to NumberOfAreaTypes do begin
    JobSupply[AreaType][timeStep]:=0;
    CommercialSpaceDemand[AreaType][timeStep]:=0;

    for EmploymentType:=1 to NumberOfEmploymentTypes do begin
      JobSupply[AreaType][timeStep]:=JobSupply[AreaType][timeStep]
        +Jobs[AreaType][EmploymentType][timeStep-1];
      CommercialSpaceDemand[AreaType][timeStep]:=CommercialSpaceDemand[AreaType][timeStep]
        +Jobs[AreaType][EmploymentType][timeStep-1]
        *BaseCommercialSpacePerJob[AreaType][EmploymentType]/(5280.0*5280) {sq feet to sq miles}
        *ExogenousEffectOnCommercialSpacePerJob[timeStep];
    end;
  end;

  {do job index relative to period 1, since not all persons who live in area work in area}
  for AreaType:=1 to NumberOfAreaTypes do begin
    JobDemandSupplyIndex[AreaType][timeStep]:=
      (JobDemand[AreaType][timeStep] / Max(1,JobSupply[AreaType][timeStep]))
     /(JobDemand[AreaType][  1     ] / Max(1,JobSupply[AreaType][   1    ]));
  end;
end;

procedure CalculateLandUseFeedbacks(timeStep:integer);
var AreaType: byte;
const LUResidential=2; LUCommercial=1; LUDevelopable=3; LUProtected=4;
begin

 {get ratio of demand and supply for Residential space, commercial space, and developable space}
  for AreaType:=1 to NumberOfAreaTypes do begin
    CommercialSpaceSupply[AreaType][timeStep]:=Land[AreaType][LUCommercial][timeStep-1];
    ResidentialSpaceSupply[AreaType][timeStep]:=Land[AreaType][LUResidential][timeStep-1];
    DevelopableSpaceSupply[AreaType][timeStep]:=Land[AreaType][LUDevelopable][timeStep-1];

    ResidentialSpaceDemandSupplyIndex[AreaType][timeStep]:=
       ResidentialSpaceDemand[AreaType][timeStep]  / Max(1,ResidentialSpaceSupply[AreaType][timeStep]);
    CommercialSpaceDemandSupplyIndex[AreaType][timeStep]:=
       CommercialSpaceDemand[AreaType][timeStep] / Max(1,CommercialSpaceSupply[AreaType][timeStep]);
    DevelopableSpaceDemandSupplyIndex[AreaType][timeStep]:=
       (Max(0,ResidentialSpaceDemand[AreaType][timeStep] - ResidentialSpaceSupply[AreaType][timeStep])
       +Max(0,CommercialSpaceDemand[AreaType][timeStep] - CommercialSpaceSupply[AreaType][timeStep]))
      / Max(1,DevelopableSpaceSupply[AreaType][timeStep] );
  end;

end;

procedure CalculateTransportationSupplyFeedbacks(timeStep:integer);
var AreaType, RoadType, TransitType: byte;
TotalRoadDemand, TotalRoadSupply, TotalTransitDemand, TotalTransitSupply:single;

const RoadTypeWeight:array[1..NumberOfRoadTypes] of single=(0.5,0.4,0.1);

begin

 {get ratio of demand and supply for road lane miles in each area type and road type}
  for AreaType:=1 to NumberOfAreaTypes do begin

    RoadVehicleCapacityDemandSupplyIndex[AreaType][timeStep]:= 0;

    for RoadType:=1 to NumberOfRoadTypes do begin

      RoadVehicleCapacitySupply[AreaType][RoadType][timeStep]:=
        RoadLaneMiles[AreaType][RoadType][timeStep-1]
      * BaseRoadLaneCapacityPerHour[AreaType,RoadType]
      * ExogenousEffectOnRoadCapacityPerLane[timeStep];


      RoadVehicleCapacityDemand[AreaType][RoadType][timeStep]:=
         WorkTripRoadMileDemand[AreaType][RoadType][timeStep-1]
       * WorkTripPeakHourFraction
       + NonWorkTripRoadMileDemand[AreaType][RoadType][timeStep-1]
       * NonWorkTripPeakHourFraction;


      RoadVehicleCapacityDemandSupplyIndex[AreaType][timeStep]:=
      RoadVehicleCapacityDemandSupplyIndex[AreaType][timeStep]
      + RoadTypeWeight[RoadType]
      * RoadVehicleCapacityDemand[AreaType][RoadType][timeStep]
       /Max(1,RoadVehicleCapacitySupply[AreaType][RoadType][timeStep]);
    end;
  end;

 {get ratio of demand and supply for transit route miles across area types - and apply to all area types}

  TotalTransitSupply:=0;
  TotalTransitDemand:=0;

  for AreaType:=1 to NumberOfAreaTypes do begin

    TransitPassengerCapacitySupply[AreaType][timeStep]:=0;
    for TransitType:=1 to NumberOfTransitTypes do begin
      TransitPassengerCapacitySupply[AreaType][timeStep]:= TransitPassengerCapacitySupply[AreaType][timeStep]
      + TransitRouteMiles[AreaType][TransitType][timeStep-1]
      * BaseTransitRouteCapacityPerHour[AreaType,TransitType]
      * ExogenousEffectOnTransitCapacityPerRoute[timeStep];
    end;
    TotalTransitSupply:=TotalTransitSupply+TransitPassengerCapacitySupply[AreaType][timeStep];

    TransitPassengerCapacityDemand[AreaType][timeStep]:=
         WorkTripTransitMileDemand[AreaType][timeStep-1]
       * WorkTripPeakHourFraction
       + NonWorkTripTransitMileDemand[AreaType][timeStep-1]
       * NonWorkTripPeakHourFraction;

    TotalTransitDemand:=TotalTransitDemand+TransitPassengerCapacityDemand[AreaType][timeStep];
  end;

  for AreaType:=1 to NumberOfAreaTypes do begin
    TransitPassengerCapacityDemandSupplyIndex[AreaType][timeStep]:=
       TotalTransitDemand
      /Max(1,TotalTransitSupply);
  end;
end;


procedure CalculateEmploymentTransitionRates(timeStep:integer);
var AreaType, EmploymentType, AreaType2: byte;
    EmployerAttractivenessIndex, ExternalEmployerAttractivenessIndex
    :array[1..NumberOfAreaTypes,1..NumberOfEmploymentTypes] of single;
    CurrentJobs,JobsMoved:single;
begin
  {set attractivness index for employment}
  for AreaType:=1 to NumberOfAreaTypes do
  for EmploymentType:=1 to NumberOfEmploymentTypes do begin

    EmployerAttractivenessIndex[AreaType][EmploymentType]:=

     ( EffectCurve(C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness,
         JobDemandSupplyIndex[AreaType][timeStep])
      * WeightOfJobDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]

     +EffectCurve(C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness,
         CommercialSpaceDemandSupplyIndex[AreaType][timeStep])
      * WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]

     +EffectCurve(C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness,
         RoadVehicleCapacityDemandSupplyIndex[AreaType][timeStep])
      * WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
     )/
      ( WeightOfJobDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
      + WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
      + WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]);

    ExternalEmployerAttractivenessIndex[AreaType][EmploymentType]:=

     ( EffectCurve(C_EffectOfJobDemandSupplyIndexOnEmployerAttractiveness,
         ExternalJobDemandSupplyIndex[timeStep])
      * WeightOfJobDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]

     +EffectCurve(C_EffectOfCommercialSpaceDemandSupplyIndexOnEmployerAttractiveness,
         ExternalCommercialSpaceDemandSupplyIndex[timeStep])
      * WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]

     +EffectCurve(C_EffectOfRoadMileDemandSupplyIndexOnEmployerAttractiveness,
         ExternalRoadMileDemandSupplyIndex[timeStep])
      * WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
     )/
      ( WeightOfJobDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
      + WeightOfCommercialSpaceDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]
      + WeightOfRoadMileDemandSupplyIndexInEmployerAttractiveness[AreaType][EmploymentType]);


  end;


  for AreaType:=1 to NumberOfAreaTypes do
  for EmploymentType:=1 to NumberOfEmploymentTypes do begin
    JobsCreated[AreaType][EmploymentType][timeStep]:=0;
    JobsLost[AreaType][EmploymentType][timeStep]:=0;
    JobsMovedOut[AreaType][EmploymentType][timeStep]:=0;
    JobsMovedIn[AreaType][EmploymentType][timeStep]:=0;
  end;

  {loop on cells and set rates}
  for AreaType:=1 to NumberOfAreaTypes do
  for EmploymentType:=1 to NumberOfEmploymentTypes do begin

    CurrentJobs:=Jobs[AreaType][EmploymentType][timeStep-1];

    JobsMoved:=CurrentJobs
        * (EmployerAttractivenessIndex[AreaType][EmploymentType]
          -ExternalEmployerAttractivenessIndex[AreaType][EmploymentType]);

    if JobsMoved>0 then begin
         JobsCreated[AreaType][EmploymentType][timeStep]:=
          Min(JobsMoved,CurrentJobs) * TimeStepLength/JobCreationDelay[timeStep]
        * ExogenousEffectOnJobCreationRate[timeStep];
    end
    else begin
         JobsLost[AreaType][EmploymentType][timeStep]:=
           Min(-JobsMoved,CurrentJobs) * TimeStepLength/JobLossDelay[timeStep]
        * ExogenousEffectOnJobLossRate[timeStep];
    end;

    {check other area types, and move jobs there if more attractive}
    for AreaType2:=1 to NumberOfAreaTypes do
    if (AreaType2 <> AreaType) then begin

        JobsMoved:=CurrentJobs
        * (EmployerAttractivenessIndex[AreaType2][EmploymentType]
          -EmployerAttractivenessIndex[AreaType][EmploymentType])
        * ExogenousEffectOnJobMoveRate[timeStep];

        if JobsMoved>0 then begin

          JobsMovedOut[AreaType][EmploymentType][timeStep]:=
            JobsMovedOut[AreaType][EmploymentType][timeStep]
            + Min(JobsMoved,CurrentJobs) * TimeStepLength/JobMoveDelay[timeStep];

          JobsMovedIn[AreaType2][EmploymentType][timeStep]:=
            JobsMovedIn[AreaType2][EmploymentType][timeStep]
            + Min(JobsMoved,CurrentJobs) * TimeStepLength/JobMoveDelay[timeStep];
       end;
    end;
  end;
end; {CalculateEmploymentTransitionRates}


procedure CalculateLandUseTransitionRates(timeStep:integer);
var AreaType : byte;
    NewResidentialSpaceNeeded,ExcessResidentialSpace,NewResidentialSpaceDeveloped,ResidentialSpaceReleased,
    NewCommercialSpaceNeeded,ExcessCommercialSpace,NewCommercialSpaceDeveloped,CommercialSpaceReleased,
    ProtectedSpaceReleased,DevelopableResidentialSpace,DevelopableCommercialSpace,
    IndicatedResidentialDevelopment,IndicatedCommercialDevelopment,DevelopableLandSufficiencyFraction:single;

const LUResidential=2; LUCommercial=1; LUDevelopable=3; LUProtected=4;
begin
 for AreaType:=1 to NumberOfAreaTypes do begin

  NewResidentialSpaceNeeded:= Max(0,ResidentialSpaceDemand[AreaType][timeStep] - ResidentialSpaceSupply[AreaType][timeStep]);

  ExcessResidentialSpace:=Max(0,ResidentialSpaceSupply[AreaType][timeStep] - ResidentialSpaceDemand[AreaType][timeStep]);

  DevelopableResidentialSpace:=DevelopableSpaceSupply[AreaType][TimeStep]
    * FractionOfDevelopableLandAllowedForResidential[AreaType];

  IndicatedResidentialDevelopment:=Min(NewResidentialSpaceNeeded,DevelopableResidentialSpace);

  NewCommercialSpaceNeeded:= Max(0,CommercialSpaceDemand[AreaType][timeStep] - CommercialSpaceSupply[AreaType][timeStep]);

  ExcessCommercialSpace:=Max(0,CommercialSpaceSupply[AreaType][timeStep] - CommercialSpaceDemand[AreaType][timeStep]);

  DevelopableCommercialSpace:=DevelopableSpaceSupply[AreaType][TimeStep]
     * FractionOfDevelopableLandAllowedForCommercial[AreaType];

  IndicatedCommercialDevelopment:=Min(NewCommercialSpaceNeeded,DevelopableCommercialSpace);

  DevelopableLandSufficiencyFraction:= DevelopableSpaceSupply[AreaType][TimeStep]/
     Max(1.0,IndicatedResidentialDevelopment+IndicatedCommercialDevelopment);

  if DevelopableLandSufficiencyFraction<1.0 then begin
      IndicatedResidentialDevelopment:=IndicatedResidentialDevelopment
        * DevelopableLandSufficiencyFraction;
      IndicatedCommercialDevelopment:=IndicatedCommercialDevelopment
        * DevelopableLandSufficiencyFraction;
  end;

  if NewResidentialSpaceNeeded>0 then
    NewResidentialSpaceDeveloped:=IndicatedResidentialDevelopment
     * TimeStepLength/ResidentialSpaceDevelopmentDelay[timeStep]
  else NewResidentialSpaceDeveloped:=0;

  if ExcessResidentialSpace>0 then
    ResidentialSpaceReleased:=ExcessResidentialSpace
     * TimeStepLength/ResidentialSpaceReleaseDelay[timeStep]
  else ResidentialSpaceReleased:=0;

  if NewCommercialSpaceNeeded>0 then
    NewCommercialSpaceDeveloped:=IndicatedCommercialDevelopment
     * TimeStepLength/CommercialSpaceDevelopmentDelay[timeStep]
   else NewCommercialSpaceDeveloped:=0;

  if ExcessCommercialSpace>0 then
    CommercialSpaceReleased:=ExcessCommercialSpace
     * TimeStepLength/CommercialSpaceReleaseDelay[timeStep]
  else CommercialSpaceReleased:=0;

  ProtectedSpaceReleased:=  {this can be negative - added to protection}
    Land[AreaType][LUProtected][timeStep-1] *
    (1.0 - ExogenousEffectOnLandProtection[timeStep])
     * TimeStepLength / LandProtectionProcessDelay[timeStep];

  ChangeInLandUseIn[AreaType][LUResidential][timeStep]:=NewResidentialSpaceDeveloped;
  ChangeInLandUseOut[AreaType][LUResidential][timeStep]:=ResidentialSpaceReleased;

  ChangeInLandUseIn[AreaType][LUCommercial][timeStep]:=NewCommercialSpaceDeveloped;
  ChangeInLandUseOut[AreaType][LUCommercial][timeStep]:=CommercialSpaceReleased;

  ChangeInLandUseIn[AreaType][LUDevelopable][timeStep]:=ResidentialSpaceReleased + CommercialSpaceReleased + ProtectedSpaceReleased;;
  ChangeInLandUseOut[AreaType][LUDevelopable][timeStep]:=NewResidentialSpaceDeveloped + NewCommercialSpaceDeveloped;

  ChangeInLandUseOut[AreaType][LUProtected][timeStep]:=ProtectedSpaceReleased;

 end;
end; {CalculateLandUseTransitionRates}

procedure CalculateTransportationSupplyTransitionRates(timeStep:integer);
var AreaType, RoadType, TransitType : byte;
FractionNewRoadMilesNeeded, FractionNewRoadMilesAdded, FractionNewTransitMilesNeeded, FractionNewTransitMilesAdded:single;
begin
 for AreaType:=1 to NumberOfAreaTypes do
 for RoadType:=1 to NumberOfRoadTypes do begin

    FractionNewRoadMilesNeeded:= Max(0,RoadVehicleCapacityDemand[AreaType][RoadType][timeStep] /
    Max(1,RoadVehicleCapacitySupply[AreaType][RoadType][timeStep]) - 1.0);

    if FractionNewRoadMilesNeeded>0 then begin
      FractionNewRoadMilesAdded:=FractionNewRoadMilesNeeded
      * ExogenousEffectOnRoadCapacityAddition[timeStep]
      * TimeStepLength/RoadCapacityAdditionDelay[timeStep];

      RoadLaneMilesAdded[AreaType][RoadType][timeStep]:=
          RoadLaneMiles[AreaType][RoadType][timeStep-1]
         * FractionNewRoadMilesAdded;
    end else begin

      RoadLaneMilesLost[AreaType][RoadType][timeStep]:=
        RoadLaneMiles[AreaType][RoadType][timeStep-1]
        * TimeStepLength/RoadCapacityRetirementDelay[timeStep];
    end;

    if AreaType<>1 then begin
      for TransitType:=1 to NumberOfTransitTypes do begin
        TransitRouteMilesAdded[AreaType][TransitType][timeStep]:=0;
        TransitRouteMilesLost[AreaType][TransitType][timeStep]:=0;
      end;
    end else begin

      FractionNewTransitMilesNeeded:= Max(0,TransitPassengerCapacityDemand[AreaType][timeStep] /
      Max(1,TransitPassengerCapacitySupply[AreaType][timeStep]) -1.0);

      if FractionNewTransitMilesNeeded>0 then begin
        FractionNewTransitMilesAdded:=FractionNewTransitMilesNeeded
        * ExogenousEffectOnTransitCapacityAddition[timeStep]
        * TimeStepLength/TransitCapacityAdditionDelay[timeStep];

        {apply in same proportion to all Transit types}
        for TransitType:=1 to NumberOfTransitTypes do
          TransitRouteMilesAdded[AreaType][TransitType][timeStep]:=
          TransitRouteMiles[AreaType][TransitType][timeStep-1]
         * FractionNewTransitMilesAdded;
      end else begin

        for TransitType:=1 to NumberOfTransitTypes do
          TransitRouteMilesLost[AreaType][TransitType][timeStep]:=
            TransitRouteMiles[AreaType][TransitType][timeStep-1]
            * TimeStepLength/TransitCapacityRetirementDelay[timeStep];
      end;
    end;
  end;
end; {CalculateTransportationSuppplyTransitionRates}


procedure CalculateDemographicTransitionRates(timeStep:integer);
var PreviousPopulation, ResidentsMoved,NewHHChildrenFraction,
tempSingle,tempCouple,temp1,temp2, PeopleMoved:single;
{indices}
AreaType,AreaType2,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup,
MigrationType,
NewAreaType,
NewWorkerGr,
NewIncomeGr,
NewEthnicGr,
NewHhldType,
NewAgeGroup,
BirthEthnicGr : byte;
ResidentAttractivenessIndex,ExternalResidentAttractivenessIndex
:array[1..NumberOfAreaTypes,1..NumberOfMigrationTypes] of single;

begin
  {set attractivness index for residents}
  for AreaType:=1 to NumberOfAreaTypes do
  for MigrationType:=1 to NumberOfMigrationTypes do begin

    ResidentAttractivenessIndex[AreaType][MigrationType]:=

     ( EffectCurve(C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness,
         JobDemandSupplyIndex[AreaType][timeStep])
      * WeightOfJobDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]

     +EffectCurve(C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness,
         ResidentialSpaceDemandSupplyIndex[AreaType][timeStep])
      * WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]

     +EffectCurve(C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness,
         RoadVehicleCapacityDemandSupplyIndex[AreaType][timeStep])
      * WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
     )/
      ( WeightOfJobDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
      + WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
      + WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]);

    ExternalResidentAttractivenessIndex[AreaType][MigrationType]:=

     ( EffectCurve(C_EffectOfJobDemandSupplyIndexOnResidentAttractiveness,
         ExternalJobDemandSupplyIndex[timeStep])
      * WeightOfJobDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]

     +EffectCurve(C_EffectOfResidentialSpaceDemandSupplyIndexOnResidentAttractiveness,
         ExternalResidentialSpaceDemandSupplyIndex[timeStep])
      * WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]

     +EffectCurve(C_EffectOfRoadMileDemandSupplyIndexOnResidentAttractiveness,
         ExternalRoadMileDemandSupplyIndex[timeStep])
      * WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
     )/
      ( WeightOfJobDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
      + WeightOfResidentialSpaceDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]
      + WeightOfRoadMileDemandSupplyIndexInResidentAttractiveness[AreaType][MigrationType]);
  end;

  {initialize all entries for each cell to 0}
  for AreaType:=1 to NumberOfAreaTypes do
  for WorkerGr:=1 to NumberOfWorkerGrs do
  for IncomeGr:=1 to NumberOfIncomeGrs do
  for EthnicGr:=1 to NumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes do
  for AgeGroup:=1 to NumberOfAgeGroups do begin
        BirthsFrom[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        DeathsOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        FirstChildOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        EmptyNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        LeaveNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        BirthsIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        MarriagesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        DivorcesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        FirstChildIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        EmptyNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        LeaveNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        AcculturationIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        ForeignInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        DomesticInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        RegionalInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        ForeignOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        DomesticOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        RegionalOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
  end;

  {apply rates for each cell}
  for AreaType:=1 to NumberOfAreaTypes do
  for WorkerGr:=1 to NumberOfWorkerGrs do
  for IncomeGr:=1 to NumberOfIncomeGrs do
  for EthnicGr:=1 to NumberOfEthnicGrs do
  for HhldType:=1 to NumberOfHhldTypes do
  for AgeGroup:=1 to NumberOfAgeGroups do begin

     PreviousPopulation:=Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1];

     if PreviousPopulation > 0 then begin
        {Calculate number ageing to the next age group}
        if (AgeGroupDuration[AgeGroup]>0.5) then begin
          {ageing rate is based only on duration of age cohort}
          AgeingOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * TimeStepLength / AgeGroupDuration[AgeGroup];
         {put them into next age group}
          NewAgeGroup:=AgeGroup+1;
          AgeingIn[AreaType][NewAgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=AgeingIn[AreaType][NewAgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + AgeingOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;

       {Calculate number of deaths}
        DeathsOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
        :=PreviousPopulation
        * BaseMortalityRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
        * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnMortalityRate[timeStep]
         + MiddleIncomeDummy[IncomeGr]
         + HighIncomeDummy[IncomeGr] * HighIncomeEffectOnMortalityRate[timeStep])
        * ExogenousEffectOnMortalityRate[timeStep];
         {deaths aren't put into any other group}

       {Calculate number of births}
        BirthsFrom[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
        :=PreviousPopulation
        * BaseFertilityRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
        * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnFertilityRate[timeStep]
         + MiddleIncomeDummy[IncomeGr]
         + HighIncomeDummy[IncomeGr] * HighIncomeEffectOnFertilityRate[timeStep])
        * ExogenousEffectOnFertilityRate[timeStep];

        {If first child, all adults in HH become "full nest" household}
        if (NumberOfChildren[HhldType]<0.5) then begin
          FirstChildOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          := BirthsFrom[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * NumberOfAdults[HhldType];

          NewHhldType:=HhldType + 2; {same number of adults, 1+ kids}

         {add full nest to new hhld type}
          FirstChildIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=FirstChildIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + FirstChildOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * NumberOfAdults[HhldType];

        end else begin
          NewHhldType:=HhldType; {not first child, same hhld type}
        end;

        BirthEthnicGr:=BirthEthnicGroup[EthnicGr];
        BirthsIn[AreaType][BirthAgeGroup][NewHhldType][BirthEthnicGr][IncomeGr][BirthWorkerGr][timeStep]
        :=BirthsIn[AreaType][BirthAgeGroup][NewHhldType][BirthEthnicGr][IncomeGr][BirthWorkerGr][timeStep]
          + BirthsFrom[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];

        {Calculate number of "marriages"}
        if (NumberOfAdults[HhldType]<1.99) then begin
          MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseMarriageRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
          * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnMarriageRate[timeStep]
          +  MiddleIncomeDummy[IncomeGr]
          +  HighIncomeDummy[IncomeGr] * HighIncomeEffectOnMarriageRate[timeStep])
          * ExogenousEffectOnMarriageRate[timeStep];

          if NumberOfChildren[HhldType]=0
            then NewHHChildrenFraction:=MarryNoChildren_ChildrenFraction
            else NewHHChildrenFraction:=MarryHasChildren_ChildrenFraction;

         {add marriages to new hhld types}
          NewHhldType:=3; {couple, no children}
          MarriagesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=MarriagesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          *(1.0-NewHHChildrenFraction);

          NewHhldType:=4; {couple, children}
          MarriagesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=MarriagesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          * NewHHChildrenFraction;
        end;

       {Calculate number "divorces"}
        if (NumberOfAdults[HhldType]>1.99) then begin
          DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseDivorceRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
          * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnDivorceRate[timeStep]
          +  MiddleIncomeDummy[IncomeGr]
          +  HighIncomeDummy[IncomeGr] * HighIncomeEffectOnDivorceRate[timeStep])
          * ExogenousEffectOnDivorceRate[timeStep];

          if NumberOfChildren[HhldType]=0
            then NewHHChildrenFraction:=DivorceNoChildren_ChildrenFraction
            else NewHHChildrenFraction:=DivorceHasChildren_ChildrenFraction;

         {add divorces to new hhld types}
          NewHhldType:=1; {single, no children}
          DivorcesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=DivorcesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          *(1.0-NewHHChildrenFraction);

         {add divorces to new hhld types}
          NewHhldType:=2; {single, w/ children}
          DivorcesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=DivorcesIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          * NewHHChildrenFraction;
        end;

        {Calculate number of 1+ child HH transitioning to 0 child ("empty nest" }
        if (NumberOfChildren[HhldType]>0.5) then begin
          EmptyNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseEmptyNestRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
          * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnEmptyNestRate[timeStep]
          +  MiddleIncomeDummy[IncomeGr]
          +  HighIncomeDummy[IncomeGr] * HighIncomeEffectOnEmptyNestRate[timeStep])
          * ExogenousEffectOnEmptyNestRate[timeStep];

         {add to new hhld type}
          NewHhldType:=HhldType-2; {same adults, no children}
           EmptyNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=EmptyNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          + EmptyNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;

        {calculate number of children "leaving the nest" }
        if (NumberOfChildren[HhldType]>0.5) then begin
          tempSingle:=PreviousPopulation
          * BaseLeaveNestSingleRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
          * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnEmptyNestRate[timeStep]
          +  MiddleIncomeDummy[IncomeGr]
          +  HighIncomeDummy[IncomeGr] * HighIncomeEffectOnEmptyNestRate[timeStep])
          * ExogenousEffectOnEmptyNestRate[timeStep];
          tempCouple:=PreviousPopulation
          * BaseLeaveNestCoupleRate[AgeGroup][HhldType][EthnicGr] * TimeStepLength
          * (LowIncomeDummy[IncomeGr] * LowIncomeEffectOnEmptyNestRate[timeStep]
          +  MiddleIncomeDummy[IncomeGr]
          +  HighIncomeDummy[IncomeGr] * HighIncomeEffectOnEmptyNestRate[timeStep])
          * ExogenousEffectOnEmptyNestRate[timeStep];

          LeaveNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
            := tempSingle + tempCouple;

        {add to new hhld types}
          NewHhldType:=1; {single, no children}
          LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
           + tempSingle * (1.0-LeaveNestSingle_ChildrenFraction);

          NewHhldType:=2; {couple, no children}
          LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
           + tempCouple * (1.0-LeaveNestCouple_ChildrenFraction);

          NewHhldType:=3; {single, w/ children}
          LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
           + tempSingle * LeaveNestSingle_ChildrenFraction;

          NewHhldType:=4; {couple, w/ children}
          LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=LeaveNestIn[AreaType][AgeGroup][NewHhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
           + tempCouple * LeaveNestCouple_ChildrenFraction;
        end;


      {Calculate workforce shifts}
        if WorkerGr=1 then begin {in workforce}
          WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseLeaveWorkforceRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / WorkforceChangeDelay[timeStep]
          * ExogenousEffectOnLeaveWorkforceRate[timeStep];

          NewWorkerGr:=2; {out of workforce}
          WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][NewWorkerGr][timeStep]
          :=WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][NewWorkerGr][timeStep]
          + WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;
        if WorkerGr=2 then begin {out workforce}
          WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseEnterWorkforceRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / WorkforceChangeDelay[timeStep]
          * ExogenousEffectOnEnterWorkforceRate[timeStep];

          NewWorkerGr:=1; {in workforce}
          WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][NewWorkerGr][timeStep]
          :=WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][NewWorkerGr][timeStep]
          + WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;

      {Calculate income shifts}
        if IncomeGr=1 then begin {leave low income}
          IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseLeaveLowIncomeRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / IncomeChangeDelay[timeStep]
          * ExogenousEffectOnLeaveLowIncomeRate[timeStep];

          NewIncomeGr:=2; {enter middle income}
          IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          :=IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          + IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end else
        if IncomeGr=2 then begin {leave middle income to low}
          temp1
          :=PreviousPopulation
          * BaseEnterLowIncomeRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / IncomeChangeDelay[timeStep]
          * ExogenousEffectOnEnterLowIncomeRate[timeStep];

          NewIncomeGr:=1; {enter low income}
          IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          :=IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          + temp1;

          {leave middle income to high}
          temp2
          :=PreviousPopulation
          * BaseEnterHighIncomeRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / IncomeChangeDelay[timeStep]
          * ExogenousEffectOnEnterHighIncomeRate[timeStep];

          NewIncomeGr:=3; {enter high income}
          IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          :=IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          + temp2;

          IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=temp1+temp2;
         end else
         if IncomeGr=3 then begin {leave high income}
          IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * BaseLeaveHighIncomeRate[AgeGroup][HhldType][EthnicGr]
          * TimeStepLength / IncomeChangeDelay[timeStep]
          * ExogenousEffectOnLeaveHighIncomeRate[timeStep];

          NewIncomeGr:=2; {enter middle income}
          IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          :=IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][NewIncomeGr][WorkerGr][timeStep]
          + IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;

      {Calculate number of non-US Born reaching 20 years in US ("acculturation") }
        if (EthnicGrDuration[EthnicGr]<0.1) then begin
          AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        end else begin
          AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
          :=PreviousPopulation
          * TimeStepLength / EthnicGrDuration[EthnicGr];

          NewEthnicGr:=NextEthnicGroup[EthnicGr];
         {add acculturated to new ethnic gr}
          AcculturationIn[AreaType][AgeGroup][HhldType][NewEthnicGr][IncomeGr][WorkerGr][timeStep]
          :=AcculturationIn[AreaType][AgeGroup][HhldType][NewEthnicGr][IncomeGr][WorkerGr][timeStep]
          + AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
        end;

        {Foreign migration only in foreign born <20 years ethnic group}
        if (EthnicGrDuration[EthnicGr]>0.1) then begin

          MigrationType:=1;

          PeopleMoved:=PreviousPopulation
          * BaseForeignInmigrationRate
          * ResidentAttractivenessIndex[AreaType][MigrationType]
          * ExogenousEffectOnForeignInmigrationRate[timeStep];

          ForeignInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
            PeopleMoved * TimeStepLength/ForeignInmigrationDelay[timeStep];

          PeopleMoved:=PreviousPopulation
          * BaseForeignOutmigrationRate
          * (1.0/ResidentAttractivenessIndex[AreaType][MigrationType])
          * ExogenousEffectOnForeignOutmigrationRate[timeStep];

          ForeignOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
             PeopleMoved * TimeStepLength/ForeignOutmigrationDelay[timeStep];
        end;

        {Domestic migration}
        begin

          MigrationType:=2;

          PeopleMoved:=PreviousPopulation
          * BaseDomesticMigrationRate
          *(ResidentAttractivenessIndex[AreaType][MigrationType]
          / ExternalResidentAttractivenessIndex[AreaType][MigrationType])
          * ExogenousEffectOnDomesticMigrationRate[timeStep];


          DomesticInmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
             PeopleMoved * TimeStepLength/DomesticMigrationDelay[timeStep];

          PeopleMoved:=PreviousPopulation
          * BaseDomesticMigrationRate
          *(ExternalResidentAttractivenessIndex[AreaType][MigrationType]
          / ResidentAttractivenessIndex[AreaType][MigrationType])
          * ExogenousEffectOnDomesticMigrationRate[timeStep];


          DomesticOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
             PeopleMoved * TimeStepLength/DomesticMigrationDelay[timeStep];

        end;

        {Internal regonal migration between area types}

        MigrationType:=3;

        {check other area types, and move jobs there if more attractive}
        for AreaType2:=1 to NumberOfAreaTypes do
        if (AreaType2 <> AreaType) then begin

          PeopleMoved:=PreviousPopulation
          * BaseRegionalMigrationRate
          *(ResidentAttractivenessIndex[AreaType2][MigrationType]
          / ResidentAttractivenessIndex[AreaType][MigrationType])
          * ExogenousEffectOnRegionalMigrationRate[timeStep];

          RegionalOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
          RegionalOutmigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
            + PeopleMoved * TimeStepLength/RegionalMigrationDelay[timeStep];

          RegionalInmigration[AreaType2][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
          RegionalInmigration[AreaType2][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
            + PeopleMoved * TimeStepLength/RegionalMigrationDelay[timeStep];
         end;

     end; {population > 0}
  end; {loop on cells}

end; {CalculateDemographicTransitionRates}


procedure ApplyDemographicTransitionRates(timeStep:integer);
var
{indices}
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup: byte;

begin
      {apply transition rates for each cell}
      for AreaType:=1 to NumberOfAreaTypes do
      for WorkerGr:=1 to NumberOfWorkerGrs do
      for IncomeGr:=1 to NumberOfIncomeGrs do
      for EthnicGr:=1 to NumberOfEthnicGrs do
      for HhldType:=1 to NumberOfHhldTypes do
      for AgeGroup:=1 to NumberOfAgeGroups do begin

       {Set new cell population by applying all the demographic rates}
        Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
        Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep-1]
         - AgeingOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract ageing}
         - DeathsOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract deaths}
         - MarriagesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract marriages}
         - DivorcesOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract divorces}
         - FirstChildOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract full nest}
         - EmptyNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract empty nest}
         - LeaveNestOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract leave nest}
         - AcculturationOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract acculturation}
         - WorkerStatusOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract workforce out}
         - IncomeGroupOut[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract income group out}
         - ForeignOutMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
         - DomesticOutMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
         - RegionalOutMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]

         + AgeingIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add ageing}
         + BirthsIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add births}
         + MarriagesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add marriages}
         + DivorcesIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add divorces}
         + FirstChildIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add full nest}
         + EmptyNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add empty nest}
         + LeaveNestIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add leave nest}
         + AcculturationIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {add acculturation}
         + WorkerStatusIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract workforce out}
         + IncomeGroupIn[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] {subtract income group out}
         + ForeignInMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
         + DomesticInMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]
         + RegionalInMigration[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep];
      end;

end; {ApplyDemographicTransitionRates}


procedure ApplyEmploymentTransitionRates(timeStep:integer);
var
{indices}
AreaType,
EmploymentType: byte;
begin

      {apply transition in number of workers for each cell}
      for AreaType:=1 to NumberOfAreaTypes do
      for EmploymentType:=1 to NumberOfEmploymentTypes do begin

       {Set new cell population by applying all the demographic rates}
        Jobs[AreaType][EmploymentType][timeStep]:=
         Jobs[AreaType][EmploymentType][timeStep-1]
        +JobsCreated[AreaType][EmploymentType][timeStep]
        -JobsLost[AreaType][EmploymentType][timeStep]
        +JobsMovedIn[AreaType][EmploymentType][timeStep]
        -JobsMovedOut[AreaType][EmploymentType][timeStep];
      end;
end; {ApplyEmploymentTransitionRates}

procedure ApplyLandUseTransitionRates(timeStep:integer);
var
{indices}
AreaType, LandUseType: byte;
begin

     {apply transition rates for all land use types}
      for AreaType:=1 to NumberOfAreaTypes do
      for LandUseType:=1 to NumberOfLandUseTypes do begin

        Land[AreaType][LandUseType][timeStep]:=
         Land[AreaType][LandUseType][timeStep-1]
        +ChangeInLandUseIn[AreaType][LandUseType][timeStep]
        -ChangeInLandUseOut[AreaType][LandUseType][timeStep]

      end;
end; {ApplyLandUseTransitionRates}

procedure ApplyTransportationSupplyTransitionRates(timeStep:integer);
var
{indices}
AreaType,
RoadType,TransitType: byte;
begin

      for AreaType:=1 to NumberOfAreaTypes do begin

         for RoadType:=1 to NumberOfRoadTypes do
          RoadLaneMiles[AreaType][RoadType][timeStep]:=
          RoadLaneMiles[AreaType][RoadType][timeStep-1]
         +RoadLaneMilesAdded[AreaType][RoadType][timeStep]
         -RoadLaneMilesLost[AreaType][RoadType][timeStep];

         for TransitType:=1 to NumberOfTransitTypes do
          TransitRouteMiles[AreaType][TransitType][timeStep]:=
          TransitRouteMiles[AreaType][TransitType][timeStep-1]
         +TransitRouteMilesAdded[AreaType][TransitType][timeStep]
         -TransitRouteMilesLost[AreaType][TransitType][timeStep];
      end;
end; {ApplyTransportationSuppplyTransitionRates}

procedure CalculateTravelDemand(timeStep:integer);
var
{indices}
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup,
CarOwnershipLevel,
TripPurpose: byte;

FullCarUtility,CarCompUtility,NoCarUtility,
CarDriverUtility,CarPassengerUtility,TransitUtility,WalkBikeUtility,
tempCarDriverTrips,tempCarPassengerTrips,tempTransitTrips,tempWalkBikeTrips,
tempCarDriverMiles,tempCarPassengerMiles,tempTransitMiles,tempWalkBikeMiles,
tempTrips,tempPop,prob:single;

VarValue:array[1..NumberOfTravelModelVariables] of single;


function TravelModelEquationResult(modelNumber,firstVar,lastVar:integer):single;
var value:single; varNumber:integer;
begin
      value:=0;
      for varNumber:=firstVar to lastVar do begin
        value:=value + + TravelModelParameter[modelNumber,varNumber] * VarValue[varNumber];
      end;
      TravelModelEquationResult := value;
end;

begin

      {apply travel demand models for each cell}
      for AreaType:=1 to NumberOfAreaTypes do
      for WorkerGr:=1 to NumberOfWorkerGrs do
      for IncomeGr:=1 to NumberOfIncomeGrs do
      for EthnicGr:=1 to NumberOfEthnicGrs do
      for HhldType:=1 to NumberOfHhldTypes do
      for AgeGroup:=1 to NumberOfAgeGroups do begin

        {initialize}
        WorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        NonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;

        CarDriverWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        CarPassengerWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        TransitWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        WalkBikeWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        CarDriverWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=  0;
        CarPassengerWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        TransitWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;

        CarDriverNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        CarPassengerNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        TransitNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;
        WalkBikeNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        CarDriverNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=  0;
        CarPassengerNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:= 0;
        TransitNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=0;

{ set the initial array of input variables }
        VarValue[1]:= 1.0; {constant}

        VarValue[2]:= Dummy(AgeGroup,1);
        VarValue[3]:= Dummy(AgeGroup,2);
        VarValue[4]:= Dummy(AgeGroup,4);
        VarValue[5]:= Dummy(AgeGroup,5);
        VarValue[6]:= Dummy(AgeGroup,6);

        VarValue[7]:= Dummy(HhldType,2) + Dummy(HhldType,4);
        VarValue[8]:= Dummy(HhldType,3) + Dummy(HhldType,4);
        VarValue[9]:= Dummy(HhldType,2);

        VarValue[10]:= Dummy(EthnicGr,1) + Dummy(EthnicGr,2) + Dummy(EthnicGr,3);
        VarValue[11]:= Dummy(EthnicGr,1) + Dummy(EthnicGr,2);
        VarValue[12]:= Dummy(EthnicGr,1);

        VarValue[13]:= Dummy(WorkerGr,1);

        VarValue[14]:= Dummy(IncomeGr,1);
        VarValue[15]:= Dummy(IncomeGr,3);

        VarValue[16]:= Dummy(AreaType,1);
        VarValue[17]:= Dummy(AreaType,3);

        VarValue[18]:= Dummy(Region,1);
        VarValue[19]:= Dummy(Region,2);
        VarValue[20]:= Dummy(Region,3);
        VarValue[21]:= Dummy(Region,4);
        VarValue[22]:= Dummy(Region,5);

        {apply the auto ownership model}

        FullCarUtility:= 1.0; {base}
        CarCompUtility:= exp(TravelModelEquationResult(CarOwnership_CarCompetition,1,22))
          * ExogenousEffectOnSharedCarFraction[timeStep];
        NoCarUtility:= exp(TravelModelEquationResult(CarOwnership_NoCar,1,22))
          * ExogenousEffectOnNoCarFraction[timeStep];

        {apply the rest of the models conditional on car ownership}
        for CarOwnershipLevel:= 1 to 3 do begin

          if CarOwnershipLevel = 1 then begin
            prob:=FullCarUtility / (FullCarUtility + CarCompUtility + NoCarUtility);
            OwnCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
              Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * prob;
          end else
          if CarOwnershipLevel = 2 then begin
            prob:=CarCompUtility / (FullCarUtility + CarCompUtility + NoCarUtility);
            ShareCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
              Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * prob;
          end else
            prob:=NoCarUtility / (FullCarUtility + CarCompUtility + NoCarUtility);
            NoCar[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
              Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * prob;

          tempPop:=Population[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] * prob;

          VarValue[23]:= Dummy(CarOwnershipLevel,3);
          VarValue[24]:= Dummy(CarOwnershipLevel,2);
          VarValue[25]:= BaseGasolinePrice * ExogenousEffectOnGasolinePrice[timeStep];

          {loop on trip purposes 1=work, 2=non-work}
          for TripPurpose:=1 to 2 do begin

             VarValue[26]:= Dummy(TripPurpose,1);

            {apply trip generation model, work trips only for workers}
            if (TripPurpose=1) and (WorkerGr = 1) then begin
              tempTrips:= tempPop * (exp(TravelModelEquationResult(WorkTrip_Generation,1,25)) - 1.0)
              * ExogenousEffectOnWorkTripRate[timeStep];
              WorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                WorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTrips;
            end
            else if (TripPurpose=2) then begin
              tempTrips:= tempPop * (exp(TravelModelEquationResult(NonWorkTrip_Generation,1,25)) - 1.0)
              * ExogenousEffectOnNonWorkTripRate[timeStep];
              NonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                NonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTrips;
            end
            else tempTrips:=0;

            if tempTrips>0 then begin

              {set mode utilities}
              if (TripPurpose=1) then begin
                CarDriverUtility:= 1.0; {base}
                CarPassengerUtility:= exp(TravelModelEquationResult(WorkTrip_CarPassengerMode,1,25))
                  * ExogenousEffectOnCarPassengerModeFraction[timeStep];
                TransitUtility:= exp(TravelModelEquationResult(WorkTrip_TransitMode,1,25))
                 * ExogenousEffectOnTransitModeFraction[timeStep];
                WalkBikeUtility:= exp(TravelModelEquationResult(WorkTrip_WalkBikeMode,1,25))
                 * ExogenousEffectOnWalkBikeModeFraction[timeStep];
              end else
              if AgeGroup = 1 then begin {different mode choice model for kids}
                CarDriverUtility:= 0.0; {not available}
                CarPassengerUtility:= 1.0 {base}
                 * ExogenousEffectOnCarPassengerModeFraction[timeStep];
                TransitUtility:= exp(TravelModelEquationResult(ChildTrip_TransitMode,1,25))
                 * ExogenousEffectOnTransitModeFraction[timeStep];
                WalkBikeUtility:= exp(TravelModelEquationResult(ChildTrip_WalkBikeMode,1,25))
                * ExogenousEffectOnWalkBikeModeFraction[timeStep];
              end else begin
                CarDriverUtility:= 1.0; {base}
                CarPassengerUtility:= exp(TravelModelEquationResult(NonWorkTrip_CarPassengerMode,1,25))
                 * ExogenousEffectOnCarPassengerModeFraction[timeStep];
                TransitUtility:= exp(TravelModelEquationResult(NonWorkTrip_TransitMode,1,25))
                 * ExogenousEffectOnTransitModeFraction[timeStep];
                WalkBikeUtility:= exp(TravelModelEquationResult(NonWorkTrip_WalkBikeMode,1,25))
                * ExogenousEffectOnWalkBikeModeFraction[timeStep];
              end;

              {split trips by mode and apply distance models}
              tempCarDriverTrips := tempTrips *
                CarDriverUtility / (CarDriverUtility + CarPassengerUtility + TransitUtility + WalkBikeUtility);

              tempCarDriverMiles := tempCarDriverTrips *
               (exp(TravelModelEquationResult(CarDriverTrip_Distance, 1,26)) - 1.0)
               * ExogenousEffectOnCarTripDistance[timeStep];

              tempCarPassengerTrips := tempTrips *
                CarPassengerUtility / (CarDriverUtility + CarPassengerUtility + TransitUtility + WalkBikeUtility);

              tempCarPassengerMiles := tempCarPassengerTrips *
               (exp(TravelModelEquationResult(CarPassengerTrip_Distance, 1,26)) - 1.0)
               * ExogenousEffectOnCarTripDistance[timeStep];

              tempTransitTrips := tempTrips *
                TransitUtility / (CarDriverUtility + CarPassengerUtility + TransitUtility + WalkBikeUtility);

              tempTransitMiles := tempTransitTrips *
               (exp(TravelModelEquationResult(TransitTrip_Distance, 1,26)) - 1.0);

              tempWalkBikeTrips := tempTrips *
                WalkBikeUtility / (CarDriverUtility + CarPassengerUtility + TransitUtility + WalkBikeUtility);


              if (TripPurpose = 1) then begin
                CarDriverWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarDriverWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarDriverTrips;
                CarPassengerWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarPassengerWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarPassengerTrips;
                TransitWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  TransitWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTransitTrips;
                WalkBikeWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  WalkBikeWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempWalkBikeTrips;

                CarDriverWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarDriverWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarDriverMiles;
                CarPassengerWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarPassengerWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarPassengerMiles;
                TransitWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  TransitWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTransitMiles;
              end else begin
                CarDriverNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarDriverNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarDriverTrips;
                CarPassengerNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarPassengerNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarPassengerTrips;
                TransitNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  TransitNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTransitTrips;
                WalkBikeNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  WalkBikeNonWorkTrips[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempWalkBikeTrips;

                CarDriverNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarDriverNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarDriverMiles;
                CarPassengerNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  CarPassengerNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempCarPassengerMiles;
                TransitNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep]:=
                  TransitNonWorkMiles[AreaType][AgeGroup][HhldType][EthnicGr][IncomeGr][WorkerGr][timeStep] + tempTransitMiles;
              end;

            end; {trips for purpose}
          end;  {purpose loop}
        end; {car ownership loop}
      end; {cells}

end; {CalculateTravelDemand}

procedure writeSimulationResults;
var ouf:text; ts,demVar:integer;
{indices}
AreaType,
WorkerGr,
IncomeGr,
EthnicGr,
HhldType,
AgeGroup,
EmploymentType,
LandUseType,
RoadType,
TransitType: byte;

procedure writeTimeArray(demArray:TimeStepArray; demLabel:string; varLabel:string);
var ts,tx:integer;
begin
  if varLabel = 'Population' then write(ouf,demLabel) else
  if demLabel = 'Total' then write(ouf,varLabel) else
  if demLabel = '' then write(ouf,varLabel) else
    write(ouf,varLabel+'-'+demLabel);
  for ts:=0 to NumberOfTimeSteps do begin
    if (ts=0) and (demArray[ts]=0) then tx:=1 else tx:=ts; {avoids 0 rate in first period}
    write(ouf,',',demArray[tx]:4:2);
  end;
  writeln(ouf);
end;

begin
   assign(ouf,OutputDirectory+RunLabel+'.csv'); rewrite(ouf);

   write(ouf,'Year');
   for ts:=0 to NumberOfTimeSteps do begin
     write(ouf,',',StartYear + ts*TimeStepLength:4:1);
   end;
   writeln(ouf);

   for demVar:=1 to NumberOfDemographicVariables do
   for AgeGroup:=0 to 0 do writeTimeArray(AgeGroupMarginals[demVar][AgeGroup],'',DemographicVariableLabels[demVar]);

   for AreaType:=1 to NumberOfAreaTypes do
   for EmploymentType:=1 to NumberOfEmploymentTypes do
      writeTimeArray(Jobs[AreaType][EmploymentType],'',
      AreaTypeLabels[AreaType]+'/'+EmploymentTypeLabels[EmploymentType]);

   for AreaType:=1 to NumberOfAreaTypes do
   for LandUseType:=1 to NumberOfLandUseTypes do
      writeTimeArray(Land[AreaType][LandUseType],'',
      AreaTypeLabels[AreaType]+'/'+LandUseTypeLabels[LandUseType]);

   for AreaType:=1 to NumberOfAreaTypes do
   for RoadType:=1 to NumberOfRoadTypes do
      writeTimeArray(RoadLaneMiles[AreaType][RoadType],
      AreaTypeLabels[AreaType]+'/'+RoadTypeLabels[RoadType],'LaneMiles');

   for AreaType:=1 to 1{NumberOfAreaTypes} do
   for TransitType:=1 to NumberOfTransitTypes do
      writeTimeArray(TransitRouteMiles[AreaType][TransitType],
      AreaTypeLabels[AreaType]+'/'+TransitTypeLabels[TransitType],'RouteMiles');

   for demVar:=1 to NumberOfDemographicVariables do begin
     for AgeGroup:=1 to NumberOfAgeGroups do writeTimeArray(AgeGroupMarginals[demVar][AgeGroup],AgeGroupLabels[AgeGroup],DemographicVariableLabels[demVar]);
     for HhldType:=1 to NumberOfHhldTypes do writeTimeArray(HhldTypeMarginals[demVar][HhldType],HhldTypeLabels[HhldType],DemographicVariableLabels[demVar]);
     for EthnicGr:=1 to NumberOfEthnicGrs do writeTimeArray(EthnicGrMarginals[demVar][EthnicGr],EthnicGrLabels[EthnicGr],DemographicVariableLabels[demVar]);
     for IncomeGr:=1 to NumberOfIncomeGrs do writeTimeArray(IncomeGrMarginals[demVar][IncomeGr],IncomeGrLabels[IncomeGr],DemographicVariableLabels[demVar]);
     for WorkerGr:=1 to NumberOfWorkerGrs do writeTimeArray(WorkerGrMarginals[demVar][WorkerGr],WorkerGrLabels[WorkerGr],DemographicVariableLabels[demVar]);
     for AreaType:=1 to NumberOfAreaTypes do writeTimeArray(AreaTypeMarginals[demVar][AreaType],AreaTypeLabels[AreaType],DemographicVariableLabels[demVar]);
   end;

   for AreaType:=1 to NumberOfAreaTypes do
       writeTimeArray(JobDemandSupplyIndex[AreaType],
      AreaTypeLabels[AreaType],'Job Demand/Supply');

   for AreaType:=1 to NumberOfAreaTypes do
       writeTimeArray(CommercialSpaceDemandSupplyIndex[AreaType],
      AreaTypeLabels[AreaType],'NonR.Space Demand/Supply');

   for AreaType:=1 to NumberOfAreaTypes do
       writeTimeArray(ResidentialSpaceDemandSupplyIndex[AreaType],
      AreaTypeLabels[AreaType],'Res.Space Demand/Supply');

   for AreaType:=1 to NumberOfAreaTypes do
       writeTimeArray(DevelopableSpaceDemandSupplyIndex[AreaType],
      AreaTypeLabels[AreaType],'Dev.Space Demand/Supply');

   for AreaType:=1 to NumberOfAreaTypes do
       writeTimeArray(RoadVehicleCapacityDemandSupplyIndex[AreaType],
      AreaTypeLabels[AreaType],'Road Miles Demand/Supply');

  close(ouf);
end;




{Main simulation program}
var demVar:integer;

begin
 {Read in all input data}
  ReadUserInputData;

{Initialize all sectors}
  InitializePopulation;
  {InitializeEmployment;  not necessary - in input data }
  {InitializeLandUse:     not necessary - in input data }
  {InitializeTransportationSupply;  not necessary - in input data }

  {Do travel demand for year 0 without supply feedback effects}
    CalculateTravelDemand(0);

  {step through time t}
  write('Simulating year ... ');
  repeat
    TimeStep := TimeStep + 1;
    Year := Year + TimeStepLength;
    if Year = trunc(Year) then write(Year:8:0);

    {Calculate feedbacks between sectors based on levels from previous time step}
    CalculateDemographicFeedbacks(TimeStep);
    CalculateEmploymentFeedbacks(TimeStep);
    CalculateLandUseFeedbacks(TimeStep);
    CalculateTransportationSupplyFeedbacks(TimeStep);

    {Calculate rate variables for time t based on levels from time t-1 and feedback effects}
    CalculateDemographicTransitionRates(TimeStep);
    CalculateEmploymentTransitionRates(TimeStep);
    CalculateLandUseTransitionRates(TimeStep);
    CalculateTransportationSupplyTransitionRates(TimeStep);

    {Apply transition rates to get new levels for time t}
    ApplyDemographicTransitionRates(TimeStep);
    ApplyEmploymentTransitionRates(TimeStep);
    ApplyLandUseTransitionRates(TimeStep);
    ApplyTransportationSupplyTransitionRates(TimeStep);

    {based on resulting population for time t, calculate the travel demand}
    CalculateTravelDemand(TimeStep);

    for DemVar:=1 to NumberOfDemographicVariables do CalculateDemographicMarginals(DemVar,TimeStep);

  until TimeStep >= NumberOfTimeSteps; {end of simulation}

  {Write out all simulation results}
  writeln;
  writeln('Writing results file ....');

  WriteSimulationResults;

  {TimeStep:=0; repeat TimeStep:=TimeStep+1 until TimeStep = 9999999;}

 { write('Simulation finished. Press Enter to send results to Excel'); readln;}

end.


