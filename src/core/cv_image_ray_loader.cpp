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

#include "mex.h"
#include <string.h>
#include <iostream>
#include <fstream>
#include <string>

const int rows = 3000;
const int cols = 4096;

bool load_image_ray_file(mxArray * rays, std::string filepath){

  size_t file_rows;
  
  char * fieldnames[4];
  fieldnames[0] = (char*)mxMalloc(20);
  fieldnames[1] = (char*)mxMalloc(20);
  fieldnames[2] = (char*)mxMalloc(20);
  fieldnames[3] = (char*)mxMalloc(20);

  memcpy(fieldnames[0], "start_depth", sizeof("start_depth"));
  memcpy(fieldnames[1], "step_size"  , sizeof("step_size"));
  memcpy(fieldnames[2], "ray_length" , sizeof("ray_length"));  
  memcpy(fieldnames[3], "data"       , sizeof("data"));
  
  // Open the file
  
  std::ifstream f(filepath);

  f.read((char *)&file_rows,sizeof(size_t));

  for (int i=0;i<file_rows;i++){

    // Load a row
    size_t curr_col_end = 0;
    bool prev_data_invalid = 0;
    size_t n_segments = 0;
    
    f.read((char *)&curr_col_end,sizeof(size_t));
    f.read((char *)&prev_data_invalid,sizeof(uint8_t));    
    f.read((char *)&n_segments,sizeof(size_t));

    for (int j=0;j<n_segments;j++){
      // Load a segment
      size_t col_start;
      size_t seg_size;

      f.read((char *)&col_start,sizeof(size_t));
      f.read((char *)&seg_size,sizeof(size_t));
      
      for (int k=0;k<seg_size;k++){

        int curr_row = i;
        int curr_col = col_start+k;
        
        float v_start_depth;
        float v_step_size;
        uint64_t v_ray_length;

        f.read((char *)&v_start_depth,sizeof(float));
        f.read((char *)&v_step_size,sizeof(float));
        f.read((char *)&v_ray_length,sizeof(size_t));

        float * data;
        data = (float *)malloc(v_ray_length*sizeof(float));
        f.read((char * )data,v_ray_length*sizeof(float));

        // Create the data structures we'll used to send the data back to matlab
        mxArray * start_depth = mxCreateDoubleScalar((double)v_start_depth);
        mxArray * step_size   = mxCreateDoubleScalar((double)v_step_size);
        mxArray * ray_length  = mxCreateDoubleScalar((double)v_ray_length);
        mxArray * mxdata      = mxCreateDoubleMatrix(1,v_ray_length,mxREAL);
        double *  data_double = mxGetPr(mxdata);

        double tmp_var = 0.0;
        for(int ii = 0; ii<v_ray_length; ii++)
          data_double[ii] = (double)data[ii];

        // Copy into the fields of our structure array
        mxArray * image_ray = mxCreateStructMatrix(1,1,4,(const char **)fieldnames);
        mxSetFieldByNumber(image_ray,0,0,start_depth);
        mxSetFieldByNumber(image_ray,0,1,step_size);
        mxSetFieldByNumber(image_ray,0,2,ray_length);
        mxSetFieldByNumber(image_ray,0,3,mxdata);
          
        int cell_idx = curr_row + curr_col*rows;
        mxSetCell(rays,cell_idx,image_ray);

        free(data);

      }      
    }
  }

  f.close();

  return true;
}

#define FILEPATH_LENGTH 4096+255

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]){
  

  size_t str_length;
  mxArray * filepath_in;
  char * filepath_c;

  // Get the filename into a string
  filepath_c = (char *)calloc(FILEPATH_LENGTH,1);
  std::string filepath_cpp;

  if (mxGetString(prhs[0],filepath_c,FILEPATH_LENGTH) == 0 ){
    filepath_cpp = filepath_c;
  }
  else{
  }

  // Set up our outputs:
  mxArray * rays = plhs[0] = mxCreateCellMatrix(rows,cols);

  load_image_ray_file(rays,filepath_cpp);

}
