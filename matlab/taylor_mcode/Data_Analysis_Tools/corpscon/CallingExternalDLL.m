%% Calling a User-defined shared library in MATLAB 
% Vincent Leclercq - The MathWorks France - 21 August 2007
%
% This example demonstrates how to use the loadlibrary function with a user
% defined Dll (Lib_Math.dll,code of the dll is also included in the package), and how to use pointers to communicate

%% Clean the environment

clear all;
%% Load the dynamic libarry
% We use the dll and the header file (Lib_Math.dll, Lib_Math.h)
loadlibrary('Lib_Math','Lib_Math.h');
%% View exported functions
% The libfunctionsview function show the MATLAB prototype of the Dll
% exported functions

libfunctionsview Lib_Math


%% Create a variable to pass by reference
% We can also create the pointer needed
InputValue = magic(10)
pt = libpointer('doublePtr', InputValue);

%% Call of the dynamic library functions (Without pointers )
%
% Code of the C Function :
% 
%  int MyComputation (int a , int b)
%  {
%  	return a * b;
%  }
% 
Result = calllib('Lib_Math','MyComputation',10,284);
disp(['The results of the Dll function call is :' num2str(Result)]);

%% Call of the dynamic library functions (With pointers)
%
% Code of the C Function :
%
%
%  bool ChangeAValue(double *x, int size)_
%  {
%     int i;
%     for (i = 0; i < size; i++)
%       x[i] =  x[i] * i;
% 
%  return TRUE;
%  }
% 
% 

calllib('Lib_Math','ChangeAValue',pt,100);

Resultat = get(pt,'Value')

%% Unload eveything
unloadlibrary('Lib_Math')
clear all