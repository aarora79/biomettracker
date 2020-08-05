"""
Preprocess data copy pasted from ideal protein website. The data on the web page appears in a tabular
form but when copy pasted on a chromebook (VS Code, gedit) it appears as each cell on a single row.
This script converts this data into a regular CSV format which can then be used by downstream apps
for analysis.

The raw data looks like this:
Date
Weight
BMI
Body Fat
Lean Mass
Muscle Percentage
Water Percentage
Action
2020/05/29
218.48 lbs
33.1
31.9 %
148.78 lbs
37.3 %
49.7 %
Edit | Delete
"""
import os
import re
import sys
import logging
import argparse
import pandas as pd
from dateutil.parser import parse

# global constants
APP_NAME = "preprocess"
CSV_HEADER = "Date,Weight,BMI,Body Fat,Lean Mass,Muscle Percentage,Water Percentage\n"
NUM_HEADER_TOKENS_PRESENT = 8
NUM_HEADER_FIELDS_NEEDED = NUM_HEADER_TOKENS_PRESENT - 1
OUTPUT_DIR = "data"


'''
All logging is to stderr. This allows us to pipe the output of commands through other
processes without the logging interfering.
'''
logging.basicConfig(format='%(asctime)s,%(module)s,%(funcName)s,%(lineno)d,%(levelname)s,%(message)s', level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger(__name__)


# ===============================================================================


def parse_args():
    # create the main top-level parser
    top_parser = argparse.ArgumentParser()
    
    # Common parameters for produce and consume sub-commands
    top_parser = argparse.ArgumentParser(add_help=True)
    top_parser.add_argument(
        '--raw-data-filepath',
        dest='raw_data_filename',
        type=str,
        required=True,
        help='Name of the file containing the raw data as exported from ideal protein')

    top_parser.add_argument(
        '--output-filename',
        dest='output_filename',
        type=str,
        required=True,
        help='Name of the CSV file generated as an output')

    if len(sys.argv) == 1:
        top_parser.print_help(sys.stderr)
        sys.exit(1)
    return top_parser.parse_args()

def main():
    """
    Top level application logic
    """
    args = parse_args()
    logger.info(f"{APP_NAME} starting...")
    logger.info(args)

    # read the file into an array of lines, each cell in what should have been a table
    # is a row in the file
    with open(args.raw_data_filename, "r") as f:
        lines = [l.strip() for l in f.readlines()]

    logger.info(f"there are {len(lines)} in the file {args.raw_data_filename}")
    # logger.info(lines)
    header = ",".join(lines[:NUM_HEADER_FIELDS_NEEDED])
    formatted_line = []
    formatted_lines = []
    i = 1
    # print(header)
    for l in lines[NUM_HEADER_TOKENS_PRESENT:]:
        # logger.info(l)
        if i % NUM_HEADER_TOKENS_PRESENT != 0:
            l = l.split(" ")[0]
            l = l if l != "-" else ""
            formatted_line.append(l)
        else:
            formatted_lines.append(",".join(formatted_line))
            formatted_line = []
        i += 1
    logger.info(f"header line=\"{header}\"")

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    file_path = os.path.join(OUTPUT_DIR, args.output_filename)
    logger.info(f"going to write {len(formatted_lines)} lines to {file_path}")
    with open(file_path, 'w') as f:
        f.write("%s\n" % header)
        for l in formatted_lines:
            f.write("%s\n" % l)
    
    logger.info(f"All done")


###########################################################
# MAIN
###########################################################

if __name__ == '__main__':
    main()