/**
* stream_client.c:
* OpenCV video streaming client
*
* Author  Nash <me_at_nashruddin.com>
*
* See the tutorial at 
* http://nashruddin.com/StrEAMinG_oPENcv_vIdEos_ovER_tHe_nEtWoRk
*/

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
//#include "cv.h"
//#include "highgui.h"
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc_c.h>

#include <jpeglib.h>

#define	MAX_WIDTH		640
#define	MAX_HEIGHT		480
uint8_t	bufRGB[MAX_WIDTH * MAX_HEIGHT *3];
uint8_t	bufJPG[MAX_WIDTH * MAX_HEIGHT *3];

IplImage* img;
int       is_data_ready = 0;
int       sock;
char*     server_ip;
int       server_port;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void* streamClient(void* arg);
void  quit(char* msg, int retval);
int decode_frame(uint8_t *in, int len, void *out);

int main(int argc, char** argv)
{
	pthread_t thread_c;
	int width, height, key;
	if (argc != 5) {
		quit("Usage: stream_client <server_ip> <server_port> <width> <height>", 0);
	}
	/* get the parameters */
	server_ip   = argv[1];
	server_port = atoi(argv[2]);
	width       = atoi(argv[3]);
	height      = atoi(argv[4]);
	/* create image */
	img = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);
	cvZero(img);
	/* run the streaming client as a separate thread */
	if (pthread_create(&thread_c, NULL, streamClient, NULL)) {
		quit("pthread_create failed.", 1);
	}
	fprintf(stdout, "Press 'q' to quit.\n\n");
	cvNamedWindow("stream_client", CV_WINDOW_AUTOSIZE);
	while(key != 'q') {
		/**
		 * Display the received image, make it thread safe
		 * by enclosing it using pthread_mutex_lock
		 */
		pthread_mutex_lock(&mutex);
		if (is_data_ready) {
			cvShowImage("stream_client", img);
			is_data_ready = 0;
		}
		pthread_mutex_unlock(&mutex);
		key = cvWaitKey(10);
	}
	/* user has pressed 'q', terminate the streaming client */
	if (pthread_cancel(thread_c)) {
		quit("pthread_cancel failed.", 1);
	}
	/* free memory */
	cvDestroyWindow("stream_client");
	quit(NULL, 0);
}

/**
* This is the streaming client, run as separate thread
*/
void* streamClient(void* arg)
{
	struct  sockaddr_in server;
	/* make this thread cancellable using pthread_cancel() */
	pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
	/* create socket */
	if ((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		quit("socket() failed.", 1);
	}
	/* setup server parameters */
	memset(&server, 0, sizeof(server));
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = inet_addr(server_ip);
	server.sin_port = htons(server_port);
	/* connect to server */
	if (connect(sock, (struct sockaddr*)&server, sizeof(server)) < 0) {
		quit("connect() failed.", 1);
	}
	int  imgsize = img->imageSize;
	char sockdata[imgsize];
	int  i, j, k, bytes;
	/* start receiving images */
	while(1) {
		/* get raw data */
		for (i = 0; i < imgsize; i += bytes) {
			if ((bytes = recv(sock, sockdata + i, imgsize - i, 0)) == -1) {
				quit("recv failed", 1);
			}
		}

		/* decompress received frame, convert to IplImage format, thread safe */
		pthread_mutex_lock(&mutex);

		decode_frame(sockdata, MAX_WIDTH * MAX_HEIGHT * 3, bufRGB);
		cvSetData(img, bufRGB, img->width * 3);

		is_data_ready = 1;
		pthread_mutex_unlock(&mutex);
		/* have we terminated yet? */
		pthread_testcancel();
		/* no, take a rest for a while */
		usleep(1000);
	}
}

/**
* This function provides a way to exit nicely from the system
*/
void quit(char* msg, int retval)
{
	if (retval == 0) {
		fprintf(stdout, "%s", (msg == NULL ? "" : msg));
		fprintf(stdout, "\n");
	} else {
		fprintf(stderr, "%s", (msg == NULL ? "" : msg));
		fprintf(stderr, "\n");
	}
	if (sock) close(sock);
	if (img) cvReleaseImage(&img);
	pthread_mutex_destroy(&mutex);
	exit(retval);
}

int decode_frame(uint8_t *in, int len, void *out)
{
	int n_samples;
	struct jpeg_error_mgr err;
	struct jpeg_decompress_struct cinfo = {0};

	/* create decompressor */
	jpeg_create_decompress(&cinfo);
	cinfo.err = jpeg_std_error(&err);
	cinfo.do_fancy_upsampling = FALSE;

	/* set source buffer */
	jpeg_mem_src(&cinfo, in, len);

	/* read jpeg header */
	jpeg_read_header(&cinfo, 1);

	/* decompress */
	jpeg_start_decompress(&cinfo);

	/* read scanlines */
	while (cinfo.output_scanline < cinfo.output_height) {
		n_samples = jpeg_read_scanlines(&cinfo, (JSAMPARRAY) &out, 1);
		out += n_samples * cinfo.image_width * cinfo.num_components;
	}

	/* clean up */
	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);

	return 0;
}