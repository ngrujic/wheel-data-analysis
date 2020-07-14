
clear all; close all

M = readmatrix('123-03232020165650-0000DLC_resnet50_All_Eyez_On_MeMar23shuffle1_1030000');

% eyes x and y positions

for eyes = 0:7
    
    eyesX(:,1+eyes) = M(:,2+eyes*3);
    eyesY(:,1+eyes) = M(:,3+eyes*3);
    
end

%stim on digital
stimOn = double(M(:,31) >0.5);

% lick digital
licks = double(M(:,28) >0.5);


%% EYE centre
eyeCentre(:,1) = mean(eyesX,2);
eyeCentre(:,2) = mean(eyesY,2);

zEyeCentre(:,1) = zscore(mean(eyesX,2));
zEyeCentre(:,2) = zscore(mean(eyesY,2));

%% PUPIL size

for eyes = 1:8
    
    
    % pythagoras for each position with each other position
    
    eyePointDistances(:,eyes) = sqrt((abs(eyeCentre(:,1) - eyesX(:,eyes))).^2 ...
            +(abs(eyeCentre(:,2) - eyesY(:,eyes))).^2);
 
    
end

pupilSize = smooth(zscore(mean(eyePointDistances,2)));

%% make video from above
figure(1)
keyboard
startFrame = 21600;
lengthVid = 60*60*2;
counter = 0;

for i = startFrame:startFrame + lengthVid
     counter = counter+1;
    n = i-120:i;
    
    subplot(7,1,1)
    plot(zEyeCentre(n,1),'LineWidth',2)
    ylim([-2.5,2.5])
    xlim([1 150])
    title('Eye position X')
    set(gca,'xtick',[0:30:150])
    set(gca,'xticklabel',[-2:0.5:0.5])
    
    subplot(7,1,2)
    plot(zEyeCentre(n,2),'LineWidth',2)
    ylim([-3,3])
    xlim([1 150])
    title('Eye position Y')
    set(gca,'xtick',[0:30:150])
    set(gca,'xticklabel',[-2:0.5:0.5])
    
    subplot(7,1,3)
    plot(pupilSize(n,1),'LineWidth',2)
    ylim([-1,1])
    xlim([1 150])
    title('Pupil Size')
    set(gca,'xtick',[0:30:150])
    set(gca,'xticklabel',[-2:0.5:0.5])
    
    subplot(7,1,4)
    plot(licks(n,1),'LineWidth',2)
    ylim([-0.5,1.5])
    xlim([1 150])
    title('Lick')
    set(gca,'xtick',[0:30:150])
    set(gca,'xticklabel',[-2:0.5:0.5])
    
    subplot(7,1,5)
    plot(stimOn(n,1),'LineWidth',2)
    if stimOn(i) == 1
        txt = 'ON';
    elseif stimOn(i) == 0
        txt = 'OFF';
    end
    text(125,1,txt,'FontSize',20)
    title('Stim ON')
    ylim([-0.5,1.5])
    xlim([1 150])
    set(gca,'xtick',[0:30:150])
    set(gca,'xticklabel',[-2:0.5:0.5])
    xlabel('Seconds')
    
    subplot(7,1,6:7)
    scatter(eyeCentre(i,1),eyeCentre(i,2));
    hold on
    scatter(eyesX(i,:),eyesY(i,:));
     line([eyesX(i,:),eyesX(i,1)],[eyesY(i,:),eyesY(i,1)]);
        xlim([65 85]);
    ylim([135 160]);
        title('Pupil representation')

    hold off
    
    
    F(counter) = getframe(gcf) ;
    drawnow
%     keyboard
end

% create the video writer with 1 fps
writerObj = VideoWriter('123test.avi');
writerObj.FrameRate = 60;
% set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);






