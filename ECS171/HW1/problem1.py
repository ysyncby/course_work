#!/usr/bin/python

import re
import numpy as np
class DataPre(object):
    """
    input: Read data file. This file has been removed the rows with "?".

    output:
        low: a mumpy array of low MPG group
        medium: a mumpy array of medium MPG group
        high: a mumpy array of low high group
        data_all: a mumpy array of all group
    """
    def __init__(self):
        datapath = '/home/ysyncby/courses/ECS171_Machine_Learning/HW1/dataset/auto-mpg_pure.data'

        # read file
        with open(datapath) as datafile:
            self.data = datafile.readlines()

    def splitGroup(self):
        # initial a numpy array to store all data
        mpg_all = []
        data_all = np.array([0,0,0,0,0,0,0,0])

        # add data to numpy array
        for l in self.data:
            line = []
            for ch in re.split(' |\t|\n', l):
                if ch != '':
                    try:
                        ch=float(ch)
                        line.append(ch)
                    except:
                        break


            mpg_all.append(line[0])
            data_all = np.row_stack([data_all, np.asarray(line)])

        # generate data and sort base on "mpg"
        data_all = data_all[1:,:]
        data_all = data_all[data_all[:,0].argsort()]
        # print(data_all)

        # calculate threshold
        bin_num = round(len(mpg_all)/3)
        # print('number of samples:', len(mpg_all))
        # print('number per bin:', bin_num)

        # split data into three categories
        low = data_all[0:bin_num]
        medium = data_all[bin_num:bin_num*2]
        high = data_all[bin_num*2-1:]

        return low, medium, high, data_all

"""
test case
"""
# datapre = DataPre()
# (low, medium, high, data_all) = datapre.splitGroup()
# print(low)
# print('****************************')
# print(medium)
# print('****************************')
# print(high)