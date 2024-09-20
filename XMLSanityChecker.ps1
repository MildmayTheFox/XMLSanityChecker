Add-Type -AssemblyName System.Windows.Forms

# Function to show a dialog for selecting a file or directory
function get_file_or_directory {
    param (
        [string]$filter = "XML Files (*.xml)|*.xml|All Files (*.*)|*.*",
        [bool]$is_directory = $false
    )
    if ($is_directory) {
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.SelectedPath = [System.Environment]::GetFolderPath('Desktop') # Start at Desktop
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $dialog.SelectedPath
        }
    } else {
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = $filter
        $dialog.InitialDirectory = [System.Environment]::GetFolderPath('Desktop') # Start at Desktop
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $dialog.FileName
        }
    }
    return $null
}

# Custom dialog for file/folder selection
function show_selection_dialog {
    $form = New-Object Windows.Forms.Form
    $form.Text = "File or Folder Selection"
    $form.Size = New-Object Drawing.Size(400,150)  # Made the form wider for readability
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true  # Ensure form is on top

    $label = New-Object Windows.Forms.Label
    $label.Text = "Would you like to check a folder of XML files or a single file?"
    $label.AutoSize = $true
    $label.Location = New-Object Drawing.Point(10, 20)
    $form.Controls.Add($label)

    $buttonFolder = New-Object Windows.Forms.Button
    $buttonFolder.Text = "Folder"
    $buttonFolder.Width = 100  # Adjusted the width to prevent text cutoff
    $buttonFolder.Location = New-Object Drawing.Point(50, 70)
    $buttonFolder.Add_Click({ $form.Tag = 'Folder'; $form.Close() })
    $form.Controls.Add($buttonFolder)

    $buttonFile = New-Object Windows.Forms.Button
    $buttonFile.Text = "Single File"
    $buttonFile.Width = 100  # Adjusted the width to prevent text cutoff
    $buttonFile.Location = New-Object Drawing.Point(200, 70)
    $buttonFile.Add_Click({ $form.Tag = 'File'; $form.Close() })
    $form.Controls.Add($buttonFile)

    $form.ShowDialog()
    return $form.Tag
}

# Custom dialog for validation type selection
function show_validation_type_dialog {
    $form = New-Object Windows.Forms.Form
    $form.Text = "Validation Type Selection"
    $form.Size = New-Object Drawing.Size(400,150)  # Made the form wider for readability
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true  # Ensure form is on top

    $label = New-Object Windows.Forms.Label
    $label.Text = "Select the type of check you want to run:"
    $label.AutoSize = $true
    $label.Location = New-Object Drawing.Point(10, 20)
    $form.Controls.Add($label)

    $buttonXSD = New-Object Windows.Forms.Button
    $buttonXSD.Text = "XSD Validation"
    $buttonXSD.Width = 120  # Increased width to prevent text cutoff
    $buttonXSD.Location = New-Object Drawing.Point(30, 70)
    $buttonXSD.Add_Click({ $form.Tag = 'XSD'; $form.Close() })
    $form.Controls.Add($buttonXSD)

    $buttonNonASCII = New-Object Windows.Forms.Button
    $buttonNonASCII.Text = "Non-ASCII Check"
    $buttonNonASCII.Width = 120  # Increased width
    $buttonNonASCII.Location = New-Object Drawing.Point(150, 70)
    $buttonNonASCII.Add_Click({ $form.Tag = 'NonASCII'; $form.Close() })
    $form.Controls.Add($buttonNonASCII)

    $buttonBoth = New-Object Windows.Forms.Button
    $buttonBoth.Text = "Both"
    $buttonBoth.Width = 120  # Increased width
    $buttonBoth.Location = New-Object Drawing.Point(270, 70)
    $buttonBoth.Add_Click({ $form.Tag = 'Both'; $form.Close() })
    $form.Controls.Add($buttonBoth)

    $form.ShowDialog()
    return $form.Tag
}

# Function to validate XML against XSD schema
function test_xml_file {
    param (
        [string] $schema_file,
        [string] $xml_file
    )

    try {
        $schema_reader = New-Object System.Xml.XmlTextReader $schema_file
        $schema = [System.Xml.Schema.XmlSchema]::Read($schema_reader, $null)
        $schema_reader.Close()
    } catch {
        Write-Error "Failed to load XSD schema: $schema_file. Error: $_"
        return $false
    }

    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.Schemas.Add($schema) | Out-Null
        $xml.Load($xml_file)
        $xml.Validate({ throw $args[1].Exception })
        return $true
    } catch {
        return $false
    }
}

# Function to check for non-printable characters in an XML file
function check_non_printable_characters {
    param (
        [string] $file_path
    )

    try {
        $content = Get-Content -Path $file_path -Raw
    } catch {
        Write-Host "Error reading file: $file_path. $_"
        return $false
    }

    $non_printable_lines = @()

    for ($i = 0; $i -lt $content.Length; $i++) {
        foreach ($char in ($content[$i] -as [string]).ToCharArray()) {
            $ascii_value = [int][char]$char
            if (($ascii_value -lt 9) -or ($ascii_value -gt 13 -and $ascii_value -lt 32) -or ($ascii_value -ge 127)) {
                $non_printable_lines += "Line $($i + 1): $($content[$i])"
                break
            }
        }
    }

    if ($non_printable_lines.Count -gt 0) {
        $output_file = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file_path), "$([System.IO.Path]::GetFileNameWithoutExtension($file_path))_nonprintable.txt")
        $non_printable_lines | Out-File -FilePath $output_file -Encoding ASCII
        Write-Host "Non-printable characters found in $file_path. Details written to: $output_file"
        return $false
    } else {
        Write-Host "No non-ASCII characters found in $file_path."
        return $true
    }
}

