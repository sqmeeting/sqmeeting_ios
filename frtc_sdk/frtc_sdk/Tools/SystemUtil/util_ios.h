#ifndef util_ios_hpp
#define util_ios_hpp

#include <stdio.h>
#include <string>
#include <deque>

class SystemUtiliOS {
public:
    static std::string GetApplicationDocumentDirectory();

private:
    SystemUtiliOS() {}
    ~SystemUtiliOS() {}
};

#endif /* util_ios_hpp */
