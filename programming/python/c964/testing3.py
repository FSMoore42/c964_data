import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import ipywidgets as widgets
from IPython.display import display, clear_output
from datetime import datetime

# Function to round values based on their specific criteria
def round_value(value, step):
    return round(value / step) * step

# Validation function to enforce rounding on tab or enter when manual edit
def validate_value(change, step, widget):
    widget.value = round_value(change['new'], step)

def validate_and_reset(change, step, widget, label_widget):
    validate_value(change, step, widget)
    label_widget.value = "<span style='font-size: 28px; font-weight: bold;'> Press Predict</span>"

# DataFrame and values to simulate input
X = pd.DataFrame({
    'bedrooms': np.random.randint(1, 11, 100),
    'bathrooms': np.random.uniform(1.0, 10.0, 100),
    'sqft_living': np.random.randint(370, 7000, 100),
    'floors': np.random.uniform(1.0, 5.0, 100),
    'condition': np.random.randint(1, 6, 100),
    'yr_built': np.random.randint(1900, datetime.now().year, 100),
    'waterfront': np.random.choice([0, 1], 100)
})

# DIctionaries for consistency and ease of editing
form_step_values = {
    'bedrooms': 1,
    'bathrooms': 0.25,
    'sqft_living': 1,
    'floors': 0.5,
    'condition': 1,
    'yr_built': 1
}

form_mean_values = {
    'bedrooms': round_value(X['bedrooms'].mean(), form_step_values['bedrooms']),
    'bathrooms': round_value(X['bathrooms'].mean(), form_step_values['bathrooms']),
    'sqft_living': 2000,  # Chosen at random
    'floors': round_value(X['floors'].mean(), form_step_values['floors']),
    'condition': round_value(X['condition'].mean(), form_step_values['condition']),
    'yr_built': round_value(X['yr_built'].mean(), form_step_values['yr_built'])
}

form_min_values = {
    'bedrooms': 1,
    'bathrooms': 1.0,
    'sqft_living': 100,
    'floors': 1,
    'condition': 1,
    'yr_built': 1848  # The oldest home in WA was built in 1848
}

form_max_values = {
    'bedrooms': 10,  # At least 1 home in WA has 8 bedrooms
    'bathrooms': 10,  # At least 1 home in WA has 10 bathrooms
    'sqft_living': 70000,  # US home in WA has 66,000 sq ft
    'floors': 5,  # At least 1 home in WA has 5 floors
    'condition': 5,
    'yr_built': datetime.now().year  # Current year
}

# Adjust color of entry fields so user knows they can be edited.
style = {'description_width': 'initial', 'handle_color': 'lightblue'}

bedrooms_widget = widgets.IntSlider(
    value=form_mean_values['bedrooms'],
    min=form_min_values['bedrooms'],
    max=form_max_values['bedrooms'],
    step=form_step_values['bedrooms'],
    description='Bedrooms:',
    style=style
)
bedrooms_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['bedrooms'], bedrooms_widget, predicted_price_value), 'value')

bathrooms_widget = widgets.FloatSlider(
    value=form_mean_values['bathrooms'],
    min=form_min_values['bathrooms'],
    max=form_max_values['bathrooms'],
    step=form_step_values['bathrooms'],
    description='Bathrooms:',
    readout_format='.2f',  # Allows for decimal display up to 2 places
    style=style
)
bathrooms_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['bathrooms'], bathrooms_widget, predicted_price_value), 'value')

sqft_living_widget = widgets.IntSlider(
    value=form_mean_values['sqft_living'],
    min=form_min_values['sqft_living'],
    max=form_max_values['sqft_living'],
    step=form_step_values['sqft_living'],
    description='Sqft Living:',
    style=style
)
sqft_living_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['sqft_living'], sqft_living_widget, predicted_price_value), 'value')

floors_widget = widgets.FloatSlider(
    value=form_mean_values['floors'],
    min=form_min_values['floors'],
    max=form_max_values['floors'],
    step=form_step_values['floors'],
    description='Floors:',
    readout_format='.1f',  # Allows for decimal display up to 1 place
    style=style
)
floors_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['floors'], floors_widget, predicted_price_value), 'value')

