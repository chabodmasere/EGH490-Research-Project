'# MWS Version: Version 2022.3 - Feb 04 2022 - ACIS 31.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 8.9 fmax = 9.1
'# created = '[VERSION]2020.0|29.0.1|20190925[/VERSION]


'@ use template: Antenna - Waveguide_9.cfg

'[VERSION]2020.0|29.0.1|20190925[/VERSION]
'set the units
With Units
    .Geometry "mm"
    .Frequency "GHz"
    .Voltage "V"
    .Resistance "Ohm"
    .Inductance "H"
    .TemperatureUnit  "Kelvin"
    .Time "ns"
    .Current "A"
    .Conductance "Siemens"
    .Capacitance "F"
End With
'----------------------------------------------------------------------------
'set the frequency range
Solver.FrequencyRange "8.9", "9.1"
'----------------------------------------------------------------------------
Plot.DrawBox True
With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With
With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With
' switch on FD-TET setting for accurate farfields
FDSolver.ExtrudeOpenBC "True"
Mesh.FPBAAvoidNonRegUnite "True"
Mesh.ConsiderSpaceForLowerMeshLimit "False"
Mesh.MinimumStepNumber "5"
With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
End With
With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With
PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"
With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With
'----------------------------------------------------------------------------
Dim sDefineAt As String
sDefineAt = "9"
Dim sDefineAtName As String
sDefineAtName = "9"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")
Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)
Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)
' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
    .Create
End With
' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .MonitorValue  zz_val
    .Create
End With
' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With
Next
'----------------------------------------------------------------------------
With MeshSettings
     .SetMeshType "Tet"
     .Set "Version", 1%
End With
With Mesh
     .MeshType "Tetrahedral"
End With
'set the solver type
ChangeSolverType("HF Frequency Domain")
'----------------------------------------------------------------------------

'@ switch working plane

'[VERSION]2020.0|29.0.1|20190925[/VERSION]
Plot.DrawWorkplane "false"

'@ new component: Chassis

'[VERSION]2020.0|29.0.1|20190925[/VERSION]
Component.New "Chassis"

'@ define brick: Chassis:body

'[VERSION]2020.0|29.0.1|20190925[/VERSION]
With Brick
     .Reset 
     .Name "body" 
     .Component "Chassis" 
     .Material "PEC" 
     .Xrange "-width/2", "width/2" 
     .Yrange "-bcavity-b-2*t", "-bcavity" 
     .Zrange "-length_delta/2", "length_delta/2" 
     .Create
End With

'@ define brick: Chassis:body2

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Brick
     .Reset 
     .Name "body2" 
     .Component "Chassis" 
     .Material "PEC" 
     .Xrange "-width/2", "width/2" 
     .Yrange "-bcavity", "0" 
     .Zrange "-length/2", "length/2" 
     .Create
End With

'@ boolean add shapes: Chassis:body, Chassis:body2

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.Add "Chassis:body", "Chassis:body2"

'@ define brick: Chassis:WaveguideCut

'[VERSION]2020.0|29.0.1|20190925[/VERSION]
With Brick
     .Reset 
     .Name "WaveguideCut" 
     .Component "Chassis" 
     .Material "PEC" 
     .Xrange "-a/2", "a/2" 
     .Yrange "-bcavity-b-t", "-bcavity-t" 
     .Zrange "-length_delta/2", "length_delta/2" 
     .Create
End With

'@ boolean subtract shapes: Chassis:body, Chassis:WaveguideCut

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.Subtract "Chassis:body", "Chassis:WaveguideCut"

'@ define brick: Chassis:CavCut

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Brick
     .Reset 
     .Name "CavCut" 
     .Component "Chassis" 
     .Material "PEC" 
     .Xrange "-acavity/2", "acavity/2" 
     .Yrange "-bcavity", "0" 
     .Zrange "-dcavity/2", "dcavity/2" 
     .Create
End With

'@ transform: translate Chassis:CavCut

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Transform 
     .Reset 
     .Name "Chassis:CavCut" 
     .Vector "0", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Translate" 
End With

'@ boolean subtract shapes: Chassis:body, Chassis:CavCut_1

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.Subtract "Chassis:body", "Chassis:CavCut_1"

'@ change material: Chassis:CavCut to: Vacuum

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.ChangeMaterial "Chassis:CavCut", "Vacuum"

'@ define brick: Chassis:CoupSlotCut

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Brick
     .Reset 
     .Name "CavSlotCut" 
     .Component "Chassis" 
     .Material "PEC" 
     .Xrange "Xcav-w/2", "Xcav+w/2" 
     .Yrange "-bcavity-t", "-bcavity" 
     .Zrange "-Lcav/2", "Lcav/2" 
     .Create
End With

'@ transform: translate Chassis:CoupSlotCut

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Transform 
     .Reset 
     .Name "Chassis:CavSlotCut" 
     .Vector "0", "0", "0" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Translate" 
End With

'@ boolean subtract shapes: Chassis:body, Chassis:CoupSlotCut_1

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.Subtract "Chassis:body", "Chassis:CavSlotCut_1"

'@ change material: Chassis:CoupSlotCut to: Vacuum

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Solid.ChangeMaterial "Chassis:CavSlotCut", "Vacuum"

'@ clear picks

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Pick.ClearAllPicks

'@ pick edge

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
Pick.PickEdgeFromId "Chassis:body", "59", "42"

'@ pick edge

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
Pick.PickEdgeFromId "Chassis:body", "63", "45"

'@ define port: 1

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-11.43", "11.43"
     .Yrange "-14.43", "-4.27"
     .Zrange "24.315128345574", "24.315128345574"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ pick edge

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
Pick.PickEdgeFromId "Chassis:body", "60", "40"

