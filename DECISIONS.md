# Architecture decision records

An [architecture
decision](https://cloud.google.com/architecture/architecture-decision-records)
is a software design choice that evaluates:

-   a functional requirement (features).
-   a non-functional requirement (technologies, methodologies, libraries).

The purpose is to understand the reasons behind the current architecture, so
they can be carried-on or re-visited in the future.

## Intial thoughts

### Problem Description

The goal is to develop a Command Line Interface (CLI) tool that counts the
number of tokens in a given file, including comments, and outputs the results
in a human-readable format, CSV, or JSON. The tool will also support grouping
results by files or file extensions and allow associating a price per token,
with the cost calculated and displayed alongside the token count.

### Use Cases

1.  **Basic Token Count with Output Options**:

    -   A user inputs a file containing source code.
    -   The tool outputs the total number of tokens in the file.
    -   Output can be in a human-readable format, CSV, or JSON.

2.  **Multiple File Types**:

    -   The tool handles files from various programming languages (e.g.,
        Python, JavaScript, C++).
    -   For example, given a Python file, the tool counts tokens like keywords,
        operators, identifiers, and comments.

3.  **Price Calculation**:

    -   The user can specify a price per token and the currency.
    -   The tool calculates the total cost based on the token count and
        displays it in the output.

4.  **Grouping by Files**:

    -   The user inputs multiple files.
    -   The tool outputs the token count and total cost for each file
        separately.

5.  **Grouping by File Extensions**:

    -   The user inputs multiple files with different extensions.
    -   The tool groups the results by file extension, showing the total token
        count and cost for each group.

6.  **Large Files**:

    -   A user inputs a large file (e.g., a 10,000-line JavaScript file).
    -   The tool processes and outputs the token count and cost efficiently
        without crashing or slowing down significantly.

7.  **Edge Case: Empty File**:

    -   The user inputs an empty file.
    -   The tool returns a token count and cost of zero.

8.  **Edge Case: File with Only Delimiters**:

    -   The user inputs a file containing only spaces, tabs, and newlines.
    -   The tool returns a token count and cost of zero, as there are no valid
        tokens.

9.  **Edge Case: File with Mixed Content**:
    -   A file containing a mix of code and comments.
    -   The tool counts all tokens, including those in comments.

### Limitations

-   **No Word or Character Counting**: The tool should not count words or
    characters. It strictly counts tokens.
-   **No Syntax Highlighting**: The tool will not provide syntax
    highlighting or any other form of code analysis.
-   **No Token Type Differentiation**: The tool will not differentiate
    between types of tokens (e.g., keywords vs. identifiers). It simply
    counts all tokens equally.
-   **No File Modifications**: The tool will not modify the input files in
    any way.
-   **No Recursive Directory Processing**: The tool will not process
    directories recursively. It handles files as specified by the user.
