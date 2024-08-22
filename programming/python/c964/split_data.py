import pandas as pd
from sklearn.model_selection import train_test_split
from matplotlib import pyplot
import numpy as np
import os

# Define the path to your data files as well as the file names
data_dir = r'e:\users\fmoore\documents\SpiderOak Hive\School\WGU\c964 - computer science capstone\data'
my_file_name = "USA Housing Dataset.csv"
other_file_name = "test_homes.csv"
data_file_name = my_file_name
data_file_input = os.path.join(data_dir,data_file_name)
data_file_train_x = os.path.join(data_dir,"data_file_rX.csv")
data_file_val_x = os.path.join(data_dir,"data_file_vX.csv")
data_file_test_x = os.path.join(data_dir,"data_file_tX.csv")
data_file_train_y = os.path.join(data_dir,"data_file_ry.csv")
data_file_val_y = os.path.join(data_dir,"data_file_vy.csv")
data_file_test_y = os.path.join(data_dir,"data_file_ty.csv")
columns_to_drop = []

# Load the dataset
df = pd.read_csv(data_file_input)

# Rename the columns to lower case and replace spaces with underscores
df.columns = df.columns.str.lower().str.replace(' ', '_')

# # Check the first few rows to confirm the changes
# print(df.head())

# Define your target variable and features
y = df['price']  # Dependant variable
x = df.drop('price', axis=1)  # Drop 'price' from the independent variables

# First, split the data into training (60%) and test + validation (40%)
X_train, X_test_val, y_train, y_test_val = train_test_split(
    x, y, test_size=0.4, random_state=42
)

# Then, split the test + validation set into the actual test set (50%) and validation set (50%)
X_test, X_val, y_test, y_val = train_test_split(
    X_test_val, y_test_val, test_size=0.5, random_state=42
)

# Save the datasets to CSV files
X_train.to_csv(data_file_train_x, index=False)
X_val.to_csv(data_file_val_x, index=False)
X_test.to_csv(data_file_test_x, index=False)
y_train.to_csv(data_file_train_y, index=False)
y_val.to_csv(data_file_val_y, index=False)
y_test.to_csv(data_file_test_y, index=False)

print(f'Training set: {len(X_train)} samples')
print(f'Validation set: {len(X_val)} samples')
print(f'Test set: {len(X_test)} samples')