/*!
   UCEcho -- C host software for ucecho examples
   Copyright (C) 2009-2010 ZTEX e.K.
   http://www.ztex.de
 
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.
 
   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.
 
   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <usb.h>

#define BUFSIZE  256
 
struct usb_device *device;
usb_dev_handle *handle;
char buf[BUFSIZE];
 
// find the first ucecho device
struct usb_device *find_device ()
{
	struct usb_bus *bus_search;
	struct usb_device *device_search;

	bus_search = usb_busses;
	while (bus_search != NULL){
		device_search = bus_search->devices;
		while (device_search != NULL){
			if ((device_search->descriptor.idVendor == 0x221a) && (device_search->descriptor.idProduct == 0x100)) {
				handle = usb_open(device_search);
				usb_get_string_simple(handle, device_search->descriptor.iProduct, buf, BUFSIZE);
				
				if (! strncmp("intraffic", buf , 9 ) )
					return device_search;
				
				usb_close(handle);
			}
			device_search = device_search->next;
		}
		bus_search = bus_search->next;
	}

	return NULL;
}
 
// main
int main(int argc, char *argv[])
{
	unsigned int sent[8] = {0xd1310ba6, 0x98dfb5ac, 0x2ffd72db, 0xd01adfb7,
				0xb8e1afed, 0x6a267e96, 0xba7c9045, 0xf12c7f99};
	unsigned int received[8] = {0};
	int i;

	usb_init();						// initializing libusb
	usb_find_busses();					// ... finding busses
	usb_find_devices();					// ... and devices

	device = find_device();				// find the device (hopefully the correct one)

	if ( device == NULL ) {				// nothing found
		fprintf(stderr, "Cannot find ucecho device\n");
		return 1;
	}

	if (usb_claim_interface(handle, 0) < 0) {
		fprintf(stderr, "Error claiming interface 0: %s\n", usb_strerror());
		return 1;
	}

	//write mode
	i = usb_control_msg(handle, 0x40, 0x60, 0, 0, NULL, 0, 1000);
	if ( i < 0 ) {
		fprintf(stderr, "Error sending data: %s\n", usb_strerror());
		return 1;
	}
	
	printf("Write S[0] to FPGA: \n");
	for(i = 0; i < 8; i++)
		printf("S[0][%d] = 0x%08x\n", i, sent[i]);
			
	// write string to ucecho device 
	i = usb_bulk_write(handle, 6, (const char *)(sent), sizeof(unsigned int) * 8, 1000);
	if (i < 0) {
		fprintf(stderr, "Error sending data: %s\n", usb_strerror());
		return 1;
	}
	
	//read mode
	i = usb_control_msg(handle, 0x40, 0x60, 1, 0, NULL, 0, 1000);
	if (i < 0) {
		fprintf(stderr, "Error sending data: %s\n", usb_strerror());
		return 1;
	}
	
	printf("Read S[0] from FPGA: \n");
 
	// read string back from ucecho device 
	i = usb_bulk_read(handle, 2, (char *)(received), 512, 1000);
	if (i < 0) {
		fprintf(stderr, "Error readin data: %s\n", usb_strerror());
		return 1;
	}
	
	for(i = 0; i < 8; i++)
		printf("S[0][%d] = 0x%08x\n", i, received[i]);
 
	usb_release_interface(handle, 0);
	usb_close(handle);
	return 0;
}
