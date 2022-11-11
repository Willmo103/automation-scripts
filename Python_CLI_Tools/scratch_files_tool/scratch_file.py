import click, os, json, readline,  time

def input_with_prefill(prompt, text):
    text = str(text)
    def hook():
        readline.insert_text(text)
        readline.redisplay()
    readline.set_pre_input_hook(hook)
    result = input(prompt)
    readline.set_pre_input_hook()
    return result

def save_entry(filepath, key, entry) -> None:
    with open(filepath, "r") as f:
        data = json.load(f)
    data[key] = entry
    with open(filepath, 'w') as f:
        json.dump(data, f)

def delete_entry(filepath, key) -> str:
    with open(filepath, "r") as f:
        data:dict = json.load(f)
    deleted = data.pop(key)
    with open(filepath, 'w') as f:
        json.dump(data, f)
    print(f"deleted: '{key}'")
    time.sleep(2)


def get_data(file_path) -> dict:
    new_data = {}
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            data = json.load(f)
        if data is None:
            with open(f, "w") as f:
                json.dump(new_data, f)
            with open(file_path, "r") as f:
                data = json.load(f)
            return data
        else:
            return data
    else:
        with open(file_path, "w") as f:
            json.dump(new_data, f)
        with open(file_path, "r") as f:
            data = json.load(f)
        return data

def check_numerical_entry() -> int:
    choice = input("\nWhich # entry would you like to view?\n> ")
    while True:
        try:
            choice = int(choice)
            break
        except ValueError:
            print("Invalid selection, numerical values only!")
            choice = input("Which # entry would you like to view?\n> ")
    return choice -1

def get_key_choice(choices) -> int:
    choice = check_numerical_entry()
    while choice not in range(choices):
        print(f"Invalid selection. Entry ({choice + 1}) does not exist.")
        choice = check_numerical_entry()
    return choice - 1

def get_user_file_choice(viewing=False, no_entries=False) -> str:
    x = {"choice": "x", "desc": "Exit"}
    b = {"choice": "b", "desc": "Back to list view" }
    d = {"choice": "d", "desc": "Delete this entry"}
    n = {"choice": "n", "desc": "Create new entry" }
    e = {"choice": "e", "desc": "Edit this entry"}
    v = {"choice": "v", "desc": "View a specific entry" }
    view_options = [ e, d, b, x]
    menu_options = [ n, v, x ]

    if viewing:
        print("\nWhat would you like to do?")
        for option in view_options:
            print(f"'{option.get('choice')}' -- {option.get('desc')}")
        user_choice = input("> ")
        while user_choice.lower() not in ['b', 'd', 'e', 'x']:
            print("Invalid selection!\nChoices: ['b', 'd', 'e', 'x']")
            user_choice = input("> ")
    else:
        print("\nWhat would you like to do?")
        for option in menu_options:
            print(f"'{option.get('choice')}' -- {option.get('desc')}")
        user_choice = input("> ")
        while user_choice.lower() not in ['v', 'n','x']:
            print("Invalid selection!\nChoices: ['v', 'n','x']")
            user_choice = input("> ")
    return user_choice.lower()

def print_keys(data: dict) -> list[str]:
    items = []
    print("Current items:\n")
    for i, key in enumerate(data.keys()):
        print(f"\t{i+1}) '{key}'")
        items.append(key)
    return items

@click.command()
@click.option('-f', required=False, help="the file where your scratch files are stored")
def scratch_file(f='') -> None:
    if f is None:
        f = "./scratch_files.json"
    q = "Enter 's' to save or 'e' to edit\n> "
    viewing_entry = ''
    data: dict = get_data(f)
    items = print_keys(data)
    file_choice = get_user_file_choice()
    while file_choice != "x":
        data: dict = get_data(f)
        os.system('cls')
        if file_choice in ['v', 'b']:
            if len(data.keys()) > 0:
                items = print_keys(data)
                choice = get_key_choice(len(data.keys()))
                selection = data.get(items[choice])
                viewing_entry = items[choice]
                os.system('cls')
                print(items[choice], selection, sep=": \n")
                file_choice = get_user_file_choice(True)
                continue

            else:
                print("Nothing to show yet")
                file_choice = get_user_file_choice(False, True)
                continue

        if file_choice == "e":
            entry = data.get(viewing_entry)
            edit_entry = input_with_prefill("Edit entry:\n", entry)
            edit_check = input(q)
            while edit_check.lower() not in ["s", "e"]:
                print("Invalid entry!")
                edit_check = input(q)
            while edit_check.lower() != "":
                if edit_check.lower() == 'e':
                    edit_entry = input_with_prefill("Edit entry:\n", entry)
                    edit_check = input(q)
                else:
                    save_entry(f, viewing_entry, edit_entry)
                    os.system("cls")
                    print("Data saved")
                    time.sleep(2)
                    break
            file_choice = "v"


        if file_choice == "n":
            new_key = input("Enter a new key:\n> ")
            os.system('cls')
            new_val = input("enter a new value\n> ")
            os.system('cls')
            print(new_key, new_val, sep=": ")
            new_check = input(q)
            while new_check != '':
                while new_check.lower() not in ['e', 's']:
                    print("Invalid Input!")
                    new_check = input(q)
                if new_check.lower() == "e":
                    new_key = input_with_prefill("Key:\n", new_key)
                    os.system('cls')
                    new_val = input_with_prefill("Entry:\n", new_val)
                    os.system('cls')
                    print(new_key, new_val, sep=": ")
                    new_check = input(q)
                if new_check == 's':
                    save_entry(f, new_key, new_val)
                    os.system("cls")
                    print(f"New entry '{new_key}' created")
                    time.sleep(2)
                    break
            file_choice = "v"
            continue

        if file_choice == "d":
            entry = data.get(viewing_entry)
            delete_check = input(f"Are you sure you want to delete '{viewing_entry}'?\n(y/n)\n> ")
            while delete_check.lower() not in ['y', 'n']:
                print("Invalid input")
                delete_check = input(f"Are you sure you want to delete '{viewing_entry}'?\n(y/n)\n> ")
            if delete_check.lower() == 'y':
                delete_entry(f, viewing_entry)
                file_choice = "v"
                continue
            else:
                file_choice = "v"
                continue
