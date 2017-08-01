function renewed_img2 = SVF(grayim)
% Implementation of Singular value feature.
% Implemented by Dongyoon Han.
% If you find a bug, please contact calintz@kaist.ac.kr
% Reference : 
% [1] B.Su, S.Lu, and C.L.Tan, "Blurred image region detection and
% classification. In ACM International Conference on Multimedia, pages
% 1397-1400, 2011.

sal_map = zeros(size(grayim));

part_num = 30;
[img_sizeY, img_sizeX] = size(grayim);
cell_sizeY = floor(img_sizeY / part_num);
cell_sizeX = floor(img_sizeX / part_num);
for y = 1 : part_num+1
    k = 3;
    rey = (y-1) * cell_sizeY+1 : y * cell_sizeY;
    if (y == part_num+1) 
        rey = (y-1) * cell_sizeY+1 : img_sizeY;
        if (size(rey,2) == 0)
            continue;
        end
        if (size(rey,2) < k)
            k = (size(rey,2));
        end        
    end
    for x = 1 : part_num+1
        rex = (x-1) * cell_sizeX+1 : x * cell_sizeX;
        if (x == part_num+1) 
            rex = (x-1) * cell_sizeX+1 : img_sizeX;
            if (size(rex,2) == 0)
                continue;
            end
            if (size(rex,2) < k )
                k = (size(rex,2));
            end
        end
  
        part_img = grayim(rey, rex);
        [~, S, ~] = svd(single(part_img),'econ');
        DS = diag(S);
        B1 = sum(DS(1:k)) / (sum(DS) + eps);
        sal_map(rey, rex) = B1;       
    end
end

renewed_img2 = (sal_map - mean(sal_map(:)))/ std(sal_map(:));
