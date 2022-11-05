import click, json, sys

def indent(i: int):
    indention = ""
    for i in range(i):
        indention += "\t"
    return indention

# This function will print the entire json object with all
# keys and values to the console with proper indention
def mapj(data, r=0, first=True):

    # set up logic for the first call to this function
    if first:
        first = False

        # Printing all the keys for the outer-most json items and
        # passing it to the remainder of this function to recurse over
        for i, key in enumerate(data.keys()):
            value = data.get(key)
            print(f"{ i + 1 }) Key: {key}")

            # passing the value from each k/v pair, with
            # no indention and the, now False 'first' variable
            mapj(value, 0, first)

    # if the value is an array we will loop over it and call the
    # function again for any more nested arrays or dictionaries
    if (type(data) == list):

        # a nice array header with an opening bracket and length info
        print(f"{indent(1 + r)}Value: (Array Length {len(data)})\n{indent(2 + r)}[")

        # If any more arrays or dicts are found we call this function
        # again to let it print those values inside our open array
        for i, item in enumerate(data):
            if type(item) == dict or type(item) == list:
                print(f"{indent(0 + r)}Arr[{i}]:")
                mapj(item, r + 1, first)
                continue

            # print any remaining values not passed to another call
            else:
                print(f"{indent(2 + r)}{i}: {item}")

        # print the closing bracket
        print(f"{indent(2 + r)}]")

    # this block handles the printing and recursion of dict objects
    elif (type(data) == dict):

        # Print our object header with opening curly brace
        print(f"{indent(0+r)}Object " + "{")

        # loop over the dict with some indexes
        for i, ky in enumerate(data):
            val = data.get(ky)

            # handle any empty values
            if not val:
                val = "None"

            # Call this function again to further
            # iterate through nested dicts or arrays
            if type(val) == dict or type(val) == list:
                print(f"{indent(1 + r)}Key: '{ky}'")
                mapj(val, r + 1, first)
                continue

            # print the non dict or list variables
            else:
                print(f"{indent(2 + r)}Key: '{ky}'\n{indent(2 + r)} Value: {val}")

        # print the closing bracket
        print(f"{indent(1 + r)}" + "}")

    # Print any variable thats not a list or array
    else:
        print(f"{indent(1 + r)}Value:'{data}'\n")


# This function just prints the information on the keys and
# values in the json file, its a lot more condensed to sort though
def unpackj(data, r=0, first=True):

    # logic to print the keys from the outer json object
    # and pass everything else to this function again
    if first:
        first = False
        for i, key in enumerate(data.keys()):
                item = data.get(key)
                print(f"{i + 1}) Key: {key}")
                unpackj(item, 0, first)

    # Handle list printing and recursion
    if type(data) == list:
        print(f"{indent(0 + r)}Array (Length {len(data)}):")
        for i, index in enumerate(data):

            # if it finds a list or array...
            if type(index) == list or type(index) == dict:

                # Print Array header with length of the array attached the
                # try except block is for trying to print the length of a number
                try:
                    print(f"{indent(1 + r)}Arr[{i}]: (Type: {type(index)})")
                except TypeError:
                    print(f"{indent(1 + r)}Arr[{i}]: (Type: N/A )")

                # and pass the rest back up
                # since Im not printing the values
                unpackj(index, r + 1, first)
                continue

    # logic to handle a dict
    elif type(data) == dict:
        keys = data.keys()

        # print dict header and number of keys
        print(f"{indent(0+r)}Object (# Keys {len(keys)}):")
        for i, ky in enumerate(keys):
            entry = data.get(ky)

            # handling any empty value slots
            if not entry:
                entry = "None"

            # passing any arrays or dicts back up
            if type(entry) == list or type(entry) == dict:
                print(f"{indent(1 + r)}Key: '{ky}' Value: ")
                unpackj(entry, r + 1, first)
                continue

            # printing values that are not lists or arrays
            # with the same try except block for number length
            else:
                try:
                    print(f"{indent(2+r)}Key: '{ky}'  Value (Type: {type(entry).__name__}, Length: {len(entry)})")
                except TypeError:
                    print(f"{indent(2+r)}Key: '{ky}'  Value (Type: {type(entry).__name__}, Length: N/A)")

    # printing any loose k/v pairs
    else:
        try:
            print(f"{indent(r + 1)}Value: (Data-Type: {type(data).__name__}, Length: {len(data)})")
        except TypeError:
            print(f"{indent(r + 1)}Value: (Data-Type: {type(data).__name__}, Length: N/A)")


