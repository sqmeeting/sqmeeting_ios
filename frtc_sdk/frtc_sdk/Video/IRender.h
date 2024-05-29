#ifndef IRender_h
#define IRender_h

#include <stdint.h>
#include <vector>

namespace Frtc_Render
{
enum Payloadtype
{
    kPayloadRaw             = 127
};

class RenderFrame
{
public:
    unsigned int width;
    unsigned int height;
    uint16_t     rotation;
    unsigned int pixelAspectRatioWidth;
    unsigned int pixelAspectRatioHeight;
    RTC::VideoColorFormat colorFormat;
    char *data;
};

class IRender
{
public:
    virtual ~IRender() {}

    virtual bool init() = 0;
    virtual void resize(unsigned int width, unsigned int height) = 0;
    virtual bool draw(const RenderFrame *frame) = 0;
};
}


#endif /* IRender_h */
