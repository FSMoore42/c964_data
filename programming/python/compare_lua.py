import ast
import re
import os


def ignore_parens(string):
    return string.replace("(", "~").replace(")", "(").replace("~",")")


def lua_to_dict(file_path):
    with open(file_path, 'r', encoding="utf-8") as file:
        #f = file.read()
        #lua_string = re.match(r'''^\nTradeSkillMasterDB = {(.*)}''',)
        lua_string = re.match(
            r'''^\nTradeSkillMasterDB = {(.*)}''',file.read(),re.DOTALL
        ).group(1).strip().replace("\n", "").replace("\t", "")
    # Conversion logic remains the same as previously described
    lua_string = re.sub(r'\[\"([^\"]+)\"\]', r"'\1'", lua_string)
    lua_string = lua_string.replace('=', ':')
    lua_string = lua_string.replace('{', '{\'')
    lua_string = lua_string.replace('}', '\'}')
    lua_string = lua_string.replace(',', ',\'')
    lua_string = re.sub(r"\'([a-zA-Z0-9_]+):", r"'\1':", lua_string)
    lua_string = lua_string.replace('\'{\'', '{')
    lua_string = lua_string.replace('\'\'}\'', '}')
    lua_string = lua_string.replace(':', "':")
    try:
        return ast.literal_eval(ignore_parens(lua_string))
    except ValueError as e:
        print(f"Error converting Lua to Dict: {e}")
        return {}


def compare_dicts(dict1, dict2, path=""):
    differences = []
    for key in dict1:
        if key not in dict2:
            differences.append(f"{path}{key} is missing in the second dictionary.")
        elif isinstance(dict1[key], dict) and isinstance(dict2[key], dict):
            differences.extend(compare_dicts(dict1[key], dict2[key], f"{path}{key}/"))
        elif dict1[key] != dict2[key]:
            differences.append(f"Different value for '{path}{key}': '{dict1[key]}' vs '{dict2[key]}'")
    for key in dict2:
        if key not in dict1:
            differences.append(f"{path}{key} is missing in the first dictionary.")
    return differences


# Modify these paths to your actual file locations
file_loc = r'e:\users\fmoore\documents'
file_path1 = os.path.join(file_loc, "tsm_with_fav.txt")
file_path2 = os.path.join(file_loc, "tsm_no_fav.txt")
file_path1 = os.path.join(file_loc, "test_tsm.txt")
#file_path2 = os.path.join(file_loc, "test_tsm_bad.txt")

dict1 = lua_to_dict(file_path1)
dict2 = lua_to_dict(file_path2)

# differences = compare_dicts(dict1, dict2)
# for difference in differences:
#     print(difference)
