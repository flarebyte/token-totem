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

### Addendum: Handling .gitignore

To extend the CLI tool with the ability to ignore files specified in a
`.gitignore` file, we need to add a mechanism to parse the `.gitignore` file
and filter out the files and directories listed in it from the token counting
process. This can be integrated into the CLI Parser and the Application
Layer.

#### Modifications:

**CLI Parser:**

-   **New Responsibility:**
    -   Parse `.gitignore` file if the user specifies an option to consider it.
    -   Filter input files based on the `.gitignore` rules.
-   **New Function:**
    -   `parseGitignore(gitignorePath: []const u8) ![]const u8`

**TokenCountService:**

-   **New Responsibility:**
    -   Filter out files based on the parsed `.gitignore` rules before
        proceeding with token counting.
-   **New Function:**
    -   `filterFilesWithGitignore(files: []File, gitignoreRules: []const u8) []File`

### Suggested CLI Parameters

Based on the current specifications and the new .gitignore handling feature,
here is a list of parameters that the CLI could support.

Aligning the CLI options with the `scc` (Sloc, Cloc, and Code) tool will help
users familiar with it to easily adopt our CLI tool. Here’s the revised list
of parameters to match `scc` conventions where applicable:

| Parameter           | Description                                            | Example                       |
| ------------------- | ------------------------------------------------------ | ----------------------------- |
| `-i, --include`     | Specify the input file(s) to process.                  | `--include file1.py file2.js` |
| `-o, --format`      | Specify the output format (human-readable, csv, json). | `--format csv`                |
| `--price-per-token` | Specify the price per token and the currency.          | `--price-per-token 0.01 USD`  |
| `-e, --exclude`     | Exclude files and directories matching the pattern.    | `--exclude test/*`            |
| `--no-gitignore`    | Disable the consideration of .gitignore files.         | `--no-gitignore`              |
| `--by-file`         | Group results by file.                                 | `--by-file`                   |
| `--by-lang`         | Group results by file extension (language).            | `--by-lang`                   |
| `-h, --help`        | Display usage instructions.                            | `--help`                      |

### Parameter Functions:

-   `-i, --include`:

    -   **Description:** Takes one or more file paths or glob patterns as
        input.
    -   **Example:** `--include file1.py file2.js`

-   `-o, --format`:

    -   **Description:** Specifies the format of the output. Options are
        `human-readable`, `csv`, and `json`.
    -   **Example:** `--format csv`

-   `--price-per-token`:

    -   **Description:** Sets the price per token and the currency.
    -   **Example:** `--price-per-token 0.01 USD`

-   `-e, --exclude`:

    -   **Description:** Exclude files and directories matching the given
        pattern.
    -   **Example:** `--exclude test/*`

-   `--no-gitignore`:

    -   **Description:** Disables the default behavior of considering
        `.gitignore` rules.
    -   **Example:** `--no-gitignore`

-   `--by-file`:

    -   **Description:** Groups the results by file.
    -   **Example:** `--by-file`

-   `--by-lang`:

    -   **Description:** Groups the results by file extension (language).
    -   **Example:** `--by-lang`

-   `-h, --help`:
    -   **Description:** Displays usage instructions and exits.
    -   **Example:** `--help`

### Example Usage:

```sh
# Count tokens in file1.py and file2.js, output results in CSV format, considering .gitignore rules
token-counter --include file1.py file2.js --format csv

# Count tokens in all .py files, group by file extension (language), and calculate costs at $0.01 per token
token-counter --include *.py --by-lang --price-per-token 0.01 USD

# Count tokens excluding test files
token-counter --include *.py *.js --exclude test/* --format json

# Count tokens in file1.py and file2.js, output results in human-readable format, ignoring .gitignore rules
token-counter --include file1.py file2.js --no-gitignore --format
human-readable
```

This approach provides the flexibility to include or ignore `.gitignore`
rules based on user preference while keeping the interface intuitive and
aligned with `scc` conventions.

### Token Counting Strategies

The CLI tool supports multiple strategies for counting tokens in source code
files. Users can choose the desired strategy using the `--strategy`
parameter. The available strategies are:

1.  **Regex-Based Token Counting**
2.  **Delimiter-Based Token Counting**
3.  **Specific Sequence Counting**
4.  **Line-Based Token Counting**
5.  **Word Boundary Token Counting**

### 1. Regex-Based Token Counting

**Description:**
Uses regular expressions to identify patterns in the code that correspond to
different types of tokens. Zig doesn't have a built-in standard library for regular expressions. 
We'll need to use a third-party library and they are not stable yet. (So perhaps an idea for the future)

**Example Usage:**

```sh
token-counter --include file1.py --strategy regex
```

### 2. Delimiter-Based Token Counting

**Description:**
Uses common delimiters (spaces, tabs, newlines, punctuation) to split the
text into tokens.

**Example Usage:**

```sh
token-counter --include file1.py --strategy delimiter
```

### 3. Specific Sequence Counting

**Description:**
Counts occurrences of specific predefined sequences (e.g., keywords,
operators).

**Example Usage:**

```sh
token-counter --include file1.py --strategy specific-sequence
```

### 4. Line-Based Token Counting

**Description:**
Breaks down the text into lines and counts tokens line by line, which can
help in handling line-based comments and simple statements.

**Example Usage:**

```sh
token-counter --include file1.py --strategy line
```

### 5. Word Boundary Token Counting

**Description:**
Uses word boundaries to identify tokens, relying on detecting transitions
between word characters and non-word characters.

**Example Usage:**

```sh
token-counter --include file1.py --strategy word-boundary
```

### Command-Line Parameter for Strategy

| Parameter    | Description                                                                                                              | Example Usage      |
| ------------ | ------------------------------------------------------------------------------------------------------------------------ | ------------------ |
| `--strategy` | Specify the token counting strategy. Options are `regex`, `delimiter`, `specific-sequence`, `line`, and `word-boundary`. | `--strategy regex` |

This allows users to choose the most appropriate token counting strategy for
their needs by specifying the `--strategy` parameter when running the CLI
tool.