def editj(data, choice="", _key="", first=True, **kwargs):
    # Define elements that reset each recursion
    current_keys = []

    # an array of the choices a user can make for editing json files
    choices = [
        {"choice": "edit", "description": "Edit An item in the current tier"},
        {"choice": "back", "description": "migrate back up the tree by one level"},
        {"choice": "continue", "description": "Migrate Down the tree by one level"},
        {"choice": "save", "description": "Update the original json file with all edits"},
        {"choice": "exit", "description": "Exit (All unsaved changes will be lost)"}
        ]

    # Set up the first call to this function to load
    # the json data into the current keys variable
    if first:
        root_data = data
        # set the bool to false so this only
        # happens the on the first call to editJ()
        first = False

        # fill the current keys list
        for i, key in enumerate(data):
            value = data[key]
            key_choice = {"index": i, "key": key, "value": value, "type": type(value).__name__}
            current_keys.append(key_choice)

        # call the function again
        editj(data, "continue", "", False, root_data=root_data, previous_keys=current_keys)

    # enter the recursive portion of this function
    else:

        # root_data will hold our entire json object so we
        # can navigate up and down the tree and log our changes
        root_data = kwargs["root_data"]

        if choice == "continue":

            # data will be whichever value from the json
            # object that was passed on the last recursion
            if type(data) == dict:

                # _key will be passed with data to
                # be used here to get the value
                if _key:
                    data = data.get(_key)

                # load the current keys with whatever data is passed
                # **This might be where I can tell it to stop if data is a single item**
                if data:
                    for i, key in enumerate(data):
                        value = data[key]
                        key_choice = {"index": i, "key": key, "value": value, "type": type(value).__name__}
                        current_keys.append(key_choice)

                # This is here to handle empty values, but may refactor
                # **I might not need this block to handle empty values**
                else:
                    value = data[key]
                    key_choice = {"index": 0, "key": _key, "value": value, "type": "null" }
                    current_keys.append(key_choice)

            # Handle list value
            elif type(data) == list:

                # key for an array will be the index in the array I want to access
                if _key:
                    data = data[_key]

                # fill out the current keys array
                if data:
                    for i in range(len(data)):
                        value = data[i]
                        key_choice = {"index": i, "key": None, "value": value, "type": type(value).__name__}
                        current_keys.append(key_choice)

                # Again, this might go away
                else:
                    value = data[i]
                    key_choice = {"index": i, "key": None, "value": value, "type": type(value).__name__}
                    current_keys.append(key_choice)

            # Another sloppy check for loose variables
            # **This will need refactoring
            else:
                current_keys.append({"index": 0, "key" : None, "value": data, "type": type(data).__name__})

            # This loop displays all the entry objects so the user
            # can make a choice on which one they would like to edit
            for entry in current_keys:
                print(f"{entry.get('index')}) Key: {entry.get('key')} Value: (Type: {entry.get('type')}) ")

            print("What would you like to do?")

            # Listing the choice objects
            for i, choice in enumerate(choices):
                print(f"{i}) {choice.get('choice')} -- {choice.get('description')}")

            # capture and validate the users choice
            user_choice = int(input("Choice (#):\n> "))
            while user_choice < 0 or user_choice > len(choices):
                print("Invalid Choice!")
                user_choice = int(input("Choice (#):\n> "))

            # changing users numerical answer to the string choice for the logic to work
            user_choice = choices[user_choice].get("choice")

            # Remaining logic for another continue choice
            if user_choice == "continue":

                # list current tree items again
                for entry in current_keys:
                    print(f"{entry.get('index')}) Key: {entry.get('key')} Value: (Type: {type(entry.get('value'))}) ")

                # get users choice from the current keys object and validating
                user_index_choice = int(input("which branch would you like to move down?\nChoice: (index #)> "))
                while user_index_choice < 0 or user_index_choice > len(current_keys):
                    print("Invalid Choice!")
                    user_index_choice = int(input("which branch would you like to move down?\nChoice: (index #)> "))

                # Putting together all the data to call this function again
                _data = current_keys[user_index_choice].get("value")
                _choice = user_choice
                if not current_keys[user_index_choice].get("key"): #This line should take the type value from the current key object
                    __key = current_keys[user_index_choice].get("index")
                else:
                    __key = current_keys[user_index_choice].get("key")

                # call the function again
                editj(_data, _choice, __key, False, root_data=root_data, previous_keys=current_keys)

            else:
                ...
    # editj(data, choice, key, False, root_data=root_data)

# CLICK command-line interface
@click.command()
@click.option("-p", "--path", required=True, help="The path to your json file", prompt="path to a json file")
@click.option("-m/--mapj", is_flag=True, help="Returns a map of the json object", default=False)
@click.option("-l/--listj", is_flag=True, help="Returns a list of the keys values and datatypes in the json tree", default=False)
@click.option("-e/--edit", is_flag=True, help="Allows user to edit items in the json file", default=False)
def json_tool(path, m: bool, l: bool, e: bool):
    """
    Json_tool offers several tools for reading, mapping and editing Json files.

        -p, --path: (Required) The path to the target json file

        -m, --mapj: (Optional) Returns a total list of the structure and all data in the file

        -l, --listj: (Optional) returns basic information about the value types of all items in the json file
    """
    with open(path, "r") as f:
        data = json.load(f)
    if m:
        mapj(data)
    if l:
        unpackj(data)
    if e:
        editj(data)


if __name__ == "__main__":
    json_tool()
