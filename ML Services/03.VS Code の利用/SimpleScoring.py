from revoscalepy import rx_lin_mod, rx_dtree, rx_logit, rx_dforest
from revoscalepy import rx_serialize_model, rx_summary
from microsoftml import rx_fast_linear, rx_neural_network
from microsoftml import rx_predict
# from revoscalepy import rx_predict
import pandas as pd
import pyodbc
import os
import numpy as np

model_file = "rx_fast_linear"

conn_str = 'Driver=SQL Server;Server=<Server Name>;Database=MLDB;Uid=<User Name>;Pwd=<Password>;'
cnxn = pyodbc.connect(conn_str)
inputsql ='''
SELECT C1, C2 FROM (
VALUES
('A',1),('B',2),('C',3),('D',4),('E',5),('F',6),('G',7),('H',8),('I',9),('J',10),
('K',11),('L',12),('M',13),('N',14),('O',15),('P',16),('Q',17),('R',18),('S',19),('T',20),
('U',21),('V',22),('W',23),('X',24),('Y',25),('Z',26)
) AS T1(C1, C2)
'''
train_data = pd.read_sql(inputsql, cnxn)
train_data["C1"] = train_data["C1"].astype("category")
print(train_data["C1"] )

# model = rx_lin_mod("C2 ~ C1", data = train_data)
model = rx_fast_linear("C2 ~ C1", data = train_data, method = "regression")
print(rx_summary("C2 ~ C1", train_data))

trained_model = rx_serialize_model(model, realtime_scoring_only = True)
# Dump learned model to file
with open(r'c:\temp\trained_model_{0}.pickle'.format(model_file), mode='wb') as f:
    f.write(trained_model)


p_data = pd.DataFrame([0,5,10,99,4], columns=["C1"])
p_data["C1"] = train_data["C1"].astype("category")
print(p_data["C1"])

pred = rx_predict(model, data = p_data)
print(pred)
