figure(1)
colors = hsv(length(oDBdataSet.oGoingStraight));

for i=1:length(oDBdataSet.oGoingStraight)
    plot(oDBdataSet.oGoingStraight(i).oDBdata.voMeasureData.fDCBIN_TimeInSecZeroAtIntersectCenter, -oDBdataSet.oGoingStraight(i).oDBdata.voMeasureData.fDCBIN_DistTraveledZeroIntersectCenter, 'Color', colors(i,:));
    hold on;
    
end
xlabel('TTI [s]');
ylabel('DTI [m]');
title('Turning Vehicle');
axis([-100 0 0 1000]);