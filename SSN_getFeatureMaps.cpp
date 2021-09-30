#include "mex.h"
#include <math.h>
#include <vector>
using std::vector;


int getNumConnections(int radius){
   int max_conns[] = {1, 5, 8, 16, 20,32,32,36,48,56,64,60,64};
   return (max_conns[radius] + 1) >> 1;
}

void getMaskCoors(int radius, int *coor_h, int *coor_w, double *coor_rad){
    int radius2 = radius * radius, cont = 0;
    double radius_previous = (radius-1) * (radius-1);
    if(radius_previous==0) radius_previous=-1;
    for (int hh = -radius ; hh <= radius ; ++hh){
        for (int ww = -radius; ww <= radius; ++ ww){
            double r = hh * hh + ww * ww;
            if (r <= radius2 && r > radius_previous){
                if ( ww > 0 || ( ww == 0 && hh >= 0 ) ){
                    coor_rad[cont] = r;
                    coor_h[cont] = hh;
                    coor_w[cont++] = ww;
                }
            }
        }
    }
    return;
}

void mexFunction(
	int nlhs,
	mxArray *plhs[],
	int nrhs,
	const mxArray *prhs[]
	)
{	
	if (nrhs != 3) {
		mexErrMsgTxt("Input arguments: image (3d matrix wXhXz), radius and maximum pixel value (L).");
	}
	else if (nlhs != 3) {
		mexErrMsgTxt("outputs 3 numeric matrices 4x(w*h*z): measures (k and str) for FULL, WITHIN and BETWEEN network connections");
	}

    int w, h, z, np;	  
    double *im;
    int radius, L;
	const long unsigned int *dimensions = mxGetDimensions(prhs[0]); //Qtde de dimensoes da img, deve ser 3.    
    im = mxGetPr(prhs[0]);
    radius = mxGetScalar(prhs[1]);  
    L = mxGetScalar(prhs[2]);
    w = dimensions[0];
    h = dimensions[1];
    z = dimensions[2];
    
    np = w*h*z;
    
    mxArray *Data = mxCreateNumericArray(3, dimensions, mxDOUBLE_CLASS, mxREAL);
    double *img = (double *) mxGetPr(Data);
      
    for(int k=0; k<z; k++){
        for(int i=0; i<w; i++){
            for(int j=0; j<h; j++){                         
                img[((w*h*k) + ((i*h) + j))] = *(im + w*h*k + j*w + i);
            }
        }
    }    
     
	plhs[0] = mxCreateDoubleMatrix(4, np, mxREAL);//ALL    
	plhs[1] = mxCreateDoubleMatrix(4, np, mxREAL);//WITHIN	    
	plhs[2] = mxCreateDoubleMatrix(4, np, mxREAL);//BETWEEN	
        
	double *saida1= mxGetPr(plhs[0]);
	double *saida2= mxGetPr(plhs[1]);
	double *saida3= mxGetPr(plhs[2]);     
   
    for (int row = 0; row < 4; row++) {
		for (int col = 0; col < np; col++) {
			saida1[4 * col + row] = 0;
            saida2[4 * col + row] = 0;
            saida3[4 * col + row] = 0;
		}
	}
    
    double radius2 = radius * radius;    
    int num_conns = getNumConnections(radius);
    int *coor_h = new int[num_conns];
    int *coor_w = new int[num_conns];
    double *coor_rad = new double[num_conns];
    
    getMaskCoors( radius, coor_h, coor_w, coor_rad);
    
	int x1=0, x2=0, x1pos=0, x2pos=0, diff=0;
    double edge=0, d=0, difference=0;
    for (int x = 0; x < w; ++x) {
        for (int c_id = 0; c_id < num_conns; ++c_id){
            int i = x + coor_w[c_id];
            if ( i < 0 || i >= w ) continue;
            for (int y = 0; y < h; ++y){
                int j = y + coor_h[c_id];                
                if ( j < 0 || j >= h  ) continue;
                double d = coor_rad[c_id];
                for (int c = 0; c < z; ++c){ //montando a rede... cada c, � um v�rtice(pixel com uma intensidade R, G ou B, ou seja cada pixel vai ser 3 vertices)

                    x1 = ((c*w*h) + ((x*h) + y));
                    x1pos = x1*4;
           
                    for (int cw = 0; cw < z; ++cw){
                        if(i != x || j != y || c != cw){
                            x2 = ((cw*w*h) + ((i*h) + j));                       
                            x2pos = x2*4;
                            diff = (img[x1] - img[x2]);
                            difference = diff;

                            if(difference < 0){
                                difference = difference*(-1);
                            }                      
                            edge = ((difference +1)*(d+1) -1)/((L+1) * (radius2+1) -1); //Nova equacao
                            if(diff > 0){//defining the direction of the connection (x2 points to x1)                                
                                saida1[x1pos] ++;
                                saida1[x1pos + 2] +=edge;
                                if(x!=i || y!=j){//when not connecting x1 to itself in another channel
                                    saida1[x2pos + 1] ++;
                                    saida1[x2pos + 3] +=edge; 
                                }                                
                                if(c==cw){//checks the vertex channel, c==cw means whithin connections                                   
                                    saida2[x1pos] ++;
                                    saida2[x1pos + 2] +=edge; 

                                    saida2[x2pos + 1] ++;
                                    saida2[x2pos + 3] +=edge;
                                }else{//otherwise, between connections
                                    saida3[x1pos] ++;
                                    saida3[x1pos + 2] +=edge;
                                    if(x!=i || y!=j){ 
                                        saida3[x2pos + 1] ++;
                                        saida3[x2pos + 3] +=edge; 
                                    }                                     
                                }                                                           
                            }else if(diff < 0){  //defining the direction of the connection (x1 points to x2)                                     
                                saida1[x1pos + 1] ++;
                                saida1[x1pos + 3] +=edge; 
                                if(x!=i || y!=j){                                                    
                                    saida1[x2pos] ++; 
                                    saida1[x2pos + 2] +=edge; 
                                }
                                if(c==cw){//checks the vertex channel, c==cw means whithin connections                                   
                                     saida2[x1pos + 1] ++;
                                     saida2[x1pos + 3] +=edge;

                                     saida2[x2pos] ++;    
                                     saida2[x2pos + 2] +=edge;
                                }else{//otherwise, between connections
                                    saida3[x1pos + 1] ++;
                                    saida3[x1pos + 3] +=edge;
                                    if(x!=i || y!=j){
                                        saida3[x2pos] ++; 
                                        saida3[x2pos + 2] +=edge; 
                                    }                                     
                                }   
                            }else{//quando os pixels tem a msm intensidade, aresta bidirecional
                                saida1[x1pos] ++;
                                saida1[x1pos + 2] +=edge;
                                saida1[x1pos + 1] ++;
                                saida1[x1pos + 3] +=edge; 
                                if(x!=i || y!=j){                                                    
                                    saida1[x2pos] ++; 
                                    saida1[x2pos + 2] +=edge; 
                                    saida1[x2pos + 1] ++; 
                                    saida1[x2pos + 3] +=edge; 
                                }
                                if(c==cw){//checks the vertex channel, c==cw means whithin connections                                   
                                     saida2[x1pos + 1] ++;
                                     saida2[x1pos + 3] +=edge;
                                     saida2[x1pos] ++;
                                     saida2[x1pos + 2] +=edge;

                                     saida2[x2pos] ++;    
                                     saida2[x2pos + 2] +=edge;
                                     saida2[x2pos + 1] ++;    
                                     saida2[x2pos + 3] +=edge;
                                }else{//otherwise, between connections
                                    saida3[x1pos + 1] ++;
                                    saida3[x1pos + 3] +=edge;
                                    saida3[x1pos] ++;
                                    saida3[x1pos + 2] +=edge;
                                    if(x!=i || y!=j){
                                        saida3[x2pos] ++; 
                                        saida3[x2pos + 2] +=edge;
                                        saida3[x2pos + 1] ++; 
                                        saida3[x2pos + 3] +=edge; 
                                    }                                     
                                }                                 
                            }
                        } 
                    }
                }
            }
        }
    }
}
