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
                mapj(item, True, r + 1, first)
                continue
            else:
                print(f"{indent(2 + r)}{i}: {item}")
        print(f"{indent(2 + r)}]")

    elif (type(data) == dict):
        print(f"{indent(0+r)}Object:\n{indent(1+r)}\n" + "{")
        for i, ky in enumerate(data):
            val = data.get(ky)
            if not val:
                val = "None"
            if type(val) == dict or type(val) == list:
                print(f"{indent(1 + r)}Key: '{ky}'")
                mapj(val, True, r + 1, first)
                continue
            else:
                print(f"{indent(2 + r)}Key: '{ky}'\n{indent(2 + r)} Value: {val}")
        print(f"{indent(1 + r)}" + "}")
    else:
        print(f"{indent(1 + r)}Value:'{data}'\n")


def unpack(data, r=0, first=True):
    if first:
        first = False
        for i, key in enumerate(data.keys()):
                item = data.get(key)
                print(f"{ i + 1 }) Key: {key}")
                unpack(item, 0, first)
    if type(data) == list:
        print(f"{indent(1 + r)}Array (Length: {len(data)})")
        #  :\n{indent(2 + r)}[")
        for i, index in enumerate(data):
            # index = thing[i]
            if type(index) == list or type(index) == dict:
                print(f"{indent(0 + r)}Arr[{i}]:")
                unpack(index, r + 1, first)
                continue
            # else:
            #     print(f"{indent(1 + r)}{i}) Data-Type: {str(type(thing))}")
        # print(f"{indent(2 + r)}]")
    elif type(data) == dict:
        keys = data.keys()
        print(f"{indent(0+r)}Object:\n{indent(1+r)}Number of Keys {len(keys)}\n")
        #  + indent(2 + r) + "{")
        for i, ky in enumerate(keys):
            entry = data.get(ky)
            if not entry:
                entry = "None"
            if type(entry) == list or type(entry) == dict:
                print(f"{indent(1 + r)}Key: '{ky}'")
                unpack(entry, r + 1, first)
                continue
            else:
                print(f"{indent(2+r)}Key: '{ky}'\n{indent(3+r)}Value-Data-Type: {type(entry)}")
        # print(f"{indent(2 + r)}" + "}")
    else:
        print(f"Value:'{data} Data-Type: {type(data)}'\n")


@click.command()
@click.option("-p", "--path", required=True, help="The path to your json file", prompt="path to a json file")
@click.option("-m/--mapj", is_flag=True, help="Returns a map of the json object", default=False)
@click.option("-l/--listj", is_flag=True, help="Returns a list of the keys values and datatypes in the json tree", default=False)
def json_tool(path, m: bool, l: bool):
    with open(path, "r") as f:
        data = json.load(f)
    if m:
        mapj(data)
    if l:
        unpack(data)



if __name__ == "__main__":
    json_tool()
