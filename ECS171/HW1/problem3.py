#!/usr/bin/python
import numpy as np
from problem1 import DataPre
import copy

class Linear_Solver(object):
    """
    args:
        data: the whole data contains independent and dependent variables
        order: the order of polynomial
        indeCol: the column number of independent variable
        depCol: the column number of dependent variable

    output:
        w: weight matrix
    """
    def _mutli(self, a, b):
        c = np.matmul(a, b)
        return c

    def solver(self, data, order, indeCol, depCol):
        (c, r) = data.shape
        x   = np.ones((c, 1))
        x_o = np.ones((c, 1))
        for o in range(order):
            x_o = np.multiply(x_o, data[:, indeCol])
            x = np.column_stack((x,copy.deepcopy(x_o)))

        left = self._mutli(x.T, x)
        righ = self._mutli(x.T, data[:, depCol])
        w = self._mutli(np.asmatrix(left).I, righ)
        return w


"""
test case
"""
# datapre = DataPre()
# (low, medium, high, data_all) = datapre.splitGroup()
# data_all = np.asmatrix(data_all)
# sol = Linear_Solver()
# print(sol.solver(data_all, 1, 2, 0).shape)
# print(sol.solver(data_all, 1, 2, 0))
# (c,r) = sol.solver(data_all, 1, 2, 0).shape
# print(r)