# Function to generate a combined summary with just file names (no full paths)
function generate_combined_summary {
    param (
        [int]$total_files,
        [int]$valid_files,
        [int]$invalid_files,
        [int]$files_without_issues,
        [int]$files_with_issues,
        [array]$invalid_file_names,
        [array]$files_with_issues_names,
        [string]$directory_path
    )

    $summary_content = @(
        "--- XML Validation and ASCII Check Summary ---"
        "Total Files Scanned: $total_files"
        ""
        "--- XSD Validation Results ---"
        "Valid Files: $valid_files out of $total_files"
        "Invalid Files: $invalid_files out of $total_files"
    )

    if ($invalid_files -gt 0) {
        $summary_content += ""
        $summary_content += "Files that failed validation:"
        $summary_content += $invalid_file_names | ForEach-Object { "  - $([System.IO.Path]::GetFileName($_))" }  # Just file name
    }

    $summary_content += ""
    $summary_content += "--- Non-ASCII Character Check Results ---"
    $summary_content += "Files Without Non-Printable Characters: $files_without_issues out of $total_files"
    $summary_content += "Files With Non-Printable Characters: $files_with_issues out of $total_files"

    if ($files_with_issues -gt 0) {
        $summary_content += ""
        $summary_content += "Files containing non-printable characters:"
        $summary_content += $files_with_issues_names | ForEach-Object { "  - $([System.IO.Path]::GetFileName($_)) (see $([System.IO.Path]::GetFileName($_).Replace('.xml', '_nonprintable.txt')) for details)" }
    }

    $summary_content += ""
    $summary_content += "--- End of Summary ---"

    $summary_file = Join-Path -Path $directory_path -ChildPath "validation_and_ascii_summary.txt"
    $summary_content | Out-File -FilePath $summary_file -Encoding ASCII
    Write-Host "Summary written to: $summary_file"
}

# Main script logic
$input_type = show_selection_dialog

if ($input_type -eq 'Folder') {
    $directory_path = get_file_or_directory -is_directory $true
    if (-not $directory_path) {
        Write-Host "No directory selected."
        exit
    }

    $check_type = show_validation_type_dialog

    $xml_files = Get-ChildItem -Path $directory_path -Filter *.xml -File
    $total_files = $xml_files.Count
    $valid_files = 0
    $invalid_files = 0
    $files_without_issues = 0
    $files_with_issues = 0
    $invalid_file_names = @()
    $files_with_issues_names = @()

    # Perform XSD validation if selected
    if ($check_type -eq 'XSD' -or $check_type -eq 'Both') {
        $schema_file_path = get_file_or_directory -is_directory $false -filter "XSD Files (*.xsd)|*.xsd|All Files (*.*)|*.*"
        foreach ($file in $xml_files) {
            $is_valid = test_xml_file -schema_file $schema_file_path -xml_file $file.FullName
            if ($is_valid) { 
                $valid_files++ 
            } else { 
                $invalid_files++
                $invalid_file_names += $file.Name 
            }
        }

        if ($valid_files -eq $total_files) {
            Write-Host "All XML files passed XSD validation."
        }
    }

    # Perform Non-ASCII check if selected
    if ($check_type -eq 'NonASCII' -or $check_type -eq 'Both') {
        foreach ($file in $xml_files) {
            $has_no_issues = check_non_printable_characters -file_path $file.FullName
            if ($has_no_issues) { 
                $files_without_issues++ 
            } else { 
                $files_with_issues++
                $files_with_issues_names += $file.Name 
            }
        }

        if ($files_without_issues -eq $total_files) {
            Write-Host "No non-ASCII characters found in any files."
        }
    }

    # Generate combined summary if both checks were run
    if ($check_type -eq 'Both') {
        generate_combined_summary -total_files $total_files -valid_files $valid_files -invalid_files $invalid_files -files_without_issues $files_without_issues -files_with_issues $files_with_issues -invalid_file_names $invalid_file_names -files_with_issues_names $files_with_issues_names -directory_path $directory_path
    }

} else {
    # Single file selection
    $file_path = get_file_or_directory -is_directory $false
    if (-not $file_path) {
        Write-Host "No file selected."
        exit
    }

    $file_directory = [System.IO.Path]::GetDirectoryName($file_path)

    $check_type = show_validation_type_dialog

    # Perform XSD validation for single file
    if ($check_type -eq 'XSD' -or $check_type -eq 'Both') {
        $schema_file_path = get_file_or_directory -is_directory $false -filter "XSD Files (*.xsd)|*.xsd|All Files (*.*)|*.*"
        $is_valid = test_xml_file -schema_file $schema_file_path -xml_file $file_path
        if ($is_valid) {
            Write-Host "File passed XSD validation."
        } else {
            Write-Host "File failed XSD validation."
        }
    }

    # Perform Non-ASCII check for single file
    if ($check_type -eq 'NonASCII' -or $check_type -eq 'Both') {
        $has_no_issues = check_non_printable_characters -file_path $file_path
        if ($has_no_issues) {
            Write-Host "File contains no non-ASCII characters."
        } else {
            Write-Host "Non-printable characters found in the file."
        }
    }

    # Generate combined summary for single file if both checks were run
    if ($check_type -eq 'Both') {
        generate_combined_summary -total_files 1 -valid_files $([int]$is_valid) -invalid_files $([int](!$is_valid)) -files_without_issues $([int]$has_no_issues) -files_with_issues $([int](!$has_no_issues)) -invalid_file_names @($file_path) -files_with_issues_names @($file_path) -directory_path $file_directory
    }
}
