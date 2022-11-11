import click, os, json, readline,  time

def input_with_prefill(prompt, text):
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
    print(f"deleted: '{key}'")
    with open(filepath, 'w') as f:
        json.dump(data, f)

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

def get_key_choice(choices) -> int:
    choice = int(input("Which item would you like to view?\n> "))
    while choice < 0 and choice > choices:
        print("Invalid selection!")
        choice = int(input("Which item would you like to view?\n> "))
    return choice - 1

def get_user_file_choice(viewing=False, no_entries=False) -> str:
    print("\n")
    x = {"choice": "x", "desc": "Exit"}
    b = {"choice": "b", "desc": "Back: Go back to the list view" }
    d = {"choice": "d", "desc": "Delete: Delete this entry"}
    n = {"choice": "n", "desc": "New: Create a new entry" }
    e = {"choice": "e", "desc": "Edit: Edit this entry"}
    v = {"choice": "v", "desc": "View: View a specific entry" }
    view_options = [ x, b, d, e ]
    menu_options = [ x, v, n ]
    new_file_options = [x, n]

    if not viewing:
        for option in menu_options:
            print(f"'{option.get('choice')}' -- {option.get('desc')}")
        user_choice = input("What would you like to do?\n> ")
        while user_choice.lower() not in ['x', 'v', 'n']:
            print("Invalid selection!")
            user_choice = input("What would you like to do?\n> ")

    elif no_entries:
        for option in new_file_options:
            print(f"'{option.get('choice')}' -- {option.get('desc')}")
        user_choice = input("What would you like to do?\n> ")
        while user_choice.lower() not in ['x', 'n']:
            print("Invalid selection!")
            user_choice = input("What would you like to do?\n> ")

    else:
        for option in view_options:
            print(f"'{option.get('choice')}' -- {option.get('desc')}")
        user_choice = input("What would you like to do?\n> ")
        while user_choice.lower() not in ['x', 'b', 'd', 'e']:
            print("Invalid selection!")
            user_choice = input("What would you like to do?\n> ")

    return user_choice.lower()

@click.command()
@click.option('-f', required=False, help="the file where your scratch files are stored")
def scratch_file(f='') -> None:
    if f is None:
        f = "./scratch_files.json"
    items = []
    q = "Enter 's' to save or 'e' to edit entry"
    file_choice = "v"
    viewing_entry = ''
    while file_choice != "x":
        data: dict = get_data(f)
        keys = data.keys()
        os.system('cls')
        if file_choice in ['v', 'b']:
            if len(data.keys()) > 0:
                items = []
                print("Current items:\n")
                for i, key in enumerate(data.keys()):
                    print(i+1, key, sep=" : ")
                    items.append(key)
                choice = get_key_choice(len(keys))
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
            edit_entry = input_with_prefill("Current entry:\n", entry)
            edit_check = input(q)
            while edit_check.lower() not in ["s", "r"]:
                print("Invalid entry!")
                edit_check = input(q)
            while edit_check.lower() != "":
                if edit_check.lower() == 'e':
                    edit_entry = input_with_prefill("Current entry:\n", entry)
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
            new_val = input("enter a new value\n> ")
            print(new_key, new_val, sep=": ")
            new_check = input(q)
            while new_check != '':
                while new_check.lower() not in ['r', 's']:
                    print("Invalid Input!")
                    new_check = input(q)
                if new_check.lower() == "e":
                    new_key = input_with_prefill("", new_key)
                    new_val = input_with_prefill("", new_val)
                    new_check = input(q)
                if new_check == 's':
                    save_entry(f, new_key, new_val)
                    os.system("cls")
                    print(f"New entry {new_key} added")
                    time.sleep(2)
            file_choice = "v"
            continue

        if file_choice == "d":
            entry = data.get(viewing_entry)
            delete_check = input(f"Are you sure you want to delete {viewing_entry}?\n('y'/'n')\n> ")
            while delete_check not in ['y', 'n']:
                print("Invalid input")
                delete_check = input(f"Are you sure you want to delete {viewing_entry}?\n('y'/'n')\n> ")
            if delete_check.lower() == 'y':
                delete_entry(f, viewing_entry)
                file_choice = "v"
                continue
            else:
                file_choice = get_user_file_choice(True)
                continue
