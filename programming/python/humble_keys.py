def import_and_clean_keyfiles(key_files_path):
    file_contents = str()
    for f in os.listdir(key_files_path):
        file_contents = "\n".join(
            [file_contents, open(os.path.join(key_files_path, f), 'r', encoding='utf-8').read().lower()]
        )

    return clean_file_contents(file_contents.strip())

def clean_file_contents(file_contents):
    file_contents = re.sub(r'\n\s', '\n', file_contents)
    file_contents = re.sub(r'^\s+?(\S)', r'\1', file_contents)
    file_contents = '\n'.join([x for x in file_contents.split('\n') if x != "" and not re.match(r'^\s+$', x)])
    return file_contents

def process_steam(file_contents):
    steam_all = re.compile(r'''(.*?)\n(.*?)\n\s*?\n(.*?)\n(?:.*?\n)?(.*?games you already own.)''')
    steam_given = steam_all.findall(file_contents)
    print(len(steam_given))

# start if main
if __name__ == "__main__":
    import re
    import os
    file_contents = import_and_clean_keyfiles('.\\depot\\keyfiles')
    process_steam(file_contents)

def nothing_here ():
    key_files_path = ".\\depot\\keyfiles"
    forig = ""
    for root, dirs, files in os.walk(key_files_path):
        for name in files:
            forig = "\n".join([forig, open(os.path.join(key_files_path, name), 'r', encoding='utf-8').read().lower()])
    print("Length of original f : " + str(len(forig)))
    f = str(forig)
    f = re.sub(r'\n\s', '\n', f)
    print("Length of f after removing pre \\s: " + str(len(f)))



    steam_given = re.findall(
        r'(?:.*?\n){2}you sent this gift .*?\nSteam will not provide extra giftable copies of games you already own.\n'.lower(),
        f)
    f = re.sub(
        r'(?:.*?\n){2}you sent this gift .*?\nSteam will not provide extra giftable copies of games you already own.*?$'.lower(),
        '', f)
    steam = re.findall(
        r'(?:.*?\n){4}(?:Gift to a friend\n)?Steam will not provide extra giftable copies of games you already own.\n'.lower(),
        f)
    steam_redeemed = [x for x in steam if "Reveal your Steam key".lower() not in x]
    steam_un = [x for x in steam if "Reveal your Steam key".lower() in x]
    f = re.sub(
        r'(?:.*?\n){4}(?:Gift to a friend\n)?Steam will not provide extra giftable copies of games you already own.\n'.lower(),
        '', f)
    f = re.sub(r'^\s+?(\S)', r'\1', f)
    print("Length of f after removing steam: " + str(len(f)))
    ubisoft = re.findall(
        r'([^\n]+?\n[^\n]+?\n[a-z0-9]{3}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\n(?:instructions\n)?)', f)
    f = re.sub(r'([^\n]+?\n[^\n]+?\n[a-z0-9]{3}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\n(?:instructions\n)?)',
               '', f)
    # f = re.sub(r'\n\s+?(\S)',r'\n\1',f)
    f = '\n'.join([x for x in f.split('\n') if x != "" and not re.match(r'^\s+$', x)])
    print("Length of f after removing ubisoft: " + str(len(f)))
    f = re.sub(r'(.*?\n.*?\n.*?\n(?:copy\n)?.*?\n.*?redeemed before.*?\n)', '', f)
    f = re.sub(r'(.*?\n.*?\n.*?redeemed to vaulden.*?\n)', '', f)
    f = re.sub(r'(.*?\n.*?\n.*?redeemed to.*?\n.*?\n)', '', f)
    f = re.sub(r'(.+?\nget my games)', '', f)
    f = re.sub(
        r'((?:.+?\n){2}.*?expired.*?\n(?:copy\n)?(?:.*?redemption instructions.*?\n)?(?:.*?steam will not provide extra.*?\n)?)',
        '', f)
    print("Length of f after alles: " + str(len(f)))

    with open(r'e:\users\fmoore\documents\SpiderOak Hive\programming\python\humble_bundle\out.txt', 'w') as fo:
        fo.write(f)


