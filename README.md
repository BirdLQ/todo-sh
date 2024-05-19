# Todo Task Manager

## Overview

This shell script manages your todo tasks. Each task has a unique identifier, a title, a description, a location, a due date and time, and a completion marker. The script provides functionalities to create, update, delete, show, list, and search tasks. When invoked without arguments, it displays completed and uncompleted tasks of the current day.

## Features

- Create a task with a unique ID, title, description, location, due date and time, and completion status.
- Update any field of an existing task.
- Delete a task by ID.
- Show all information about a task by ID.
- List tasks of a specific day, categorized into completed and uncompleted sections.
- Search for tasks by title.
- Input validation ensures correct date and time format.

## Design Choices

### Data Storage

Tasks are stored in a hidden file named `.todo_tasks` in the same directory as the script. Each task is stored as a single line with fields separated by the pipe (`|`) character:
```
ID|Title|Description|Location|Due Date|Completion Status
```

- **ID**: Unique identifier for the task.
- **Title**: Title of the task (required).
- **Description**: Description of the task (optional).
- **Location**: Location of the task (optional).
- **Due Date**: Due date and time in the format `DD-MM-YYYY HH:MM` (required).
- **Completion Status**: `0` for uncompleted, `1` for completed.

### Code Organization

- **Input Validation**: Functions `prompt_title` and `prompt_due_date` ensure valid inputs for required fields.
- **Task Management**: Separate functions handle creating, updating, deleting, showing, listing, and searching tasks.
- **Main Logic**: Determines the action based on the command-line arguments and invokes the corresponding function.

## Usage

### Running the Script

1. **Without Arguments**: Displays completed and uncompleted tasks of the current day.
   ```sh
   ./todo
   ```

2. **Create a Task**: Prompts for task details and creates a new task.
   ```sh
   ./todo create
   ```

3. **Update a Task**: Prompts for task ID and new details to update an existing task.
   ```sh
   ./todo update
   ```

4. **Delete a Task**: Prompts for task ID and deletes the specified task.
   ```sh
   ./todo delete
   ```

5. **Show a Task**: Prompts for task ID and displays all information about the specified task.
   ```sh
   ./todo show
   ```

6. **List Tasks**: Prompts for a date and lists completed and uncompleted tasks of that day.
   ```sh
   ./todo list
   ```

7. **Search for a Task**: Prompts for a title and displays tasks that match the title.
   ```sh
   ./todo search
   ```

### Error Handling

- If invalid input is provided, the script prompts the user to enter the information again.
- Error messages are redirected to standard error (`stderr`).

## Dependencies

- Bash shell (version 4.0 or higher)
- `date` command for date and time validation

## License

This project is licensed under the MIT License.