condition_widget = widgets.IntSlider(
    value=form_mean_values['condition'],
    min=form_min_values['condition'],
    max=form_max_values['condition'],
    step=form_step_values['condition'],
    description='Condition:',
    style=style
)
condition_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['condition'], condition_widget, predicted_price_value), 'value')

yr_built_widget = widgets.IntSlider(
    value=form_mean_values['yr_built'],
    min=form_min_values['yr_built'],
    max=form_max_values['yr_built'],
    step=form_step_values['yr_built'],
    description='Year Built:',
    style=style
)
yr_built_widget.observe(lambda change: validate_and_reset(
    change, form_step_values['yr_built'], yr_built_widget, predicted_price_value), 'value')

# Adding the Waterfront widget with left alignment and space before Predict button
waterfront_widget = widgets.ToggleButtons(
    options=[('No', 0), ('Yes', 1)],  # Options for No (0) and Yes (1)
    value=0,  # Default to No
    description='Waterfront:',
    button_style='',  # Options are: 'success', 'info', 'warning', 'danger' or ''
    tooltips=['Not on waterfront', 'On waterfront'],
    layout=widgets.Layout(width='50%')  # Adjust the width to align left
)

# Labels to display the predicted price with explicit CSS styling
predicted_price_label = widgets.HTML(
    value="<span style='font-size: 24px; font-weight: bold;'>Predicted Price:</span>",
    layout=widgets.Layout(margin='0px 30px 0px 0px')
)

predicted_price_value = widgets.HTML(
    value="<span style='font-size: 28px; font-weight: bold;'> Press Predict</span>",
    layout=widgets.Layout(margin='0px 0px 0px 30px')
)

# Define the Predict button widget
predict_button = widgets.Button(
    description="Predict",
    button_style='info',  # 'success', 'info', 'warning', 'danger' or ''
    tooltip='Click to predict house price',
    icon='check'  # (FontAwesome names without the `fa-` prefix)
)

# Ensure the feature order matches what the model was trained on
expected_features = ['bedrooms', 'bathrooms', 'sqft_living', 'floors', 'waterfront', 'condition', 'yr_built']

# Create an output widget to control the output display
output = widgets.Output()

# Function to handle the predict button click
def on_predict_button_clicked(b):
    with output:
        try:
            clear_output(wait=True)  # Clear previous output

            # Gather the input values from the widgets
            user_input = pd.DataFrame({
                'bedrooms': [bedrooms_widget.value],
                'bathrooms': [bathrooms_widget.value],
                'sqft_living': [sqft_living_widget.value],
                'floors': [floors_widget.value],
                'waterfront': [int(waterfront_widget.value)],  # Convert boolean to int (0 or 1)
                'condition': [condition_widget.value],
                'yr_built': [yr_built_widget.value]
            })

            # Reorder the user_input to match the expected order of features
            user_input = user_input[expected_features]

            # Use the trained model to predict the price
            predicted_price = model.predict(user_input)[0]

            # Update the label with the predicted price
            predicted_price_value.value = f"<span style='font-size: 28px; font-weight: bold;'>${predicted_price:,.2f}</span>"

        except Exception as e:
            # Display the error message for debugging
            print("An error occurred during prediction:")
            print(e)

# Connect the predict button to the handler function
predict_button.on_click(on_predict_button_clicked)

# Align the labels horizontally with appropriate spacing
price_display = widgets.HBox([predicted_price_label, predicted_price_value])

# Display the form, predict button, and price display
display(widgets.VBox([
    bedrooms_widget,
    bathrooms_widget,
    sqft_living_widget,
    floors_widget,
    waterfront_widget,
    condition_widget,
    yr_built_widget,
    widgets.Label(" "),  # Add spacing before the Predict button
    predict_button,
    widgets.Label(" "),  # Add spacing before the Predict button
    price_display,  # Display the predicted price labels
    output  # This is where the prediction output will be displayed
]))

# Example of training the model (not provided in the original notebook, assuming the model is trained beforehand)
# Here we simulate the model training process for the script to be fully functional.

# Generate some synthetic data for the purpose of this script
y = np.random.randint(100000, 1000000, 100)

# Split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initialize the model
model = RandomForestRegressor(n_estimators=100, random_state=42)

# Train the model
model.fit(X_train, y_train)

# Example usage:
# After the model is trained, use the Predict button in the form to see the predictions.

