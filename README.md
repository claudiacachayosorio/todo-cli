# todo-cli
A simple command line task manager written in pure Bash.

## :joystick: Demo

```text
$ ./todo.sh add "create task"
[+] Added line 1: "finish readme"

$ ./todo.sh do 2
[x] Done line 2: "x run test suite"

$ ./todo.sh status
1 todo | 2 done | 3 total
```

## :gear: Installation
```bash
# Clone this repository
git clone https://github.com/claudiacachayosorio/todo-cli
cd todo-cli

# Make the script executable
chmod +x todo.sh
```

## :book: Usage
```text
./todo.sh [<command> [<argument>...]]
```
### :sparkles: Commands
```text
add <task>         Add new task.
do <index>...      Mark task as done.
undo <index>...    Undo task marked as done.
del <index>...     Delete task.
status             Display task count.
--version, -v      Display version number.
help, --help, -h   List available commands.
```

## :test_tube: Testing
To run automated tests, ensure `bats` 1.10.0 or higher is installed.
```bash
# Install bats-core libraries
git submodule update --init --recursive

# Run test suite
bats test/
```

## :busts_in_silhouette: Acknowledgments
This project was inspired by Gina Trapani's [todo.txt-cli](https://github.com/todotxt/todo.txt-cli). 