'@ pick edge

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
Pick.PickEdgeFromId "Chassis:body", "64", "46"

'@ define port: 2

'[VERSION]2023.0|32.0.1|20220912[/VERSION]
With Port 
     .Reset 
     .PortNumber "2" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-11.43", "11.43"
     .Yrange "-14.43", "-4.27"
     .Zrange "-24.315128345574", "-24.315128345574"
     .XrangeAdd "0.0", "0.0"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.0", "0.0"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ create group: meshgroup1

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Group.Add "meshgroup1", "mesh"

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "All", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-4" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "", "", "1", "Automatic", "True" 
     .AddSampleInterval "", "", "", "Automatic", "False" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ create group: meshgroup2

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Group.Add "meshgroup2", "mesh"

'@ set local mesh properties for: meshgroup2

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup2")
          .SetMeshType "Tet"
          .Set "LayerStackup", "Automatic"
          .Set "LocalAutomaticEdgeRefinement", "0"
          .Set "LocalAutomaticEdgeRefinementOverwrite", 0
          .Set "MaterialIndependent", 0
          .Set "OctreeSizeFaces", "0"
          .Set "PatchIndependent", 0
          .Set "Size", "0.7"
     End With
End With

'@ add items to group: "meshgroup2"

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Group.AddItem "solid$Chassis:CoupSlotCut", "meshgroup2"
Group.AddItem "solid$Chassis:SlotCut", "meshgroup2"

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.02" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.02", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-4" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ clear picks

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Pick.ClearAllPicks

''@ transform: rotate selected
'
''[VERSION]2020.7|29.0.1|20200710[/VERSION]
'With Transform 
'     .Reset 
'     .Name "port$port1" 
'     .AddName "port$port2" 
'     .AddName "solid$Chassis:CavCut" 
'     .AddName "solid$Chassis:CoupSlotCut" 
'     .AddName "solid$Chassis:SlotCut" 
'     .AddName "solid$Chassis:body" 
'     .Origin "Free" 
'     .Center "0", "0", "0" 
'     .Angle "90", "0", "0" 
'     .MultipleObjects "False" 
'     .GroupObjects "False" 
'     .Repetitions "1" 
'     .MultipleSelection "False" 
'     .Transform "Mixed", "Rotate" 
'End With
'
'@ define curve 3dpolygon: curve1:line_coup

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Polygon3D 
     .Reset 
     .Version 10 
     .Name "line_cav" 
     .Curve "curve1" 
     .Point "Xcav-w/2", "-bcavity-2*t", "0" 
     .Point "Xcav+w/2", "-bcavity-2*t", "0" 
     .Create 
End With

'@ define curve 3dpolygon: curve2:line_rad

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Polygon3D 
     .Reset 
     .Version 10 
     .Name "line_rad" 
     .Curve "curve2" 
     .Point "-acavity/2", "0", "0" 
     .Point "acavity/2", "0", "0" 
     .Create 
End With

'@ define boundaries

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Boundary
     .Xmin "open"
     .Xmax "open"
     .Ymin "open"
     .Ymax "expanded open"
     .Zmin "electric"
     .Zmax "open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
     .ApplyInAllDirections "False"
     .OpenAddSpaceFactor "0.5"
End With

'@ define monitor: e-field (f=9)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=9)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .MonitorValue "9" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-12.157564172787", "12.157564172787", "-12.157564172787", "12.157564172787", "-19.05", "8.8817841970013e-16" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.02" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.02", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.005" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.005", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set mesh properties (Tetrahedral special)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-4" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.005" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.005", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.005" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.005", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.005" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.005", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.005" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.005", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshAdaption3D
    .SetType "HighFrequencyTet" 
    .SetAdaptionStrategy "ExpertSystem" 
    .MinPasses "3" 
    .MaxPasses "8" 
    .ClearStopCriteria 
    .MaxDeltaS "0.001" 
    .NumberOfDeltaSChecks "1" 
    .EnableInnerSParameterAdaptation "True" 
    .PropagationConstantAccuracy "0.005" 
    .NumberOfPropConstChecks "2" 
    .EnablePortPropagationConstantAdaptation "True" 
    .RemoveAllUserDefinedStopCriteria 
    .AddStopCriterion "All S-Parameters", "0.001", "1", "True" 
    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
    .AddStopCriterion "All Probes", "0.05", "2", "False" 
    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
    .MinimumAcceptedCellGrowth "0.5" 
    .RefThetaFactor "" 
    .SetMinimumMeshCellGrowth "5" 
    .ErrorEstimatorType "Automatic" 
    .RefinementType "Automatic" 
    .SnapToGeometry "True" 
    .SubsequentChecksOnlyOnce "False" 
    .WavelengthBasedRefinement "True" 
    .EnableLinearGrowthLimitation "True" 
    .SetLinearGrowthLimitation "" 
    .SingularEdgeRefinement "2" 
    .DDMRefinementType "Automatic" 
End With

'@ set mesh properties (Tetrahedral special)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "CurvatureOrder", "1" 
     .Set "CurvatureOrderPolicy", "automatic" 
     .Set "CurvRefinementControl", "NormalTolerance" 
     .Set "NormalTolerance", "22.5" 
     .Set "SrfMeshGradation", "1.5" 
     .Set "SrfMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "UseMaterials",  "1" 
     .Set "MoveMesh", "0" 
End With 
With MeshSettings 
     .SetMeshType "All" 
     .Set "AutomaticEdgeRefinement",  "0.2" 
