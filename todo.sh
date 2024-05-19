#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
TODO_FILE="$SCRIPT_DIR/.todo_tasks"

# Function to display usage
usage() {
    echo "Usage: $0 [command] [arguments]"
    echo "Commands:"
    echo "  create       Create a new task"
    echo "  update       Update an existing task"
    echo "  delete       Delete a task"
    echo "  show         Show all information about a task"
    echo "  list         List tasks of a given day"
    echo "  search       Search for a task by title"
    exit 1
}

# Function to validate date and time
validate_datetime() {
    date -d "$1" >/dev/null 2>&1
    return $?
}

# Function to prompt for a valid title
prompt_title() {
    while true; do
        echo "Enter title (required): "
        read title
        if [ -n "$title" ]; then
            break
        else
            echo "Title is required." >&2
        fi
    done
    echo "$title"
}

# Function to prompt for a valid due date and time
prompt_due_date() {
    while true; do
        echo "Enter due date and time (DD-MM-YYYY HH:MM) (required): "
        read due_date
        if validate_datetime "$due_date"; then
            break
        else
            echo "Invalid date format. Please use 'DD-MM-YYYY HH:MM'" >&2
        fi
    done
    echo "$due_date"
}

# Function to create a new task
create_task() {
    title=$(prompt_title)

    echo "Enter description: "
    read description

    echo "Enter location: "
    read location

    due_date=$(prompt_due_date)

    id=$(date +%s)
    echo "$id|$title|$description|$location|$due_date|0" >> $TODO_FILE
    echo "Task created with ID $id"
}

# Function to update a task
update_task() {
    echo "Enter task ID to update: "
    read id

    if ! grep -q "^$id|" $TODO_FILE; then
        echo "Task ID not found." >&2
        exit 1
    fi

    echo "Enter new title (leave empty to keep current): "
    read title

    echo "Enter new description (leave empty to keep current): "
    read description

    echo "Enter new location (leave empty to keep current): "
    read location

    echo "Enter new due date and time (leave empty to keep current): "
    read due_date
    if [ -n "$due_date" ]; then
        if ! validate_datetime "$due_date"; then
            echo "Invalid date format. Please use 'DD-MM-YYYY HH:MM'" >&2
            exit 1
        fi
    fi

    current_task=$(grep "^$id|" $TODO_FILE)
    IFS='|' read -r -a task <<< "$current_task"
    new_title=${title:-${task[1]}}
    new_description=${description:-${task[2]}}
    new_location=${location:-${task[3]}}
    new_due_date=${due_date:-${task[4]}}
    new_completed=${task[5]}

    sed -i "/^$id|/d" $TODO_FILE
    echo "$id|$new_title|$new_description|$new_location|$new_due_date|$new_completed" >> $TODO_FILE
    echo "Task updated."
}

# Function to delete a task
delete_task() {
    echo "Enter task ID to delete: "
    read id

    if ! grep -q "^$id|" $TODO_FILE; then
        echo "Task ID not found." >&2
        exit 1
    fi

    sed -i "/^$id|/d" $TODO_FILE
    echo "Task deleted."
}

# Function to show all information about a task
show_task() {
    echo "Enter task ID to show: "
    read id

    task=$(grep "^$id|" $TODO_FILE)
    if [ -z "$task" ]; then
        echo "Task ID not found." >&2
        exit 1
    fi

    IFS='|' read -r -a task <<< "$task"
    echo "ID: ${task[0]}"
    echo "Title: ${task[1]}"
    echo "Description: ${task[2]}"
    echo "Location: ${task[3]}"
    echo "Due Date: ${task[4]}"
    echo "Completed: ${task[5]}"
}

# Function to list tasks of a given day
list_tasks() {
    while true; do
        echo "Enter date (DD-MM-YYYY): "
        read date
        if validate_datetime "$date"; then
            break
        else
            echo "Invalid date format." >&2
        fi
    done

    completed_tasks=$(grep "|$date" $TODO_FILE | grep '|1$')
    uncompleted_tasks=$(grep "|$date" $TODO_FILE | grep '|0$')

    echo "Completed tasks:"
    if [ -z "$completed_tasks" ]; then
        echo "none"
    else
        echo "$completed_tasks" | while IFS= read -r task; do
            IFS='|' read -r -a t <<< "$task"
            echo "ID: ${t[0]}, Title: ${t[1]}, Due Date: ${t[4]}"
        done
    fi

    echo "Uncompleted tasks:"
    if [ -z "$uncompleted_tasks" ]; then
        echo "none"
    else
        echo "$uncompleted_tasks" | while IFS= read -r task; do
            IFS='|' read -r -a t <<< "$task"
            echo "ID: ${t[0]}, Title: ${t[1]}, Due Date: ${t[4]}"
        done
    fi
}

# Function to search for a task by title
search_task() {
    echo "Enter title to search for: "
    read title

    tasks=$(grep "|$title" $TODO_FILE)
    if [ -z "$tasks" ]; then
        echo "No tasks found with the title \"$title\"." >&2
        exit 1
    fi

    echo "Tasks matching \"$title\":"
    echo "$tasks" | while IFS= read -r task; do
        IFS='|' read -r -a t <<< "$task"
        echo "ID: ${t[0]}, Title: ${t[1]}, Due Date: ${t[4]}, Completed: ${t[5]}"
    done
}

# Main script logic
if [ ! -f $TODO_FILE ]; then
    touch $TODO_FILE
fi

if [ $# -eq 0 ]; then
    today=$(date +%d-%m-%Y)
    completed_tasks=$(grep "|$today" $TODO_FILE | grep '|1$')
    uncompleted_tasks=$(grep "|$today" $TODO_FILE | grep '|0$')

    echo "Completed tasks:"
    if [ -z "$completed_tasks" ]; then
        echo "none"
    else
        echo "$completed_tasks" | while IFS= read -r task; do
            IFS='|' read -r -a t <<< "$task"
            echo "ID: ${t[0]}, Title: ${t[1]}, Due Date: ${t[4]}"
        done
    fi

    echo "Uncompleted tasks:"
    if [ -z "$uncompleted_tasks" ]; then
        echo "none"
    else
        echo "$uncompleted_tasks" | while IFS= read -r task; do
            IFS='|' read -r -a t <<< "$task"
            echo "ID: ${t[0]}, Title: ${t[1]}, Due Date: ${t[4]}"
        done
    fi
else
    case $1 in
        create) create_task ;;
        update) update_task ;;
        delete) delete_task ;;
        show) show_task ;;
        list) list_tasks ;;
        search) search_task ;;
        *) usage ;;
    esac
fi