## iFinanceHelper project

Swift native iOS app that help you woth tracking your spendings.

This app helps you collect, analyze your spending to know better where your money are going.

# Pages:
Full video preview: [![Watch demo on YouTube](https://youtu.be/sy6EwiMdvfY?si=JpwCNZp8gDqu2cJ4)]

### 1. Add expense page.
Here you can specify the amount, roughly describe category, date and optionally add a small note.
You can add a unique note or select from suggested notes based on latest expenses.
|  |  |  |
|--|--|--|
| <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 51 56" src="https://github.com/user-attachments/assets/dcf31c63-10e2-4d6c-8045-f3a35aba1f26" /> | <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 52 20" src="https://github.com/user-attachments/assets/0b44ae89-3ac3-44df-a3dd-69d74dfe7dd3" /> | <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 52 04" src="https://github.com/user-attachments/assets/9dd090be-93c7-450a-988b-97cc864d1c9a" />

### 2. Categories page
This page gives you insights into the spending by categories in the last month.
You are also able to set the target per category - limit of money you want to spend
on this category each month. Then total spending is calculated, and shown how
many money are you left before overspening.
<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 54 33" src="https://github.com/user-attachments/assets/4f295d8a-7684-489c-a1d8-918b14e627ec" />

### 3. Analytics page
This page shows all the data about your expenses in a easy to analyze way.
First, you have the ability to filter the expenses by the notes.
Then, you can choose the time period you want to analyze:
- Week is default
- Month
- 6 Month
- Year to date
- Year

You can also swipe left or right to go one time period backwards of forwards.

#### Charts:
First chart presents the day-by-day spending by category in selected time period. You can also hold on the specific day: a popover appears showing a date and expenses totals
by categories that day:
<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 55 00" src="https://github.com/user-attachments/assets/f667c4d2-dced-49b6-9043-baab98a7bf6b" />

Second chart presents the spendings total in the selected time period by categories
in donut styled chart:
<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 55 09" src="https://github.com/user-attachments/assets/a31982aa-6295-484b-8612-7f9f95e1cd0f" />

Below there are also two banners:
- Day when the most money was spent, which also shows the category at which was spent the most that day
- The single biggest recorded expense, with its note and category.

### 4. List expenses page (search)
On this page you are able to look at all the recorded expenses as in the list.

You can choose the timeperiod, filter by category and choose the order and text search by the text in notes:

|  |  |  |
|--|--|--|
| <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 55 20" src="https://github.com/user-attachments/assets/dcd22fd1-7ddf-436f-a8f7-08e1daa53763" /> | <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 55 24" src="https://github.com/user-attachments/assets/722a4abd-b290-41f8-8811-7bee923e6fe1" /> | <img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 56 02" src="https://github.com/user-attachments/assets/71421c24-0feb-4105-8c13-cb9593a4fa38" />

You can click the `Edit` button at the top right corner to delete the expenses:

<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 56 08" src="https://github.com/user-attachments/assets/be6149fd-b079-44d9-b9f1-5f47dfc33aee" />

You can also click on any of them to edit this expense data.

### 5. Edit expense page
This page is similar to the page where you can add the expense, because it consists
of the same reusable components:
<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 55 38" src="https://github.com/user-attachments/assets/b211301d-e792-4ba2-8e2b-871f8574ff14" />

### 6. Learn page
This static page has a video and advices how to decrease your day-to-day spendings and develop
a good habits:
<img width="301" height="655" alt="Simulator Screenshot - iPhone 17 - 2026-04-25 at 09 57 04" src="https://github.com/user-attachments/assets/502e74c5-c23a-436a-b959-0b379074d61e" />

## Architecture & stack
This app uses MVVM architecture.
The reused UI elements are stored independently in the `components`.
Models are also in `models` folder. 2 of them are stored in the DB:
- Expense (the core domain model)
- ExpenseTypeTarget (the limit of spending per month per transaction)

UI -> SwiftUI.
Persistent data store -> SwiftData.
Charts -> SwiftCharts.

Also, `Fit` package is used for the notes suggestion (in `components/TagCardView.swift`)

