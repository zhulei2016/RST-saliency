function [descPara, opts] = makeDefaultParameters()

%%%%%%%%%%%%%%%%%%FCN setup%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('./toolboxes/piotr_toolbox'));   % download from http://vision.ucsd.edu/~pdollar/toolbox/doc/
 p = './toolboxes/vlfeat-0.9.20/toolbox/vl_setup.m';
run(p);

addpath('./refinenet/main');    
addpath('./refinenet/main/my_utils');
dir_matConvNet='./toolboxes/matconvnet/matlab';
run(fullfile(dir_matConvNet, 'vl_setupnn.m'));
descPara.cnnOpt.modelPath = './data/models_cnn/refinenet/THUS-101-ep160-ep100';

descPara.cnnOpt.gpus = 1;
descPara.cnnOpt.alignment = 0;
descPara.cnnOpt.propagation = 0;
descPara.cnnOpt.mask = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% path setting
addpath(genpath('./featureExtr'));
% load dollaredge model for edeg detection
load('./data/edgeRFModel.mat'); descPara.edgeModel = model; clear model;

addpath(genpath('./SelectiveSearch'));
addpath(genpath('./segmentation'))
addpath(genpath('./struct forest'))
addpath(genpath('./saliency propagation'))

descPara.testinVocformat = 0;

Fdog = load('FbDoG.mat'); Fgabor = load('FbGabor.mat');
descPara.Fdog = Fdog.FB; descPara.Fgabor = Fgabor.FB;

opts.modelDir='./data/models_forest/';   % model will be in models/forest

%% parameters setting
%--------feat extraction settings--------------------
descPara.minImsize = 300;           % min image size
descPara.patchSize = 17;            % window size of the struct label (must be devideble by 4)
descPara.nstride_test = 6;          % ssp stride
descPara.surroundingWidth = 0.5;    % size of the surrounding area
descPara.shrink = [1, 0.75, 0.5];   % times for resizing image, for test
descPara.bw = 15;                   % boundary width of each image
descPara.split = 20000;             % for memory efficiency, >20000 may cause mex file faliture

%--------ssp ranking settings-------------
descPara.ssprank.alpha = 0.6;       % ratio of ranking loss
descPara.ssprank.k = 0.6;       	% scaler of variance of tree weight
descPara.ssprank.thres = 0.05;      % threshold for remove noise in mask
descPara.ssprank.isnorm = false;     % we do not normalize two losses

%--------saliency propagation settings----
descPara.salprop.spNum = 500;       % slic params in saliency propagation
descPara.salprop.beta = 0.8;        % ratio of two graph weight
descPara.salprop.gamma = 1;         % weight for Quadratic energymodels
descPara.salprop.sigma = 10;        % covariance scaler of similarity matrix

end
