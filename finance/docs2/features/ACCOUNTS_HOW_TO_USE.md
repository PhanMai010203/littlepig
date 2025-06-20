# 🗂️ Accounts Usage Guide

The **Accounts** system is a fundamental component for managing the sources of funds in the application, such as bank accounts, cash, or digital wallets. Every transaction is linked to an account to accurately track financial movements.

## 1. Core Concepts

### Account Properties

An `Account` entity has the following key properties:

| Property | Type | Description |
|---|---|---|
| `id` | `int` | Unique identifier for the account. |
| `name` | `String` | The name of the account (e.g., "Checking Account", "Cash"). |
| `balance` | `double` | The current balance of the account. This can be set as the **starting balance** upon creation. |
| `currency` | `String` | The currency code for the account (e.g., "USD", "EUR"). This ensures that all associated transactions are correctly categorized. |
| `isDefault`| `bool` | A flag to indicate if this is the default account for new transactions. |
| `createdAt`| `DateTime` | Timestamp of when the account was created. |
| `updatedAt`| `DateTime` | Timestamp of the last update. |
| `color` | `Color` | Custom color for the account (defaults to grey). Users can personalize accounts with different colors for easy identification. |

> 📝 **Note on Customization**: You can set the name, currency, initial balance, and custom color for each account. Colors help users visually distinguish between different accounts.

## 2. Key Operations

### Creating an Account

To create a new account, you need to provide its `name`, initial `balance`, and `currency`. The system will handle the rest.

- **Use Case**: When a user adds a new bank account or a digital wallet to track.
- **Implementation**: Involves calling the `AccountRepository` to insert a new account record into the database.

### Reading Account Information

You can retrieve a list of all accounts or fetch a single account by its ID. This is essential for populating UI elements like account selectors in the transaction creation form.

### Counting Associated Transactions

Since every transaction is linked to an account via the `accountId`, you can easily determine how many transactions have affected a specific account.

- **How it Works**: The `TransactionRepository` provides methods to query transactions based on the `accountId`. By fetching all transactions for a given `accountId`, you can get the total count.
- **Example Use Case**: Displaying "25 Transactions" on an account details page.

## 3. Integration & Best Practices

- **Default Account**: It is recommended to have a default account set. This streamlines the process of adding new transactions, as the account field can be pre-filled.
- **Currency Consistency**: Ensure that the currency of the account is correctly set, as this affects all financial calculations and reports related to that account.
- **Balance Updates**: The account balance is not automatically updated when a new transaction is added. Your business logic should handle updating the account's balance after a transaction is created, updated, or deleted to maintain data integrity. 