LED_Master
============

## Dependencies
 - You need to install [Löve](https://love2d.org/#download)

## Usage
### Get the code.
1. Clone the repository. `git clone git@github.com:spectrenoir06/LED_master.git`
2. Clone the submodules: `git submodule update --init --recursive`
### Run it
#### Linux
`love .`
#### OSX
`/Applications/love.app/Contents/MacOS/love .`
#### Windows
`"C:\Program Files\LOVE\love.exe" --console .`
#### More info
[Here](https://love2d.org/wiki/Getting_Started)

## Roadmap

- Work
  - Protocol
    - [x] Art-net
    - [x] RGB888
    - [x] RGB565
    - [x] RLE888
    - [x] BRO888 (brotli)
    - [x] Z888 (zlib)
    - [ ] udpx
  - Shader
    - [x] Fragment Shader
    - [x] External parameter
    - [ ] FFT sound input ( FFT => canvas => shader:send )
    - [x] Drag and drop
  - Music
    - [x] Music Loader
    - [x] FFT visualization
    - [x] Microphone In
    - [x] Aux In
    - [x] Drag and drop
  - Video
    - [x] Video Loader
  - Script
    - [x] Custom script loader
    - [x] Drag and drop
    - [ ] Doc
  - Pixel mapping
    - [x] Viewer
    - [ ] Editor
  - Network mapping
    - [x] Viewer
    - [ ] Editor
  - Network discovery
    - [x] Art-net
    - [ ] ?
  - Setting
    - [x] Canvas size
    - [x] Brightness
    - [ ] White mode
  - Animation
    - [ ] Loader
    - [ ] Editor
    - [ ] Saver
  - Compatibility ( need test )
    - [x] Linux
    - [x] Windows
    - [x] OSX
    - [x] Android
    - [ ] iOS
    - [x] Raspberry Pi
    - [ ] Nintendo Switch
  - Ideas
    - Screen grabber
