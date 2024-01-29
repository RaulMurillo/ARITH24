/* Generation of for floating-point units */
#include <string> // for strcmp()
#include <stdlib.h> // for strtoull()
#include <functional> // for std::function<>
#include <random> // for random_device, uniform_int_distribution
#include <iostream>
#include <iomanip>
#include <string.h> 
// #define HALF_ARITHMETIC_TYPE 1
#include "half.hpp"

using half_float::half; 


/*
template<typename Real>
inline Real r_add(const Real& a, const Real& b) {
    return a + b;
}

template<typename Real>
inline Real r_sub(const Real& a, const Real& b) {
    return a - b;
}

template<typename Real>
inline Real r_mul(const Real& a, const Real& b) {
    return a * b;
}

template<typename Real>
inline Real r_div(const Real& a, const Real& b) {
    return a / b;
}
*/
template<typename Real>
inline Real r_sqrt(const Real& a) {
    return sqrt(a);
}

// template<typename Real>
// void test_op(std::function<Real(Real)> op){

//     Real x(0);
//     Real r;

//     unsigned long long max_p;
//     if (sizeof(x) == 8){
//         max_p = 0ULL-1;
//     }
//     else {
//         max_p = (1ULL<<(8*sizeof(x)))-1;
//     }
//     ///////// For sqrt
//     max_p = (max_p>>1)+2;
//     /////////
//     //const unsigned long long max_p = (1ULL<<N)-1;
    
//     // std::cout << "X Y R" << std::endl;
    
//     for (unsigned long long i=0;i<=max_p; ++i){
//         r = op(x);
//         // std::cout << std::hex << reinterpret_cast<char*>(&x) << " " << reinterpret_cast<char*>(&r) <<std::endl;
//         std::cout << x << " " << r <<std::endl;
//         x = nextafter(x,x+1);
//     }
// }

void test_op(std::function<half(half)> op){

    half x(0);
    half r;

    unsigned long long max_p;
    if (sizeof(x) == 8){
        max_p = 0ULL-1;
    }
    else {
        max_p = (1ULL<<(8*sizeof(x)))-1;
    }
    ///////// For sqrt
    max_p = (max_p>>1)+2;
    /////////
    //const unsigned long long max_p = (1ULL<<N)-1;
    
    // std::cout << "X Y R" << std::endl;
    
    for (unsigned long long i=0;i<=10; ++i){
        r = op(x);
        // std::cout << std::hex << reinterpret_cast<char*>(&x) << " " << reinterpret_cast<char*>(&r) <<std::endl;
        std::cout << x << " " << r <<std::endl;
        x = nextafter(x,x+1);
    }
}

template<typename Real>
void check_op(const char *str_op, uint64_t test_size){
    std::function<Real(Real, Real)> op;

    /*
    if (strcmp(str_op, "add") == 0) {
        op = &r_add<Real>;
    }
    else if (strcmp(str_op, "sub") == 0) {
        op = &r_sub<Real>;
    }
    else if (strcmp(str_op, "mul") == 0) {
        op = &r_mul<Real>;
    }
    else if (strcmp(str_op, "div") == 0) {
        op = &r_div<Real>;
    }
    else 
    */
    if (strcmp(str_op, "sqrt") == 0) {
        std::function<Real(Real)> op_single;
        op_single = &r_sqrt<Real>;
        test_op(op_single);
        return;
    }
    else {
        printf("\nInvalid argument: %s\n",str_op);
        return;
    }
}


int main(int argc, char *argv[]) {

    half x(0.0);
    half r;

    unsigned long long max_p;
    if (sizeof(x) == 8){
        max_p = 0ULL-1;
    }
    else {
        max_p = (1ULL<<(8*sizeof(x)))-1;
    }
    ///////// For sqrt
    max_p = (max_p>>1)+2;
    /////////
    //const unsigned long long max_p = (1ULL<<N)-1;
    
    // std::cout << "X Y R" << std::endl;
    
    for (unsigned long long i=0;i<=max_p; ++i){
        r = r_sqrt(x);
        // std::cout << std::hex << reinterpret_cast<char*>(&x) << " " << reinterpret_cast<char*>(&r) <<std::endl;
        std::cout << std::hex << std::setw(4) << std::setfill('0') << x.get() << " " << std::setw(4) << r.get() <<std::endl;

        x = nexttoward(x,HUGE_VALH);
    }


    return 0;
}
