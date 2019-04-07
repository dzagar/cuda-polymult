CS 4402 Distributed and Parallel Systems

Assignment 2: CUDA Implementation of Univariate Polynomial Multiplication
Dana Zagar | 250790176
April 7 2019

--

Question 1: CUDA Program with n Thread-Blocks and n Threads
To compile:

nvcc dzagar_CS4402_a2q1 -o dzagar_CS4402_a2q1

To run:

./dzagar_CS4402_a2q1

To test:

Inputs to test: exponent = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

Note: will not work past exponent = 10 on GPU1,GPU2 due to space constraints.

--

Question 2: Modified CUDA Program with n^2/t Thread-Blocks and t Threads
To compile:
nvcc dzagar_CS4402_a2q2 -o dzagar_CS4402_a2q2

To run:

./dzagar_CS4402_a2q2 

To test:

Inputs to test: [exponent = 10, t = 64], [exponent = 10, t = 512], [exponent = 8, t = 128], [exponent = 9, t = 512]

Note: will not work past exponent = 10 on GPU1,GPU2 due to space constraints.
Note: tested case when t > n and it does not work. However, n >= t cases pass.

