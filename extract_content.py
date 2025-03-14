import os
import re

def extract_files_from_combined(filepath, output_dir):
    """
    Extracts individual files from a combined text file and recreates the directory structure.

    Args:
        filepath (str): Path to the combined text file.
        output_dir (str): Path to the directory where files will be extracted.
    """

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regular expression to find file blocks
    file_pattern = r"File: (.*?)\nPath: (.*?)\n-{40}\n(.*?)(?=\nFile: |$)"
    file_blocks = re.findall(file_pattern, content, re.DOTALL)

    extracted_files_count = 0
    created_dirs_count = 0
    file_paths_extracted=[]

    for filename, path, code in file_blocks:
        filename = filename.strip()
        path = path.strip()
        code = code.strip()

        # Create directory structure
        full_path = os.path.join(output_dir, path)
        if not os.path.exists(full_path) and path !='.':
            os.makedirs(full_path, exist_ok=True)
            created_dirs_count += 1
        elif path=='.':
            full_path=output_dir


        # Write file content
        filepath_to_write = os.path.join(full_path, filename)
        with open(filepath_to_write, 'w', encoding='utf-8') as outfile:
            outfile.write(code)
        
        extracted_files_count += 1
        file_paths_extracted.append(os.path.join(path,filename) if path != '.' else filename)

    #Parse the tree
    tree_pattern = r"ARBOL:\n=+"
    tree_start = re.search(tree_pattern, content)
    tree_end = re.search(r"=+", content[tree_start.end():])
    tree_content=content[tree_start.end():tree_start.end()+tree_end.start()]
    tree_files=[]
    for line in tree_content.split('\n'):
        if any(c in line for c in ['├──','└──']):
            clean_line=line.replace('├──','').replace('└──','').replace('│','').strip()
            tree_files.append(clean_line)
    

    diff_files_count = len(tree_files) - extracted_files_count

    print(f"Extracted {extracted_files_count} files.")
    print(f"Created {created_dirs_count} directories.")
    print(f"Difference between files listed in the 'tree' and the extracted files: {diff_files_count}")
    print("File paths extracted:")

    for path in file_paths_extracted:
        print(f"- {path}")
    
    print("File paths listed in the tree:")
    for path in tree_files:
        print(f"- {path}")

# Example usage:
combined_file_path = "combined_files_2025-03-13.txt"  # Replace with your file path
output_directory = "extracted_files"  # Replace with your desired output directory
extract_files_from_combined(combined_file_path, output_directory)
