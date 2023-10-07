@echo off
rem Author: Shantanu Ramanujapuram
rem Dependencies: 
::  - ffmpeg (https://ffmpeg.org/download.html) 
::  - ascii-image-converter (https://github.com/TheZoraiz/ascii-image-converter)
::  - python (https://www.python.org/downloads/)
::  - requirements.txt (pip install -r requirements.txt)
rem Only one argument is required, the path to the video file.
rem This script is run assuming you have ffmpeg and ascii-image-converter installed and in your PATH.
rem This script assumes you have the required green screen video downloaded and in the same directory as this script.

rem Check if the user has provided a video file
if "%1"=="" (
    echo "Please provide a video file. Usage: ConvertVideoToAsciiFramesFull.cmd <path_to_video_file>"
    echo.
    echo "Try to keep the video file in the same directory as this script."
    exit /b
)

echo "Clearning Cache"
echo.
rmdir frames /s /q 

if not exist frames md frames
if not exist frames\NormalExtract md frames\NormalExtract
if not exist frames\AsciiFrames md frames\AsciiFrames

echo "Extracting frames from video"
echo.

set fps=30
ffmpeg -i "%1" -r %fps% frames\NormalExtract\out-%%03d.jpg

echo "Converting frames to ascii"
echo.

pushd frames
rem =========== Change these values to change the size of the output ===========
set width=100
set height=50
set servertype="flask"
rem ===========================================================================


set outputLoc=.\AsciiFrames
set framesLoc=.\NormalExtract
set filecnt=0
set fileindx=0
set completePerc=0

for %%A in (%framesLoc%\*.jpg) do set /a filecnt+=1
echo The number of frames is %filecnt%

setlocal enableextensions disabledelayedexpansion

@REM echo %%~nxi

for /r %%i in (%framesLoc%\*.jpg) do (
    set /A fileindx=fileindx+1
    set /A completePerc=fileindx*100/filecnt
    call :drawProgressBar !completePerc! "Processing frame %%~nxi"
    ascii-image-converter %framesLoc%\%%~nxi -n -b -d %width%,%height%  > %outputLoc%\%%~ni.txt
)

endlocal
popd 

echo.
echo Running python script to generate frames array

python make_frames_arr.py

exit /b
rem Clean all after use
call :finalizeProgressBar 1

:drawProgressBar value [text]
    if "%~1"=="" goto :eof
    if not defined pb.barArea call :initProgressBar
    setlocal enableextensions enabledelayedexpansion
    set /a "pb.value=%~1 %% 101", "pb.filled=pb.value*pb.barArea/100", "pb.dotted=pb.barArea-pb.filled", "pb.pct=1000+pb.value"
    set "pb.pct=%pb.pct:~-3%"
    if "%~2"=="" ( set "pb.text=" ) else ( 
        set "pb.text=%~2%pb.back%" 
        set "pb.text=!pb.text:~0,%pb.textArea%!"
    )
    <nul set /p "pb.prompt=[!pb.fill:~0,%pb.filled%!!pb.dots:~0,%pb.dotted%!][ %pb.pct% ] %pb.text%!pb.cr!"
    endlocal
    goto :eof

:initProgressBar [fillChar] [dotChar]
    if defined pb.cr call :finalizeProgressBar
    for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
    if "%~1"=="" ( set "pb.fillChar=#" ) else ( set "pb.fillChar=%~1" )
    if "%~2"=="" ( set "pb.dotChar=." ) else ( set "pb.dotChar=%~2" )
    set "pb.console.columns="
    for /f "tokens=2 skip=4" %%f in ('mode con') do if not defined pb.console.columns set "pb.console.columns=%%f"
    set /a "pb.barArea=pb.console.columns/2-2", "pb.textArea=pb.barArea-9"
    set "pb.fill="
    setlocal enableextensions enabledelayedexpansion
    for /l %%p in (1 1 %pb.barArea%) do set "pb.fill=!pb.fill!%pb.fillChar%"
    set "pb.fill=!pb.fill:~0,%pb.barArea%!"
    set "pb.dots=!pb.fill:%pb.fillChar%=%pb.dotChar%!"
    set "pb.back=!pb.fill:~0,%pb.textArea%!
    set "pb.back=!pb.back:%pb.fillChar%= !"
    endlocal & set "pb.fill=%pb.fill%" & set "pb.dots=%pb.dots%" & set "pb.back=%pb.back%"
    goto :eof

:finalizeProgressBar [erase]
    if defined pb.cr (
        if not "%~1"=="" (
            setlocal enabledelayedexpansion
            set "pb.back="
            for /l %%p in (1 1 %pb.console.columns%) do set "pb.back=!pb.back! "
            <nul set /p "pb.prompt=!pb.cr!!pb.back:~1!!pb.cr!"
            endlocal
        )
    )
    for /f "tokens=1 delims==" %%v in ('set pb.') do set "%%v="
    goto :eof