/*
 * MET1323: Broadband Multimedia Networks
 *
 * Objective:
 * 1. Capture image from webcam.
 * 2. Compress using JPEG.
 * 3. Display the compressed image.
 *
 * CREDITS:-
 * Adapted from https://gist.github.com/jayrambhia/5866483
 *
 * References:-
 * 1. http://libjpeg.sourceforge.net/
 * 2. http://www.christian-etter.de/?p=882
 * 3. http://www.cim.mcgill.ca/~junaed/libjpeg.php
 * 4. http://andrewewhite.net/wordpress/2008/09/02/very-simple-jpeg-writer-in-c-c
 * 5. http://answers.opencv.org/question/9659/solved-how-to-make-opencv-to-ask-libv4l-yuyv/
 *
 */

#include <stdio.h>
#include <string.h>

#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#include <linux/videodev2.h>

#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc_c.h>

#include <jpeglib.h>

#define	MAX_WIDTH	640
#define	MAX_HEIGHT	480
#define	QUALITY		100

uint8_t	*buffer;
uint8_t	bufRGB[MAX_WIDTH*MAX_HEIGHT*3];
uint8_t	bufJPG[MAX_WIDTH*MAX_HEIGHT*3];
uint8_t	bufJPGraw[MAX_WIDTH*MAX_HEIGHT*3];

static int xioctl(int fd, int request, void *arg) {
	int status;

	do {
		status = ioctl(fd, request, arg);
	} while (-1 == status && EINTR == errno);

	return status;
}

/* Convert from YUYV to RGB24 */
#define	SAT(c)	if (c & (~255)) { if (c < 0) c = 0; else c = 255; }

static void yuyv2rgb24(int width, int height, uint8_t *src, uint8_t *dst) {
	unsigned char *s;
	unsigned char *d;
	int rows, columns;
	int r, g, b, cr, cg, cb, y1, y2;

	rows = height;
	s = src;
	d = dst;

	while (rows--) {
		columns = width >> 1;
		while (columns--) {
			y1 = *s++;
			cb = ((*s - 128) * 454) >> 8;
			cg = (*s++ - 128) * 88;
			y2 = *s++;
			cr = ((*s - 128) * 359) >> 8;
			cg = (cg + (*s++ - 128) * 183) >> 8;

			r = y1 + cr;
			b = y1 + cb;
			g = y1 - cg;
			SAT(r); SAT(g); SAT(b);
			*d++ = r; *d++ = g;	*d++ = b;

			r = y2 + cr;
			b = y2 + cb;
			g = y2 - cg;
			SAT(r);	SAT(g);	SAT(b);
			*d++ = r; *d++ = g; *d++ = b;
		}
	}
}

/* JPEG compression, using libjpeg */
static int rgb2jpeg(int width, int height, int quality,
						uint8_t *in, uint8_t *out, uint64_t *outlen) {
	JSAMPROW row_pointer[1];

	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
	jpeg_mem_dest(&cinfo, &out, outlen);

	/* Setting the parameters of the output file. */
	cinfo.image_width = width;
	cinfo.image_height = height;
	cinfo.input_components = 3;
	cinfo.in_color_space = JCS_RGB;
	/* default compression parameters */
	jpeg_set_defaults(&cinfo);

	/* do the compression */
	jpeg_set_quality(&cinfo, quality, TRUE);
	jpeg_start_compress(&cinfo, TRUE);

	while (cinfo.next_scanline < cinfo.image_height) {
		row_pointer[0] = &in[cinfo.next_scanline * cinfo.image_width * 3];
		jpeg_write_scanlines(&cinfo, row_pointer, 1);
	}

	/* clean up */
	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	return 0;
}

int main(void) {
	/* open the device */
	int fd = open("/dev/video0", O_RDWR);
	if (-1 == fd) {
		perror("Opening video device");
		return 1;
	}

	/* query the device capability */
	if (print_caps(fd))
		return 1;

	/*  */
	if (init_mmap(fd))
		return 1;

	/*  */
	if (capture_image(fd))
		return 1;

	/*  */
	if (display_images())
		return 1;

	close(fd);

	return 0;
}

