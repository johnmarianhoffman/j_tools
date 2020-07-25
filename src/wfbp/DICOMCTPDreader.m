function [] = DICOMCTPDreader(DICOMCTPDfile,DICOMCTPDdict)
%DICOMCTPDreader demonstrates how information can be extract from a DICOM-CT-PD file
%
%This function extracts information from a DICOM-CT-PD file. 
%The users can modify the funciton output to export the information  
%necessary for their reconstruction
%
% Syntax:  DICOMCTPDreader(DICOMCTPDfile,DICOMCTPDdict);
%
% Inputs:
%    DICOMCTPDfile - A char string, representing the name of the DICOM-CT-PD 
%    file (including the file path)
%    DICOMCTPDdict - A char string, representing the name of the DICOM-CT-PD 
%    dictionary file (including the file path)
%
% Example: 
%    DICOMCTPDreader('L067_4L_100kv_fulldose1.00005.dcm','DICOM-CT-PD-dict_v9.txt');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%

% Author: Baiyu Chen, Ph.D.
% Mayo Clinic
% March 2016
% 

%------------- BEGIN CODE --------------
header = dicominfo(DICOMCTPDfile,'dictionary',DICOMCTPDdict);

% display series information
fprintf('%s\n','SERIES ----------------------------------------------------------');
fprintf('%40s \t %s\n','Number of Series in This Scan',num2str(header.NumberofSpectra));
fprintf('%40s \t %s\n','Series Number',num2str(header.SpectrumIndex));

% display patient information
if isfield(header,'BodyPartExamined')
    fprintf('\n\n%s\n','PATIENT & LESION ------------------------------------------------');
    fprintf('%40s \t %s\n','Patient Code Name',header.PatientName.FamilyName);
    fprintf('%40s \t %s\n','Patient Age',header.PatientAge);
    fprintf('%40s \t %s\n','Patient Sex',header.PatientSex);
    fprintf('%40s \t %s\n','Body Part',header.BodyPartExamined);
    fprintf('%40s \t %s\n','Series UID',header.SeriesInstanceUID);
    fprintf('%40s \t %s\n','Study UID',header.StudyInstanceUID);
    
end

% readout scan parameters
manufacturer = header.Manufacturer; % 'SIEMENS', 'GE', or 'PHILIPS'
scanMode = header.TypeofProjectionData; % 'HELICAL' or 'AXIAL'
FFSmode = header.FlyingFocalSpotMode; % flying focal spot mode, 'FFSnone', 'FFSz', 'FFSxy', or 'FFSxyz'
prjNumRotation = double(header.NumberofSourceAngularSteps); % number of projections in 2PI
rotationTime = double(header.ExposureTime); % rotation time, ms
if strcmp(header.TypeofProjectionData,'HELICAL')
    pitch = double(header.SpiralPitchFactor); % helical pitch 
end
tubeCurrent = header.XrayTubeCurrent; % tube current, mA
                                      %photonProfile = header.PhotonStatistics; % photon statistics
 

% read out detector information
detPixSizeCol = double(header.DetectorElementTransverseSpacing); % dcol, detector column width measured at detector surface, mm
detPixSizeRow = double(header.DetectorElementAxialSpacing); % drow, detector row width measured at detector surface, mm
detColNum = double(header.NumberofDetectorColumns); % Ncol, number of detector columns
detRowNum = double(header.NumberofDetectorRows); %Nrow, number of detector rows 
detFocalCenterRho = double(header.DetectorFocalCenterRadialDistance); % rho0, detector focal center radial location, mm
detFocalCenterPhi = double(header.DetectorFocalCenterAngularPosition); % phi0, detector focal center angular location, rad
detFocalCenterZ = double(header.DetectorFocalCenterAxialPosition); % z0, detector focal center z location, mm
detCentralCol = double(header.DetectorCentralElement(1)); % ColX, the detector column that aligns with isocenter and detector focal center
detCentralRow = double(header.DetectorCentralElement(2)); % RowY, the detector row that aligns with isocenter and detector focal center
detFocalCenterToDetDistance = double(header.ConstantRadialDistance); % d0, in-plane detector focal center-to-detector distance(radius of detector arc), mm

% read out focal spot location
focalSpotRho = detFocalCenterRho + double(header.SourceRadialDistanceShift); % rho0+drho
focalSpotPhi = detFocalCenterPhi + double(header.SourceAngularPositionShift); % phi0+dphi
focalSpotZ = detFocalCenterZ + double(header.SourceAxialPositionShift); % z0+dz

% readout projection data (2D matrix, detector_column x detector_row)
projectionUncorr = double(dicomread(DICOMCTPDfile)); % uncorrected projection
projection = projectionUncorr * double(header.RescaleSlope) + double(header.RescaleIntercept);% projection representing line integral of linear attenuation coefficients, double-precision














end