/*************************************************************************
    > File Name: convert.h
    > Author:
    > Mail:
    > Created Time:
 ************************************************************************/

#ifndef _CONVERT_H
#define _CONVERT_H

#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

#define WORD  unsigned short
#define DWORD unsigned int
#define LONG  unsigned int


/* Bitmap header */
typedef struct tagBITMAPFILEHEADER {
    WORD bfType;
    DWORD bfSize;
    WORD bfReserved1;
    WORD bfReserved2;
    DWORD bfOffBits;
}__attribute__((packed)) BITMAPFILEHEADER;

/* Bitmap info header */
typedef struct tagBITMAPINFOHEADER {
    DWORD biSize;
    LONG biWidth;
    LONG biHeight;
    WORD biPlanes;
    WORD biBitCount;
    DWORD biCompression;
    DWORD biSizeImage;
    LONG biXPelsPerMeter;
    LONG biYPelsPerMeter;
    DWORD biClrUsed;
    DWORD biClrImportant;
}__attribute__((packed)) BITMAPINFOHEADER;

typedef int (*ConverFunc)(void *rgbData,void *yuvData,int width,int height,int h_flip,int v_flip);

int NV21ToYV12(void *save_YV12,void *NV21,int width,int height,int h_flip,int v_flip);
int YUYVToNV21(void *save_NV21,void *YUYV,int width,int height,int h_flip,int v_flip);
int RGB24ToRGB555(void *RGB555,void *RGB24,int width,int height,int h_flip,int v_flip);
int RGB24ToRGB565(void *RGB565,void *RGB24,int width,int height,int h_flip,int v_flip);
int NV12ToRGB24(void *RGB24,void *NV12,int width,int height,int h_flip,int v_flip);
int NV21ToRGB24(void *RGB24,void *NV21,int width,int height,int h_flip,int v_flip);
int YUV422PToRGB24(void *RGB24,void *YUV422P,int width,int height,int h_flip,int v_flip);
int YUV420ToRGB24(void *RGB24,void *YUV420,int width,int height,int h_flip,int v_flip);
int YVU420ToRGB24(void *RGB24,void *YVU420,int width,int height,int h_flip,int v_flip);
int YUYVToRGB24(void *RGB24,void *YUYV,int width,int height,int h_flip,int v_flip);
int YVYUToRGB24(void *RGB24,void *YVYU,int width,int height,int h_flip,int v_flip);
int UYVYToRGB24(void *RGB24,void *UYVY,int width,int height,int h_flip,int v_flip);
int VYUYToRGB24(void *RGB24,void *VYUY,int width,int height,int h_flip,int v_flip);
int NV16ToRGB24(void *RGB24,void *NV16,int width,int height,int h_flip,int v_flip);
int NV61ToRGB24(void *RGB24,void *NV61,int width,int height,int h_flip,int v_flip);
int YV12ToRGB24(void *RGB24,void *YV12,int width,int height,int h_flip,int v_flip);
int YUVToRGBfile(const char *rgb_path,char *yuv_data,ConverFunc func,int width,int height,int h_flip,int v_flip);
int YUVToBMP565(const char *bmp_path,char *yuv_data,ConverFunc func,int width,int height,int h_flip,int v_flip);
int YUVToBMP555(const char *bmp_path,char *yuv_data,ConverFunc func,int width,int height,int h_flip,int v_flip);
int YUVToBMP(const char *bmp_path,char *yuv_data,ConverFunc func,int width,int height,int h_flip,int v_flip);
int saveYUV_NV21(char *path, void *NV21, int width, int height,int h_flip,int v_flip);
int saveY_UV_NV21(char *path, void *NV21, int width, int height,int h_flip,int v_flip);

#endif
