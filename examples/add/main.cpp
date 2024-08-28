#include <threadpool-cpp/threadpool-cpp.h>

#include <iostream>

int main(int, char*[])
{
    auto sum = threadpoolcpp::add(1, 1);
    std::cout << sum << std::endl;
    return 0;
}
