#!/bin/bash

printf "Secuencial\n\n" >> resultados.txt &&
cd Secuencial/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg &&
cd ../reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg &&
cd ../reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
printf "Pthreads\n\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg 16 &&
./reduccion4k 4k.jpg result.jpg 8 && ./reduccion4k 4k.jpg result.jpg 4 && 
./reduccion4k 4k.jpg result.jpg 2 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg 2 &&
./reduccion1080 1080.jpg result.jpg 4 && ./reduccion1080 1080.jpg result.jpg 8 && 
./reduccion1080 1080.jpg result.jpg 16 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd Pthreads/ && cd reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg 2 &&
./reduccion720 720.jpg result.jpg 4 && ./reduccion720 720.jpg result.jpg 8 && 
./reduccion720 720.jpg result.jpg 16 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
printf "OpenMP\n\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion4k/ && cmake . && make && ./reduccion4k 4k.jpg result.jpg 2 &&
./reduccion4k 4k.jpg result.jpg 4 && ./reduccion4k 4k.jpg result.jpg 8 && 
./reduccion4k 4k.jpg result.jpg 16 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion1080/ && cmake . && make && ./reduccion1080 1080.jpg result.jpg 2 &&
./reduccion1080 1080.jpg result.jpg 4 && ./reduccion1080 1080.jpg result.jpg 8 && 
./reduccion1080 1080.jpg result.jpg 16 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
cd OpenMP/ && cd reduccion720/ && cmake . && make && ./reduccion720 720.jpg result.jpg 2 &&
./reduccion720 720.jpg result.jpg 4 && ./reduccion720 720.jpg result.jpg 8 && 
./reduccion720 720.jpg result.jpg 16 &&
cd .. && cd .. &&
printf "\n" >> resultados.txt &&
printf "Succesfully finished!" >> resultados.txt



