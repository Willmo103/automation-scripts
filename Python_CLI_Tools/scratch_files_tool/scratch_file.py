import click, os, json

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

def get_user_file_choice():
    options = [
        {"choice": "x", "desc": "Exit" },
        {"choice": "v", "desc": "View: View a specific entry" },
        {"choice": "n", "desc": "New: Create a new entry" },
        {"choice": "d", "desc": "Delete: Delete an entry" },
        {"choice": "e", "desc": "Edit: Edit an entry" }
    ]
    for option in options:
        opt_choice = option['choice']
        opt_desc = option['desc']
        print(f"'{opt_choice}' : {opt_desc}")


@click.command()
@click.option('-f', required=False, help="the file where your scratch files are stored")
def scratch_file(f=''):

    # create a default value
    # if none is passed
    if f is None:
        f = "./scratch_files.json"

    data: dict = get_data(f)
    keys = data.keys()

    if len(keys) == 0:
        print("Nothing to show yet")

    else:
        print("Current items:\n")
        items = []
        for i, key in enumerate(keys):
            print(i+1, key, sep=" : ")
            items.append(key)

        file_choice = get_user_file_choice()

    while file_choice != "x":
        if file_choice is "v":
            choice = get_key_choice(len(keys))
            selection = data.get(items[choice])
            print(items[choice], selection, sep=": \n")
            file_choice = get_user_file_choice()




    # create a check for a file
        # if theirs not a file location prompt the user to add a new scratch file from scratch
    # use options to:
        # List the keys from the json scratch file, and give the user an option to select which file they want to read from
        # edit any of the entries they have in the scratch file,
        # Create a new file,
        # add to or delete a file
