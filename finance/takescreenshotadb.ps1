# Load the required .NET assemblies for image handling and clipboard access
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Function to run adb and capture the binary screenshot output
function Get-AdbScreenshot {
    # Set up the process to run adb with redirected output
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "adb"
    $processInfo.Arguments = "exec-out screencap -p"
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    # Start the process
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    # Read the binary output from adb
    $outputStream = $process.StandardOutput.BaseStream
    $memoryStream = New-Object System.IO.MemoryStream
    $outputStream.CopyTo($memoryStream)
    $process.WaitForExit()

    # Return the byte array of the screenshot
    return $memoryStream.ToArray()
}

# Capture the screenshot as a byte array
$imageData = Get-AdbScreenshot

# Create a memory stream from the byte array
$stream = New-Object System.IO.MemoryStream (,$imageData)

# Convert the stream to an image object
$image = [System.Drawing.Image]::FromStream($stream)

# Copy the image to the Windows clipboard
[System.Windows.Forms.Clipboard]::SetImage($image)

# Close the stream to free up resources
$stream.Close()