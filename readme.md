# Video To ASCII Art Converter

## Description

I made [this](https://github.com/ShanTen/FortniteDDAnimated) a while back now thought to myself huh, I wish I could do this with other videos. So I did.

The repository consists of two scripts, one that converts a video to ASCII art and the other a flask server to actually handle the curl request.

![](https://cdn.discordapp.com/attachments/1070991530015338576/1160196734186692698/output.gif)

## How to use

### Requirements/Perquisites
1. [Python 3.6+](https://www.python.org/downloads/)
2. [ffmpeg](https://ffmpeg.org/download.html) (make sure to add it to your path)
3. A video file (you can use [yt-dlp](https://github.com/yt-dlp/yt-dlp) to download videos from youtube)
4. A terminal that supports ANSI escape codes (I use [windows terminal](https://github.com/microsoft/terminal))
5. [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter)

### Steps
1. Clone the repo `git clone https://github.com/shanTen/VideoToASCIIArt.git`
2. Install the requirements `pip install -r requirements.txt`
3. run `ConvertVideoToAsciiFramesFull.cmd <SomeVideo.ext>` 
4. W A I T. (not too long)
5. run `python3 server.py`
6. In another tab/window run `curl localhost:7070` (or whatever port you set it to)
7. Enjoy! (optional)
