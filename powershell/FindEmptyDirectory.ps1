# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Create a Folder Browser Dialog
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select a Directory to Check for Empty Folders"

# Show the dialog and get the selected path
$dialogResult = $folderBrowser.ShowDialog()

if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $directoryPath = $folderBrowser.SelectedPath
    
    # Get all subfolders
    $folders = Get-ChildItem -Path $directoryPath -Directory

    # Initialize an array to store empty folders
    $emptyFolders = @()

    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        $items = Get-ChildItem -Path $folderPath -Recurse -Force
        
        if ($items.Count -eq 0) {
            $emptyFolders += $folderPath
        }
    }

    # Show results in a message box
    if ($emptyFolders.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No empty folders found in $directoryPath", "Result", 0, 64)
    } else {
        $emptyList = $emptyFolders -join "`n"
        [System.Windows.Forms.MessageBox]::Show("Empty Folders:`n$emptyList", "Result", 0, 48)
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("No directory selected. Exiting...", "Warning", 0, 16)
}
