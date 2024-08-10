
def import_and_clean_keyfiles(key_files_path):
    file_contents = str()
    for f in os.listdir(key_files_path):
        file_contents = "\n".join(
            [file_contents, open(os.path.join(key_files_path, f), 'r', encoding='utf-8').read()]
        )

    return clean_file_contents(file_contents.strip())


def clean_file_contents(orig_contents):
    contents = re.sub(r'\n\s', '\n', orig_contents)
    contents = re.sub(r'^\s+?(\S)', r'\1', contents)
    contents = '\n'.join([x for x in contents.split('\n') if x != "" and not re.match(r'^\s+$', x)])
    return contents


def process_vendor(contents, input_string, ignore):
    reg = re.compile(input_string)
    ven_list = reg.findall(contents)    
    return ven_list, remove_found(contents, ven_list)


def remove_found(orig_contents, found):
    contents = str(orig_contents)
    for f in found:
        contents = contents.replace(f[0], '')
    return clean_file_contents(contents)


def get_partial_list(contents, partial_str):
    return [x for x in contents if partial_str in x[0]]

def out_txt(contents,key):
    with open(f'.\\depot\\post_{key}.txt', 'w', encoding='utf-8') as of:
        for x in contents:
            of.write(x)

def out_key(vendors,key,ignore):
    with open(f'.\\depot\\key_{key}.txt', 'w', encoding='utf-8') as of:
        for x in vendors[key]:
            if [x[1],x[3],x[2]] not in ignore:
                t = f"{x[1]}\t{x[3]}\t\t\t\t{x[2]}\n"
                of.write(t)
            else:
                print(x)

def get_existing_keys(f):    
    data =[x.split(',') for x in open(f, 'r').read().strip().split('\n')]

    return [[x[0],x[1],x[5]] for x in data]
    
    

if __name__ == "__main__":
    import re
    import os    

    reg_str = {
        'steam': r'''((.+?)\n(.+?)\n(.*?)\n(?:.*?\n)?.*?games you already own.)''',
        'misc': r'''((.+?)\n(.+?)\nReveal your (.*?) key\nRedemption Instructions)''',
        'courses': r'''((.+?)\n(.+?)\nClick here to claim your (.*?) course.*?\n(.+?)\nRedemption Instructions)''',
        'software': r'''((.+?)\n(.*?Software Bundle.+?)\n(.*?)\n)''',
        'book': r'''((.+?)\n(.*?Book Bundle.+?)\n(.*?)\n)'''
        #'ubi': r'''(.+?)\n(.+?)\n([A-Z0-9]{3,4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}(?:-[A-Z0-9]{4})?)\n'''

    }

    file_contents = import_and_clean_keyfiles('.\\depot\\keyfiles')
    existing =  get_existing_keys(r'E:\fmoore\Documents\humble_bundle_keys.csv')

    vendors = {}
    for key in reg_str.keys():
        if key not in vendors.keys():
            vendors[key]= []

    for key in vendors.keys():            
        if key == "steam":
            vendors[key],file_contents = process_vendor(file_contents, reg_str[key], existing)
            out_txt(file_contents, key)
            out_key(vendors, key, existing)
    


def nothing_here():
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
        r'([^\n]+?\n[^\n]+?\n[a-z0-9]{3}-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\n(?:instructions\n)?)', f)
    f = re.sub(
        r'([^\n]+?\n[^\n]+?\n[a-z0-9]{3}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\n(?:instructions\n)?)',
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
