function boundary_index = pbgnessSeed( input_im, spnum, superpixels, pb_im)
%% background seeds
% L = imlab(:,:,1);
% A = imlab(:,:,2);
% B = imlab(:,:,3);


[row,col,~] = size(input_im);
row_thes = 0.1*row;
col_thes = 0.1*col;
pos_mat=zeros(spnum,2);
% color_mat=zeros(spnum,3);
pb_weight = zeros(spnum, 1);
STA=regionprops(superpixels,'PixelList','Centroid','Area');
[sx,sy]=vl_grad(double(superpixels), 'type', 'forward') ; s = sx | sy;
for j = 1:spnum
    mask = superpixels == j; 
    %     boundary = edge(mask).*pb_im; %edge(I) matlab函数，求图像中的边edge(mask)得到当前超像素块的轮廓，edge(mask).*pb_im则为pb_im在此超像素边缘上存在的图像边缘像素数
    %     idx = find(edge(mask) == 1);%得到当前超像素块的边缘有多少像素
    %     weight = sum(sum(boundary))/length(idx);
    sj = s & mask; boundary = sj .* pb_im;
    weight = sum(sum(boundary))/sum(sum(sj));
    %用超像素包含图像边缘的像素数占整个超像素边缘数的比例作为权重，超像素边缘包含的图像边缘的比例越大，权重越大
    pb_weight(j) = weight;
    %     pixelind = STA(j).PixelIdxList;%将图像全部排成一列，然后存储此超像素包含的像素序号
    indxy = STA(j).PixelList; %当前超像素包含的所有像素的 [列号,行号]
    pos_mat(j,:) = [mean(indxy(:,1)),mean(indxy(:,2))];
    %当前超像素的重心值 ，这个和运用STATS(j).Centroid的结果是一样的
    %位置坐标是以左上角为原点，横向为X轴，纵向为Y轴的位置值
    %     color_mat(j,:) = [mean(L(pixelind)),mean(A(pixelind)),mean(B(pixelind))];%超像素平均颜色
end
thresh = graythresh(pb_weight);% graythresh 是在计算所有超像素权重之后，运用 Otsu 方法来得到一个归一化的阈值
boundary_index = zeros(spnum, 1); ind = 1; %存储背景种子超像素
% background_seeds_map=zeros(row,col,3);
% guided_input = ones(row,col);%要照背景种子超像素，首先设整幅图都是前景图，所以值都为1
for j = 1: spnum
    center = STA(j).Centroid;
    if (center(2)<row_thes||center(2)>(row-row_thes)||center(1)<col_thes||center(1)>(col-col_thes))
        %背景种子超像素首先要满足超像素重心在border的宽度范围内，满足此条件再看下一个条件是否满足
        if pb_weight(j)<thresh
            %如果权重小于计算的阈值，则认为它是背景种子超像素
            boundary_index(ind) = j; ind = ind + 1;
            %             pixelind = STA(j).PixelIdxList;
            %             guided_input(pixelind) = 0;%将这些背景种子超像素的所有像素位置的值设为0
        end
    end
end
boundary_index(ind : end) = [];

% R = input_im(:,:,1);
% G = input_im(:,:,2);
% B1 = input_im(:,:,3);
% background_seeds_map(:,:,1)=R.*guided_input;
% background_seeds_map(:,:,2)=G.*guided_input;
% background_seeds_map(:,:,3)=B1.*guided_input;
% imwrite(background_seeds_map,[background_seeds_map_path,imName(1:end-4),'.jpg']);

end