End With 
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "UseAnisoCurveRefinement", "1" 
     .Set "UseSameSrfAndVolMeshGradation", "1" 
     .Set "VolMeshGradation", "1.5" 
     .Set "VolMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "SmallFeatureSize", "0" 
     .Set "CoincidenceTolerance", "1e-06" 
     .Set "SelfIntersectionCheck", "1" 
     .Set "OptimizeForPlanarStructures", "0" 
End With 
With Mesh 
     .SetParallelMesherMode "Tet", "maximum" 
     .SetMaxParallelMesherThreads "Tet", "1" 
End With

'@ set mesh properties (Tetrahedral special)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "CurvatureOrder", "1" 
     .Set "CurvatureOrderPolicy", "automatic" 
     .Set "CurvRefinementControl", "NormalTolerance" 
     .Set "NormalTolerance", "22.5" 
     .Set "SrfMeshGradation", "1.5" 
     .Set "SrfMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "UseMaterials",  "1" 
     .Set "MoveMesh", "1" 
End With 
With MeshSettings 
     .SetMeshType "All" 
     .Set "AutomaticEdgeRefinement",  "0.2" 
End With 
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "UseAnisoCurveRefinement", "1" 
     .Set "UseSameSrfAndVolMeshGradation", "1" 
     .Set "VolMeshGradation", "1.5" 
     .Set "VolMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "SmallFeatureSize", "0" 
     .Set "CoincidenceTolerance", "1e-06" 
     .Set "SelfIntersectionCheck", "1" 
     .Set "OptimizeForPlanarStructures", "0" 
End With 
With Mesh 
     .SetParallelMesherMode "Tet", "maximum" 
     .SetMaxParallelMesherThreads "Tet", "1" 
End With

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-4" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ change solver type

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
ChangeSolverType "HF Frequency Domain"

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-4" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ set mesh properties (Tetrahedral special)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "CurvatureOrder", "1" 
     .Set "CurvatureOrderPolicy", "automatic" 
     .Set "CurvRefinementControl", "NormalTolerance" 
     .Set "NormalTolerance", "22.5" 
     .Set "SrfMeshGradation", "1.5" 
     .Set "SrfMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "UseMaterials",  "1" 
     .Set "MoveMesh", "0" 
End With 
With MeshSettings 
     .SetMeshType "All" 
     .Set "AutomaticEdgeRefinement",  "0.2" 
End With 
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "UseAnisoCurveRefinement", "1" 
     .Set "UseSameSrfAndVolMeshGradation", "1" 
     .Set "VolMeshGradation", "1.5" 
     .Set "VolMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "SmallFeatureSize", "0" 
     .Set "CoincidenceTolerance", "1e-06" 
     .Set "SelfIntersectionCheck", "1" 
     .Set "OptimizeForPlanarStructures", "0" 
End With 
With Mesh 
     .SetParallelMesherMode "Tet", "maximum" 
     .SetMaxParallelMesherThreads "Tet", "1" 
End With

'@ set mesh properties (Tetrahedral special)

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "CurvatureOrder", "1" 
     .Set "CurvatureOrderPolicy", "automatic" 
     .Set "CurvRefinementControl", "NormalTolerance" 
     .Set "NormalTolerance", "22.5" 
     .Set "SrfMeshGradation", "1.5" 
     .Set "SrfMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "UseMaterials",  "1" 
     .Set "MoveMesh", "1" 
End With 
With MeshSettings 
     .SetMeshType "All" 
     .Set "AutomaticEdgeRefinement",  "0.2" 
End With 
With MeshSettings 
     .SetMeshType "Tet" 
     .Set "UseAnisoCurveRefinement", "1" 
     .Set "UseSameSrfAndVolMeshGradation", "1" 
     .Set "VolMeshGradation", "1.5" 
     .Set "VolMeshOptimization", "1" 
End With 
With MeshSettings 
     .SetMeshType "Unstr" 
     .Set "SmallFeatureSize", "0" 
     .Set "CoincidenceTolerance", "1e-06" 
     .Set "SelfIntersectionCheck", "1" 
     .Set "OptimizeForPlanarStructures", "0" 
End With 
With Mesh 
     .SetParallelMesherMode "Tet", "maximum" 
     .SetMaxParallelMesherThreads "Tet", "1" 
End With

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 
With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-5" 
     .AccuracySrf "1e-3" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With
With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With
With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ change solver type

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
ChangeSolverType "HF IntegralEq"

'@ define frequency domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 

With FDSolver
     .Reset 
     .SetMethod "Surface", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-5" 
     .AccuracySrf "1e-4" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
     .HardwareAcceleration "False"
     .MaximumNumberOfGPUs "1"
End With

With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
End With

With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
End With

'@ change solver type

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
ChangeSolverType "HF Time Domain"

'@ define time domain solver parameters

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "True"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ change solver type

'[VERSION]2020.7|29.0.1|20200710[/VERSION]
ChangeSolverType "HF Eigenmode"

'@ define eigenmode solver parameters

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
Mesh.SetFlavor "High Frequency" 

Mesh.SetCreator "High Frequency" 

EigenmodeSolver.Reset 
With Solver
     .CalculationType "Eigenmode" 
     .AKSReset 
     .AKSPenaltyFactor "1" 
     .AKSEstimation "0" 
     .AKSAutomaticEstimation "True" 
     .AKSEstimationCycles "5" 
     .AKSIterations "2" 
     .AKSAccuracy "1e-12" 
