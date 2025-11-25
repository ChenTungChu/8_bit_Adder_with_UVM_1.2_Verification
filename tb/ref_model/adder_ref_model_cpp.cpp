// File: tb/ref_model/adder_ref_cpp.cpp

#include "svdpi.h"

extern "C" int adder_ref_model_cpp(int a, int b){
	return a + b;
}