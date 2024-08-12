import pandas as pd
from sklearn.model_selection import train_test_split
from matplotlib import pyplot
import numpy as np
import os

# Define the path to your data files as well as the file names
data_dir = r'e:\users\fmoore\documents\SpiderOak Hive\School\WGU\c964 - computer science capstone\data'
data_file_name = "USA Housing Dataset.csv"
data_file_input = os.path.join(data_dir,data_file_name)
data_file_train_x = os.path.join(data_dir,"data_file_rx.csv")
data_file_val_x = os.path.join(data_dir,"data_file_vx.csv")
data_file_test_x = os.path.join(data_dir,"data_file_tx.csv")
data_file_train_y = os.path.join(data_dir,"data_file_ry.csv")
data_file_val_y = os.path.join(data_dir,"data_file_vy.csv")
data_file_test_y = os.path.join(data_dir,"data_file_ty.csv")
columns_to_drop = ['date', 'sqft_lot', 'waterfront', 'view', 'sqft_above', 'sqft_basement', 'yr_renovated', 'street', 'country']

# Load your dataset
df = pd.read_csv(data_file_input)

pyplot.show()

# Rename the columns to lower case and replace spaces with underscores
df.columns = df.columns.str.lower().str.replace(' ', '_')
df = df.drop(columns=columns_to_drop)

# Roun

# Covert statezip to separate state and zipcode, then drop statezip
df['zipcode'] = df['statezip'].str.split(' ').str[-1]
df = df.drop(columns=['statezip'])

# Check the first few rows to confirm the changes
# print(df.head())

# Define your target variable and features
x = df.drop('price', axis=1)  # Features (drop the target 'price')
y = df['price']  # Target variable

# First, split the data into training + validation (80%) and test sets (20%)
x_train_val, x_test, y_train_val, y_test = train_test_split(
    x, y, test_size=0.2, random_state=42
)

# Then, split the training + validation set into the actual training set (60%) and validation set (20%)
x_train, x_val, y_train, y_val = train_test_split(
    x_train_val, y_train_val, test_size=0.25, random_state=42
    # 0.25 of 0.8 gives us 0.2 of the total data for validation, and the remaining 0.6 for training
)

# print(f"Training set: {x_train.shape[0]} samples")
# print(f"Validation set: {x_val.shape[0]} samples")
# print(f"Test set: {x_test.shape[0]} samples")

# Save the datasets to CSV files
x_train.to_csv(data_file_train_x, index=False)
x_val.to_csv(data_file_val_x, index=False)
x_test.to_csv(data_file_test_x, index=False)
y_train.to_csv(data_file_train_y, index=False)
y_val.to_csv(data_file_val_y, index=False)
y_test.to_csv(data_file_test_y, index=False)


# x_train = ""
# x_val = ""
# x_test = ""
# y_train = ""
# y_val = ""
# y_test = ""

# # Load the datasets from CSV files
# x_train = pd.read_csv(data_file_train_x)
# x_val = pd.read_csv(data_file_val_x)
# x_test = pd.read_csv(data_file_test_x)
# y_train = pd.read_csv(data_file_train_y)
# y_val = pd.read_csv(data_file_val_y)
# y_test = pd.read_csv(data_file_test_y)

# print(x_train.head())
# print(x_val.head())
# print(x_test.head())
# print(y_train.head())
# print(y_val.head())
# print(y_test.head())

# print(df.columns)