BEGIN_FILE
	Version 1.0
	Collection CellScaleBiaxial

BEGIN_BLOCK

BEGIN_DEVICES
1	Biotester5000	COM8	AutoDetectCOM	LoadcellX	250	24.3996	LoadcellY	250	23.3092	Temperature	22
	PreloadEx 2 25 25 10 5 6 100

BEGIN_CAMERAS
1	DMKCamera	USB	8	25	PixPerUmPerZoom	0.305	Maxfps	15

BEGIN_DISPLAYS
1	Video	1	Live_Video	710	593	262	387	FixedAspectRatio

BEGIN_CHARTS
1	Force_mN	FAuto	0	500	Time_S	Scroll	0	600	Position	600	0	ShowLegend
	Series	1	X	(255,0,0)	2
	Series	2	Y	(0,0,255)	2
2	Displacement_um	FAuto	0	400	Time_S	Scroll	0	600	Position	600	350	ShowLegend
	Series	1	X	(255,0,0)	2
	Series	2	Y	(0,0,255)	1
3	Force_mN	FAuto	0	500	Displacement_um	FAuto	0	400	Position	600	700	ShowLegend
	Series	1	X	(255,0,0)	2
	Series	2	Y	(0,0,255)	2

BEGIN_HARDWAREOPTS
TemperatureSetPoint	22
PreloadSettingsEx2 2 25 25 10 5 6 10 100
IdleCurrent 0
SyncPulseDivisor -1
CameraType	DMKCamera
CameraShutter	8
CameraGain	25


BEGIN_CONTROLS
Timestamp	Seconds
SampleSizeX_um	5000
SampleSizeY_um	5000
NumTrueStrainSegments	10
NumDataAveragingPoints	1
SizeAdjustWithPreload
SoftLimits	0	40000	0	40000
SoftForceLimits2	-1	-1
TemperatureWarnings	0	1
ResetWarning	1
ZeroWarning	1
OutputColumns	SetName	Cycle	Time_S	Temperature	XSize_um	YSize_um	XDisplacement_um	YDisplacement_um	XForce_mN	YForce_mN

BEGIN_MULTISET
Name	XMode	XFunction	XUnits	XMagnitude	XPreloadType	XPreloadMag	YMode	YFunction	YUnits	YMagnitude	YPreloadType	YPreloadMag	StretchDurationSec	RecoveryDurationSec	HoldTimeSec	RestTimeSec	NumReps	DataFreqHz	ImageFreqHz	
Until[_]breaking	Disp	Ramp	%	600	None	0	Disp	Ramp	%	600	None	0	360	0	0	0	1	1	1	
