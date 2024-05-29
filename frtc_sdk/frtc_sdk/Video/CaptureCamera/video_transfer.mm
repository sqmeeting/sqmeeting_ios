#include "video_transfer.h"
#include "string.h"

void nv12_to_i420(unsigned char *src_plane1, size_t src_stride1, unsigned char *src_plane2,
                  size_t src_stride2, int width, int height, unsigned char *dest)
{
    unsigned char *y = dest;
    unsigned char *u = dest + width * height;
    unsigned char *v = dest + width * height * 5 / 4;
    
    if (src_stride1 == 0)
    {
        src_stride1 = width;
    }
    
    if (src_stride2 == 0)
    {
        src_stride2 = width;
    }
    
    if (src_plane2 == NULL)
    {
        src_plane2 = src_plane1 + src_stride1 * height;
    }
    
    for (int i = 0; i < height; i++)
    {
        memcpy(y, src_plane1, width);
        src_plane1 += src_stride1;
        y += width;
    }
    
    for (int i = 0; i < height / 2; i++)
    {
        for (int j = 0; j < width / 2; j++)
        {
            u[j] = src_plane2[j * 2];
            v[j] = src_plane2[j * 2 + 1];
        }
        u += width / 2;
        v += width / 2;
        src_plane2 += src_stride2;
    }
}


void i420_mirror(unsigned char *src, unsigned char *dest, int width, int height)
{
    unsigned char *y = dest;
    unsigned char *u = dest + width * height;
    unsigned char *v = dest + width * height * 5 / 4;
    unsigned char *src_y = src;
    unsigned char *src_u = src + width * height;
    unsigned char *src_v = src + width * height * 5 / 4;
    
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            y[j] = src_y[width - 1 - j];
        }
        src_y += width;
        y += width;
    }
    
    for (int i = 0; i < height / 2; i++)
    {
        for (int j = 0; j < width / 2; j++)
        {
            u[j] = src_u[width / 2 - 1 - j];
            v[j] = src_v[width / 2 - 1 - j];
        }
        src_u += width / 2;
        u += width / 2;
        src_v += width / 2;
        v += width / 2;
    }
}
