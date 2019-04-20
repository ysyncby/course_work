#!/usr/bin/python
import matplotlib.pyplot as plt
import numpy as np
from problem1 import DataPre

"""
this python file is to plot the scatter matrix figure and help us to understand the interconnection of these data. 
"""
datapre = DataPre()
(low, medium, high, data_all) = datapre.splitGroup()

axes = ['mpg', 'cylinders', 'displacement', 'horsepower', 'weight', 'acceleration', 'year', 'origin']

for i, axe in enumerate(axes):

    for j in range(0,8):

        plt.subplot(8,8,i*8+j+1)
        #
        plt.yticks([])
        if i == j:
            plt.hist(np.concatenate((low[:, i], medium[:, i], high[:, i])), alpha=0.8)
        else:
            plt.scatter(low[:,j], low[:,i],alpha=0.8, c='red', edgecolors='none', s=30, label='low', marker='+')
            plt.scatter(medium[:,j], medium[:,i],alpha=0.8, c='green', edgecolors='none', s=30, label='medium', marker='x')
            plt.scatter(high[:,j], high[:,i],alpha=0.8, c='blue', edgecolors='none', s=30, label='high', marker='o')
        if i == 0 and j == 7:
            plt.legend(loc = 1)
        if j == 0:
            plt.ylabel(axe, fontsize=7, fontweight='bold')
        if i == 7:
            plt.xlabel(axes[j], fontsize=7, fontweight='bold')
        else:
            plt.xticks([])

plt.show()