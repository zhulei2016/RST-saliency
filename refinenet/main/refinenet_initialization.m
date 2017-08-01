
function [run_config, runner_info] = refinenet_initialization(refinenetOpt)
warning('off', 'MATLAB:namelengthmaxexceeded');

rng('shuffle');
run_config=[];

if refinenetOpt.gpus, run_config.use_gpu=true; 
else run_config.use_gpu=false; 
end

% run_config.use_gpu=false;
run_config.gpu_idx=refinenetOpt.gpus;

run_config.trained_model_path=refinenetOpt.modelPath;
run_config.class_info=gen_class_info_sal();

% for trained model, control the size of input images
run_config.input_img_short_edge_min=450;
run_config.input_img_short_edge_max=1100;

% use softmax output
runner_info=prepare_runner_test_simple(run_config);

warning('on', 'MATLAB:namelengthmaxexceeded');
end


