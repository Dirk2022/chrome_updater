powershell ./Chromium_Updater.ps1

start h:\Progs\Chrome_portable\chrome-win\chrome.exe --flag-switches-begin --user-data-dir=..\profile --no-default-browser-check  --disable-logging --disable-breakpad  --autoplay-policy=user-required --flag-switches-end
exit