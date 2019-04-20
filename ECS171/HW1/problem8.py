#!/usr/bin/python
import numpy as np
from problem1 import DataPre
from problem5 import Linear_Solver_MultiVari
"""
This file is to calculate the vechile's MPG based on the solver in problem5.
All the assumption are defined in the homework PDF. 
We use the assumption directly.
"""
# data preparing
datapre = DataPre()
(low, medium, high, data_all) = datapre.splitGroup()
data_all = np.asmatrix(data_all)

# initialize the multi-variable solver
sol = Linear_Solver_MultiVari()

# use all the 392 groups of data to train the solver
(train_x, train_y) = (data_all[:, 1:8], data_all[:, 0])

# use solver to get the wieght
w = sol.solver(2, train_x, train_y)

# we use order 2
order = 2
(c, r) = data_all.shape
x = np.ones((1, 1))
x_o = np.ones((1, 1))

# use the data given in the problem 7
# 'cylinders', 'displacement', 'horsepower', 'weight', 'acceleration', 'year', 'origin'
new_car = np.array([0, 0, 1.3, 1800, 2, 80, 1])
for i in range(order):
    x_o = np.multiply(x_o, new_car)
    x = np.column_stack((x, x_o))

# get the predicted MPG
predicted_mpg = np.matmul(x, w)
print(predicted_mpg)
