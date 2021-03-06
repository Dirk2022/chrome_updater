# ---------------------------------------------------------------------------------
# Chromium Updater v.1.0
# By Mikhail Tsennykh, 2012 (http://www.codeproject.com/Members/Mikhail-T)
# Chromium Updater v.1.2 
# By Dirk Paehl 2021/22 https://www.paehl.de
# ---------------------------------------------------------------------------------

# Pre-run actions
cls; ""; "Welcome to Chromium Updater!"; "v.1.2"; ""

# Download the 64bit otherwise the 32bit
$versionOS=64

# Load update settings
$config = [xml](get-content Chromium_Updater_Settings.xml -ErrorAction SilentlyContinue) 
if ($config -eq $null) { 
  ""; "Chromium_Updater_Settings.xml file is not found! It should reside in the same directory as main script."
  Start-Sleep -s 5; exit 
}
$chromium_archive_name = $config.settings.archive_name
$chromium_archive_ext  = $config.settings.archive_ext
$download_path = $env:USERPROFILE + "\"
if ($config.settings.download_path) { $download_path = $config.settings.download_path }
$install_path = $config.settings.install_path + "\" 
$install_path1 = $install_path + "chrome-win\"

# Set local variables
$source_archive_path = $download_path + $chromium_archive_name + $chromium_archive_ext
#$old_version_path = $install_path + $chromium_archive_name          # Chromium installation directory
$old_version_path = $install_path1 

# Download source archive (while deleting any previous copies)
if (Test-Path $source_archive_path) { Remove-Item -Recurse -Force $source_archive_path }
if ((Test-Path $source_archive_path) -eq $false) {
  # Get latest version of Chromium (continuous build)
  ""; "Checking for the latest Chromium build..."; ""
  
  $web = New-Object System.Net.WebClient
  
if ($versionOS -eq 64){ 
#$latest_version = $web.DownloadString("https://chromium.woolyss.com/api/?os=windows&bit=64&out=revision")
$latest_version = $web.DownloadString("https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2FLAST_CHANGE?&alt=media")
} else {
#32bit
$latest_version = $web.DownloadString(
"https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win%2FLAST_CHANGE?&alt=media")
}


  $Old_Version = Get-Content 'version.txt'
  if ($Old_Version -eq $latest_version) {
	 ""; "Chromium_update not needed."
    Start-Sleep -s 2; exit   
  }

  $FilePath = 'version.txt'
  $latest_version | Out-File $FilePath
  
  # If latest version is not null, download archive  
  if ($latest_version) {
    ""; "Continuous build " + $latest_version + " is being downloaded..."; ""

if ($versionOS -eq 64){ 
#64 version    
    $url = "https://download-chromium.appspot.com/dl/Win_x64?type=snapshots"
} else {  
  $url = "https://download-chromium.appspot.com/dl/Win?type=snapshots"  
}  
   $web.DownloadFile($url, $source_archive_path);

    # If download complete, start update
    ""; "Download complete! Proceeding..."; ""
    Start-Sleep -s 1    
  } 
}


# If source archive exists, proceed to update
if (Test-Path $source_archive_path) {
  $chromium_was_open = $false  # will be used to restart Chromium, if it was open before update
  # Close any open chrome windows first (use: 'Get-Process chrome' to show process details)
  if (Get-Process chrome -ErrorAction SilentlyContinue) {
    # Message
    ""; "Chromium will be closed for the update and will restart after update is done."; "" 
    $attempts = 10
    do {
    
      # Try to safely close Chromium
      Get-Process chrome | % { $_.CloseMainWindow() | out-null }
      # Remember if Chromium was open before update
      $chromium_was_open = $true  
      # Wait for some time so that Chromium will close correctly
    
      Start-Sleep -s 1
      $attempts = $attempts - 1
    }
    until ((Get-Process chrome -ErrorAction SilentlyContinue) -eq $null -Or $attempts -eq 0)
  }

  # If all Chromium windows are closed
  if ((Get-Process chrome -ErrorAction SilentlyContinue) -eq $null) {
    # Remove old version of Chromium, if it exists
    $new_install = $false
    if (Test-Path $old_version_path) {
      ""; "Chromium is being updated now. Please wait..."; ""    
      Remove-Item -Recurse -Force $old_version_path
    } else {
      $new_install = $true
      ""; "Chromium is being installed to:";
      $old_version_path; ""; "Please wait..."
    }
    
    # If installation directory is not present, create it
    if ((Test-Path $install_path1) -eq $false) {
      New-Item $install_path1 -type directory
    }
    
    # Unpack zip archive
    $zip_file_path = $source_archive_path
    $unzip_path = $install_path
    
    if (Test-Path $zip_file_path) { 
      $shellApplication = New-Object -com shell.application 
      $zipPackage = $shellApplication.NameSpace($zip_file_path) 
      $destinationFolder = $shellApplication.NameSpace($unzip_path) 
      $destinationFolder.CopyHere($zipPackage.Items(),0x14) 
    }  
  
    # Delete source archive:
    Remove-Item -Recurse -Force $source_archive_path
    
      # Success message
      ""; "Success! Enjoy your Chromium!"; "(this window will close automatically)"     
   
    
  } else {
    # If Chromium is still running, show message
    ""; "Chromium cannot be closed and/or it needs your attention..."
  }
}

# Wait for some time, before PowerShell window will automatically close
Start-Sleep -s 3