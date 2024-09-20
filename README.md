# XML Sanity Check Tool

## Overview

This PowerShell script (`XMLSanityChecker.ps1`) is designed to validate and inspect XML files either individually or within a directory. It provides two main functionalities:

1. **Schema Validation (XSD)**: Validates XML files against a specified XSD schema.
2. **Non-Printable Character Check**: Identifies non-printable ASCII characters in XML files, helping detect hidden issues in XML data.

In addition to validating files, it provides detailed output reports and feedback for easy review. The script has been optimized for both single file and directory-based operations.

## Features

- **Directory and Single File Support**: You can validate all XML files in a directory or check a single XML file using a user-friendly interface with dialog boxes.
- **Graphical Dialog Boxes**: Easy-to-use graphical interface for file, folder, and validation type selection.
- **Combined Checks**: Option to run both XSD validation and non-ASCII checks in a single run.
- **Detailed Summary Reports**: Generates separate or combined summary reports:
  - `xmlvalidationsummary.txt` for XSD validation results.
  - `asciivalidationsummary.txt` for non-ASCII character results.
  - `validation_and_ascii_summary.txt` when both checks are performed.
- **File Output**: Outputs validation results to easy-to-read `.txt` files, capturing detailed issues.
- **User Feedback**: Provides clear feedback in both the terminal and summary reports, ensuring users are fully informed of the results.

## Usage

### Running the Script

1. **Execute the Script**:
   - Run the script in PowerShell: `.\XMLSanityChecker.ps1`
   - No flags are required. The script provides a graphical interface for file and directory selection.

2. **Choose Operation Mode**:
   - A dialog box will appear for you to choose whether to check all XML files in a directory or validate a single XML file.
   - Select "Folder" to check all XML files in a directory, or "Single File" to validate one XML file.

3. **Schema Validation (Optional)**:
   - After selecting the file or directory, choose the validation type:
     - **XSD Validation**: Validates XML files against a provided XSD schema.
     - **Non-ASCII Check**: Skips schema validation and checks for non-printable characters.
     - **Both**: Performs both checks in one run.

4. **View the Results**:
   - Depending on the selected validation, summary reports will be generated in the same directory as the XML files.

## Example Output

#### **xmlvalidationsummary.txt**

Total Files Scanned: 10

Valid Files: 8 out of 10  
Invalid Files: 2 out of 10

Files that failed validation:
- invalidfile1.xml
- invalidfile2.xml

#### **asciivalidationsummary.txt**

*** This check looked for characters outside the standard ASCII printable range (control characters and characters outside the printable ASCII range 0-31 and 127+). ***

Total Files Scanned: 10

Files Without Non-Printable Characters: 9 out of 10  
Files With Non-Printable Characters: 1 out of 10

Files containing non-printable characters:
- problematicfile.xml (see problematicfile_nonprintable.txt for details)

#### **validation_and_ascii_summary.txt**

--- XML Validation and ASCII Check Summary ---  
Total Files Scanned: 10

--- XSD Validation Results ---  
Valid Files: 8 out of 10  
Invalid Files: 2 out of 10

Files that failed validation:
- invalidfile1.xml
- invalidfile2.xml

--- Non-ASCII Character Check Results ---  
Files Without Non-Printable Characters: 9 out of 10  
Files With Non-Printable Characters: 1 out of 10

Files containing non-printable characters:
- problematicfile.xml (see problematicfile_nonprintable.txt for details)

--- End of Summary ---

## Changelog

### **Version 3.0**
- **New Features**:
  - Introduced graphical dialog boxes for file/folder selection and validation type (XSD, Non-ASCII, or Both).
  - Added support for running both XSD validation and non-ASCII checks in a single run, generating a combined summary report (`validation_and_ascii_summary.txt`).
- **Summary Files**:
  - Introduced the combined summary `validation_and_ascii_summary.txt` when both checks are run, simplifying the output.
- **User Experience Enhancements**:
  - All dialog boxes now appear in the forefront of other windows to prevent them from being hidden behind the PowerShell window.
- **File Name Change**:
  - The script was renamed from `XmlSanityCheck.ps1` to `XMLSanityChecker.ps1` to reflect the correct capitalization of "XML" for readability and consistency (because "XML" looks odd if it's not fully capitalized or fully lowercase — just a personal aesthetic choice).

- **SHA1SUM of `XMLSanityChecker.ps1`**: `A1632B745BE549CFE578DA52F03DFE67A11F077E`

### **Version 2.0**
- **Enhancements**:
  - Added non-printable ASCII character check functionality (`asciivalidationsummary.txt`).
  - Improved feedback and summaries with clear, concise results for XSD validation and non-ASCII checks.
  - Provided support for directory-based checks alongside single file validation.

- **SHA1SUM of `XmlSanityCheck.ps1`**: `6058E64D60F047742ED4C6E07B5FA8C804FFD49B`

### **Version 1.0**
- **Initial Release**:
  - Supported XSD validation for XML files.
  - Provided simple feedback on validation status (valid/invalid).

- **SHA1SUM of `XmlSanityCheck.ps1`**: `376822C7CA063EFEAAC3390AD52477B77F2C22D2`

## Bug Fixes

- **Version 3.0**:
  - Fixed an issue where multiple summary files were being generated during the "Both" validation check. Now, only the `validation_and_ascii_summary.txt` file is generated for both checks.
  - Fixed a display issue where dialog boxes would open behind the PowerShell window. Dialog boxes now use the `TopMost` property to ensure they appear in the forefront.

## Testing Script Functionality

When we use the term "printable ASCII characters" in this context, we're being a bit more specific. What we actually mean are characters with ASCII values:

- **32 to 126**: These include standard letters (A-Z, a-z), digits (0-9), punctuation marks, and symbols like `!`, `@`, `#`, and so on.
- **Tab**: ASCII value 9.
- **Line Feed (LF)**: ASCII value 10.
- **Carriage Return (CR)**: ASCII value 13.

We are not allowing other characters, such as extended ASCII (values 127 and above) or certain control characters (like those with values less than 9 or between 14 and 31). This is due to limitations in some systems where such characters might cause processing issues. If this changes in the future, adjustments will need to be made to the corresponding function in the code to capture the change.

### Testing Steps:

1. **Using Notepad++ or Visual Studio Code**:
   - Open your XML file in Notepad++ or Visual Studio Code.
   - Manually insert extended ASCII characters such as `é`, `ç`, `ñ`, `ø`, and `ß` into a field, like so:
     ```xml
     <FreeTextField>Test with extended characters: é, ç, ñ, ø, ß</FreeTextField>
     ```

2. **Programmatically Using PowerShell**:
   - You can use the following PowerShell command to append a line with extended ASCII characters to your XML file:
     ```powershell
     Add-Content -Path "C:\path\to\your\file.xml" -Value '<FreeTextField>Test with extended characters: é, ç, ñ, ø, ß</FreeTextField>'
     ```
   - This command adds a line with extended characters directly to your XML file.

## Disclaimer

**PowerShell Script Execution**: If the `.ps1` script doesn't run, it might be due to the file not originating on your system. On some systems, security restrictions may block the execution of scripts to prevent potential risks. To resolve this, you can open the script in Notepad, save it as a new file, and ensure it is recognized as a locally generated file.

## Version

Current version: 3.0  
SHA1SUM of `XMLSanityChecker.ps1`: `A1632B745BE549CFE578DA52F03DFE67A11F077E`

## Author

Danny Rotondo

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).  
