#include "mex.h"
#include "matrix.h"
//#include "stdafx.h"
#include "SLIC.h"
#include "SLIC.cpp"
#include <cstdio>
#include <cstdlib>

#ifdef _MSC_VER
typedef unsigned __int8 uint8_t;
typedef unsigned __int32 uint32_t;
#else
#include <stdint.h>
#endif


//#define uint32_t unsigned int
//#define uint8_t unsigned char
#define RGB(r, g ,b) ((uint32_t)(r) << 16 | (uint32_t)(g) << 8 | (uint32_t)(b))

//Entry Function: The name should always be 'mexFunction'
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
	//Get the Input data
	//The image data
	double*	ubuff = mxGetPr(prhs[0]);
	//uint8_t* ubuff = (uint8_t*) mxGetData(prhs[0]);
	//Required number of super-pixels
    const double K = mxGetScalar(prhs[1]);
	//Weight given to spatial distance
    const double compactness = mxGetScalar(prhs[2]);
	//The label for using LAB(1) or RGB(0)
	const double colorspace = mxGetScalar(prhs[3]);
	
	//Get some information of the image
	const mwSize *dims = mxGetDimensions( prhs[0] );
	const int height = dims[0];
	const int width = dims[1];
	const int chn = dims[2];
	const int pixNum = width * height;
	
	//Initialize the output data
	//int* klabels = new int[width * height];
	plhs[0] = mxCreateNumericMatrix( pixNum, 1,mxINT32_CLASS, mxREAL);
    int* klabels = reinterpret_cast<int*>(mxGetPr(plhs[0]));
	//double* klabels = mxGetPr(plhs[0]);
	//for( int ix = 0; ix < pixNum; ++ix ) klabels[ix] = (int)0;
	//mexPrintf( "klabels[0]: %d, size: %d\n", (int)klabels[50], sizeof(klabels) );
	
	//int	numlabels = 0;
	plhs[1] = mxCreateNumericMatrix( 1, 1,mxINT32_CLASS, mxREAL);
	int* numlabels = reinterpret_cast<int*>(mxGetPr(plhs[1]));

	//Convert the image to the 1 dimension array
	//Be ware the matrix in mat-lab is indexed along the col.

	
	//uint32* image = new uint32[pixNum * chn];
	unsigned int* image = new unsigned int[pixNum];
	
	//typedef unsigned char uint8;
	//uint8 r, g, b;
	//
	//for (int y = 0; y < height; y++) 
	//{
	//	for (int x = 0; x < width; x++) 
	//	{
	//		int index = height*x + y;
	//		r = static_cast<uint8>( ubuff[index] );
	//		g = static_cast<uint8>( ubuff[width*height + index] );
	//		b = static_cast<uint8>( ubuff[width*height*2 + index] );
	//		image[y * width + x] = (r << 16) + (g << 8) + b;
	//	}
	//}
	
	int pix = 0, index=0;
	for (int y = 0; y < height; ++y)
	{
		index = y;
		for (int x = 0; x < width; ++x)
		{
			// index = x * height + y;
			// pix = y * width + x;
			image[pix] = RGB(ubuff[index], ubuff[pixNum+index], ubuff[(2*pixNum)+index]);
			++pix;
			index += height;
		}
	}
	
	//Do the work
    SLIC slic;
	slic.DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels
		//(const_cast<const unsigned int*>(image),width, height, klabels, *numlabels, int(K), compactness, (int)colorspace);
	(image,width, height, klabels, *numlabels, int(K), compactness, (int)colorspace);
	//Save the segments data to the local disk
	//slic.SaveSuperpixelLabels(klabels,width, height,"segments.dat", "E:\\My Research\\SLIC\\read the result\\compare experiment\\");
	

	//// Regularize the labels for each super pixel
	//int num = numlabels[0];
	////mexPrintf("number of labels is %d\n",num);
	//int* org_labels = new int[num];
	//int* temp_labels = new int[pixNum];
	//// initial org_labels with -1
	//memset(org_labels, -1, sizeof(int)* num);
	//// copy klabels to a temporary array
	//memcpy(temp_labels, klabels, sizeof(int) * pixNum);
	//
	//// Initial with the first value
	//org_labels[0] = klabels[0];
	//int idx = 0;
	//bool isExist;
	//for (int i = 1; i < pixNum; ++i)
	//{
	//	isExist = false;
	//	for (int j = 0; j < num; ++j)
	//	{
	//		if (org_labels[j] == klabels[i])
	//		{
	//			isExist = true;
	//			break;
	//		}
	//	}
	//	if (!isExist)
	//	{
	//		org_labels[++idx] = klabels[i];
	//	}
	//}

	//// Resign the label to klabels
	//for (int i = 0; i < num; ++i)
	//{
	//	for (int j = 0; j < pixNum; ++j)
	//	{
	//		if (temp_labels[j] == org_labels[i])
	//		{
	//			klabels[j] = i + 1;
	//		}
	//	}
	//}

	//Free the array
	//if(image) delete [] image;
	delete [] image;
	//delete [] org_labels;
	//delete [] temp_labels;
}
