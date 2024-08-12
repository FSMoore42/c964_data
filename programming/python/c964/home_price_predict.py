import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt
import os

# Define the path to your data files as well as the file names
data_dir = r'e:\users\fmoore\documents\SpiderOak Hive\School\WGU\c964 - computer science capstone\data'
data_file_training_x = os.path.join(data_dir,"data_file_rx.csv")
data_file_training_y = os.path.join(data_dir,"data_file_ry.csv")

# Load the datasets from CSV files
training_X = pd.read_csv(data_file_training_x)
training_y = pd.read_csv(data_file_training_y)

# Select the features and target
features = ['bedrooms', 'bathrooms', 'sqft_living', 'floors', 'condition', 'yr_built', 'zipcode']
X = training_X[features]  # Features matrix
y = training_y  # Target variable (home prices)

# Apply one-hot encoding to categorical variables
#X = pd.get_dummies(X, columns=['city', 'state'])

# Initialize the linear regression model
model = LinearRegression()

# Fit the model to the training data
model.fit(X, y)

# Print the coefficients and intercept
print(f"Coefficients: {model.coef_}")
print(f"Intercept: {model.intercept_}")

y_pred_train = model.predict(X)

mse = mean_squared_error(y, y_pred_train)
r2 = r2_score(y, y_pred_train)

print(f"Mean Squared Error: {mse}")
print(f"R-squared: {r2}")

# Visualize the results
plt.scatter(y, y_pred_train)
plt.xlabel('Actual Prices')
plt.ylabel('Predicted Prices')
plt.title('Actual vs Predicted Prices')
plt.show()

