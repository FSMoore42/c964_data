import os
import pandas as pd
import numpy as np

from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_score, GridSearchCV
import seaborn as sns
import matplotlib.pyplot as plt

# Load your data
data_dir = r'e:\users\fmoore\documents\SpiderOak Hive\School\WGU\c964 - computer science capstone\data'
data_file_training_x = os.path.join(data_dir, "data_file_rX.csv")
data_file_training_y = os.path.join(data_dir, "data_file_ry.csv")

training_X = pd.read_csv(data_file_training_x)
training_y = pd.read_csv(data_file_training_y)

# Select numeric features and target
features = training_X.select_dtypes(include=[np.number]).columns
X = training_X[features]
y = training_y

# Remove rows where y (price) is zero
y = y[y['price'] > 0]

# Apply IQR method to remove outliers in y
low_quantile = 0.15
Q1_y = y.quantile(low_quantile)
Q3_y = y.quantile(1 - low_quantile)
IQR_y = Q3_y - Q1_y
y = y[~((y < (Q1_y - 1.5 * IQR_y)) | (y > (Q3_y + 1.5 * IQR_y))).any(axis=1)]

# Align X with the cleaned y
X = X.loc[y.index]

# Standardize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Reshape y to avoid DataConversionWarning
y = y.values.ravel()

# Train and evaluate Random Forest model
# rf_model = RandomForestRegressor(n_estimators=300, random_state=42)
rf_model = RandomForestRegressor(
    max_depth=None,
    min_samples_split=2,
    n_estimators=300,
    random_state=42
)
rf_model.fit(X_scaled, y)
y_pred_rf = rf_model.predict(X_scaled)

mse_rf = mean_squared_error(y, y_pred_rf)
r2_rf = r2_score(y, y_pred_rf)
print(f"Random Forest Mean Squared Error: {mse_rf}")
print(f"Random Forest R-squared: {r2_rf}")

# Cross-validation
scores = cross_val_score(rf_model, X_scaled, y, cv=5, scoring='r2')
print(f"Cross-validated R-squared scores: {scores}")
print(f"Mean Cross-validated R-squared: {scores.mean()}")

# Hyperparameter tuning with GridSearchCV
# param_grid = {'n_estimators': [100, 200, 300], 'max_depth': [None, 10, 20, 30], 'min_samples_split': [2, 5, 10]}
param_grid = {'n_estimators': [100,255,300], 'max_depth': [None], 'min_samples_split': [2]}
grid_search = GridSearchCV(rf_model, param_grid, cv=5, scoring='r2', n_jobs=-1)
grid_search.fit(X_scaled, y)
print("Best parameters found:", grid_search.best_params_)
print("Best R-squared from Grid Search:", grid_search.best_score_)

# Plot actual vs predicted prices
plt.figure(figsize=(10, 6))
plt.scatter(y, y_pred_rf)
plt.plot([min(y), max(y)], [min(y), max(y)], color='red', linewidth=2)  # Diagonal line
plt.xlabel('Actual Prices')
plt.ylabel('Predicted Prices')
plt.title('Actual vs Predicted Prices')
plt.show()

# Feature importance filtering
importance_threshold = 0.03
feature_importance = rf_model.feature_importances_
important_features = np.where(feature_importance > importance_threshold)[0]
sorted_idx = np.argsort(feature_importance[important_features])

plt.figure(figsize=(10, 6))
plt.barh(np.array(X.columns)[important_features][sorted_idx], feature_importance[important_features][sorted_idx])
plt.xlabel("Feature Importance")
plt.title(f"Important Features (Importance > {importance_threshold})")
plt.show()


# Residual analysis
residuals = y - y_pred_rf
plt.figure(figsize=(10, 6))
sns.histplot(residuals, kde=True)
plt.title("Distribution of Residuals (Actual - Predicted)")
plt.xlabel("Residual")
plt.show()

