#include <threadpool-cpp/threadpool-cpp.h>

#include <gtest/gtest.h>

TEST(add_test, add_1_1)
{
    EXPECT_EQ(threadpoolcpp::add(1, 1), 2);
}
