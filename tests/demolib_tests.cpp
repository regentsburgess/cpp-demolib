#include <demolib/example.hpp>
#include <gtest/gtest.h>

TEST(DemoLibMetadata, NameMatchesProject) {
    EXPECT_EQ(demolib::lib_name(), EXPECTED_LIB_NAME);
}

TEST(DemoLibMetadata, VersionMatchesProject) {
    EXPECT_EQ(demolib::lib_version(), EXPECTED_LIB_VERSION);
}

TEST(DemoLibGreet, EmptyNameReturnsGenericHello) {
    std::string expected{"Hello from "};
    expected += demolib::lib_name();
    expected += ' ';
    expected += demolib::lib_version();

    EXPECT_EQ(demolib::greet(""), expected);
}

TEST(DemoLibGreet, NonEmptyNameReturnsPersonalizedHello) {
    const auto* name = "Regent";

    std::string expected{"Hello from "};
    expected += demolib::lib_name();
    expected += ' ';
    expected += demolib::lib_version();
    expected += ", ";
    expected += name;
    expected += '!';

    EXPECT_EQ(demolib::greet(name), expected);
}

TEST(DemoLibGreet, PreservesWhitespaceAndPunctuation) {
    const auto* name = "Regent Jr.";

    std::string expected{"Hello from "};
    expected += demolib::lib_name();
    expected += ' ';
    expected += demolib::lib_version();
    expected += ", ";
    expected += name;
    expected += '!';

    EXPECT_EQ(demolib::greet(name), expected);
}
