#!/usr/bin/env python3

import sys
import re

def process_verilog_file_list(target, file_list):
    # Check input
    if target not in ['Makefile', 'Synlig']:
        print(f'Unknown target {target}')
        return ''

    # List of allowed file extensions
    synlig_allowed_extensions = ['.sv', '.v', '.svh', '.vh']
    makefile_allowed_extensions = ['.sv', '.v', '.svh', '.vh', 'vlt']

    # Read the Verilog file list
    with open(file_list, 'r') as f:
        lines = f.readlines()

    processed_lines = []

    for line in lines:
        # Remove comments from each line
        line = re.sub(r'//.*', '', line)

        # Replace "+incdir+" with "-I"
        line = line.replace('+incdir+', '-I')

        # Replace -pvalue+<name>=<value> and -G<name>=<value> with -P<name>=<value>
        line = re.sub(r'-pvalue\+(\w+)=(\S+)', r'-P\1=\2', line)
        line = re.sub(r'-G(\w+)=(\S+)', r'-P\1=\2', line)

        # Remove extra whitespace
        line = ' '.join(line.split())

        # Check if the line ends with an allowed extension or is -I or -P
        if target=='Makefile':
            if any(line.endswith(ext) for ext in makefile_allowed_extensions):
                processed_lines.append(line)
        elif target=='Synlig':
            if any(line.endswith(ext) for ext in synlig_allowed_extensions) or '-I' in line or '-P' in line:
                processed_lines.append(line)

    # Reorder lines: -I/-P first, then others
    processed_lines.sort(key=lambda x: '-I' in x or '-P' in x, reverse=True)

    # Print the processed content
    print(' '.join(processed_lines))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <target> <verilog_file_list>")
        sys.exit(1)

    target = sys.argv[1]
    verilog_file_list = sys.argv[2]
    process_verilog_file_list(target, verilog_file_list)
