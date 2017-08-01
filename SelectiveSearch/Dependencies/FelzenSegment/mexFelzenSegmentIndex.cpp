#include <cmath>
#include "mex.h"
#include "segment-image.h"

#define UInt8 char

// dissimilarity measure between pixels. Adjusted from segment-image.h
static inline float diffVec(std::vector<image<float>* > imageVec,
			 int x1, int y1, int x2, int y2) {
    float dist = 0;
    for (int i=0; i < imageVec.size(); i++){
        dist = dist + square(imRef(imageVec[i], x1, y1) - imRef(imageVec[i], x2, y2));
    }
    return sqrt(dist);

//  return sqrt(square(imRef(r, x1, y1)-imRef(r, x2, y2)) +
//	      square(imRef(g, x1, y1)-imRef(g, x2, y2)) +
//	      square(imRef(b, x1, y1)-imRef(b, x2, y2)));
}

/*
 * Segment an image (Adjusted from segment-image.h)
 *
 * Returns a color image representing the segmentation. 
 * JASPER: Random is replaced by just an index.
 * VIKA:   4-connectivity instead of 8.
 * JASPER: Works now with arrays of any dimensionality (depth)
 *
 * im: image to segment.
 * sigma: to smooth the image.
 * c: constant for treshold function.
 * min_size: minimum component size (enforced by post-processing stage).
 * num_ccs: number of connected components in the segmentation.
 */
