import numpy as np
from sklearn import linear_model
from problem1 import DataPre
from problem4 import Single_Vari_Eval
from sklearn.preprocessing import StandardScaler

class Logi_Regre(object):
    """
    this class is to train logistic regression solver and evaluate it
    """
    def train_solver(self, x, y):
        """
        training function
        :param x: training_X
        :param y: training_Y
        :return: the solver
        """
        sc = StandardScaler()
        sc.fit(X_train)
        X_train_std = sc.transform(x)
        self.logreg = linear_model.LogisticRegression(C=1e5, random_state=0, solver='lbfgs')
        self.logreg.fit(X_train_std, y)

    def predict(self, x):
        """
        the predictor
        :param x: the input_X
        :return: the class name of input_X
        """
        sc = StandardScaler()
        sc.fit(X_train)
        X_pred_std = sc.transform(x)
        pred = self.logreg.predict(X_pred_std)
        return pred

    def cal_precision(self, pred, real):
        """
        the precision calculator
        :param pred: predicted class name
        :param real: expected class name
        :return: the precision of this prediction
        """
        real = np.asarray(real.flatten())[0]
        err = 0
        for i in range(len(pred)):
            if pred[i] != real[i]:
                err += 1
        return 1-err/len(pred)


"""
Test Case
"""
# # data prepare: modified the first row and randomly split them into training and testing set
# datapre = DataPre()
# (low, medium, high, data_all) = datapre.splitGroup()
# data_all = np.asmatrix(data_all)
#
# # modified the first row
# """
# 0: low MPG
# 1: medium MPG
# 2: high MPG
# """
# d = np.where(data_all[:,0]>26.8, 2, data_all[:,0])
# d = np.where(d>18.6, 1, d)
# d = np.where(d>2, 0, d)
# data_all = np.column_stack((d, data_all[:, 1:8]))
#
# # split into training and testing set
# sve = Single_Vari_Eval()
# (train, test) = sve.spilit_train_test(data_all)
# (X_train, X_test, Y_train, Y_test) = (train[:,1:8], test[:, 1:8], train[:, 0], test[:, 0])
#
# # initilize the solver
# lr = Logi_Regre()
# # train solver
# lr.train_solver(X_train, Y_train)
# # make a prediction
# pred_train = lr.predict(X_train)
# pred_test = lr.predict(X_test)
#
# # calculate precision
# # the error of the training set
# err_train = lr.cal_precision(pred_train, Y_train)
# # the error of the testing set
# err_test = lr.cal_precision(pred_test, Y_test)
# print("error of train:", err_train)
# print("error of test:", err_test)


