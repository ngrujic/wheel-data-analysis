v = VideoReader('222-07202020143735-0000.avi')
a=0;
while hasFrame(v)
    a = a+1 
    frame = readFrame(v);
croppedVid(a) = mean(max(frame(240:280,40:80,1)));
imshow(frame)
end