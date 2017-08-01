
#include <mex.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
//#include <D:\OpenCV2p49\opencv\build\include\opencv2\opencv.hpp>
#ifdef USEOMP
#include <omp.h>
#endif

typedef unsigned int uint32;
typedef unsigned short uint16;
typedef unsigned char uint8;
template<typename T> inline T min(T x, T y) { return x < y ? x : y; }


void mexFunction(int nl, mxArray *pl[], int nr, const mxArray *pr[])
{
	// get inputs
	mxArray *model = (mxArray*)pr[0];			// point to model
	double *feat = (double*)mxGetData(pr[1]);		// point to feature 
	const mwSize *featSize = mxGetDimensions(pr[1]);
	const int samplNum = (int)featSize[0];		// number of samples
	const int featDims = (int)featSize[1];		// dimension of feature

	uint32 *grid = (uint32*)mxGetData(pr[2]);

	mxArray *para = (mxArray*)pr[3];
	const int h = (int)mxGetScalar(mxGetField(para, 0, "imh"));
	const int w = (int)mxGetScalar(mxGetField(para, 0, "imw"));

	// extract relevant fields from model and options
	float *thrs = (float*)mxGetData(mxGetField(model, 0, "thrs"));			//	threshold corresponding to each fid (see below)
	uint32 *fids = (uint32*)mxGetData(mxGetField(model, 0, "fids"));		//	feature ids for each node
	uint32 *child = (uint32*)mxGetData(mxGetField(model, 0, "child"));		//	index of child for each node
	uint8 *segs = (uint8*)mxGetData(mxGetField(pr[0], 0, "segs"));			//	representative segment that is stored in each leaf
	uint8 *nSegs = (uint8*)mxGetData(mxGetField(pr[0], 0, "nSegs"));		//	number of parts in each segment (0,1 in our case, may be more patterns in edge detection)
	mxArray *opts = mxGetField(model, 0, "opts");							//	forest parameters and settings 
	const int gtWidth = (int)mxGetScalar(mxGetField(opts, 0, "gtWidth"));	// size of struct window
	const int nTreesEval = (int)mxGetScalar(mxGetField(opts, 0, "nTreesEval"));	//	number of trees used for evaluation
	int nThreads = (int)mxGetScalar(mxGetField(opts, 0, "nThreads"));		// number of thread for computing
	// get dimensions and constants
	const mwSize *fidsSize = mxGetDimensions(mxGetField(model, 0, "fids"));
	const int nTreeNodes = (int)fidsSize[0];		//	max number of nodes in all trees
	const int nTrees = (int)fidsSize[1];			//	number of trees 
	const int indDims[2] = { samplNum, nTreesEval };	// size macro for the leaf node of each sample (in every tree)
	const int imgDims[2] = { h, w};					// size macro for the image/saliency map
	const int segSize = gtWidth * gtWidth;
	const int segDims[3] = { segSize, samplNum, nTreesEval };	// size macro for the structure prediction for each sample

	// create outputs
	pl[0] = mxCreateNumericArray(2, indDims, mxUINT32_CLASS, mxREAL);
	uint32 *ind = (uint32*)mxGetData(pl[0]);
	pl[1] = mxCreateNumericArray(3, segDims, mxUINT8_CLASS, mxREAL);
	uint8 *segsOut;	segsOut = (uint8*)mxGetData(pl[1]);

	pl[2] = mxCreateNumericArray(2, imgDims, mxUINT32_CLASS, mxREAL);
	uint32 *salmap = (uint32*)mxGetData(pl[2]);
	pl[3] = mxCreateNumericArray(2, imgDims, mxUINT32_CLASS, mxREAL);
	uint32 *hitTime = (uint32*)mxGetData(pl[3]);
	

	//// test for column/row major
	//double ftr1 = feat[0 * samplNum + 3];
	//double ftr2 = feat[1 * samplNum + 4];
	//double ftr3 = feat[3 * samplNum + 5];
	//double ftr4 = feat[4 * samplNum + 6];
	//ind[3 + 0 * samplNum] = 1;
	//ind[4 + 1 * samplNum] = 2;
	//ind[5 + 2 * samplNum] = 3;
	//ind[6 + 3 * samplNum] = 4;


#ifdef USEOMP
	nThreads = min(nThreads, omp_get_max_threads());
#pragma omp parallel for num_threads(nThreads)
#endif
	// apply forest to all patches and store leaf inds
	for (int i = 0; i < samplNum; ++i){	// simply use all trees for predicting each data sample
		for (int t = 0; t < nTreesEval; ++t){
			uint32 k = t * nTreeNodes;	// point to the data of target tree
			while (child[k]){
				uint32 f = fids[k];	//	point to the selected dimension
				double ftr = feat[f * samplNum + i];	// get selected feature of current sample
				// compare ftr to threshold and move left or right accordingly
				if (ftr < thrs[k])
					k = child[k] - 1;
				else
					k = child[k];
				k += t*nTreeNodes;
			}
			// store leaf index
			ind[i + t*samplNum] = k;
		}
	}

	#ifdef USEOMP
	#pragma omp parallel for num_threads(nThreads)
	#endif
	for (int s = 0; s < samplNum; ++s){
		for (int t = 0; t < nTreesEval; ++t){
			uint32 k = ind[s + t*samplNum];
			memcpy(segsOut + (s + t*samplNum)*segSize,
				segs + k*segSize, segSize*sizeof(uint8));

			if (nl > 2){
				uint32 kg = k*segSize;
				for (int x = 0; x < gtWidth; ++x){
					for (int y = 0; y < gtWidth; ++y){
						int c1 = grid[s] + x;
						int r1 = grid[samplNum + s] + y;
						salmap[c1*h + r1] += segs[kg + x*gtWidth + y];
						hitTime[c1*h + r1]++;
					}
				}
			}
		}
	}
}
