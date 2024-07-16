// test.cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

int Add(int a, int b);

TEST(AdditionTest, PositiveNumbers) {
    EXPECT_EQ(Add(1, 2), 3);
    EXPECT_EQ(Add(10, 20), 30);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
