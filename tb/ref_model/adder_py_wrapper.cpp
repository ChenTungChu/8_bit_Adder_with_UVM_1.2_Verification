// File: tb/ref_model/adder_py_wrapper.cpp

#include <Python.h>
#include <iostream>
#include <stdexcept>
#include <mutex>

// ============================================================
//  PyAdderRef Class — Python module and function handler
// ============================================================
class PyAdderRef {
public:
    PyAdderRef(const char* module_name = "adder_ref_model_py",
               const char* func_name   = "adder_ref_model_py") {
        std::lock_guard<std::mutex> lock(py_mutex);

        if (!Py_IsInitialized()) {
            Py_Initialize();
            if (!Py_IsInitialized()) {
                throw std::runtime_error("Failed to initialize Python interpreter");
            }
        }

        PyObject* pName = PyUnicode_FromString(module_name);
        pModule = PyImport_Import(pName);
        Py_DECREF(pName);

        if (!pModule) {
            PyErr_Print();
            throw std::runtime_error(std::string("Failed to import Python module: ") + module_name);
        }

        pFunc = PyObject_GetAttrString(pModule, func_name);
        if (!pFunc || !PyCallable_Check(pFunc)) {
            Py_XDECREF(pFunc);
            Py_DECREF(pModule);
            throw std::runtime_error(std::string("Invalid Python function: ") + func_name);
        }

        std::cout << "[PyAdderRef] Python module loaded successfully." << std::endl;
    }

    ~PyAdderRef() {
        std::lock_guard<std::mutex> lock(py_mutex);

        Py_XDECREF(pFunc);
        Py_XDECREF(pModule);
    }

    int compute(int a, int b) {
        std::lock_guard<std::mutex> lock(py_mutex);

        PyObject* pArgs = PyTuple_Pack(2, PyLong_FromLong(a), PyLong_FromLong(b));
        if (!pArgs)
            throw std::runtime_error("Failed to build Python argument tuple");

        PyObject* pValue = PyObject_CallObject(pFunc, pArgs);
        Py_DECREF(pArgs);

        if (!pValue) {
            PyErr_Print();
            throw std::runtime_error("Python function call failed");
        }

        int result = static_cast<int>(PyLong_AsLong(pValue));
        Py_DECREF(pValue);
        return result;
    }

private:
    PyObject* pModule = nullptr;
    PyObject* pFunc   = nullptr;
    static std::mutex py_mutex; // thread-safe lock for multi-thread DPI
};

// Define the static mutex
std::mutex PyAdderRef::py_mutex;

// ============================================================
//  C interface — for SystemVerilog DPI-C call
// ============================================================
extern "C" int adder_ref_model_cpp(int a, int b) {
    try {
        static PyAdderRef pyAdder; // Singleton instance
        return pyAdder.compute(a, b);
    } catch (const std::exception& e) {
        std::cerr << "[adder_ref_wrapper] Error: " << e.what() << std::endl;
        return -1; // return -1 on error
    }
}
