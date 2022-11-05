import click, json

def indent(i: int):
    indention = ""
    for i in range(i):
        indention += "\t"
    return indention


def mapj(data, r=0, first=True):
    if first:
        first = False
        for i, key in enumerate(data.keys()):
            value = data.get(key)
            print(f"{ i + 1 }) Key: {key}")
            mapj(value, 0, first)
    if (type(data) == list):
        print(f"{indent(1 + r)}Value: (Array Length {len(data)})\n{indent(2 + r)}[")
        for i, item in enumerate(data):
            if type(item) == dict or type(item) == list:
                print(f"{indent(0 + r)}Arr[{i}]:")
                mapj(item, r + 1, first)
                continue
            else:
                print(f"{indent(2 + r)}{i}: {item}")
        print(f"{indent(2 + r)}]")
    elif (type(data) == dict):
        print(f"{indent(0+r)}Object " + "{")
        for i, ky in enumerate(data):
            val = data.get(ky)
            if not val:
                val = "None"
            if type(val) == dict or type(val) == list:
                print(f"{indent(1 + r)}Key: '{ky}'")
                mapj(val, r + 1, first)
                continue
            else:
                print(f"{indent(2 + r)}Key: '{ky}'\n{indent(2 + r)} Value: {val}")
        print(f"{indent(1 + r)}" + "}")
    else:
        print(f"{indent(1 + r)}Value:'{data}'\n")


def unpackj(data, r=0, first=True):
    if first:
        first = False
        for i, key in enumerate(data.keys()):
                item = data.get(key)
                print(f"{i + 1}) Key: {key}")
                unpackj(item, 0, first)
    if type(data) == list:
        print(f"{indent(0 + r)}Array (Length {len(data)}):")
        for i, index in enumerate(data):
            if type(index) == list or type(index) == dict:
                try:
                    print(f"{indent(1 + r)}Arr[{i}]: (Type: {type(index)})")
                except TypeError:
                    print(f"{indent(1 + r)}Arr[{i}]: (Type: N/A )")
                unpackj(index, r + 1, first)
                continue
    elif type(data) == dict:
        keys = data.keys()
        print(f"{indent(0+r)}Object (# Keys {len(keys)}):")
        for i, ky in enumerate(keys):
            entry = data.get(ky)
            if not entry:
                entry = "None"
            if type(entry) == list or type(entry) == dict:
                print(f"{indent(1 + r)}Key: '{ky}' Value: ")
                unpackj(entry, r + 1, first)
                continue
            else:
                try:
                    print(f"{indent(2+r)}Key: '{ky}'  Value (Type: {type(entry).__name__}, Length: {len(entry)})")
                except TypeError:
                    print(f"{indent(2+r)}Key: '{ky}'  Value (Type: {type(entry).__name__}, Length: N/A)")
    else:
        try:
            print(f"{indent(r + 1)}Value: (Data-Type: {type(data).__name__}, Length: {len(data)})")
        except TypeError:
            print(f"{indent(r + 1)}Value: (Data-Type: {type(data).__name__}, Length: N/A)")


def editj(data, choice="", _key="", first=True, **kwargs):
    current_keys = []
    choices = [
        {"choice": "edit", "description": "Edit An item in the current tier"},
        {"choice": "back", "description": "migrate back up the tree by one level"},
        {"choice": "continue", "description": "Migrate Down the tree by one level"},
        {"choice": "save", "description": "Update the original json file with all edits"}
        ]
    if first:
        root_data = data
        first = False
        for i, key in enumerate(data):
            value = data[key]
            key_choice = {"index": i, "key": key, "value": value, "type": type(value).__name__}
            current_keys.append(key_choice)
        editj(data, "continue", "", False, root_data=root_data, previous_keys=current_keys)
    else:
        root_data = kwargs["root_data"]
        if choice == "continue":
            if type(data) == dict:
                if _key:
                    data = data.get(_key)
                if data:
                    for i, key in enumerate(data):
                        value = data[key]
                        key_choice = {"index": i, "key": key, "value": value, "type": type(value).__name__}
                        current_keys.append(key_choice)
                    else:
                        value = data[key]
                        key_choice = {"index": 0, "key": _key, "value": value, "type": "null" }
                        current_keys.append(key_choice)

            elif type(data) == list:
                if _key:
                    data = data[_key]
                if data:
                    for i in range(len(data)):
                        value = data[i]
                        key_choice = {"index": i, "key": None, "value": value, "type": type(value).__name__}
                        current_keys.append(key_choice)
                    else:
                        value = data[i]
                        key_choice = {"index": i, "key": None, "value": value, "type": type(value).__name__}
                        current_keys.append(key_choice)

            else:
                current_keys.append({"index": 0, "key" : None, "value": data, "type": type(data).__name__})
            for entry in current_keys:
                print(f"{entry.get('index')}) Key: {entry.get('key')} Value: (Type: {entry.get('type')}) ")
            print("What would you like to do?")
            for i, choice in enumerate(choices):
                print(f"{i}) {choice.get('choice')} -- {choice.get('description')}")
            user_choice = int(input("Choice (#):\n> "))
            while user_choice < 0 or user_choice > len(choices):
                print("Invalid Choice!")
                user_choice = int(input("Choice (#):\n> "))
            user_choice = choices[user_choice].get("choice")
            if user_choice == "continue":
                for entry in current_keys:
                    print(f"{entry.get('index')}) Key: {entry.get('key')} Value: (Type: {type(entry.get('value'))}) ")
                user_index_choice = int(input("which branch would you like to move down?\nChoice: (index #)> "))
                while user_index_choice < 0 or user_index_choice > len(current_keys):
                    print("Invalid Choice!")
                    user_index_choice = int(input("which branch would you like to move down?\nChoice: (index #)> "))
                _data = current_keys[user_index_choice].get("value")
                _choice = user_choice
                if not current_keys[user_index_choice].get("key"):
                    __key = current_keys[user_index_choice].get("index")
                else:
                    __key = current_keys[user_index_choice].get("key")
                editj(_data, _choice, __key, False, root_data=root_data, previous_keys=current_keys)
            else:
                ...
    # editj(data, choice, key, False, root_data=root_data)

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
