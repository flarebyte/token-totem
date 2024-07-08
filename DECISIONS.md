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

## Rough initial architecture

### 1. Command Line Interface (CLI) Layer

This layer handles user interactions, processes input arguments, and triggers
appropriate actions in the application layer.

**Components:**

-   **CLI Parser:**
    -   **Responsibilities:**
        -   Parse command-line arguments.
        -   Validate input parameters.
        -   Provide usage instructions.
    -   **Functions:**
        -   `parseArguments(args: []const u8) !ParsedArguments`
        -   `printUsage() void`

### 2. Application Layer

This layer coordinates the execution of the main logic, interacting with the
domain layer to perform operations and the infrastructure layer to handle I/O
operations.

**Components:**

-   **TokenCountService:**
    -   **Responsibilities:**
        -   Coordinate token counting for a single file.
        -   Handle multiple files and group by file extension if required.
        -   Calculate costs based on token count and user-defined price.
        -   Format the output in the specified format (human-readable, CSV, JSON).
    -   **Functions:**
        -   `countTokens(file: File, language: Language) TokenCountResult`
        -   `groupByFileExtensions(files: []File) GroupedTokenCountResult`
        -   `calculateCost(tokenCount: usize, pricePerToken: f64) f64`
        -   `formatOutput(result: TokenCountResult, format: OutputFormat) ![]u8`

### 3. Domain Layer

This layer contains the core business logic and models, handling the actual
token counting and cost calculation.

**Components:**

-   **TokenCounter:**

    -   **Responsibilities:**
        -   Tokenize the input file based on the programming language.
        -   Count tokens including comments.
    -   **Functions:**
        -   `countTokens(content: []const u8, language: Language) usize`

-   **CostCalculator:**
    -   **Responsibilities:**
        -   Calculate the total cost based on the number of tokens and price per
            token.
    -   **Functions:**
        -   `calculateCost(tokenCount: usize, pricePerToken: f64) f64`

### 4. Infrastructure Layer

This layer handles I/O operations, including reading files and formatting
output.

**Components:**

-   **FileHandler:**

    -   **Responsibilities:**
        -   Read content from input files.
        -   Handle large files efficiently.
    -   **Functions:**
        -   `readFile(filePath: []const u8) ![]u8`
        -   `handleLargeFile(filePath: []const u8) ![]u8`

-   **OutputFormatter:**
    -   **Responsibilities:**
        -   Format the output in human-readable, CSV, or JSON format.
    -   **Functions:**
        -   `formatAsHumanReadable(result: TokenCountResult) []u8`
        -   `formatAsCSV(result: TokenCountResult) []u8`
        -   `formatAsJSON(result: TokenCountResult) []u8`

### Component Responsibilities and Communication

| Layer                | Component         | Responsibilities                                                                 | Functions/Communication                                                                                                                                                                                                                                          |
| -------------------- | ----------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CLI Layer            | CLI Parser        | Parse and validate command-line arguments, provide usage instructions            | `parseArguments(args: []const u8) !ParsedArguments`, `printUsage() void`                                                                                                                                                                                         |
| Application Layer    | TokenCountService | Coordinate token counting, handle multiple files, calculate costs, format output | `countTokens(file: File, language: Language) TokenCountResult`, `groupByFileExtensions(files: []File) GroupedTokenCountResult`, `calculateCost(tokenCount: usize, pricePerToken: f64) f64`, `formatOutput(result: TokenCountResult, format: OutputFormat) ![]u8` |
| Domain Layer         | TokenCounter      | Tokenize files, count tokens                                                     | `countTokens(content: []const u8, language: Language) usize`                                                                                                                                                                                                     |
|                      | CostCalculator    | Calculate total cost based on token count and price per token                    | `calculateCost(tokenCount: usize, pricePerToken: f64) f64`                                                                                                                                                                                                       |
| Infrastructure Layer | FileHandler       | Read content from files, handle large files                                      | `readFile(filePath: []const u8) ![]u8`, `handleLargeFile(filePath: []const u8) ![]u8`                                                                                                                                                                            |
|                      | OutputFormatter   | Format output in specified format                                                | `formatAsHumanReadable(result: TokenCountResult) []u8`, `formatAsCSV(result: TokenCountResult) []u8`, `formatAsJSON(result: TokenCountResult) []u8`                                                                                                              |

### Detailed Breakdown

#### CLI Parser

-   **Input:** Command-line arguments.
-   **Output:** Parsed arguments object.
-   **Functions:**
    -   `parseArguments(args: []const u8) !ParsedArguments`
    -   `printUsage() void`

#### TokenCountService

-   **Input:** Parsed arguments.
-   **Output:** Token count and cost in specified format.
-   **Functions:**
    -   `countTokens(file: File, language: Language) TokenCountResult`
    -   `groupByFileExtensions(files: []File) GroupedTokenCountResult`
    -   `calculateCost(tokenCount: usize, pricePerToken: f64) f64`
    -   `formatOutput(result: TokenCountResult, format: OutputFormat) ![]u8`

#### TokenCounter

-   **Input:** File content.
-   **Output:** Token count.
-   **Functions:**
    -   `countTokens(content: []const u8, language: Language) usize`

#### CostCalculator

-   **Input:** Token count, price per token.
-   **Output:** Total cost.
-   **Functions:**
    -   `calculateCost(tokenCount: usize, pricePerToken: f64) f64`

#### FileHandler

-   **Input:** File path.
-   **Output:** File content.
-   **Functions:**
    -   `readFile(filePath: []const u8) ![]u8`
    -   `handleLargeFile(filePath: []const u8) ![]u8`

#### OutputFormatter

-   **Input:** Token count, cost, format type.
-   **Output:** Formatted string.
-   **Functions:**
    -   `formatAsHumanReadable(result: TokenCountResult) []u8`
    -   `formatAsCSV(result: TokenCountResult) []u8`
    -   `formatAsJSON(result: TokenCountResult) []u8`
