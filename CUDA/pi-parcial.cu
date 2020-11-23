#@title CODIGO DEL PARCIAL
%%cu
/****** codigo para calcular PI*******/
#include <stdio.h>
#include <cuda.h>
#include <sys/time.h>

#define ITERACIONES  2e09  
#define NUMERO_BLOQUES 8
#define NUMERO_HILOS 1032
int id_hilo;
double pi = 0;

__global__ void calcular_pi(double *suma, int numero_iteraciones, double paso, int numero_hilos, int numero_bloques) {
	int i;
	double x;
	int index = blockIdx.x*blockDim.x+threadIdx.x;
	for (i=index; i< numero_iteraciones; i+=numero_hilos*numero_bloques) {
		x = (i+0.5)*paso;
		suma[index] += 4.0/(1.0+x*x);
	}
}

int main(void) {
    
    struct timeval tval_before, tval_after, tval_result;
    gettimeofday(&tval_before, NULL); 

	dim3 dimGrid(NUMERO_BLOQUES,1,1); 
	dim3 dimBlock(NUMERO_HILOS,1,1);
	double *sumaHost, *sumaDispositivo;
	double paso = 1.0/ITERACIONES;
	size_t size = NUMERO_BLOQUES*NUMERO_HILOS*sizeof(double);
    
    sumaHost = (double *)malloc(size); 
	cudaMalloc((void **) &sumaDispositivo, size);
	cudaMemset(sumaDispositivo, 0, size);
    
    calcular_pi <<<dimGrid, dimBlock>>> (sumaDispositivo, ITERACIONES, paso, NUMERO_HILOS, NUMERO_BLOQUES);
	
	cudaMemcpy(sumaHost, sumaDispositivo, size, cudaMemcpyDeviceToHost);
	for(id_hilo=0; id_hilo<NUMERO_HILOS*NUMERO_BLOQUES; id_hilo++)
		pi += sumaHost[id_hilo];
	pi *= paso;

    gettimeofday(&tval_after, NULL);
    timersub(&tval_after, &tval_before, &tval_result);

    printf("Tiempo transcurrido: %ld.%06ld segundos\n", (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);

	printf("PI = %lf\n",pi);

	free(sumaHost); 
	cudaFree(sumaDispositivo);

	return 0;
}