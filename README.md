# wheel-data-analysis
Analysing multiple mice on the wheel detection and discrimination tasks

1. Download all functions and code from this repository
   - make sure that it is on the matlab path
   
2. First open the load_data_functions.m code
   - select the location of mouse data in dialog box (folder with folders M123, M124...etc.) 
   - exp type doesn't matter, all will be marked correctly in the combined data structure
   
3. After it is finished running run the code called combining.m
   - run it from the same folder where the last code left you - in the folder with mouse folders
   
4. The final data structure is a cell array, saved in the mouse data folder called allmaus_dat.
Each cell is a mouse - inside the cell columns are as follows:

1. Day success average \ 2. Date \ 3. Mouse \ 4. Experiment Type \ 5. Experiment trials data

The experiment trials data columns are as follows in Detection Experiment type:
1. Orientation \ 2. Number of trial repetition \ 3. RT \ 4. Success? \ 5. Correct side \ 6. Left Side Contrast \ 7. Right Side Contrast

In the discrimination experiment first two columns are left and right side orientation, respectively, everything else shifted by one.
