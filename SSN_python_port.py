# -*- coding: utf-8 -*-
"""
Testing SSN python version

@author: scabini
"""

import numpy
import time
import numba

@numba.jit(nopython=True)
def getNumConnections(radius):
   max_conns = [1, 5, 8, 16, 20,32,32,36,48,56,64,60,64]
   max_conns = max_conns[int(radius)]
   return (max_conns + 1) >> 1

@numba.jit(nopython=True)
def getMaskCoors(radius, coor_h, coor_w, coor_rad):
    radius2 = radius * radius
    cont = 0
    radius_previous = (radius-1) * (radius-1)
    
    if(radius_previous==0):
        radius_previous=-1
    
    for hh in range(-radius, radius+1):
        for ww in range(-radius, radius+1):
            r = hh * hh + ww * ww
            if (r <= radius2 and r > radius_previous):
                if ( ww > 0 or ( ww == 0 and hh >= 0 ) ):
                    coor_rad[cont] = r
                    coor_h[cont] = hh
                    coor_w[cont] = ww
                    cont+=1

#SSN_getFeatureMaps(double(image), rset(r), double(L));  
@numba.jit(nopython=True)
def SSN(im, radius, L):
      
    [w,h,z] = im.shape
    np = w*h*z
    saida1 = numpy.zeros((4*np))
    saida2 = numpy.zeros((4*np))
    saida3 = numpy.zeros((4*np))
     
    img = im.reshape((np))
    
    radius2 = radius * radius;
    num_conns = getNumConnections(radius);
    
    coor_h = numpy.zeros((num_conns))
    coor_w = numpy.zeros((num_conns))
    coor_rad = numpy.zeros((num_conns))
    
    getMaskCoors(radius, coor_h, coor_w, coor_rad)
    
    x1=0
    x2=0    
    x1pos=0
    x2pos=0    
    diff=0    
    edge=0
    d=0
    difference=0
    
    for x in range(0,w): #(int x = 0; x < w; ++x) {
        for c_id in range(0,num_conns):#(int c_id = 0; c_id < num_conns; ++c_id){
            i = x + coor_w[c_id]
            if ( i < 0 or i >= w ):
                continue
            for y in range(0, h): #(int y = 0; y < h; ++y){
                j = y + coor_h[c_id]                
                if ( j < 0 or j >= h  ):
                    continue
                d = coor_rad[c_id];
                for c in range(0,z):#(int c = 0; c < z; ++c){
                    x1 = int((c*w*h) + ((x*h) + y))
                    x1pos = x1*4
           
                    for cw in range(0,z):#(int cw = 0; cw < z; ++cw){
                        if(i != x or j != y or c != cw):
                            x2 = int((cw*w*h) + ((i*h) + j));                       
                            x2pos = x2*4;
                            diff = (img[x1] - img[x2]);
                            difference = diff;

                            if(difference < 0):
                                difference = difference*(-1);
                                                 
                            edge = ((difference +1)*(d+1) -1)/((L+1) * (radius2+1) -1);
                            if(diff > 0):                            
                                saida1[x1pos]+=1
                                saida1[x1pos + 2] +=edge;
                                if(x!=i or y!=j):
                                    saida1[x2pos + 1] +=1
                                    saida1[x2pos + 3] +=edge; 
                                                              
                                if(c==cw):                              
                                    saida2[x1pos] +=1
                                    saida2[x1pos + 2] +=edge; 

                                    saida2[x2pos + 1] +=1
                                    saida2[x2pos + 3] +=edge;
                                else:
                                    saida3[x1pos] +=1
                                    saida3[x1pos + 2] +=edge;
                                    if(x!=i or y!=j): 
                                        saida3[x2pos + 1] +=1
                                        saida3[x2pos + 3] +=edge; 
                                                                                       
                            elif(diff < 0):                                  
                                saida1[x1pos + 1] +=1
                                saida1[x1pos + 3] +=edge; 
                                if(x!=i or y!=j):                                                   
                                    saida1[x2pos] +=1 
                                    saida1[x2pos + 2] +=edge; 
                                
                                if(c==cw):                             
                                     saida2[x1pos + 1] +=1
                                     saida2[x1pos + 3] +=edge;
                                     saida2[x2pos] +=1    
                                     saida2[x2pos + 2] +=edge;
                                     
                                else:
                                    saida3[x1pos + 1] +=1
                                    saida3[x1pos + 3] +=edge;
                                    if(x!=i or y!=j):
                                        saida3[x2pos] +=1 
                                        saida3[x2pos + 2] +=edge; 
                            
                            else:
                                saida1[x1pos] +=1
                                saida1[x1pos + 2] +=edge;
                                saida1[x1pos + 1] +=1
                                saida1[x1pos + 3] +=edge; 
                                if(x!=i or y!=j):                                                    
                                    saida1[x2pos] +=1 
                                    saida1[x2pos + 2] +=edge; 
                                    saida1[x2pos + 1] +=1 
                                    saida1[x2pos + 3] +=edge; 
                                
                                if(c==cw):                               
                                     saida2[x1pos + 1] +=1
                                     saida2[x1pos + 3] +=edge;
                                     saida2[x1pos] +=1
                                     saida2[x1pos + 2] +=edge;

                                     saida2[x2pos] +=1    
                                     saida2[x2pos + 2] +=edge;
                                     saida2[x2pos + 1] +=1    
                                     saida2[x2pos + 3] +=edge;
                                else:
                                    saida3[x1pos + 1] +=1
                                    saida3[x1pos + 3] +=edge;
                                    saida3[x1pos] +=1
                                    saida3[x1pos + 2] +=edge;
                                    if(x!=i or y!=j):
                                        saida3[x2pos] +=1 
                                        saida3[x2pos + 2] +=edge;
                                        saida3[x2pos + 1] +=1 
                                        saida3[x2pos + 3] +=edge; 
                                      
    return saida1.reshape((4,w,h,z)), saida2.reshape((4,w,h,z)), saida3.reshape((4,w,h,z))

image = numpy.zeros((128,128,3))
start_time = time.time()
saida1, saida2, saida3 = SSN(im=image, radius=4, L=255)
print('Spent', numpy.round(time.time() - start_time, decimals=3), 'seconds')






