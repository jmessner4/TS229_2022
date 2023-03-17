clear;
close all;
clc;

load('data/adsb_msgs.mat');
len = length(adsb_msgs(1,:));
strures = [];

for i=1:len
    res = bit2registre(adsb_msgs(:,i));
    strures = [strures res];
end