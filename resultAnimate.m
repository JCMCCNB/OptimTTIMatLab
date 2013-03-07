P1ind = VideoMetadata.P1.ind;
P2ind = VideoMetadata.P2.ind;

video = VideoWriter([num2str(P1ind(1)), '-', num2str(P2ind(1)), '.avi']);
video.FrameRate = 10;
open(video);


hresult = figure('Position', [0, 0, 2000, 1000]);

subplot(1, 2, 1)
title('Without the Algorithm (Historic)');
plot(Profiles.P1.RT90y, Profiles.P1.RT90x, Profiles.P2.RT90y, Profiles.P2.RT90x);
hold on;

subplot(1, 2, 2)
title('Following the Algorithm');
plot(Profiles.P1.RT90y, Profiles.P1.RT90x, Profiles.P2.RT90y, Profiles.P2.RT90x);
hold on;



for i=1:length(P1ind)
    subplot(1, 2, 1)
    
    plot(Profiles.P1.RT90y(P1ind(i)), Profiles.P1.RT90x(P1ind(i)), 'x', Profiles.P2.RT90y(P2ind(i)), Profiles.P2.RT90x(P2ind(i)), 'x');
    drawnow;
    
    subplot(1, 2, 2)
    
    plot(Profiles.P1.RT90y(P1ind(i)), Profiles.P1.RT90x(P1ind(i)), 'x', AlgoProfiles.P2.RT90y(i), AlgoProfiles.P2.RT90x(i), 'rx');    
    drawnow;
    
    writeVideo(video, getframe(hresult));
end


close(video);