double *segment_matrix_index(double* theIm, int width, int height, int depth, float sigma, float c, int min_size,
			  int *num_ccs) {

  // Make a vector of image channels
  std::vector<image<float>* > imChannels(depth);
  for (int i = 0; i < depth; i++){
      imChannels[i] = new image<float>(width, height);
  }
  
  // Fill each color channel
  for (int y=0; y < height; y++){
      for (int x = 0; x < width; x++){
          for (int z = 0; z < depth; z++){
              imRef(imChannels[z], x, y) = theIm[y + height * x + height * width * z];
          }
      }
  }

  // Smooth each color channel 
  std::vector<image<float>* > smoothedIm(depth);
  for (int i = 0; i < depth; i++){
      smoothedIm[i] = smooth(imChannels[i], sigma);
      delete imChannels[i];
  }

  // Get minimum and maximum, this in order to make the threshold always similar regardless of
  // what kind of image is put in and in which range
  float minIm = imRef(smoothedIm[0], 0, 0);
  float maxIm = imRef(smoothedIm[0], 0, 0);
  float currVal;
  for (int y=0; y < height; y++){
      for (int x = 0; x < width; x++){
          for (int z = 0; z < depth; z++){
              currVal = imRef(smoothedIm[z], x, y);
              if (currVal > maxIm){
                  maxIm = currVal;
              }
              if (currVal < minIm){
                  minIm = currVal;
              }
          }
      }
  }
  float diffIm = maxIm - minIm;

  // Adjust threshold parameter c based on the difference in the image.
  c = c * diffIm / 255.0;

  // build graph
  edge *edges = new edge[width*height*4];
  int num = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (x < width-1) {
	edges[num].a = y * width + x;
	edges[num].b = y * width + (x+1);
	//edges[num].w = diffVec(smooth_r, smooth_g, smooth_b, x, y, x+1, y);
	edges[num].w = diffVec(smoothedIm, x, y, x+1, y);
	num++;
      }

      if (y < height-1) {
	edges[num].a = y * width + x;
	edges[num].b = (y+1) * width + x;
	//edges[num].w = diffVec(smooth_r, smooth_g, smooth_b, x, y, x, y+1);
	edges[num].w = diffVec(smoothedIm, x, y, x, y+1);
	num++;
      }

      // Commented code below to get 4-connectivity
      /*
      if ((x < width-1) && (y < height-1)) {
	edges[num].a = y * width + x;
	edges[num].b = (y+1) * width + (x+1);
	//edges[num].w = diff(smooth_r, smooth_g, smooth_b, x, y, x+1, y+1);
	edges[num].w = diff(smoothedIm, x, y, x+1, y+1);
	num++;
      }

      if ((x < width-1) && (y > 0)) {
	edges[num].a = y * width + x;
	edges[num].b = (y-1) * width + (x+1);
	//edges[num].w = diff(smooth_r, smooth_g, smooth_b, x, y, x+1, y-1);
	edges[num].w = diff(smoothedIm, x, y, x+1, y-1);
	num++;
      }
      */
    }
  }
  
  // Delete smoothed im
  for (int i = 0; i < depth; i++){
      delete smoothedIm[i];
  }

  // segment
  universe *u = segment_graph(width*height, num, edges, c);
  
  // post process small components
  for (int i = 0; i < num; i++) {
    int a = u->find(edges[i].a);
    int b = u->find(edges[i].b);
    if ((a != b) && ((u->size(a) < min_size) || (u->size(b) < min_size)))
      u->join(a, b);
  }
  delete [] edges;
  *num_ccs = u->num_sets();

  //image<rgb> *output = new image<rgb>(width, height);

  // pick random colors for each component
  double *colors = new double[width*height];
  for (int i = 0; i < width*height; i++)
    colors[i] = 0;
  
  int idx = 1;
  double* indexmap = new double[width * height];
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int comp = u->find(y * width + x);
      if (!(colors[comp])){
          colors[comp] = idx;
          idx = idx + 1;
      }

      //imRef(output, x, y) = colors[comp];
      indexmap[x * height + y] = colors[comp];
    }
  }  
  //mexPrintf("indexmap 0: %f\n", indexmap[0]);
  //mexPrintf("indexmap 1: %f\n", indexmap[1]);

  delete [] colors;
  delete u;

  return indexmap;
}

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *input[])
{
    // Checking number of arguments
    if(nlhs > 3){
        mexErrMsgTxt("Function has three return values");
        return;
    }

    if(nrhs != 4){
        mexErrMsgTxt("Usage: mexFelzenSegment(UINT8 im, double sigma, double c, int minSize)");
        return;
    }

    if(!mxIsClass(input[0], "double")){
        mexErrMsgTxt("Only arrays of the double class are allowed.");
        return;
    }

    // Load in arrays and parameters
    //double* matIm = (double*) mxGetPr(input[0]);
    double* matIm = mxGetPr(input[0]);
    int nrDims = (int) mxGetNumberOfDimensions(input[0]);
    int* dims = (int*) mxGetDimensions(input[0]);
    double* sigma = mxGetPr(input[1]);
    double* c = mxGetPr(input[2]);
    double* minSize = mxGetPr(input[3]);
    int min_size = (int) *minSize;

    int height = dims[0];
    int width = dims[1];
    int depth;
    if (nrDims == 2){ // Set depth to 1 for 2 dimensional array
        depth = 1;
    }
    else{
        depth = dims[2];
    }

    int numElements = width * height * depth;

    // Call Felzenswalb segmentation algorithm
    int num_css;
    double* segIndices = segment_matrix_index(matIm, width, height, depth, *sigma, *c, min_size, &num_css); // Modified to deal directly with Matlab arrays

    // The segmentation index image
    out[0] = mxCreateDoubleMatrix(dims[0], dims[1], mxREAL);
    double* outSegInd = mxGetPr(out[0]);

    // Keep track of minimum and maximum of each blob
    out[1] = mxCreateDoubleMatrix(num_css, 4, mxREAL);
    double* minmax = mxGetPr(out[1]);
    for (int i=0; i < num_css; i++)
        minmax[i] = dims[0];
    for (int i= num_css; i < 2 * num_css; i++)
        minmax[i] = dims[1];

    // Keep track of neighbouring blobs using square matrix
    out[2] = mxCreateDoubleMatrix(num_css, num_css, mxREAL);
    double* nn = mxGetPr(out[2]);

    // Copy the contents of segIndices
    // Keep track of neighbours
    // Get minimum and maximum
    // These actually comprise of the bounding boxes
    double currDouble;
    int mprev, curr, prevHori, mcurr, idx;
    for(int x = 0; x < width; x++){
        mprev = segIndices[x * height]-1;
        for(int y=0; y < height; y++){
            //mexPrintf("x: %d y: %d\n", x, y);
            idx = x * height + y;
            //mexPrintf("idx: %d\n", idx);
            //currDouble = segIndices[idx]; 
            //mexPrintf("currDouble: %d\n", currDouble);
            curr = segIndices[idx]; 
            //mexPrintf("curr: %d\n", curr);
            outSegInd[idx] = curr; // copy contents
            //mexPrintf("outSegInd: %f\n", outSegInd[idx]);
            mcurr = curr-1;

            // Get neighbours (vertical)
            //mexPrintf("idx: %d", curr * num_css + mprev);
            //mexPrintf(" %d\n", curr + num_css * mprev);
            //mexPrintf("mprev: %d\n", mprev);
            nn[(mcurr) * num_css + mprev] = 1;
            nn[(mcurr) + num_css * mprev] = 1;

            // Get horizontal neighbours
            //mexPrintf("Get horizontal neighbours\n");
            if (x > 0){
                prevHori = outSegInd[(x-1) * height + y] - 1;
                nn[mcurr * num_css + prevHori] = 1;
                nn[mcurr + num_css * prevHori] = 1;
            }

            // Keep track of min and maximum index of blobs
            //mexPrintf("Keep track of min and maximum index\n");
            if (minmax[mcurr] > y)
                minmax[mcurr] = y;
            if (minmax[mcurr + num_css] > x)
                minmax[mcurr + num_css] = x;
            if (minmax[mcurr + 2 * num_css] < y)
                minmax[mcurr + 2 * num_css] = y;
            if (minmax[mcurr + 3 * num_css] < x)
                minmax[mcurr + 3 * num_css] = x;

            //mexPrintf("Mprev = mcurr");
            mprev = mcurr;
        }
    }

    // Do minmax plus one for Matlab
    for (int i=0; i < 4 * num_css; i++)
        minmax[i] += 1;

    //delete theIm;
    delete [] segIndices;

    return;
}
       







