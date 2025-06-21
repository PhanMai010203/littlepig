param (
    [string]$name = ""
)

# Load required .NET assemblies for image handling and clipboard access
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Function to capture screenshot from Android device via ADB
function Get-AdbScreenshot {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "adb"
    $processInfo.Arguments = "exec-out screencap -p"
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    $outputStream = $process.StandardOutput.BaseStream
    $memoryStream = New-Object System.IO.MemoryStream
    $outputStream.CopyTo($memoryStream)
    $process.WaitForExit()

    return $memoryStream.ToArray()
}

# Capture the screenshot as a byte array
$imageData = Get-AdbScreenshot

# Create a memory stream from the byte array
$stream = New-Object System.IO.MemoryStream (,$imageData)

# Load the image from the stream
$image = [System.Drawing.Image]::FromStream($stream)

# If a name is provided, add it as a caption to the image
if ($name -ne "") {
    $graphics = [System.Drawing.Graphics]::FromImage($image)
    $fontSize = [math]::Round($image.Height * 0.05)
    $font = New-Object System.Drawing.Font("Arial", $fontSize)
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(128, 0, 0, 0))  # Semi-transparent black

    # Calculate text position and size
    $textSize = $graphics.MeasureString($name, $font)
    $x = ($image.Width - $textSize.Width) / 2
    $y = $image.Height - $textSize.Height - 10
    $rect = New-Object System.Drawing.Rectangle($x, $y, $textSize.Width, $textSize.Height)

    # Draw background rectangle and text
    $graphics.FillRectangle($bgBrush, $rect)
    $graphics.DrawString($name, $font, $textBrush, $x, $y)

    # Clean up graphics resources
    $graphics.Dispose()
    $font.Dispose()
    $textBrush.Dispose()
    $bgBrush.Dispose()
}

# Copy the image to the clipboard
[System.Windows.Forms.Clipboard]::SetImage($image)

# Clean up resources
$stream.Close()
$image.Dispose()