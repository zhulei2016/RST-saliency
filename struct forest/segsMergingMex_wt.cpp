
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

void mexFunction(int nl, mxArray *pl[], int nr, const mxArray *pr[])
{
	// get inputs
	uint8 *slabel_2d = (uint8*)mxGetData(pr[0]);
	const mwSize *lblSize = mxGetDimensions(pr[0]);
	const int sz_r = (int)lblSize[0];	
	const int sz_c = (int)lblSize[1];
	const int num_pix = (int)lblSize[2];
	const int num_tree = (int)lblSize[3];

	double *wt = (double*)mxGetData(pr[1]);

	uint32 *grid = (uint32*)mxGetData(pr[2]);

	mxArray *para = (mxArray*)pr[3];
	const int h = (int)mxGetScalar(mxGetField(para, 0, "imh"));
	const int w = (int)mxGetScalar(mxGetField(para, 0, "imw"));
	const int imgDims[2] = { h, w };									// size macro for the image/saliency map

	// create outputs
	pl[0] = mxCreateNumericArray(2, imgDims, mxDOUBLE_CLASS, mxREAL);
	double *salmap = (double*)mxGetData(pl[0]);
	pl[1] = mxCreateNumericArray(2, imgDims, mxUINT32_CLASS, mxREAL);
	uint32 *hitTime = (uint32*)mxGetData(pl[1]);

	//#ifdef USEOMP
	//#pragma omp parallel for num_threads(nThreads)
	//#endif
	for (int s = 0; s < num_pix; ++s){
		for (int t = 0; t < num_tree; ++t){
			uint32 kg = sz_c * sz_r * (s + t * num_pix);
			for (int x = 0; x < sz_c; ++x){
				for (int y = 0; y < sz_r; ++y){
					int c1 = grid[s] + x;
					int r1 = grid[num_pix + s] + y;
					salmap[c1 * h + r1] += (double)slabel_2d[kg + x * sz_r + y] *
						wt[s + t * num_pix];
					hitTime[c1 * h + r1]++;
				}
			}
		}
	}
}
