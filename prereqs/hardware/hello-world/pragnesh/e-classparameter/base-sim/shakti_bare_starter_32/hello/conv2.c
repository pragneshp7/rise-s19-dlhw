#include <stdio.h>
int main()
{
    int array[16][16];
    int weight[4][4];
    int con[13][13];
    int cnt = 0;

    //initialising arrays

    	for(int i=0; i <16; i=i+1){
        	for(int k=0; k<16;k=k+1){
            		array[i][k] = k+1;
                    cnt++;
                    printf("x input\n %x", cnt);
        	}
    	}

     	for(int i=0; i <13; i=i+1){
        	for(int k=0; k<13;k=k+1){
            		con[i][k] = 0;
                    printf("y output\n");
        	}
    	}   

	for(int i=0; i <4; i=i+1){
		for(int k=0; k<4;k=k+1){
			weight[i][k] = 1;
            printf("w input\n");
        	}
    	}
    
    //
    
	for(int i = 0; i<13;i=i+1){
		for(int j=0; j<13;j=j+1){

	            	con[j][i]= array[j][i]*weight[0][0] + con[j][i];
			con[j][i]= array[j][i+1]*weight[0][1] + con[j][i];
        		con[j][i]= array[j][i+2]*weight[0][2] + con[j][i];
       			con[j][i]= array[j][i+3]*weight[0][3] + con[j][i];



	            	con[j][i]= array[j+1][i]*weight[1][0] + con[j][i];
			con[j][i]= array[j+1][i+1]*weight[1][1] + con[j][i];
        		con[j][i]= array[j+1][i+2]*weight[1][2] + con[j][i];
       			con[j][i]= array[j+1][i+3]*weight[1][3] + con[j][i];


	            	con[j][i]= array[j+2][i]*weight[2][0] + con[j][i];
			con[j][i]= array[j+2][i+1]*weight[2][1] + con[j][i];
        		con[j][i]= array[j+2][i+2]*weight[2][2] + con[j][i];
       			con[j][i]= array[j+2][i+3]*weight[2][3] + con[j][i];

	            	con[j][i]= array[j+3][i]*weight[3][0] + con[j][i];
			con[j][i]= array[j+3][i+1]*weight[3][1] + con[j][i];
        		con[j][i]= array[j+3][i+2]*weight[3][2] + con[j][i];
       			con[j][i]= array[j+3][i+3]*weight[3][3] + con[j][i];
                printf("conv cycle done\n");
        	}
    	}

	printf("The output array is \n");

	for(int i = 0; i<13;i=i+1){
		for(int j=0; j<13;j=j+1){
			printf("%d ",con[j][i]);
		}
		printf("\n");
	}




    return 0;
}
