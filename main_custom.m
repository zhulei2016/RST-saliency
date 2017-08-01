clc;clear variables; close all;

%% parameter parsing
[descPara, ~] = makeDefaultParameters;

if descPara.testinVocformat
    path_dataset = fullfile(descPara.folderPath_trainSet, 'JPEGImages');
    testFiles = fullfile(descPara.folderPath_trainSet, 'ImageSets', 'Main', 'saliency_test.txt');
    fid = fopen(testFiles); C = textscan(fid, '%s %d'); flist = C{1}; fclose(fid);
    nImgNum = length(flist);
    pathImgs = cell(nImgNum, 1); filesforTest = cell(nImgNum, 1);
    for ii = 1 : nImgNum
        filesforTest{ii} = [flist{ii}, '.jpg'];
        pathImgs{ii} = fullfile(path_dataset, filesforTest{ii});
    end
else
    path_dataset = './test_samples/';
    flist = dir(fullfile([path_dataset, '*.jpg'])); nImgNum = length(flist);
    pathImgs = cell(nImgNum, 1); filesforTest = cell(nImgNum, 1);
    for ii = 1 : length(flist)
        filesforTest{ii} = flist(ii).name;
        pathImgs{ii} = fullfile(path_dataset, filesforTest{ii});
    end
end

saldir='./test_samples_result/';   % the output path of the saliency map
if ~isdir(saldir), mkdir(saldir); end

%% for each testing image...
modelFile = './data/models_forest/forest/modelMix.mat';
disp('loading forest and CNN models, they take a while.');
load(modelFile);
[net.run_config, net.runner_info] = refinenet_initialization(descPara.cnnOpt);

for ii = 1 : nImgNum
    fprintf('processing %d th of %d images \n', ii, nImgNum);
    imgName = filesforTest{ii}; imgName = imgName(1 : end - 4);

    sal_opt = saliencyDetection(pathImgs{ii}, model, net, descPara);
    outname=[saldir, imgName, '.png']; imwrite(sal_opt,outname);
end





