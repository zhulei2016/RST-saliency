% ------------------------------------------------------------------------%
% compute the W2 distance between feature a and b
% code written by Lei Zhu, IPRAI, Huazhong Univ. Sci. & Tech.
% last modified time: 2013.07.11
% ------------------------------------------------------------------------%
function D = W2Dist2(fea_a, fea_b, bSqrt, rep_as_mtrx)
%% check parameters
if ~isfield(fea_a,'centrd')
    error('invalid feature format! centrd vector is needed');
end

if ~isfield(fea_a,'co_var')
    error('invalid feature format! covariance matrix is needed');
end

if ~isfield(fea_a,'tr_co_var')
    error('invalid feature format! trace of covariance matrix is needed');
end

if (exist('fea_b','var') && ~isempty(fea_b))
    if ~isfield(fea_b,'centrd')
        error('invalid feature format! centrd vector is needed');
    end
    
    if ~isfield(fea_b,'co_var')
        error('invalid feature format! covariance matrix is needed');
    end
    
    if ~isfield(fea_b,'tr_co_var')
        error('invalid feature format! trace of covariance matrix is needed');
    end
end

if ~exist('bSqrt','var')
    bSqrt = 1;
end

if ~exist('rep_as_mtrx','var')
    rep_as_mtrx = 1;
end

%% compute distance matrix
% self pair-wise distance computation
if (~exist('fea_b','var')) || isempty(fea_b)
    N = length(fea_a.centrd);
    edges = ...
        [reshape(repmat(1 : N, N, 1), N * N, 1), repmat((1 : N)', N, 1)];
%     edges(1 : N + 1 : end, :)=[];
    edges((edges(:, 2) - edges(:, 1)) <= 0, :) = [];
    
    % firstly, get the mean distance between distributions
    avg_d = sum((fea_a.centrd(edges(:,1), :) - fea_a.centrd(edges(:,2), :)).^2,2);
    % secondly, get the trace difference between distributions
    tr_d = fea_a.tr_co_var(edges(:,1)) + fea_a.tr_co_var(edges(:,2));
    % thirdly, get the co trace difference between distributions
    n = size(edges, 1);
    cotr_d = zeros(n, 1);
    for i = 1 : n,
        E = eig(fea_a.co_var{edges(i,1)} * fea_a.co_var{edges(i,2)});
        % eliminate coputational error
        E(E < 0) = 0;
        cotr_d(i) = sum(sqrt(E));
    end
    % eliminate coputational error
    D = avg_d + tr_d - 2 * cotr_d;
    D(D < 0) = 0;
    if bSqrt
        D = sqrt(D);
    end
    % reshape to symmetric matrix representation
    if rep_as_mtrx,
        W = zeros(N, N);
        ind = 1;
        for i = 1 : N,
            idx = edges(edges(:, 1) == i, 2);
            W(i, idx) = D(ind : ind + length(idx) - 1);
            ind = ind + length(idx);
        end
        D = W + W';
        clear W;
    end
    
    % cross pair-wise distance computation
else
    Na = length(fea_a.centrd);
    Nb = length(fea_b.centrd);
    edges = ...
        [reshape(repmat(1 : Na, Nb,1), Na * Nb,1),repmat((1 : Nb)', Na, 1)];
    % firstly, get the mean distance between distributions
    avg_d = sum((fea_a.centrd(edges(:,1), :) - fea_b.centrd(edges(:,2), :)).^2,2);
    % secondly, get the trace difference between distributions
    tr_d = fea_a.tr_co_var(edges(:,1)) + fea_b.tr_co_var(edges(:,2));
    % thirdly, get the co trace difference between distributions
    n = size(edges, 1);
    cotr_d = zeros(n, 1);
    for i = 1 : n,
        E = eig(fea_a.co_var{edges(i,1)} * fea_b.co_var{edges(i,2)});
        % eliminate coputational error
        E(E < 0) = 0;
        cotr_d(i) = sum(sqrt(E));
    end
    % eliminate coputational error
    D = avg_d + tr_d - 2 * cotr_d;
    D(D < 0) = 0;
    if bSqrt
        D = sqrt(D);
    end
    % reshape to symmetric matrix representation
    if rep_as_mtrx,
        W = zeros(Na, Nb);
        ind = 1;
        for i = 1 : Na,
            W(i, :) = D(ind : (ind + Nb - 1));
            ind = ind + Nb;
        end
        D = W;
        clear W;
    end
end

end