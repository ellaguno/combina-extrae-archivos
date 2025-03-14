# 2 tools: combine and extract:
## Content Processor: File Combiner with Directory Tree

This shell script, `combine_files.sh`, is a powerful tool for combining multiple files into a single output file (`combined_files_<date>.txt`) while preserving the directory structure. It's designed to be used for project documentation, backups, or any situation where you need to consolidate multiple files into one.

## Features

*   **File Combination:** Combines the content of multiple files into a single output file.
*   **Directory Tree Generation:** Generates a visual representation of the directory tree within the output file.
*   **Customizable Search Path:** Allows you to specify the directory to search for files.
*   **Exclusion Patterns:** Supports excluding specific files or directories based on patterns (e.g., file extensions, names).
*   **Default Exclusions:** Automatically excludes common binary files, images, and other file types that are typically not needed in text-based combinations.
*   **Project Name:** Allows you to specify a project name, which is included in the output file's header.
*   **Date Stamp:** The output file name includes the current date for easy identification.
*   **Binary File Detection:** Skips binary files to avoid including non-text data.
* **Debug mode:** Includes a debug mode to see the steps of the script.

## How It Works

The script performs the following steps:

1.  **Initialization:**
    *   Sets up variables for the output file name, search path, and exclusion patterns.
    *   Parses command-line arguments to customize the script's behavior.
    *   Creates the output file (or overwrites it if it already exists).
    *   Writes a header to the output file, including the project name and date.

2.  **Directory Tree Generation:**
    *   The `generate_tree()` function recursively traverses the directory structure.
    *   It uses `find` to list files and directories and `sort` to order them.
    *   It uses `should_exclude()` to check if a file or directory should be excluded.
    *   It outputs a visual representation of the tree to the output file using `├──`, `└──`, and `│` characters.

3.  **File Processing:**
    *   The `process_file()` function handles each file found by `find`.
    *   It checks if the file is within the search path and if it should be excluded.
    *   It checks if the file is binary.
    *   It writes a header for the file in the output file, including the filename and its relative path.
    *   It appends the file's content to the output file.

4.  **Exclusion Logic:**
    *   The `should_exclude()` function checks if a file or directory should be excluded based on:
        *   **Default Exclusions:** A list of common binary and image file types.
        *   **Custom Exclusions:** Patterns provided via the `-x` command-line argument.

5. **Debug mode:**
    * The script includes a debug mode that can be activated with `set -x`.

## Usage

```bash
./combine_files.sh [-n project_name] [-p path] [-x exclude_pattern1] [-x exclude_pattern2] [...]
```

---

## Project Extractor from Combined File

This Python script, `extract_content.py`, is designed to extract multiple files and their corresponding directory structure from a single "combined" text file. This combined file is expected to have a specific format, where each file's information (name, path, and content) is separated by a delimiter. Additionally, it parses a tree structure within the combined file to provide a comparison of the files listed in the tree versus the files actually extracted.

## Features

