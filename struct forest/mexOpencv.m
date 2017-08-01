OCVRoot = 'D:\OpenCV2p49\opencv\build';
IPath = ['-I',fullfile(OCVRoot,'include')];
LPath = fullfile(OCVRoot, 'x64','vc12','lib');

% lib1 = fullfile(LPath,'cv210d.lib');
lib2 = fullfile(LPath,'opencv_core249d.lib');
lib3 = fullfile(LPath,'opencv_highgui249d.lib');

mex('edgesDetectMex.cpp', IPath, lib2, lib3, '-g'); 