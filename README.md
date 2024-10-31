# Expensy


Welcome to the official repository of **Expensy**!  
An app for Android that allows you to **track your expenses**

## Key Features

- 📊 **Expense Management**: Easily track your expenses.
- ☁️ **Backup and Restore**: Easily back up your data and restore it when needed.
- 📂 **Import and Export Expenses to Excel**: Export your transactions to an Excel file or import them from an existing file.
- 🌗 **Dark or Light Theme**: Choose between a dark or light mode based on your preferences.
- 📊 **Bar Chart Visualization**: View your spending trends with bar charts, filtered by year or month.
- 💱 **Multi-Currency Support**: Manage expenses in different currencies.
- 🏷️ **Add Tags to Expenses**: Categorize your expenses with custom tags.
- 💳 **Manage Payment Accounts**: Add and track expenses by linking them to different payment accounts.
- 🔒 **Local-Only Storage**: The app runs entirely offline, and all data remains stored locally on your device.
- 🌐 **Multi-language Support**: The app is available in English and Italian.

## Download
[Download the latest APK](https://github.com/fabranx/Expensy/releases/latest)

## Getting Started
### Prerequisites

Make sure you have the following installed:

- **Flutter SDK**: Download and install Flutter by following the [official instructions](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: You do not need to install Dart separately as the Flutter SDK includes the full Dart SDK.
- **Android Studio** or **Visual Studio Code**: Choose one of these development editors and install the Flutter and Dart plugins.

### Steps to Run Locally

1. **Clone the repository**  
   Clone the project to your working directory. Open the terminal and use the following command, replacing `your-username` and `your-repo-name`:
   ```bash
   git clone https://github.com/fabranx/Expensy.git
   ```
2. **Enter the project directory**
   ```bash
   cd Expensy
   ```
3. **Install Flutter packages**   
   Once inside the project folder, run the following command to install all dependencies declared in the ```pubspec.yaml``` file:
   ```bash
   flutter pub get
   ```
4. **Start an emulator or connect a device**
   If using Android Studio, you can start an emulator directly from the IDE. If you prefer Visual Studio Code, ensure you have a device connected or an Android emulator

5. **Run the app**
   ```bash
   flutter run
   ```

### Additional Notes
* Check that Flutter is correctly set up by running:
   ```bash
   flutter doctor
   ```
  This command will display any issues with your Flutter installation and your environment configurations.


## How To Import Expenses via Excel

To import your expenses into the app using an Excel file, follow these steps:

1. **Row 0: Column Titles**  
   In the first row (Row 0), insert the following titles, one for each column in this exact order:
    - `Date`
    - `Description`
    - `Amount`
    - `Currency`
    - `Tags`
    - `Payment-Account`

2. **Date Column**  
   In the `Date` column, enter the date of the expense. Make sure the date is formatted as a **date** in Excel.

3. **Description Column**  
   In the `Description` column, enter text describing the expense. If the cell is empty, the entire row will be skipped during import.

4. **Amount Column**  
   In the `Amount` column, enter a numeric value representing the amount spent. This can be a whole number or a decimal, and it must be zero or positive. If the value is invalid (negative, non-numeric, or empty), the entire row will be skipped.

5. **Currency Column**  
   In the `Currency` column, enter one of the following valid currencies. If an invalid or empty value is entered, the entire row will be skipped:
    - `USD`
    - `EUR`
    - `JPY`
    - `GBP`
    - `AUD`
    - `CAD`
    - `CHF`
    - `CNH`
    - `HKD`
    - `NZD`

6. **Tags Column**  
   In the `Tags` column, you can either leave the cell empty or enter text representing one or more tags for the expense. If entering multiple tags, separate them using a semicolon (`;`). Example: `groceries;food`.

7. **Payment-Account Column**  
   In the `Payment-Account` column, you can either leave the cell empty or enter text representing a single payment account associated with the expense.

### Example Excel Layout

| Date       | Description       | Amount | Currency | Tags               | Payment-Account |
|------------|-------------------|--------|----------|--------------------|-----------------|
| 2024-01-15 | Grocery shopping   | 50.25  | USD      | groceries;food     | Credit Card     |
| 2024-01-16 | Monthly Rent       | 1200   | EUR      | rent               | Bank Transfer   |
| 2024-01-17 | Dinner at restaurant | 45.60  | GBP      | dining;entertainment | Debit Card      |

Once your Excel file is correctly formatted, you can proceed with the import process within the app.


## Screenshots