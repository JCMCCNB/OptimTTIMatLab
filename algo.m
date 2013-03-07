function [P1, P2] = algo(P1, P2, rate)

%% Description
% Project: DCBIN
% Function: This function determines the optimal speed for the 2nd vehicle
% (P2) for the next step.
%
% Parameters:
% - Profiles : The historic profiles data for the given road (should be
% defined by the distance against the time to intersection)
% - Margin : All the limitations in term of kinematics, temporal, etc.
% - rate : The working rate (optimally should match the GPS update rate)
%
% Variables:
% - P1 and P2 : The cars' kinematics data (position, velocity, ...)
%
% Author(s):
% - Christian-Nils Boda : christian-nils.boda@gadz.org
%
% Date of creation: 2013-03-04
%
% Changelog:
% - 2013-03-05 : Add the next expected RT90x and RT90y

%% Initialization
% Declare global Variables
global Profiles Margin

% Define the step (in second)
dt = 1/rate;

%% Get the time to intersection for each vehicle
% Get the distance to intersection (DTI) from the current position
P1.DTI = getDTI('P1', P1.RT90x, P1.RT90y);

if ~isfield(P2, 'DTI')
    P2.DTI = getDTI('P2', P2.RT90x, P2.RT90y);    
end

% Get the predicted time to intersection from the current position
P1.TTI = getTTI('P1', P1.DTI);
P2.TTI = getTTI('P2', P2.DTI);



% Compare both timings
% if the TTI are roughly identic then just return the next historic velocity 
% otherwise calculate the optimal velocity to adjust the P2.TTI at the next
% step
if abs(P1.TTI-P2.TTI) < Margin.TTI
    % use profile of P2 to determine the velocity to the next step (1/rate)
     P2.Velns = Profiles.P2.Vel(P2.ind)/3.6;
else
    % determine the DTI to the next step
    P2.DTIns = interp1(Profiles.P2.TTI, Profiles.P2.DTI, P1.TTI+dt);
    % check if the new distance is bigger than the current one, if so the
    % velocity is null
    
    % Compute the optimal velocity for the 2nd vehicle
    if (P2.DTIns - P2.DTI)<=0
        P2.Velns = 0;
    else
        P2.Velns = P2.Vel + (P2.DTIns - P2.DTI)/dt;
    end
    % check if the acceleration at the next step is too high
    
end

if abs(P2.Velns - P2.Vel)/dt < Margin.acc
    % return the speed previously calculated
else
    % otherwise limit the change of velocity
    P2.Velns = P2.Vel + sign(P2.Velns - P2.Vel)*Margin.acc*dt;
end
% check if the velocity is within the allowed speed
if P2.Velns>Margin.Vel
    P2.Velns = Margin.Vel;
elseif P2.Velns<0
    P2.Velns = 0;
end
    
P2.DTIns = P2.DTI + P2.Velns*dt;

[P2.RT90y, P2.RT90x] = getRT90('P2', P2.DTIns);

end