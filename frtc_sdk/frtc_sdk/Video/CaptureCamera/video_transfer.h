#ifndef VideoTransfer_h
#define VideoTransfer_h

#include <stdio.h>

void nv12_to_i420(unsigned char *src_plane1, size_t src_stride1, unsigned char *src_plane2,
                  size_t src_stride2, int width, int height, unsigned char *dest);

void i420_mirror(unsigned char *src, unsigned char *dest, int width, int height);

#endif /* VideoTransfer_h */