*   **File Extraction:** Extracts multiple files from a single combined text file.
*   **Directory Structure Recreation:** Recreates the original directory structure of the extracted files.
*   **Tree Structure Parsing:** Parses a tree structure (typically representing the project's file hierarchy) within the combined file.
*   **File and Directory Counting:** Counts the number of files extracted and directories created.
*   **Difference Reporting:** Calculates and reports the difference between the number of files listed in the tree structure and the number of files actually extracted.
*   **File Path Listing:** Lists the paths of the extracted files and the files listed in the tree.
*   **Error Handling:** Includes basic error handling for file operations.
*   **UTF-8 Encoding:** Handles files with UTF-8 encoding.

## Input File Format

The combined file should follow this general structure:

##ARBOL:

├── backend

│ ├── app

│ │ ├── blueprints

│ │ │ └── tasks

│ │ │ └── ejemplo.py

│ │ └── init.py

│ └── requirements.txt

└── frontend

└── styles

└── globals.css

File: ejemplo.py Path: backend/app/blueprints/tasks
Content of ejemplo.py
print("Hello from ejemplo.py")

File: requirements.txt Path: backend
Content of requirements.txt
flask==3.0.0 ...

File: globals.css Path: frontend/styles
/* Content of globals.css */ @tailwind base; ...

*   **Tree Structure:** The file starts with an "ARBOL" section, followed by a visual representation of the directory structure. This section is delimited by lines of equal signs (`=`).
*   **File Blocks:** Each file is represented by a block that starts with:
    *   `File: <filename>`: The name of the file.
    *   `Path: <filepath>`: The relative path of the file within the project.
    *   `----------------------------------------`: A separator line.
    *   `<file content>`: The actual content of the file.
*   **File Block Separator:** File blocks are separated by either the start of a new `File:` block or the end of the file.

## How to Use

1.  **Prerequisites:**
    *   Python 3 installed on your system.
    *   No external Python libraries are required (all used modules are part of the Python Standard Library).

2.  **Save the Script:** Save the Python code as `extract.py` (or any other name you prefer).

3.  **Prepare the Combined File:** Ensure your combined file (e.g., `combined_files_2025-03-13.txt`) is in the same directory as the script.

4.  **Run the Script:** Open a terminal or command prompt, navigate to the directory, and run the script:

    ```bash
    python extract_content.py
    ```

5.  **Output:**
    *   A new directory named `extracted_files` (by default) will be created in the same directory as the script.
    *   The extracted files and their directory structure will be placed inside `extracted_files`.
    *   The script will print the following information to the console:
        *   The number of files extracted.
        *   The number of directories created.
        *   The difference between the number of files listed in the "ARBOL" and the number of files extracted.
        *   A list of the paths of the extracted files.
        *   A list of the paths of the files listed in the tree.

6. **Change the file and output path**
    * You can change the file and output path in the last lines of the script:
    ```python
    # Example usage:
    combined_file_path = "combined_files_2025-03-13.txt"  # Replace with your file path
    output_directory = "extracted_files"  # Replace with your desired output directory
    extract_files_from_combined(combined_file_path, output_directory)
    ```

## Script Breakdown

*   **`extract_files_from_combined(filepath, output_dir)`:**
    *   This is the main function that performs the extraction.
    *   It reads the combined file.
    *   It uses a regular expression (`file_pattern`) to find file blocks.
    *   It iterates through the file blocks, extracting the filename, path, and content.
    *   It creates the necessary directories using `os.makedirs(full_path, exist_ok=True)`.
    *   It writes the file content to the correct location.
    *   It counts the number of files extracted and directories created.
    *   It parses the tree structure to get the list of files.
    *   It calculates the difference between the files in the tree and the extracted files.
    *   It prints the results and the lists of file paths.

## Dependencies

*   **Python Standard Library:** This script only uses modules from the Python Standard Library:
    *   `os`: For interacting with the operating system (file paths, directories).
    *   `re`: For regular expressions (used to parse the combined file).

## Example

If you have a `combined_files_2025-03-13.txt` file with the structure described above, running `python extract.py` will:

1.  Create an `extracted_files` directory.
2.  Create the `backend/app/blueprints/tasks`, `backend`, and `frontend/styles` directories within `extracted_files`.
3.  Create the `ejemplo.py` file in `extracted_files/backend/app/blueprints/tasks`, `requirements.txt` in `extracted_files/backend` and `globals.css` in `extracted_files/frontend/styles`.
4.  Print the extraction statistics and file path lists to the console.

## Notes

*   The script assumes the combined file is encoded in UTF-8.
*   The regular expression (`file_pattern`) is designed to match the specific format described above. If the format of your combined file is different, you may need to adjust the regular expression.
* The script is designed to work with the output of the previous scripts, that generate the combined file.

## Author

[Eduardo Llaguno/GitHub ellaguno]
