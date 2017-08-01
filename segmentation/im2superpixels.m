function imsegs = im2superpixels(im, method, varargin )
    if nargin < 3
        % default parameters to generate superpixels
        switch method
            case 'pedro'
                pedro_sigma = 0.8;
                pedro_k = 100;
                pedro_min_size = 150;
            case 'SLIC'
                slic_num_superpixel = 200;
                slic_regularizer = 15;
            otherwise
                error( 'unknown method to generate superpixels.' );
        end
    else
        para = varargin{1};
        switch method
            case 'pedro'
                pedro_sigma = para(1);
                pedro_k = para(2);
                pedro_min_size = para(3);
            case 'SLIC'
                slic_num_superpixel = para(1);
                slic_regularizer = para(2);
            otherwise
                error( 'unknown method to generate superpixels.' );
        end
    end

    if isa(im, 'uint8')
        im = double(im);
    end
    
%     if max(im(:)) < 10
%         im = double(im * 255);
%     end
    
    switch method
        case 'pedro'
            segim = mexSegment(im, ...
                pedro_sigma, pedro_k, int32(pedro_min_size));
        case 'SLIC'
            [segim, ~, ~] = mexSLIC(im,...
                slic_num_superpixel,slic_regularizer); 
        otherwise
            error( 'unknown method to generate superpixels.' );
    end
    imsegs = processSuperpixelImage(segim, 1);
