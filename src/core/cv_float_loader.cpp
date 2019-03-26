#include "mex.h"
#include "matrix.h"
#include <opencv2/opencv.hpp>

// To compile (for linux/mac):
// make sure to add the returned contents of
//     $ pkg-config --libs opencv
// to the 'LINKLIBS' variable in the file at
//     >> fullfile(prefdir,'mex_C++_glnxa64.xml').
//
// At the MATLAB command line, run
//     >> mex fullfile(j_path,'j_tools/src/core/cv_float_loader.cpp');
//
// Call using
//     >> tmp = cv_float_loader('/path/to/float_mat_yaml_bullshit_file.whatever');
//
// Final thoughts: took me way too long to figure this shit out.
// 
// John Hoffman 2019 03 26

bool load_cv_matrix(cv::Mat &matrix, size_t &rows, size_t &cols, std::string filepath){
  cv::FileStorage fs (filepath, cv::FileStorage::READ);
  cv::Mat mat;
  fs["Mat"] >> mat;
  matrix = mat;

  rows = mat.rows;
  cols = mat.cols;

  return true;
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]){
  
    if (nrhs != 1) {
        mexErrMsgTxt("Only one input. Input should be filepath.");
    }
    
    //if (nlhs != 0) {
    //    mexErrMsgTxt("Too many output arguments. (One allowed)");
    //}

    const mwSize *dims;
    size_t str_length;
    mxArray * filepath_in;
    char * filepath_c;

    mxArray * array_out;

    // Get the filename into a string
    dims = mxGetDimensions(prhs[0]);
    str_length = (size_t)dims[1];
    filepath_c = (char * )calloc(4096+255,1);
    std::string filepath_cpp;

    if (mxGetString(prhs[0],filepath_c,4096+255) == 0 ){
      filepath_cpp = filepath_c;
      mexPrintf("String size: %d\n",str_length);
      mexPrintf("String contents: %s\n",filepath_cpp.c_str());
    }
    else{
      mexPrintf("Something went wrong.\n");
    }

    cv::Mat m;
    size_t rows,cols;

    if (load_cv_matrix(m,rows,cols,filepath_cpp)){
      mexPrintf("Rows: %d\n",rows);
      mexPrintf("Cols: %d\n",cols);

      mxArray * array_out = plhs[0] = mxCreateDoubleMatrix(rows,cols,mxREAL);
      double * array_return = mxGetPr(array_out);

      for (int i= 0;i<rows;i++){
        for (int j= 0;j<cols;j++){          
          int idx = i + j*rows;
          array_return[idx] = m.at<float>(i,j);
        }
      }
      
    }    


    
}
