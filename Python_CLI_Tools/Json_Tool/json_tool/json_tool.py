import click, json

def map(data, r=False):
    if (type(data) == list):
        if r:
            print(f"\tValue: Array [")
        else:
            print(f"Value: Array [")
        for i, item in enumerate(data):
            if type(item) == dict or type(item) == list:
                map(item, True)
                continue
            else:
                if r:
                    print(f"\t\t{i}: {item}")
                else:
                    print(f"\t{i}: {item}")
        if r:
            print("\t\t]\n")
        else:
            print("\t]\n")
    if (type(data)== dict):
        if r:
            print("\tValue: Object {")
        else:
            print("Value: Object {")
        for i, ky in enumerate(data):
            val = data.get(ky)
            if not val:
                val = "None"
            if type(val) == dict or type(val) == list:
                map(val, True)
                continue
            else:
                if r:
                    print(f"\t\tKey:'{ky}'\n\t\t Value: {val}")
                else:
                    print(f"\tKey:'{ky}'\n\t Value: {val}")
        if r:
            print("\t\t}\n")
        else:
            print("\t}\n")
    if type(data) == str:
        print(f"\tValue:'{data}'\n")


def unpack(item, r=False):
    if type(item) == dict:
        keys = item.keys()
        print(f"Object:\n\tNumber of Keys {len(keys)}\n")
        print("{")
        for i, key in enumerate(keys):
            entry = item.get(key)
            if not entry:
                entry = "None"
            if type(entry) == list or type(entry) == dict:
                unpack(entry, True)
                continue
            else:
                if r:
                    print(f"\tKey: '{key}' Value-Data-Type: {type(entry)}, Number of Keys {len(keys)}")
                else:
                    print(f"\t\tKey: '{key}' Value-Data-Type: {type(entry)}, Number of Keys {len(keys)}")
        if r:
            print("\t}")
        else:
            print("\t\t}")
    if type(item) == list:
        print(f"Array:\n\tLength: {len(item)}\n[")
        for i, thing in enumerate(item):
            index = item[i]
            if type(index) == list or type(index) == dict:
                unpack(index, True)
                continue
            else:
                if r:
                    print(f"\t{i}) Data-Type: {str(type(thing))}")
                else:
                    print(f"\t\t{i}, {str(type(thing))}")
        if r:
            print("\t]")
        else:
            print("\t\t]")
    if item :
        print(f"Value:'{item} Data-Type: {type(item)}'\n")


@click.command()
@click.option("-p", "--path", required=True, help="The path to your json file", prompt="path to a json file")
@click.option("-m", is_flag=True, help="Returns a map of the json object", default=False)
@click.option("-l", is_flag=True, help="Returns a list of the keys values and datatypes in the json tree", default=False)
def json_tool(path, m: bool, l: bool):
    with open(path, "r") as f:
        data = json.load(f)
    if m:
        for i, key in enumerate(data.keys()):
            value = data.get(key)
            print(f"{ i + 1 }) Key: {key}")
            map(value)
    if l:
        for i, key in enumerate(data.keys()):
            value = data.get(key)
            print(f"{ i + 1 }) Key: {key}")
            unpack(value)


if __name__ == "__main__":
    json_tool()
