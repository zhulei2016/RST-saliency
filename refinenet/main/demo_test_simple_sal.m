
% Author: Guosheng Lin (guosheng.lin@gmail.com)

% this is a simpler demo file for testing on your own images.

function demo_test_simple_sal()

rng('shuffle');
addpath('./my_utils');
dir_matConvNet='../libs/matconvnet/matlab';
run(fullfile(dir_matConvNet, 'vl_setupnn.m'));


run_config=[];

run_config.use_gpu=true;
% run_config.use_gpu=false;
run_config.gpu_idx=1;


% result dir:
% result_name=['runner_result_dir' datestr(now, 'YYYYmmDDHHMMSS')];
result_name='runner_result_dir';

result_dir=fullfile('../cache_data', 'test_examples_sal', result_name);
mkdir_notexist(result_dir);


% the folder that contains testing images:
img_data_root = '/home/lab/lei/sal_trainval';
img_data_dir=fullfile(img_data_root, 'JPEGImages');
img_data_text = fullfile(img_data_root, 'ImageSets', 'Main', 'saliency_test.txt');
fid = fopen(img_data_text); C = textscan(fid, '%s %s'); imgName = C{1};


% using a trained model which is trained on VOC 2012
% run_config.trained_model_path='../model_trained/refinenet_res101_voc2012.mat';
run_config.trained_model_path='../cache_data/sal_trainval/model_20170122_sal/model_cache/epoch_200';
% run_config.class_info=gen_class_info_voc();
run_config.class_info=gen_class_info_sal();

% for trained model, control the size of input images
run_config.input_img_short_edge_min=450;
run_config.input_img_short_edge_max=1100;

runner_info=prepare_runner_test_simple(run_config);

% img_filenames=my_list_file(img_data_dir);
img_num=length(imgName);
for img_idx=1:img_num
    task_info=[];
    task_info.img_dir=img_data_dir;
    task_info.img_filename=[imgName{img_idx}, '.jpg'];
    task_result=runner_info.run_task_fn(runner_info, task_info);
    
    [~, img_name]=fileparts(task_info.img_filename);
    one_cache_file=fullfile(result_dir, [img_name '.png']);
    fprintf('save predict mask:%s\n', one_cache_file);
    imwrite(task_result.mask_data, run_config.class_info.mask_cmap, one_cache_file);
end


end


