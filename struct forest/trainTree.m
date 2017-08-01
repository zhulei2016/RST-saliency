function trainTree( opts, stream, ftrs, labels, treeInd )
% Train a single tree in forest model.

% finalize setup
treeDir = [opts.modelDir '/tree/'];
treeFn = [treeDir opts.modelFnm '_tree'];

% TODO: comment to prevant loading pre-compute tree
if(exist([treeFn int2str2(treeInd,3) '.mat'],'file'))
    fprintf('Reusing tree %d of %d\n',treeInd,opts.nTrees); return; end

fprintf('\n-------------------------------------------\n');
fprintf('Training tree %d of %d\n',treeInd,opts.nTrees); tStart=clock;
% set global stream to stream with given substream (will undo at end) 
streamOrig = RandStream.getGlobalStream();
set(stream,'Substream',treeInd);
RandStream.setGlobalStream( stream );

patchSize = size(labels{1}, 1);
% train structured edge classifier (random decision tree)
pTree=struct('minCount',opts.minCount, 'minChild',opts.minChild, ...
    'maxDepth',opts.maxDepth, 'H',opts.nClasses, 'split',opts.split);
pTree.discretize=@(hs,H) discretize(hs,H,patchSize * patchSize,opts.discretize);
nTotFtrs = size(ftrs, 2);   % randomly choose feature dimensions
fids=sort(randperm(nTotFtrs,round(nTotFtrs*opts.fracFtrs)));
ftrs = ftrs(:, fids);
tree=forestTrain(ftrs,labels,pTree); 
tree.hs=cell2array(tree.hs);
tree.fids(tree.child>0) = fids(tree.fids(tree.child>0)+1)-1;
if(~exist(treeDir,'dir')), mkdir(treeDir); end
save([treeFn int2str2(treeInd,3) '.mat'],'tree'); e=etime(clock,tStart);
fprintf('Training of tree %d complete (time=%.1fs).\n',treeInd,e);
RandStream.setGlobalStream( streamOrig );
end

%% mapping annotated segmenting labels to N class
function [hs,segs_rp] = discretize( segs, nClasses, nSamples, type )
% get selected samples of labels
patchSize = size(segs{1}, 1); 
labelNum = patchSize * patchSize;   
nSamples=min(nSamples, labelNum);   
kp=randperm(labelNum, nSamples);
n=length(segs); 
zs = false(n, nSamples);            
for i=1:n
    zs(i,:)=segs{i}(kp);
end
zs=bsxfun(@minus,zs,sum(zs,1)/n); 
% test if there is all-zero collumn
zs=zs(:,any(zs,1));    

if(isempty(zs))
    hs=ones(n,1,'uint32'); 
    segs_rp=segs{1}; 
    return; 
end
% find most representative segs (closest to mean)
[~,ind]=min(sum(zs.*zs,2)); 
% segs=segs{ind};
segs_rp = segs{ind};
% apply PCA to reduce dimensionality of zs
U=pca(zs'); 
d=min(5,size(U,2)); 
zs=zs*U(:,1:d);
% discretize zs by clustering or discretizing pca dimensions
d=min(d,floor(log2(nClasses))); 
hs=zeros(n,1);
for i=1:d
    hs=hs+(zs(:,i)<0)*2^(i-1); 
end

[~,~,hs]=unique(hs); 
hs=uint32(hs);
% an another option, use kmeans to get nClasses
if(strcmpi(type,'kmeans'))
    tic
    nClasses1=max(hs); 
    C=zs(1:nClasses1,:);
    for i=1:nClasses1
        C(i,:)=mean(zs(hs==i,:),1); 
    end
    hs=uint32(kmeans2(zs,nClasses,'C0',C,'nIter',1));
    toc
end
% optionally display different types of hs
for i=1:0
    figure(i); 
    montage2(cell2array(segs(hs==i))); 
    
    %     fp = ['E:\My saliency works\saliency work in progress\multi-view saliency grid\data\train_patch\', num2str(i - 1)];
    %     t = segs(hs==i);
    %     for j = 1 : length(t),
    %         imwrite(t{j} * 255, [fp, '\', num2str(j),'.png']);
    %     end
end
end
