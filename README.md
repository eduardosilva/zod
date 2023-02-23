# Zod - YouTube Music Separator

This application allows you to download a YouTube music video and separate it into five stems: vocals, drums, bass, piano, and other. The stems are exported as separate audio files that can be used for remixing or other purposes.

## Installation

* Clone the repository from GitHub: git clone https://github.com/eduardosilva/zod.git

## Usage

To run the application from the command line, use the following syntax:

```bash
zod.sh -u <url>
```

Replace <url> with the URL of the YouTube music video you want to download and separate.

The resulting stems will be saved in the "output" folder.

You can also use the following command to see the available options:

```bash
zod.sh -h 
```

## Options

* **-u, --url**: The URL of the YouTube video to download and separate (required).
* **-o, --output**: The output directory to save the separated stems (default: current directory).
* **-f, --filename**: Define a new name to the file (default: youtube file name)

## Technical Details

This application uses the following tools and technologies:

* Docker
* Python 3
* yt-dlp (a command line tool for downloading YouTube videos)
* spleeter (a command line tool for separation process)

The separation process is performed using the Spleeter library, which is built on top of deep learning models to separate audio into different stems. Spleeter is included in the application and does not require any additional installation.

## Limitations

This application may not work for all YouTube music videos, as some videos may be protected by copyright or may not have clear separation between the different stems. Additionally, the separation quality may vary depending on the complexity of the music and the quality of the original audio.

## Credits
Zod was developed by Eduardo Silva and is based on the Spleeter library by Deezer.

## License

This application is licensed under the MIT License. You are free to use, modify, and distribute this code for any purpose. However, the application is provided "as is" and without any warranty, and the authors are not liable for any damages or losses that may result from its use.
