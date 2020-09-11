#!/usr/bin/env python3
import json
import sys
def main():
    args = sys.argv
    if args.__len__() < 2:
        print("Error !")
        exit(-1)
    json_fname=args[1]
    json_f = open(json_fname,"r")
    json_d=json.load(json_f)
    repokun_str=""
    enablekun_str=""
    for jsobj in json_d["repo"]:
        repokun_str = repokun_str + " --repofrompath " + jsobj["name"] + "," + jsobj["url"]
        enablekun_str = enablekun_str + " --enablerepo=" + jsobj["name"]
    output_str = repokun_str + " --disablerepo=* --nogpgcheck "  + enablekun_str
    print(output_str)
main()