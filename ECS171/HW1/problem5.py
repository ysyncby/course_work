#!/usr/bin/python
import numpy as np
from problem1 import DataPre
from problem4 import Single_Vari_Eval
import copy

class Linear_Solver_MultiVari(object):
    """
    args:
    order: the order of polynomial
    indeCol: the column number of independent variable
    depCol: the column number of dependent variable

    output:
    w: weight matrix
    """
    def _mutli(self, a, b):
        c = np.matmul(a, b)
        return c

    def solver(self, order, inde, dep):
        (c, r) = inde.shape
        x   = np.ones((c, 1))
        x_o = np.ones((c, 1))
        for o in range(order):
            x_o = np.multiply(x_o, inde)
            x = np.column_stack((x,copy.deepcopy(x_o)))

        left = self._mutli(x.T, x)
        righ = self._mutli(x.T, dep)
        w = self._mutli(np.asmatrix(left).I, righ)
        return w

    def eval(self, input, output, w):
        order = int((len(w)-1)/7)
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
Calculate all the MSE.
"""
# datapre = DataPre()
# (low, medium, high, data_all) = datapre.splitGroup()
# data_all = np.asmatrix(data_all)
#
# sve = Single_Vari_Eval()
# (train, test) = sve.spilit_train_test(data_all)
#
# sol = Linear_Solver_MultiVari()
# for i in range(3):
#     print('order:', i)
#     w = sol.solver(i, train[:, 1:8], train[:, 0])
#
#     mse_train = sol.eval(train[:, 1:8], train[:, 0], w)
#     mse_test = sol.eval(test[:, 1:8], test[:, 0], w)
#     print(mse_train)
#     print(mse_test)