End With
With EigenmodeSolver 
     .SetMethodType "AKS", "Hex" 
     .SetMethodType "Default", "Tet" 
     .SetMeshType "Tetrahedral Mesh" 
     .SetMeshAdaptationHex "False" 
     .SetMeshAdaptationTet "True" 
     .SetNumberOfModes "1" 
     .SetStoreResultsInCache "False" 
     .SetCalculateExternalQFactor "False" 
     .SetConsiderStaticModes "True" 
     .SetCalculateThermalLosses "True" 
     .SetModesInFrequencyRange "False" 
     .SetFrequencyTarget "True", "0.0" 
     .SetAccuracy "1e-6" 
     .SetQExternalAccuracy "1e-4" 
     .SetMaterialEvaluationFrequency "True", "" 
     .SetTDCompatibleMaterials "False" 
     .SetOrderTet "2" 
     .SetUseSensitivityAnalysis "False" 
     .SetConsiderLossesInPostprocessingOnly "True" 
     .SetMinimumQ "1.0" 
     .SetUseParallelization "True"
     .SetMaxNumberOfThreads "1024"
     .MaximumNumberOfCPUDevices "2"
     .SetRemoteCalculation "False"
End With
UseDistributedComputingForParameters "False"
MaxNumberOfDistributedComputingParameters "2"
UseDistributedComputingMemorySetting "False"
MinDistributedComputingMemoryLimit "0"
UseDistributedComputingSharedDirectory "False"
OnlyConsider0D1DResultsForDC "False"

'@ change solver type

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
ChangeSolverType "HF Frequency Domain"

'@ define frequency domain solver parameters

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
Mesh.SetCreator "High Frequency" 

With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-5" 
     .AccuracySrf "1e-4" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseEnhancedCFIE2 "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .UseEnhancedNFSImprint "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With

With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
     .ExtraPreconditioning "False" 
End With

With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
     .DetectThinDielectrics "True" 
End With

