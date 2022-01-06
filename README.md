# chromium updater
Update the developer build with Powershell

# Chromium Updater v.1.0
# By Mikhail Tsennykh, 2012 (http://www.codeproject.com/Members/Mikhail-T)
# Chromium Updater v.1.2 
# By Dirk Paehl 2021/2022 https://www.paehl.de
# -------------------------------------------

This version works for the newest chromium version. Tested with Windows 11 and Windows 10. Standard Powershell version.

First open Chromium_Updater_Settings.xml with an editor and change the following


  
  <!-- Chromium archive temp download path (default: empty, will use user's home folder) -->
  <download_path>c:\temp\</download_path>
  
  <!-- Chromium install path (contents of the archive will be extracted there) -->
  <install_path>c:\Chrome_portable</install_path>
  
</settings>

now open the bat and change the c:\Chrome_portable\chrome-win\chrome.exe with your parameter and start the bat file or make a shortcut and start it.
The script check for an update if available download into the download_path and install into the install_path
