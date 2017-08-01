function maskdata = refinenetPredict(net, I)
imwrite(I, 'temp.png');
task_info=[];
    task_info.img_dir='./';
    task_info.img_filename='temp.png';
    task_result=net.runner_info.run_task_fn(net.runner_info, task_info);
    maskdata = task_result.mask_data;
end


