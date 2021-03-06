@echo off

:: Set repository info
set key={your-api-key}
set url={nuget-gallery-url}

:: Make sure the nuget executable is writable
attrib -R ..\.nuget\NuGet.exe

:: Make sure the nupkg files are writeable and create backup
IF EXIST *.nupkg (
	echo.
	echo Creating backup...
	forfiles /m *.nupkg /c "cmd /c attrib -R @File"
	forfiles /m *.nupkg /c "cmd /c move /Y @File @File.bak"
)

echo.
echo Updating NuGet...
cmd /c ..\.nuget\NuGet.exe update -Self

IF not exist c:\development\localnuget mkdir c:\development\localnuget

echo.
echo Creating package...
..\.nuget\NuGet.exe pack Package.nuspec -Verbose  -o c:\development\localnuget

:: Check if package should be published
IF /I "%2"=="Publish" goto :publish
goto :eof

:publish
IF EXIST *.nupkg (
	echo.
	echo Publishing package...
	echo API Key: %key%
	echo NuGet Url: %url%
	forfiles /m *.nupkg /c "cmd /c ..\.nuget\NuGet.exe push @File %key% -Source %url%"
	goto :eof
)

:eof