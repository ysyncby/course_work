#!/usr/bin/python
import numpy as np
from problem1 import DataPre
from problem5 import Linear_Solver_MultiVari
from problem6 import Logi_Regre
"""
This file is to calculate the car's potential MPG and try to classify its class.
First, prepare the training data for solvers. Use all 392 data as training data.
Second, predict its MPG based on solver in problem5.
Finally, predict its class based on solver in problem6. 
"""
# data preparing
datapre = DataPre()
(low, medium, high, data_all) = datapre.splitGroup()
data_all = np.asmatrix(data_all)

# initialize the multi-variable solver
sol = Linear_Solver_MultiVari()

# use all the 392 groups of data to train the solver
(train_x, train_y) = (data_all[:, 1:8], data_all[:, 0])
"""
use linear regression to predict the MPG
"""
# use solver to get the wieght
w = sol.solver(2, train_x, train_y)

# we use order 2
order = 2
(c, r) = data_all.shape
x = np.ones((1, 1))
x_o = np.ones((1, 1))

# use the data given in the problem 7
# 'cylinders', 'displacement', 'horsepower', 'weight', 'acceleration', 'year', 'origin'
new_car = np.array([6, 350, 180, 3700, 9, 80, 1])
for i in range(order):
    x_o = np.multiply(x_o, new_car)
    x = np.column_stack((x, x_o))

# get the predicted MPG
predicted_mpg = np.matmul(x, w)
print(predicted_mpg)

"""
use the logistic regression to classify this car
"""
# initilize the solver
lr = Logi_Regre()
# train solver
d = np.where(train_y>26.8, 2, train_y)
d = np.where(d>18.6, 1, d)
d = np.where(d>2, 0, d)

lr.train_solver(train_x, d)
# make a prediction
print(np.asmatrix(new_car))
pred_test = lr.predict(np.asmatrix(new_car))

print(pred_test)