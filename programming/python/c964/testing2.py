import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt
import seaborn as sns

# Function to load data
def load_data(train_file):
    df = pd.read_csv(train_file)
    X = df.drop(columns=['price'])
    y = df['price']

    #
    # Show Statistics for Price Prior to Clean
    #
    description = df['price'].describe()

    # Convert to DataFrame
    description_df = pd.DataFrame(description).map(lambda x: f'${int(x):,}')

    # Create and Show the Plot
    plt.figure(figsize=(4, 3))  # Adjust figure size to make it narrower
    plt.table(cellText=description_df.values,
              rowLabels=description_df.index,
              colLabels=description_df.columns,
              cellLoc='left',  # Aligns text to the left
              colWidths=[0.3],  # Adjusts the column width to reduce white space
              loc='center')
    plt.axis('off')

    # Wrapping the title text manually by adding '\n' for a new line
    plt.title('Descriptive Statistics\nof Cleaned Prices')
    plt.show()

    return X, y

# Function to clean data (remove outliers, drop non-numeric columns, and align columns)
def clean_data(X, y):
    # Select only numeric columns for the correlation matrix
    numeric_cols = X.select_dtypes(include=[np.number]).columns
    X_numeric = X[numeric_cols]

    # Remove rows where y (price) is zero
    y_cleaned = y[y > 0]

    # Apply IQR method to remove outliers in y
    Q1 = y_cleaned.quantile(0.25)
    Q3 = y_cleaned.quantile(0.75)
    IQR = Q3 - Q1
    mask = ~((y_cleaned < (Q1 - 1.5 * IQR)) | (y_cleaned > (Q3 + 1.5 * IQR)))

    # Apply the mask and align X
    y_cleaned = y_cleaned[mask]
    X_cleaned = X_numeric.loc[y_cleaned.index]

    print(f"Number of records before cleaning: {len(y)}")
    print(f"Number of records after cleaning: {len(y_cleaned)}")

    return X_cleaned, y_cleaned

# Function to evaluate the model
def evaluate_model(model, X, y):
    # Train the model
    model.fit(X, y)

    # Predictions on training data
    y_pred = model.predict(X)
    train_mse = mean_squared_error(y, y_pred)
    train_r2 = r2_score(y, y_pred)

    # Plot actual vs predicted prices
    plt.figure(figsize=(10, 6))
    plt.scatter(y, y_pred)
    plt.plot([min(y), max(y)], [min(y), max(y)], color='red', linewidth=2)  # Diagonal line
    plt.xlabel('Actual Prices')
    plt.ylabel('Predicted Prices')
    plt.title('Actual vs Predicted Prices')
    plt.show()

    print(f"Training Mean Squared Error: {train_mse}")
    print(f"Training R-squared: {train_r2}")

    # Feature importance filtering
    importance_threshold = 0.03
    feature_importance = model.feature_importances_
    important_features = np.where(feature_importance > importance_threshold)[0]
    sorted_idx = np.argsort(feature_importance[important_features])

    plt.figure(figsize=(10, 6))
    plt.barh(np.array(X.columns)[important_features][sorted_idx],
             feature_importance[important_features][sorted_idx])
    plt.xlabel("Feature Importance")
    plt.title(f"Important Features (Importance > {importance_threshold})")
    plt.show()

    # Residual analysis on training data
    residuals = y - y_pred
    plt.figure(figsize=(10, 6))
    sns.histplot(residuals, kde=True)
    plt.title("Distribution of Residuals (Actual - Predicted)")
    plt.xlabel("Residual")
    plt.show()

# Function to plot correlations and select features based on a threshold
def plot_correlations(X, y):
    correlations = X.copy()
    correlations['price'] = y

    # Calculate correlations only for price
    price_corr = correlations.corr()['price'].drop('price')

    # Sort the price_corr in descending order
    price_corr_sorted = price_corr.sort_values(ascending=False)

    # Plot the sorted correlations
    plt.figure(figsize=(10, 6))
    sns.barplot(x=price_corr_sorted.index, y=price_corr_sorted.values, hue=price_corr_sorted.index,
                palette="coolwarm", dodge=False, legend=False)
    plt.xlabel('Features')
    plt.ylabel('Correlation with Price')
    plt.title('Feature Correlation with Price')
    plt.xticks(rotation=45, ha="right")  # Rotate x labels for better readability
    plt.show()

    # Assuming y is your Series with the cleaned data
    description = y.describe()

    # Convert to DataFrame for easier formatting
    description_df = pd.DataFrame(description).map(lambda x: f'${int(x):,}')

    # Plot the descriptive statistics as a table
    plt.figure(figsize=(6, 3))
    plt.table(cellText=description_df.values,
              rowLabels=description_df.index,
              colLabels=description_df.columns,
              cellLoc='left',  # Aligns text to the left
              loc='center')
    plt.axis('off')
    plt.title('Descriptive Statistics of Cleaned Prices')
    plt.show()


def main():
    # Load data
    data_file_train = r'https://raw.githubusercontent.com/FSMoore42/c964_data/main/data_file_train.csv'
    X_train, y_train = load_data(data_file_train)

    # # Clean data
    # X_train_cleaned, y_train_cleaned = clean_data(X_train, y_train)
    #
    # # Plot correlations with a threshold of 0.3 and get selected features
    # plot_correlations(X_train_cleaned, y_train_cleaned)
    #
    # # Initialize the RandomForest model
    # rf_model = RandomForestRegressor(
    #     max_depth=None,
    #     min_samples_split=2,
    #     n_estimators=350,
    #     random_state=42
    # )
    #
    # # Evaluate the model using only the selected features
    # evaluate_model(rf_model, X_train_cleaned, y_train_cleaned)

if __name__ == "__main__":
    main()