/* print the webcam capabilities */
int print_caps(int fd) {
	struct v4l2_capability caps = {};
	if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &caps)) {
		perror("Querying capabilities");
		return 1;
	}

	printf("Driver Caps:\n"
			"  Driver: \"%s\"\n"
			"  Card: \"%s\"\n"
			"  Bus: \"%s\"\n"
			"  Version: \"%d.%d\"\n"
			"  Capabilities: 0x%08x\n"
			, caps.driver, caps.card, caps.bus_info
			, (caps.version >> 16) && 0xff
			, (caps.version >> 24) && 0xff
			, caps.capabilities
		  );

	struct v4l2_fmtdesc fmtdesc = {0};
	fmtdesc.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	char fourcc[5] = {0};
	char c, e;

	printf("  FMT : CE Desc\n"
			"  -------------\n"
		  );
	while (0 == xioctl(fd, VIDIOC_ENUM_FMT, &fmtdesc)) {
		strncpy(fourcc, (char *)&fmtdesc.pixelformat, 4);
		c = fmtdesc.flags & 1 ? 'C' : ' ';
		e = fmtdesc.flags & 2 ? 'E' : ' ';
		printf("  %s: %c%c %s\n",
				fourcc, c, e, fmtdesc.description
			  );
		fmtdesc.index++;
	}

	//
	struct v4l2_format fmt = {0};
	fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	fmt.fmt.pix.width = 640;
	fmt.fmt.pix.height = 480;
	fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
	fmt.fmt.pix.field = V4L2_FIELD_NONE;

	if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmt)) {
		perror("Setting pixel format");
		return 1;
	}

	strncpy(fourcc, (char *)&fmt.fmt.pix.pixelformat, 4);
	printf("Selected Camera Mode:\n"
			"  Width: %d\n"
			"  Height: %d\n"
			"  PixFmt: %s\n"
			"  Field: %d\n"
			, fmt.fmt.pix.width, fmt.fmt.pix.height
			, fourcc, fmt.fmt.pix.field
		  );

	return 0;
}

/*  */
int init_mmap(int fd) {
	int i;

	// Initialize buffer
	struct v4l2_requestbuffers req;
	memset(&req, sizeof(req), 0);
	req.count = 1;
	req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	req.memory = V4L2_MEMORY_MMAP;

	if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
		perror("Requesting buffer");
		return 1;
	}

	struct v4l2_buffer buf;
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	buf.memory = V4L2_MEMORY_MMAP;
	buf.index = 0;

	if (-1 == xioctl(fd, VIDIOC_QUERYBUF, &buf)) {
		perror("Querying buffer");
		return 1;
	}

	buffer = mmap(NULL, buf.length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, buf.m.offset);

	return 0;
}

/*  */
int capture_image(int fd) {
	struct v4l2_buffer buf;
	buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	buf.memory = V4L2_MEMORY_MMAP;
	buf.index = 0;

	if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)) {
		perror("Query buffer");
		return 1;
	}

	if (-1 == xioctl(fd, VIDIOC_STREAMON, &buf.type)) {
		perror("Start capture");
		return 1;
	}

	/* wait for a new frame to become available */
	struct timeval timeout;
	timeout.tv_sec = 2;
	timeout.tv_usec = 0;

	fd_set fds;
	FD_ZERO(&fds);
	FD_SET(fd, &fds);
	int r = select(fd + 1, &fds, NULL, NULL, &timeout);
	if (-1 == r) {
		perror("Waiting for frame");
		return 1;
	}

	/* hold one frame */
	if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
		perror("Retrieving frame");
		return 1;
	}

	/* release the frame */
	if (-1 == xioctl(fd, VIDIOC_QBUF, &buf)) {
		perror("Releasing frame");
		return 1;
	}

	/*  */
	if (-1 == xioctl(fd, VIDIOC_STREAMOFF, &buf.type)) {
		perror("Stop capture");
		return 1;
	}

	uint64_t len;

	/* convert from YUYV to RGB */
	yuyv2rgb24(MAX_WIDTH, MAX_HEIGHT, buffer, bufRGB);

	/* compress and save a file */
	rgb2jpeg(MAX_WIDTH, MAX_HEIGHT, QUALITY, bufRGB, bufJPG, &len);
	int fp = open("out.jpg", O_WRONLY|O_CREAT, 0666);
	write(fp, bufJPG, len);
	close(fp);

	return 0;
}

/*  */
int display_images(void) {
	IplImage *jpg = cvLoadImage("out.jpg", CV_LOAD_IMAGE_COLOR);
	IplImage *rgb = cvCreateImageHeader(cvSize(MAX_WIDTH, MAX_HEIGHT),
							IPL_DEPTH_8U, 3);

	cvSetData(rgb, bufRGB, rgb->widthStep);
	cvCvtColor(rgb, rgb, CV_RGB2BGR);

	cvNamedWindow("RGB", CV_WINDOW_AUTOSIZE);
	cvMoveWindow("RGB", 0, 0);

	cvNamedWindow("JPEG", CV_WINDOW_AUTOSIZE);
	cvMoveWindow("JPEG", 700, 0);

	cvShowImage("RGB", rgb);
	cvShowImage("JPEG", jpg);

	cvWaitKey(0);

	cvReleaseImageHeader(&rgb);
	cvDestroyWindow("RGB");
	cvDestroyWindow("JPEG");

	return 0;
}