''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Surface", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "All" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'     .HardwareAcceleration "False"
'     .MaximumNumberOfGPUs "1"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "False" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ create group: meshgroup3
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Group.Add "meshgroup3", "mesh"
'
''@ set local mesh properties for: meshgroup3
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshSettings
'     With .ItemMeshSettings ("group$meshgroup3")
'          .SetMeshType "Srf"
'          .Set "LocalAutomaticEdgeRefinement", "0"
'          .Set "LocalAutomaticEdgeRefinementOverwrite", 0
'          .Set "LocalMLActive", 0
'          .Set "LocalMLElevation", "0"
'          .Set "LocalMLReference", "localml1"
'          .Set "LocalMLUseElevation", "Automatic"
'          .Set "LocalSurfaceMeshQuadMeshing", 0
'          .Set "LocalSurfaceMeshQuadMeshingOverwrite", 0
'          .Set "OctreeSizeFaces", "0"
'          .Set "PatchIndependent", 0
'          .Set "Size", "0.7"
'     End With
'End With
'
''@ add items to group: "meshgroup3"
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Group.AddItem "solid$Chassis:CavCut", "meshgroup3"
'Group.AddItem "solid$Chassis:CavSlotCut", "meshgroup3"
'Group.AddItem "solid$Chassis:RadSlotCut", "meshgroup3"
'
''@ pick face
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Pick.PickFaceFromId "Chassis:CavSlotCut", "5"
'
''@ define facefrompick: CavFace
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Face
'     .Reset 
'     .Name "CavFace" 
'     .Type "PickFace" 
'     .Offset "0.0" 
'     .Create
'End With
'
''@ pick face
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Pick.PickFaceFromId "Chassis:CavCut", "5"
'
''@ define facefrompick: RadFace
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Face
'     .Reset 
'     .Name "RadFace" 
'     .Type "PickFace" 
'     .Offset "0.0" 
'     .Create
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Surface", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "All" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'     .HardwareAcceleration "False"
'     .MaximumNumberOfGPUs "1"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "False" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "High" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ define boundaries
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Boundary
'     .Xmin "open"
'     .Xmax "open"
'     .Ymin "electric"
'     .Ymax "expanded open"
'     .Zmin "open"
'     .Zmax "open"
'     .Xsymmetry "none"
'     .Ysymmetry "none"
'     .Zsymmetry "none"
'     .ApplyInAllDirections "False"
'     .OpenAddSpaceFactor "0.5"
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Surface", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "All" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'     .HardwareAcceleration "False"
'     .MaximumNumberOfGPUs "1"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ change solver type
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'ChangeSolverType "HF Frequency Domain"
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "All" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ set local mesh properties for: meshgroup3
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshSettings
'     With .ItemMeshSettings ("group$meshgroup3")
'          .SetMeshType "Tet"
'          .Set "LayerStackup", "Automatic"
'          .Set "LocalAutomaticEdgeRefinement", "0"
'          .Set "LocalAutomaticEdgeRefinementOverwrite", 0
'          .Set "MaterialIndependent", 0
'          .Set "OctreeSizeFaces", "0"
'          .Set "PatchIndependent", 0
'          .Set "Size", "0.7"
'     End With
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "All" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .AddSampleInterval "9", "9", "1", "Single", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ define pml specials
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Boundary
'     .ReflectionLevel "0.0001" 
'     .MinimumDistanceType "Fraction" 
'     .MinimumDistancePerWavelengthNewMeshEngine "2" 
'     .MinimumDistanceReferenceFrequencyType "Center" 
'     .FrequencyForMinimumDistance "9" 
'     .SetAbsoluteDistance "0.0" 
'End With
'
''@ set 3d mesh adaptation properties
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshAdaption3D
'    .SetType "HighFrequencyTet" 
'    .SetAdaptionStrategy "ExpertSystem" 
'    .MinPasses "3" 
'    .MaxPasses "8" 
'    .ClearStopCriteria 
'    .MaxDeltaS "0.001" 
'    .NumberOfDeltaSChecks "1" 
'    .EnableInnerSParameterAdaptation "True" 
'    .PropagationConstantAccuracy "0.005" 
'    .NumberOfPropConstChecks "2" 
'    .EnablePortPropagationConstantAdaptation "True" 
'    .RemoveAllUserDefinedStopCriteria 
'    .AddStopCriterion "All S-Parameters", "0.001", "1", "True" 
'    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
'    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
'    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
'    .AddStopCriterion "All Probes", "0.05", "2", "False" 
'    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
'    .MinimumAcceptedCellGrowth "0.5" 
'    .RefThetaFactor "" 
'    .SetMinimumMeshCellGrowth "5" 
'    .ErrorEstimatorType "Automatic" 
'    .RefinementType "Automatic" 
'    .SnapToGeometry "True" 
'    .SubsequentChecksOnlyOnce "False" 
'    .WavelengthBasedRefinement "True" 
'    .EnableLinearGrowthLimitation "True" 
'    .SetLinearGrowthLimitation "" 
'    .SingularEdgeRefinement "2" 
'    .DDMRefinementType "Automatic" 
'End With
'
''@ define boundaries
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Boundary
'     .Xmin "open"
'     .Xmax "open"
'     .Ymin "electric"
'     .Ymax "expanded open"
'     .Zmin "open"
'     .Zmax "open"
'     .Xsymmetry "none"
'     .Ysymmetry "none"
'     .Zsymmetry "none"
'     .ApplyInAllDirections "False"
'     .OpenAddSpaceFactor "0.5"
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "All", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .AddSampleInterval "9", "9", "1", "Single", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ define frequency range
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Solver.FrequencyRange "9.275", "9.375"
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "All", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .AddSampleInterval "9.375", "9.375", "1", "Single", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ define monitor: e-field (f=9.325)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "e-field (f=9.325)" 
'     .Dimension "Volume" 
'     .Domain "Frequency" 
'     .FieldType "Efield" 
'     .MonitorValue "9.325" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-34.29", "34.29", "-18.97", "0", "-48.630256691149", "48.630256691149" 
'     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
'     .SetSubvolumeInflateWithOffset "False" 
'     .Create 
'End With
'
''@ define frequency range
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Solver.FrequencyRange "9.275", "9.475"
'
''@ delete monitor: e-field (f=9.325)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "e-field (f=9.325)"
'
''@ define monitor: e-field (f=9.375)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "e-field (f=9.375)" 
'     .Dimension "Volume" 
'     .Domain "Frequency" 
'     .FieldType "Efield" 
'     .MonitorValue "9.375" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-34.29", "34.29", "-18.97", "0", "-48.630256691149", "48.630256691149" 
'     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
'     .SetSubvolumeInflateWithOffset "False" 
'     .Create 
'End With
'
''@ define farfield monitor: farfield (f=9.375)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "farfield (f=9.375)" 
'     .Domain "Frequency" 
'     .FieldType "Farfield" 
'     .MonitorValue "9.375" 
'     .ExportFarfieldSource "False" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-34.29", "34.29", "-18.97", "0", "-48.630256691149", "48.630256691149" 
'     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
'     .SetSubvolumeInflateWithOffset "False" 
'     .SetSubvolumeOffsetType "FractionOfWavelength" 
'     .EnableNearfieldCalculation "True" 
'     .Create 
'End With
'
''@ delete monitor: e-field (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "e-field (f=9)"
'
''@ delete monitor: h-field (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "h-field (f=9)"
'
''@ delete monitor: farfield (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "farfield (f=9)"
'
''@ define frequency range
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Solver.FrequencyRange "8.9", "9.1"
'
''@ delete monitors
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "e-field (f=9.375)" 
'Monitor.Delete "farfield (f=9.375)"
'
''@ define monitor: e-field (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "e-field (f=9)" 
'     .Dimension "Volume" 
'     .Domain "Frequency" 
'     .FieldType "Efield" 
'     .MonitorValue "9" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-34.29", "34.29", "-18.97", "0", "-44.742882930143", "44.742882930143" 
'     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
'     .SetSubvolumeInflateWithOffset "False" 
'     .Create 
'End With
'
''@ define farfield monitor: farfield (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "farfield (f=9)" 
'     .Domain "Frequency" 
'     .FieldType "Farfield" 
'     .MonitorValue "9" 
'     .ExportFarfieldSource "False" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-34.29", "34.29", "-18.97", "0", "-44.742882930143", "44.742882930143" 
'     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
'     .SetSubvolumeInflateWithOffset "False" 
'     .SetSubvolumeOffsetType "FractionOfWavelength" 
'     .EnableNearfieldCalculation "True" 
'     .Create 
'End With
'
''@ define pml specials
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Boundary
'     .ReflectionLevel "0.0001" 
'     .MinimumDistanceType "Fraction" 
'     .MinimumDistancePerWavelengthNewMeshEngine "2" 
'     .MinimumDistanceReferenceFrequencyType "Center" 
'     .FrequencyForMinimumDistance "9" 
'     .SetAbsoluteDistance "0.0" 
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddSampleInterval "9", "9", "1", "Single", "True" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ define pml specials
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With Boundary
'     .ReflectionLevel "0.0001" 
'     .MinimumDistanceType "Fraction" 
'     .MinimumDistancePerWavelengthNewMeshEngine "2" 
'     .MinimumDistanceReferenceFrequencyType "Center" 
'     .FrequencyForMinimumDistance "9" 
'     .SetAbsoluteDistance "0.0" 
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "All", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddSampleInterval "9", "9", "1", "Single", "True" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .SetPortMeshMatches3DMeshTet "True" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ set local mesh properties for: meshgroup3
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshSettings
'     With .ItemMeshSettings ("group$meshgroup3")
'          .SetMeshType "Tet"
'          .Set "LayerStackup", "Automatic"
'          .Set "LocalAutomaticEdgeRefinement", "0"
'          .Set "LocalAutomaticEdgeRefinementOverwrite", 0
'          .Set "MaterialIndependent", 0
'          .Set "OctreeSizeFaces", "0"
'          .Set "PatchIndependent", 0
'          .Set "Size", "0.7"
'     End With
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "All", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddSampleInterval "9", "9", "1", "Single", "True" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ farfield plot options
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With FarfieldPlot 
'     .Plottype "Cartesian" 
'     .Vary "angle1" 
'     .Theta "90" 
'     .Phi "90" 
'     .Step "1" 
'     .Step2 "1" 
'     .SetLockSteps "True" 
'     .SetPlotRangeOnly "False" 
'     .SetThetaStart "0" 
'     .SetThetaEnd "180" 
'     .SetPhiStart "0" 
'     .SetPhiEnd "360" 
'     .SetTheta360 "False" 
'     .SymmetricRange "False" 
'     .SetTimeDomainFF "False" 
'     .SetFrequency "-1" 
'     .SetTime "0" 
'     .SetColorByValue "True" 
'     .DrawStepLines "False" 
'     .DrawIsoLongitudeLatitudeLines "False" 
'     .ShowStructure "True" 
'     .ShowStructureProfile "True" 
'     .SetStructureTransparent "False" 
'     .SetFarfieldTransparent "False" 
'     .AspectRatio "Free" 
'     .ShowGridlines "True" 
'     .InvertAxes "False", "False" 
'     .SetSpecials "enablepolarextralines" 
'     .SetPlotMode "Directivity" 
'     .Distance "1" 
'     .UseFarfieldApproximation "True" 
'     .IncludeUnitCellSidewalls "True" 
'     .SetScaleLinear "False" 
'     .SetLogRange "40" 
'     .SetLogNorm "0" 
'     .DBUnit "0" 
'     .SetMaxReferenceMode "abs" 
'     .EnableFixPlotMaximum "False" 
'     .SetFixPlotMaximumValue "1.0" 
'     .SetInverseAxialRatio "False" 
'     .SetAxesType "user" 
'     .SetAntennaType "directional_linear" 
'     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
'     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
'     .SetCoordinateSystemType "ludwig3" 
'     .SetAutomaticCoordinateSystem "True" 
'     .SetPolarizationType "Slant" 
'     .SlantAngle 0.000000e+00 
'     .Origin "bbox" 
'     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .SetUserDecouplingPlane "False" 
'     .UseDecouplingPlane "False" 
'     .DecouplingPlaneAxis "X" 
'     .DecouplingPlanePosition "0.000000e+00" 
'     .LossyGround "False" 
'     .GroundEpsilon "1" 
'     .GroundKappa "0" 
'     .EnablePhaseCenterCalculation "False" 
'     .SetPhaseCenterAngularLimit "3.000000e+01" 
'     .SetPhaseCenterComponent "boresight" 
'     .SetPhaseCenterPlane "both" 
'     .ShowPhaseCenter "True" 
'     .ClearCuts 
'     .AddCut "lateral", "0", "1"  
'     .AddCut "lateral", "90", "1"  
'     .AddCut "polar", "90", "1"  
'
'     .StoreSettings
'End With
'
''@ set local mesh properties for: meshgroup3
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshSettings
'     With .ItemMeshSettings ("group$meshgroup3")
'          .SetMeshType "Tet"
'          .Set "LayerStackup", "Automatic"
'          .Set "LocalAutomaticEdgeRefinement", "0"
'          .Set "LocalAutomaticEdgeRefinementOverwrite", 0
'          .Set "MaterialIndependent", 0
'          .Set "OctreeSizeFaces", "0"
'          .Set "PatchIndependent", 0
'          .Set "Size", "0.9"
'     End With
'End With
'
''@ delete monitor: farfield (f=9)
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Monitor.Delete "farfield (f=9)"
'
''@ set 3d mesh adaptation properties
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With MeshAdaption3D
'    .SetType "HighFrequencyTet" 
'    .SetAdaptionStrategy "ExpertSystem" 
'    .MinPasses "3" 
'    .MaxPasses "8" 
'    .ClearStopCriteria 
'    .MaxDeltaS "0.001" 
'    .NumberOfDeltaSChecks "1" 
'    .EnableInnerSParameterAdaptation "True" 
'    .PropagationConstantAccuracy "0.005" 
'    .NumberOfPropConstChecks "2" 
'    .EnablePortPropagationConstantAdaptation "True" 
'    .RemoveAllUserDefinedStopCriteria 
'    .AddStopCriterion "All S-Parameters", "0.001", "1", "True" 
'    .AddStopCriterion "Reflection S-Parameters", "0.02", "1", "False" 
'    .AddStopCriterion "Transmission S-Parameters", "0.02", "1", "False" 
'    .AddStopCriterion "Portmode kz/k0", "0.005", "2", "True" 
'    .AddStopCriterion "All Probes", "0.05", "2", "False" 
'    .AddSParameterStopCriterion "True", "", "", "0.002", "1", "False" 
'    .MinimumAcceptedCellGrowth "0.5" 
'    .RefThetaFactor "" 
'    .SetMinimumMeshCellGrowth "5" 
'    .ErrorEstimatorType "Automatic" 
'    .RefinementType "Automatic" 
'    .SnapToGeometry "True" 
'    .SubsequentChecksOnlyOnce "False" 
'    .WavelengthBasedRefinement "True" 
'    .EnableLinearGrowthLimitation "True" 
'    .SetLinearGrowthLimitation "" 
'    .SingularEdgeRefinement "2" 
'    .DDMRefinementType "Automatic" 
'End With
'
''@ define frequency domain solver parameters
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'Mesh.SetCreator "High Frequency" 
'
'With FDSolver
'     .Reset 
'     .SetMethod "Tetrahedral", "General purpose" 
'     .OrderTet "Second" 
'     .OrderSrf "First" 
'     .Stimulation "1", "1" 
'     .ResetExcitationList 
'     .AutoNormImpedance "False" 
'     .NormingImpedance "50" 
'     .ModesOnly "False" 
'     .ConsiderPortLossesTet "True" 
'     .SetShieldAllPorts "False" 
'     .AccuracyHex "1e-6" 
'     .AccuracyTet "1e-5" 
'     .AccuracySrf "1e-4" 
'     .LimitIterations "False" 
'     .MaxIterations "0" 
'     .SetCalcBlockExcitationsInParallel "True", "True", "" 
'     .StoreAllResults "False" 
'     .StoreResultsInCache "False" 
'     .UseHelmholtzEquation "True" 
'     .LowFrequencyStabilization "True" 
'     .Type "Auto" 
'     .MeshAdaptionHex "False" 
'     .MeshAdaptionTet "True" 
'     .AcceleratedRestart "True" 
'     .FreqDistAdaptMode "Distributed" 
'     .NewIterativeSolver "True" 
'     .TDCompatibleMaterials "False" 
'     .ExtrudeOpenBC "True" 
'     .SetOpenBCTypeHex "Default" 
'     .SetOpenBCTypeTet "Default" 
'     .AddMonitorSamples "True" 
'     .CalcPowerLoss "True" 
'     .CalcPowerLossPerComponent "False" 
'     .StoreSolutionCoefficients "True" 
'     .UseDoublePrecision "False" 
'     .UseDoublePrecision_ML "True" 
'     .MixedOrderSrf "False" 
'     .MixedOrderTet "False" 
'     .PreconditionerAccuracyIntEq "0.15" 
'     .MLFMMAccuracy "Default" 
'     .MinMLFMMBoxSize "0.3" 
'     .UseCFIEForCPECIntEq "True" 
'     .UseEnhancedCFIE2 "True" 
'     .UseFastRCSSweepIntEq "false" 
'     .UseSensitivityAnalysis "False" 
'     .UseEnhancedNFSImprint "False" 
'     .UseFastDirectFFCalc "False" 
'     .RemoveAllStopCriteria "Hex"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
'     .RemoveAllStopCriteria "Tet"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
'     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
'     .RemoveAllStopCriteria "Srf"
'     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
'     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
'     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
'     .SweepMinimumSamples "3" 
'     .SetNumberOfResultDataSamples "1001" 
'     .SetResultDataSamplingMode "Automatic" 
'     .SweepWeightEvanescent "1.0" 
'     .AccuracyROM "1e-4" 
'     .AddSampleInterval "9", "9", "1", "Single", "True" 
'     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
'     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
'     .MPIParallelization "False"
'     .UseDistributedComputing "False"
'     .NetworkComputingStrategy "RunRemote"
'     .NetworkComputingJobCount "3"
'     .UseParallelization "True"
'     .MaxCPUs "128"
'     .MaximumNumberOfCPUDevices "2"
'End With
'
'With IESolver
'     .Reset 
'     .UseFastFrequencySweep "True" 
'     .UseIEGroundPlane "True" 
'     .SetRealGroundMaterialName "" 
'     .CalcFarFieldInRealGround "False" 
'     .RealGroundModelType "Auto" 
'     .PreconditionerType "Type 1" 
'     .ExtendThinWireModelByWireNubs "False" 
'     .ExtraPreconditioning "False" 
'End With
'
'With IESolver
'     .SetFMMFFCalcStopLevel "0" 
'     .SetFMMFFCalcNumInterpPoints "6" 
'     .UseFMMFarfieldCalc "True" 
'     .SetCFIEAlpha "0.500000" 
'     .LowFrequencyStabilization "False" 
'     .LowFrequencyStabilizationML "True" 
'     .Multilayer "False" 
'     .SetiMoMACC_I "0.0001" 
'     .SetiMoMACC_M "0.0001" 
'     .DeembedExternalPorts "True" 
'     .SetOpenBC_XY "True" 
'     .OldRCSSweepDefintion "False" 
'     .SetRCSOptimizationProperties "True", "100", "0.00001" 
'     .SetAccuracySetting "Custom" 
'     .CalculateSParaforFieldsources "True" 
'     .ModeTrackingCMA "True" 
'     .NumberOfModesCMA "3" 
'     .StartFrequencyCMA "-1.0" 
'     .SetAccuracySettingCMA "Default" 
'     .FrequencySamplesCMA "0" 
'     .SetMemSettingCMA "Auto" 
'     .CalculateModalWeightingCoefficientsCMA "True" 
'     .DetectThinDielectrics "True" 
'End With
'
''@ s-parameter post processing: yz-matrices
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'PostProcess1D.ActivateOperation "yz-matrices", "FALSE"
'
''@ s-parameter post processing: vswr
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'PostProcess1D.ActivateOperation "vswr", "FALSE"
'
''@ define voltage monitor from curve: Vcav
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With VoltageMonitor
'     .Reset 
'     .Name "Vcav" 
'     .InvertOrientation "False" 
'     .Curve "curve1" 
'     .Add
'End With
'
''@ define voltage monitor from curve: Vrad
'
''[VERSION]2023.0|32.0.1|20220912[/VERSION]
'With VoltageMonitor
'     .Reset 
'     .Name "Vrad" 
'     .InvertOrientation "False" 
'     .Curve "curve2" 
'     .Add
'End With
'
'@ define frequency domain solver parameters

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
Mesh.SetCreator "High Frequency" 

With FDSolver
     .Reset 
     .SetMethod "Tetrahedral", "General purpose" 
     .OrderTet "Second" 
     .OrderSrf "First" 
     .Stimulation "1", "All" 
     .ResetExcitationList 
     .AutoNormImpedance "False" 
     .NormingImpedance "50" 
     .ModesOnly "False" 
     .ConsiderPortLossesTet "True" 
     .SetShieldAllPorts "False" 
     .AccuracyHex "1e-6" 
     .AccuracyTet "1e-5" 
     .AccuracySrf "1e-4" 
     .LimitIterations "False" 
     .MaxIterations "0" 
     .SetCalcBlockExcitationsInParallel "True", "True", "" 
     .StoreAllResults "False" 
     .StoreResultsInCache "False" 
     .UseHelmholtzEquation "True" 
     .LowFrequencyStabilization "True" 
     .Type "Auto" 
     .MeshAdaptionHex "False" 
     .MeshAdaptionTet "True" 
     .AcceleratedRestart "True" 
     .FreqDistAdaptMode "Distributed" 
     .NewIterativeSolver "True" 
     .TDCompatibleMaterials "False" 
     .ExtrudeOpenBC "True" 
     .SetOpenBCTypeHex "Default" 
     .SetOpenBCTypeTet "Default" 
     .AddMonitorSamples "True" 
     .CalcPowerLoss "True" 
     .CalcPowerLossPerComponent "False" 
     .StoreSolutionCoefficients "True" 
     .UseDoublePrecision "False" 
     .UseDoublePrecision_ML "True" 
     .MixedOrderSrf "False" 
     .MixedOrderTet "False" 
     .PreconditionerAccuracyIntEq "0.15" 
     .MLFMMAccuracy "Default" 
     .MinMLFMMBoxSize "0.3" 
     .UseCFIEForCPECIntEq "True" 
     .UseEnhancedCFIE2 "True" 
     .UseFastRCSSweepIntEq "false" 
     .UseSensitivityAnalysis "False" 
     .UseEnhancedNFSImprint "False" 
     .RemoveAllStopCriteria "Hex"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Hex", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Hex", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Hex", "False"
     .RemoveAllStopCriteria "Tet"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Tet", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Tet", "False"
     .AddStopCriterion "All Probes", "0.05", "2", "Tet", "True"
     .RemoveAllStopCriteria "Srf"
     .AddStopCriterion "All S-Parameters", "0.01", "2", "Srf", "True"
     .AddStopCriterion "Reflection S-Parameters", "0.01", "2", "Srf", "False"
     .AddStopCriterion "Transmission S-Parameters", "0.01", "2", "Srf", "False"
     .SweepMinimumSamples "3" 
     .SetNumberOfResultDataSamples "1001" 
     .SetResultDataSamplingMode "Automatic" 
     .SweepWeightEvanescent "1.0" 
     .AccuracyROM "1e-4" 
     .AddSampleInterval "9", "9", "1", "Single", "True" 
     .AddInactiveSampleInterval "", "", "1", "Automatic", "False" 
     .AddInactiveSampleInterval "", "", "", "Automatic", "False" 
     .SetPortMeshMatches3DMeshTet "True" 
     .MPIParallelization "False"
     .UseDistributedComputing "False"
     .NetworkComputingStrategy "RunRemote"
     .NetworkComputingJobCount "3"
     .UseParallelization "True"
     .MaxCPUs "128"
     .MaximumNumberOfCPUDevices "2"
End With

With IESolver
     .Reset 
     .UseFastFrequencySweep "True" 
     .UseIEGroundPlane "False" 
     .SetRealGroundMaterialName "" 
     .CalcFarFieldInRealGround "False" 
     .RealGroundModelType "Auto" 
     .PreconditionerType "Auto" 
     .ExtendThinWireModelByWireNubs "False" 
     .ExtraPreconditioning "False" 
End With

With IESolver
     .SetFMMFFCalcStopLevel "0" 
     .SetFMMFFCalcNumInterpPoints "6" 
     .UseFMMFarfieldCalc "True" 
     .SetCFIEAlpha "0.500000" 
     .LowFrequencyStabilization "False" 
     .LowFrequencyStabilizationML "True" 
     .Multilayer "False" 
     .SetiMoMACC_I "0.0001" 
     .SetiMoMACC_M "0.0001" 
     .DeembedExternalPorts "True" 
     .SetOpenBC_XY "True" 
     .OldRCSSweepDefintion "False" 
     .SetRCSOptimizationProperties "True", "100", "0.00001" 
     .SetAccuracySetting "Custom" 
     .CalculateSParaforFieldsources "True" 
     .ModeTrackingCMA "True" 
     .NumberOfModesCMA "3" 
     .StartFrequencyCMA "-1.0" 
     .SetAccuracySettingCMA "Default" 
     .FrequencySamplesCMA "0" 
     .SetMemSettingCMA "Auto" 
     .CalculateModalWeightingCoefficientsCMA "True" 
     .DetectThinDielectrics "True" 
End With

'@ change solver type

'[VERSION]2022.3|31.0.1|20220204[/VERSION]
ChangeSolverType "HF Frequency Domain"

