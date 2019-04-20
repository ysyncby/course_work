#!/usr/bin/python
import numpy as np
from problem1 import DataPre
from problem3 import Linear_Solver
import matplotlib.pyplot as plt


class Single_Vari_Eval(object):
    """
    This clase is to evaluate the weight generated in the solver(problem2).
    """
    def __init__(self):
        pass

    def spilit_train_test(self, data):
        """
        split data into training and testing sets
        """
        np.random.shuffle(data)
        train = data[0:200, :]
        test = data[200:, :]
        return train, test

    def mse(self, input, output, w):
        """
        :param input: the train_X
        :param output: the train_Y
        :param w: the weight we got from the solver(problem)
        :return: MSE of the weight
        """
        order = len(w) - 1
        (c, r) = input.shape
        x   = np.ones((c, 1))
        x_o = np.ones((c, 1))

        for i in range(order):
            x_o = np.multiply(x_o, input)
            x = np.column_stack((x,x_o))

        pred = np.matmul(x, w)
        mse = np.matmul((pred-output).T, (pred-output))/len(pred)

        return mse

"""
test case
In the first part, we calculate all the MSE.
In the second part, we draw 7 figures.
"""
"""
First Part
"""
# datapre = DataPre()
# (low, medium, high, data_all) = datapre.splitGroup()
# data_all = np.asmatrix(data_all)
#
# sve = Single_Vari_Eval()
# (train, test) = sve.spilit_train_test(data_all)
#
# sol = Linear_Solver()
# w_all= []
# for o in range(4):
#     w_ord = []
#     for i in range(1,8):
#
#         w = sol.solver(train, o, i, 0)
#
#         mse_train = sve.mse(train[:, i], train[:, 0], w)
#         mse_test = sve.mse(test[:, i], test[:, 0], w)
#         print(mse_train, mse_test)
#         w_ord.append(w)
#     w_all.append(w_ord)
#
# """
# Second Part
# """
# axes = ['cylinders', 'displacement', 'horsepower', 'weight', 'acceleration', 'year', 'origin']
# label = ['0th', '1st', '2nd', '3rd']
# for i in range(7):
#     for j in range(4):
#         w = np.asarray(w_all[j][i].flatten())[0][::-1]
#         func = np.poly1d(w)
#         x = np.asarray(data_all[:,i+1].flatten())[0]
#         x.sort()
#         y = func(x.T)
#         plt.plot(x,y, label = label[j])
#         plt.xlabel(axes[i])
#         plt.ylabel('MPG')
#     input = np.asarray(data_all[:, i+1].flatten())[0]
#     output = np.asarray(data_all[:, 0].flatten())[0]
#     plt.scatter(input, output ,alpha=0.8, c='blue', edgecolors='none', s=30, label='data', marker='+')
#     plt.legend()
#     plt.show()

