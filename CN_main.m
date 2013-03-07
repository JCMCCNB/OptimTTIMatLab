% function CN_main

%% Description
% Project: DCBIN
% Function: This function determines the optimal speed for the 2nd vehicle
% (P2) for the next step.
%
% Parameters:
% - Profiles : The historic profiles data for the given road
% - Margin : All the limitations in term of kinematics, temporal, etc.
%
% Author(s):
% - Christian-Nils Boda : christian-nils.boda@gadz.org
%
% Date of creation: 2013-03-04
%
% Changelog:
% - 2013-03-05: implement the random test for the algorithm
% - 2013-03-06: 
%         display the result in a video
%         write a video each run
%         use all profiles

clearvars -except oDBdataSet;
close all;

% Add the profiles folder
addpath('./AllProfiles');

if ~exist('oDBdataSet', 'var')
    load('oDBdataSetTrajsForThesisSim.mat');
end

clearvars -global
% declare the global variables
global Profiles Margin AlgoProfiles VideoMetadata;


vRand(1) = randi(length(oDBdataSet.oGoingStraight), 1);
vRand(2) = randi(length(oDBdataSet.oTurningLeft), 1);
    
Profiles.P2.RT90x = oDBdataSet.oGoingStraight(vRand(1)).oDBdata.voMeasureData.mRT90x_fused;
Profiles.P2.RT90y = oDBdataSet.oGoingStraight(vRand(1)).oDBdata.voMeasureData.mRT90y_fused;
Profiles.P2.Vel = oDBdataSet.oGoingStraight(vRand(1)).oDBdata.voMeasureData.mVehicleSpeed;
Profiles.P2.DTI = oDBdataSet.oGoingStraight(vRand(1)).oDBdata.voMeasureData.fDCBIN_DistTraveledZeroIntersectCenter;
Profiles.P2.TTI = round(oDBdataSet.oGoingStraight(vRand(1)).oDBdata.voMeasureData.fDCBIN_TimeInSecZeroAtIntersectCenter*10)/10;

Profiles.P1.RT90x = oDBdataSet.oTurningLeft(vRand(2)).oDBdata.voMeasureData.mRT90x_fused;
Profiles.P1.RT90y = oDBdataSet.oTurningLeft(vRand(2)).oDBdata.voMeasureData.mRT90y_fused;
Profiles.P1.Vel = oDBdataSet.oTurningLeft(vRand(2)).oDBdata.voMeasureData.mVehicleSpeed;
Profiles.P1.DTI = oDBdataSet.oTurningLeft(vRand(2)).oDBdata.voMeasureData.fDCBIN_DistTraveledZeroIntersectCenter;
Profiles.P1.TTI = round(oDBdataSet.oTurningLeft(vRand(2)).oDBdata.voMeasureData.fDCBIN_TimeInSecZeroAtIntersectCenter*10)/10;

clearvars i files oDBdata;

%% Define the margins

Margin.acc = 1; % 1m/s²
Margin.TTI = 1; % 1sec of TTI diff
Margin.Vel = 70/3.6; % Speed limit in m/s

%% Draw the paths
% figure(1)
% plot(Profiles.P1.RT90y, Profiles.P1.RT90x, Profiles.P2.RT90y, Profiles.P2.RT90x);
% hold on;
%% here give the P1 and P2, i.e. RT90x, RT90y and velocity for the current
% position for each vehicle.
AlgoProfiles.P1 = Profiles.P1;

% Initialization of the test
P1ind = randi([find(~isnan(Profiles.P1.RT90x(Profiles.P1.DTI<=0)), 1 ), find(~isnan(Profiles.P1.RT90x(Profiles.P1.DTI<=0)), 1, 'last' )], 1);
P2ind = randi([find(~isnan(Profiles.P2.RT90x(Profiles.P2.DTI<=0)), 1 ), find(~isnan(Profiles.P2.RT90x(Profiles.P2.DTI<=0)), 1, 'last' )], 1);

