#include <stdio.h>
#include <stdint.h>
#include "csr.h"
#include "machine.h"
#include "trap.h"
#include "encoding.h"

int main(int argc, char** argv) {
   

long time1 = rdtime();
printf(" time = %d\n", time1);
//printf("hello world\n");

uint64_t *wreg = 0x12300;
uint64_t *xreg = 0x12308;
uint64_t *yout = 0x12310;
uint64_t *status = 0x12318;
uint64_t i;
*status = 0x01;
//first 13x4 conv
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
*status = 0x02;
for (i=0; i<16; i++)
{
    *wreg = 0x01;
}
*status = 0x04;
*status = 0x08;
/*for (i=0; i<50; i++)
{
}*/
*status = 0x10;
*status = 0x20;
for (i=0; i<52; i++)
{
    uint64_t x = *yout;
    printf(" %d: val read is %d\n", i,x);
}
//second 13x4 conv
*status = 0x80;

for (i=0; i<13; i++)
{
    printf(" reset cycle %d \n", i);
}

*status = 0x01;

for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
for (i=0; i<16; i++)
{
    *xreg = i+2;
}
*status = 0x02;
for (i=0; i<16; i++)
{
    *wreg = 0x01;
}
*status = 0x04;
*status = 0x08;
/*for (i=0; i<50; i++)
{
}*/
*status = 0x10;
*status = 0x20;
for (i=0; i<52; i++)
{
    uint64_t x = *yout;
    printf(" %d: val read is %d\n", i,x);
}

//third 13x4 conv
*status = 0x80;
for (i=0; i<13; i++)
{
    printf(" reset cycle %d \n", i);
}

*status = 0x01;

for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
for (i=0; i<16; i++)
{
    *xreg = i+3;
}
*status = 0x02;
for (i=0; i<16; i++)
{
    *wreg = 0x01;
}
*status = 0x04;
*status = 0x08;
/*for (i=0; i<50; i++)
{
}*/
*status = 0x10;
*status = 0x20;
for (i=0; i<52; i++)
{
    uint64_t x = *yout;
    printf(" %d: val read is %d\n", i,x);
}
//last 13x4 conv
*status = 0x80;
for (i=0; i<13; i++)
{
    printf(" reset cycle %d \n", i);
}

*status = 0x01;

for (i=0; i<64; i++)
{
    *xreg = 0x01;
}
for (i=0; i<48; i++)
{
    *xreg = 0x00;
}
*status = 0x02;
for (i=0; i<16; i++)
{
    *wreg = 0x08;
}
*status = 0x04;
*status = 0x08;
/*for (i=0; i<50; i++)
{
}*/
*status = 0x10;
*status = 0x20;
for (i=0; i<13; i++)
{
    uint64_t x = *yout;
    printf(" %d: val read is %d\n", i,x);
}
//new 13x4 conv
*status = 0x80;

for (i=0; i<13; i++)
{
    printf(" reset cycle %d \n", i);
}

*status = 0x01;

for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
for (i=0; i<16; i++)
{
    *xreg = i+1;
}
*status = 0x02;
for (i=0; i<16; i++)
{
    *wreg = 0x01;
}
*status = 0x04;
*status = 0x08;
/*for (i=0; i<50; i++)
{
}*/
*status = 0x10;
*status = 0x20;
for (i=0; i<52; i++)
{
    uint64_t x = *yout;
    printf(" %d: val read is %d\n", i,x);
}

/*
*base = 0x30;
*base = 0x55;
*base++;
*base++;
*base++;
*base =0x01;
*base--;
uint64_t x = *base;
printf("Val read is %x\n", x);
uint64_t y = *base;
printf("Val read is %x\n", y);
*base++;
*base =0x00;
*/

/* *base--;
uint64_t x = *base;
printf("Val read is %x\n", x);
*base++;
*base =0x01;
*base--;
uint64_t y = *base;
printf("Val read is %x\n", y); */
//*base++;
//*base = 0x40;
//uint64_t y = *base;
//printf("Val read is %x\n", y);

long time2 = rdtime();
printf(" time = %d\n", time2);
}
