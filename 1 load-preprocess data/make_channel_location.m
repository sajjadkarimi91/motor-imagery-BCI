close all
clc

%% BCI EEG channels location for future plots

chanlocs(1).X = 0;
chanlocs(1).Y = 2;
chanlocs(1).Z = 0;


chanlocs(2).X = -2;
chanlocs(2).Y = 1;
chanlocs(2).Z = 0;

chanlocs(3).X = -1;
chanlocs(3).Y = 1;
chanlocs(3).Z = 0;

chanlocs(4).X = 0;
chanlocs(4).Y = 1;
chanlocs(4).Z = 0;

chanlocs(5).X = 1;
chanlocs(5).Y = 1;
chanlocs(5).Z = 0;

chanlocs(6).X = 2;
chanlocs(6).Y = 1;
chanlocs(6).Z = 0;

chanlocs(7).X = -3;
chanlocs(7).Y = 0;
chanlocs(7).Z = 0;

chanlocs(8).X = -2;
chanlocs(8).Y = 0;
chanlocs(8).Z = 0;

chanlocs(9).X = -1;
chanlocs(9).Y = 0;
chanlocs(9).Z = 0;

chanlocs(10).X = 0.01;
chanlocs(10).Y = 0.01;
chanlocs(10).Z = 0;

chanlocs(11).X = 1;
chanlocs(11).Y = 0;
chanlocs(11).Z = 0;

chanlocs(12).X = 2;
chanlocs(12).Y = 0;
chanlocs(12).Z = 0;

chanlocs(13).X = 3;
chanlocs(13).Y = 0;
chanlocs(13).Z = 0;

chanlocs(14).X = -2;
chanlocs(14).Y = -1;
chanlocs(14).Z = 0;

chanlocs(15).X = -1;
chanlocs(15).Y = -1;
chanlocs(15).Z = 0;

chanlocs(16).X = 0;
chanlocs(16).Y = -1;
chanlocs(16).Z = 0;

chanlocs(17).X = 1;
chanlocs(17).Y = -1;
chanlocs(17).Z = 0;

chanlocs(18).X = 2;
chanlocs(18).Y = -1;
chanlocs(18).Z = 0;

chanlocs(19).X = -1;
chanlocs(19).Y = -2;
chanlocs(19).Z = 0;

chanlocs(20).X = 0;
chanlocs(20).Y = -2;
chanlocs(20).Z = 0;

chanlocs(21).X = 1;
chanlocs(21).Y = -2;
chanlocs(21).Z = 0;

chanlocs(22).X = 0;
chanlocs(22).Y = -3;
chanlocs(22).Z = 0;

xyz = 0.001+[[2;1;1;1;1;1;0;0;0;0.01;0;0;0;-1;-1;-1;-1;-1;-2;-2;-2;-3],-[0;-2;-1;0;1;2;-3;-2;-1;0.01;1;2;3;-2;-1;0;1;2;-1;0;1;0],[0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0]];
xyz = xyz / 8;
[th, r,x, y, z] = cart2topo(xyz);

r = sqrt(sum(xyz.^2,2));

for i = 1:22
    chanlocs(i).X=xyz(i,1)*10;
    chanlocs(i).Y=xyz(i,2)*10;
    chanlocs(i).theta = th(i);
    chanlocs(i).radius = r(i);
    chanlocs(i).labels = ['E',num2str(i)];
end
rng(2)
datavector = rand(22,1);
datavector = datavector;
datavector(1)=0.5;
% datavector(1)=0.5;
topoplot(datavector, chanlocs);

try
    save([save_dir,'\chanlocs.mat'], 'chanlocs')
catch
    save('chanlocs.mat', 'chanlocs')
end