VideoMetadata.P1.ind = P1ind;
VideoMetadata.P2.ind = P2ind;
% P1ind = 8019;
% P2ind = 4154;

P1.RT90x = Profiles.P1.RT90x(P1ind);
P1.RT90y = Profiles.P1.RT90y(P1ind);

P2.RT90x = Profiles.P2.RT90x(P2ind);
P2.RT90y = Profiles.P2.RT90y(P2ind);
P2.Vel = Profiles.P2.Vel(P2ind)/3.6; % in m/s

[newP1, newP2] = algo(P1, P2, 10);

disp(['Init : ',num2str(newP1.TTI - newP2.TTI), ' TTI delay']);
disp(['Init : ',num2str(newP1.DTI + newP2.DTI), ' DTI distance between both vehicles']);

AlgoProfiles.P2 = newP2;
t = 0;
while P1ind+1<=length(Profiles.P1.RT90x) && P2ind+1<=length(Profiles.P2.RT90x) && newP2.DTI<0 && newP1.DTI<0
t = t + 1;
P1ind = P1ind + 1;
P2ind = P2ind + 1;

P1.RT90x = Profiles.P1.RT90x(P1ind);
P1.RT90y = Profiles.P1.RT90y(P1ind);
    
P2.DTI = newP2.DTIns;

if isnan(P1.RT90x)
    break;
end

P2.Vel = newP2.Velns;
P2.ind = P2ind;
%     plot(AlgoProfiles.P2.RT90y(end), AlgoProfiles.P2.RT90x(end), 'rx');
%     plot(Profiles.P1.RT90y(P1.ind), Profiles.P1.RT90x(P1.ind), 'bx');
%     drawnow
%     pause(1);
[newP1, newP2] = algo(P1, P2, 10);

clearvars P1 P2;

% store the 'optimal' profile
AlgoProfiles.P2.Vel(end+1) = newP2.Velns; 
AlgoProfiles.P2.DTI(end+1) = newP2.DTIns;
AlgoProfiles.P2.RT90x(end+1) = newP2.RT90x;
AlgoProfiles.P2.RT90y(end+1) = newP2.RT90y;
AlgoProfiles.P2.TTI(end+1) = AlgoProfiles.P2.TTI(end) + 0.1;

%Store the metadata for the video
VideoMetadata.P1.ind(end+1) = P1ind;
VideoMetadata.P2.ind(end+1) = P2ind;
end

if P1ind+1>length(Profiles.P1.RT90x)
    flag = 'No more positioning data for the subject vehicle';
elseif P2ind+1>length(Profiles.P2.RT90x)
    flag = 'No more positioning data for the experimental vehicle';
elseif newP2.DTI>=0
    flag = 'The experimental vehicle reached the intersection.';
elseif newP1.DTI>=0
    flag = 'The subject vehicle reached the intersection.';
end

disp(['Result : ',num2str(newP1.TTI - newP2.TTI), ' TTI delay']);
disp(['Result : ',num2str(newP1.DTI + newP2.DTI), ' DTI distance between both vehicles']);

disp(flag);

if abs(newP1.TTI - newP2.TTI)<=Margin.TTI
    disp('You Win! GG!');
else
    disp('You Lose! Try Again!');
end

% resultAnimate();

figure
plot(AlgoProfiles.P2.TTI, AlgoProfiles.P2.DTI,Profiles.P2.TTI, Profiles.P2.DTI, 'g')
legend('DTI Rectified', 'Profile DTI');
ylabel('DTI [m]');
xlabel('TTI [s]');

figure
plot(AlgoProfiles.P2.TTI, AlgoProfiles.P2.Vel * 3.6,Profiles.P2.TTI, Profiles.P2.Vel,'g')
legend('Velocity Rectified', 'Profile Velocity');
ylabel('Velocity [m/s]');
xlabel('TTI [s]');
