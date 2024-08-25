

import pandas as pd
import os
import subprocess
from sklearn.model_selection import train_test_split

# Define the path to your data file
data_dir = r'e:\users\fmoore\documents\SpiderOak Hive\School\WGU\c964 - computer science capstone\data'
data_file = os.path.join(data_dir, "USA Housing Dataset.csv")
data_file_train = os.path.join(data_dir, "data_file_train.csv")
data_file_val = os.path.join(data_dir, "data_file_validate.csv")
data_file_test = os.path.join(data_dir, "data_file_test.csv")
columns_to_drop = ["sqft_lot","sqft_above","sqft_basement","view","yr_renovated"]

# Load the dataset
data = pd.read_csv(data_file)
data.drop(columns_to_drop, axis=1, inplace=True)

# # Split the data into train (60%), validation (20%), and test (20%) sets
# train_data, temp_data = train_test_split(data, test_size=0.4, random_state=42)
# val_data, test_data = train_test_split(temp_data, test_size=0.5, random_state=42)

# Save the datasets as CSV files
# train_data.to_csv(data_file_train, index=False)
# val_data.to_csv(data_file_val, index=False)
# test_data.to_csv(data_file_test, index=False)
data.to_csv(data_file_train, index=False)

print("Data successfully split and saved.")
subprocess.Popen(f'explorer {os.path.realpath(data_dir)}')
