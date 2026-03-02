Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Files and Directory"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"

# Video file controls
$videoLabel = New-Object System.Windows.Forms.Label
$videoLabel.Text = "Video File:"
$videoLabel.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($videoLabel)

$videoTextBox = New-Object System.Windows.Forms.TextBox
$videoTextBox.Location = New-Object System.Drawing.Point(100, 20)
$videoTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($videoTextBox)

$videoButton = New-Object System.Windows.Forms.Button
$videoButton.Text = "..."
$videoButton.Location = New-Object System.Drawing.Point(310, 20)
$videoButton.Size = New-Object System.Drawing.Size(50, 20)
$form.Controls.Add($videoButton)

# Audio file controls
$audioLabel = New-Object System.Windows.Forms.Label
$audioLabel.Text = "Audio File:"
$audioLabel.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($audioLabel)

$audioTextBox = New-Object System.Windows.Forms.TextBox
$audioTextBox.Location = New-Object System.Drawing.Point(100, 60)
$audioTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($audioTextBox)

$audioButton = New-Object System.Windows.Forms.Button
$audioButton.Text = "..."
$audioButton.Location = New-Object System.Drawing.Point(310, 60)
$audioButton.Size = New-Object System.Drawing.Size(50, 20)
$form.Controls.Add($audioButton)

# Directory controls
$directoryLabel = New-Object System.Windows.Forms.Label
$directoryLabel.Text = "Directory:"
$directoryLabel.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($directoryLabel)

$directoryTextBox = New-Object System.Windows.Forms.TextBox
$directoryTextBox.Location = New-Object System.Drawing.Point(100, 100)
$directoryTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($directoryTextBox)

$directoryButton = New-Object System.Windows.Forms.Button
$directoryButton.Text = "..."
$directoryButton.Location = New-Object System.Drawing.Point(310, 100)
$directoryButton.Size = New-Object System.Drawing.Size(50, 20)
$form.Controls.Add($directoryButton)

# Combine button
$combineButton = New-Object System.Windows.Forms.Button
$combineButton.Text = "Combine Video & Audio"
$combineButton.Location = New-Object System.Drawing.Point(10, 140)
$combineButton.Size = New-Object System.Drawing.Size(350, 30)
$form.Controls.Add($combineButton)

# Event handlers
$videoButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Video Files (*.mp4;*.mkv;*.avi)|*.mp4;*.mkv;*.avi|All Files (*.*)|*.*"
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $videoTextBox.Text = $fileDialog.FileName
    }
})

$audioButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Audio Files (*.mp3;*.wav;*.aac)|*.mp3;*.wav;*.aac|All Files (*.*)|*.*"
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $audioTextBox.Text = $fileDialog.FileName
    }
})

$directoryButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $directoryTextBox.Text = $folderBrowser.SelectedPath
    }
})

$combineButton.Add_Click({
    if (-not ($videoTextBox.Text -and $audioTextBox.Text -and $directoryTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a video, an audio file, and a directory.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $outputFile = Join-Path -Path $directoryTextBox.Text -ChildPath "output.mp4"
    $ffmpegCommand = "ffmpeg -i `"$($videoTextBox.Text)`" -i `"$($audioTextBox.Text)`" -c:v libx265 -crf 24 -preset fast -c:a aac -b:a 160k `"$outputFile`""

    try {
        Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c $ffmpegCommand" -Wait
        [System.Windows.Forms.MessageBox]::Show("Video and audio combined successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred while combining the files.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Show the form
$form.ShowDialog()
