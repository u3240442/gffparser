import re
import sys
import os

def gffParser(inputFileName):
    print(f' {inputFileName}')  # Welcome message

def parse_gff3(input_filename, chromosome_id):
    output_dir = "SDDGFFOutput"
    os.makedirs(output_dir, exist_ok=True)  # Create the output directory if it doesn't exist

    output_filename = os.path.join(output_dir, f"parsed_{os.path.basename(input_filename)}")
    try:
        with open(input_filename, "r") as input_file, open(output_filename, "w") as output_file:
            in_header = True
            for line in input_file:
                if line.startswith("##") or line.startswith("#!"):
                    # Skip lines in the header
                    continue
                if in_header:
                    # The first non-header line marks the end of the header
                    in_header = False
                if "gene\t" in line and "pseudogene\t" not in line:
                    # Process the actual data lines here
                    parsed_line = line.strip()  # or parse the line as needed

                    # Define the regular expression pattern
                    pattern = r'^N[^.]*\.\d+'
                    # Replace the matched pattern with the desired text
                    parsed_line = re.sub(pattern, chromosome_id, parsed_line)

                    output_file.write(parsed_line + '\n')

        return output_filename
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Invalid command:\nUsage: python SDDGFFParser.py input_gff3_filename chromosome_id")
    else:
        input_gff3_filename = sys.argv[1]
        chromosome_id = sys.argv[2]

        gffParser('|:: GffParser ::|')

        # Usage
        out_file_name = parse_gff3(input_gff3_filename, chromosome_id)
        if out_file_name:
            print(f'File parsed and generated in the following path: {out_file_name}')
            print(f'Done')
        else:
            print("File parsing failed.")