# RST-saliency
This is the source code for our paper in ICCV 2017: 'Saliency Pattern Detection by Ranking Structured Trees'. Lei Zhu, Haibin Ling, Jin Wu, Huiping Deng and Jin Liu.

# Requirements
The project is build on MATLAB and is validated on both Windows 10 and Ubuntu 16.04 with CUDA 8. While in Windows system, visual studio 2013 is tested for generating the mex files.

# Installation
* Download dependencies from [Baidu Yun](http://pan.baidu.com/s/1miE8B9I/) or [Google Drive](https://drive.google.com/drive/folders/0B6qAIWXkeAeLcWprbE8xRVdOcUE?usp=sharing).
Please place both folders `data` and `toolboxes` into the root directory.

* Compile `MatConvNet` in `toolboxes` if it is necessary. Please refer to the [official guide](http://www.vlfeat.org/matconvnet/install/) for the instruction.

* Put your own images in JPEG format into the folder `test_samples` and run the stript `main_custom.m`.

# Citation
If you find the code useful, please cite the following Bibtex code

```
@inproceedings{RSTsaliency-zhul,
	title = {Saliency Pattern Detection by Ranking Structured Trees},
	booktitle = {International Conference on Computer Vision},
	author = {Zhu, L. and Ling, H. and Wu, J. and Deng, H. and Liu, J.},
	month = {Oct.},
	year = {2017}
}
```
# License
For academic usage, the code is released under the permissive BSD license. For any commercial purpose, please contact the authors.
