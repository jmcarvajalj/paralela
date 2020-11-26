#!/bin/bash

#Secuencial
printf "Secuencial\n\n" >> resultados.txt &&
cd Secuencial/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg &&
cd ../reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg &&
cd ../reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&

#Pthreads
printf "Pthreads\n\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg 16 &&
./reduccion4k 4k.jpg result.jpg 8 && ./reduccion4k 4k.jpg result.jpg 4 && 
./reduccion4k 4k.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg 16 &&
./reduccion1080 1080.jpg result.jpg 8 && ./reduccion1080 1080.jpg result.jpg 4 && 
./reduccion1080 1080.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg 16 &&
./reduccion720 720.jpg result.jpg 8 && ./reduccion720 720.jpg result.jpg 4 && 
./reduccion720 720.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&

#OpenMP
printf "OpenMP\n\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg 16 &&
./reduccion4k 4k.jpg result.jpg 8 && ./reduccion4k 4k.jpg result.jpg 4 && 
./reduccion4k 4k.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg 16 &&
./reduccion1080 1080.jpg result.jpg 8 && ./reduccion1080 1080.jpg result.jpg 4 && 
./reduccion1080 1080.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg 16 &&
./reduccion720 720.jpg result.jpg 8 && ./reduccion720 720.jpg result.jpg 4 && 
./reduccion720 720.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&

#CUDA
printf "CUDA\n\n" >> resultados.txt &&
cd CUDA/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg 2 20 &&
./reduccion4k 4k.jpg result.jpg 4 20 && ./reduccion4k 4k.jpg result.jpg 8 20 && 
./reduccion4k 4k.jpg result.jpg 16 20 &&
cd .. && cd .. &&
printf "\n\n" >> resultados.txt &&
cd CUDA/ && cd reduccion4k/ &&
./reduccion4k 4k.jpg result.jpg 2 40 && ./reduccion4k 4k.jpg result.jpg 4 40 && 
./reduccion4k 4k.jpg result.jpg 8 40 && ./reduccion4k 4k.jpg result.jpg 16 40 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd CUDA/ && cd reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg 2 20 &&
./reduccion1080 1080.jpg result.jpg 4 20 && ./reduccion1080 1080.jpg result.jpg 8 20 && 
./reduccion1080 1080.jpg result.jpg 16 20 &&
cd .. && cd .. && 
printf "\n" >> resultados.txt &&
cd CUDA/ && cd reduccion4k/ &&
./reduccion1080 1080.jpg result.jpg 2 40 && ./reduccion1080 1080.jpg result.jpg 4 40 && 
./reduccion1080 1080.jpg result.jpg 8 40 && ./reduccion1080 1080.jpg result.jpg 16 40 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd CUDA/ && cd reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg 2 20 &&
./reduccion720 720.jpg result.jpg 4 20 && ./reduccion720 720.jpg result.jpg 8 20 && 
./reduccion720 720.jpg result.jpg 16 20 &&
cd .. && cd .. && 
printf "\n" >> resultados.txt &&
cd CUDA/ && cd reduccion720/ &&
./reduccion720 720.jpg result.jpg 2 40 && ./reduccion720 720.jpg result.jpg 4 40 && 
./reduccion720 720.jpg result.jpg 8 40 && ./reduccion720 720.jpg result.jpg 16 40 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&

printf "Succesfully finished!" >> resultados.txt