/* Generation of Testbenches with Universal library */
#include <universal/number/posit/posit.hpp>
#include <string> // for strcmp()
#include <stdlib.h> // for strtoull()
#include <functional> // for std::function<>
#include <random> // for random_device, uniform_int_distribution


// Namespaces
using namespace sw::universal;

// Definitions
// #define N	8
#define ES	2

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

template<typename Real>
void test_op(std::function<Real(Real)> op){

    Real x = 0;
    Real r;

    const size_t N = x.nbits;
    unsigned long long max_p;
    if (N == 64){
        max_p = 0ULL-1;
    }
    else {
        max_p = (1ULL<<N)-1;
    }
    ///////// For sqrt
    max_p = (max_p>>1)+2;
    /////////
    //const unsigned long long max_p = (1ULL<<N)-1;
    
    // std::cout << "X Y R" << std::endl;
    
    for (unsigned long long i=0;i<=max_p; ++i){
        r = op(x);
        std::cout << x.get() << " " << r.get() <<std::endl;
        x++;
    }
}

template<typename Real>
void rand_test_op(std::function<Real(Real)> op, const uint64_t max_p){
    // const uint max_p = 1<<N;
    
    Real x;
    Real r;
    const size_t N = x.nbits;
    unsigned long long max_k;
    if (N == 64){
        max_k = 0ULL-1;
    }
    else {
        max_k = (1ULL<<N)-1;
    }

    // random numbers logic
    std::random_device rd; // obtain a random number from hardware
    std::mt19937 gen(rd()); // seed the generator
    std::uniform_int_distribution<uint64_t> distr(0, max_k); // define the range
    
    // std::cout << "X Y R" << std::endl;
    
    for (uint64_t i=0;i<max_p; ++i){
        //x.setbits(uint64_t value);
        x.setbits(distr(gen));
	if (x>0) {
          r = op(x);
          std::cout << x.get() << " " << r.get() <<std::endl;
	}
	else {
	  i--;
	}
    }
}

template<typename Real>
void check_op(const char *str_op, bool rand_t, uint64_t test_size){
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
        if (rand_t)
            rand_test_op<Real>(op_single, test_size);
        else
            test_op<Real>(op_single);
        return;
    }
    else {
        printf("\nInvalid argument: %s\n",str_op);
        return;
    }
    /*
    if (rand_t)
        rand_test_op<Real>(op, test_size);
    else
        test_op<Real>(op);
    */
}


int main(int argc, char *argv[]) {
    // using Real = sw::universal::posit<N,ES>;
    // std::function<Real(Real, Real)> op;
    bool rand_t = false;
    uint64_t test_size = 0;

    const char *str_op = "sqrt";
    
    if(argc<2)
    {
        printf("\nNo Extra Command Line Arguments Passed\nPlease, indicate data width and, optinally, the number or inputs (random test)\n");
	printf("Usage: gen_testbench <data width> [<# random inputs>]\n");
        return 1;
    }
    if(argc==3){
    	char* p;
    	unsigned long arg = strtoull(argv[2], &p, 10);
    	if (*p != '\0' || errno != 0)
    	    return 1; // In main(), returning non-zero means failure
        // if (arg < (1UL<<(N)) && arg > 0) {
        if (arg > 0) {
    	    test_size = arg;
    	    rand_t = true;
        }
        else
            return 1;
    }

    if (strcmp(argv[1], "8") == 0) {
    	using Real = sw::universal::posit<8,ES>;
	check_op<Real>(str_op, rand_t, test_size);
    }
    else if (strcmp(argv[1], "10") == 0) {
    	using Real = sw::universal::posit<10,ES>;
	check_op<Real>(str_op, rand_t, test_size);
    }
    else if (strcmp(argv[1], "16") == 0) {
        using Real = sw::universal::posit<16,ES>;
	check_op<Real>(str_op, rand_t, test_size);
    }
    else if (strcmp(argv[1], "32") == 0) {
        using Real = sw::universal::posit<32,ES>;
	check_op<Real>(str_op, rand_t, test_size);
    }
    else if (strcmp(argv[1], "64") == 0) {
        using Real = sw::universal::posit<64,ES>;
	check_op<Real>(str_op, rand_t, test_size);
    }
    else {
        printf("\nInvalid posit bitwidth: %s\nPosit size must be 8, 16, 32 or 64\n",argv[1]);
        return 1;
    }


    return 0;
}
