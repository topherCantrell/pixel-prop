CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
 
    pinPIX1   = 0 ' Pixel output pins on J3
    pinPIX2   = 1
    pinPIX3   = 2
    pinPIX4   = 3

    pinPadP4 = 4 ' I/O pins brought to pads
    pinPadP5 = 5
    pinPadP6 = 6
    pinPadP7 = 7

    pinIOJ44 = 8 ' J4 I/O
    pinIOJ43 = 9
    pinIOJ42 = 10
    pinIOJ41 = 11            

    pinIOJ51 = 15 ' J5 I/O
    pinIOJ52 = 14
    pinIOJ53 = 13
    pinIOJ54 = 12

    pinCS   = 24 ' Micro SD pins
    pinDI   = 25
    pinSCLK = 26
    pinDO   = 27

OBJ    
    STRIP    : "NeoPixelStrip"    
    PST      : "Parallax Serial Terminal"
    SD       : "SDCard"

VAR
    byte sectorBuffer[2048]
      
pub main | i
                          
  ' Go ahead and drive the pixel data lines low.
  dira[pinPIX1] := 1
  outa[pinPIX1] := 0

  dira[pinPIX2] := 1
  outa[pinPIX2] := 0

  dira[pinPIX3] := 1                                                                 
  outa[pinPIX3] := 0

  dira[pinPIX4] := 1
  outa[pinPIX4] := 0

  STRIP.init

  PauseMSec(2000)   ' Give the user time to switch to terminal
  
  PST.start(115200) ' Start the serial terminal

  ' ======================================================================
  ' Test the SD card hardware
  ' ======================================================================
  
  ' - Format a 2G SD card for FAT (the default)
  ' - Create a file on the disk that starts with the text "2018"
  ' - Put the card into the card slot on the board
  
  PST.str(string("Reading the SD card ...",13))

  sectorBuffer[0] := 1
  sectorBuffer[1] := 2
  i := SD.start(@sectorBuffer, pinDO, pinSCLK, pinDI, pinCS)           

  PST.str(string("Return code: ")) 
  PST.hex(i,8)
  PST.char(13)

  SD.readFileSectors(@sectorBuffer,0,1)
  repeat i from 0 to 512
    PST.hex(sectorBuffer[i],2)
    PST.char(32)

  PST.char(13)
  
  ' ======================================================================
  ' Test the GPIO pins
  ' ======================================================================

  ' Jummper the I/O pins together in pairs as follows:
  '   - J4-1 to J5-1
  '   - J4-2 to J5-2
  '   - J4-3 to J5-3
  '   - J4-4 to J5-4

  dira[pinIOJ44] := 1
  dira[pinIOJ43] := 1
  dira[pinIOJ42] := 1
  dira[pinIOJ41] := 1

  outa[pinIOJ44] := 0
  outa[pinIOJ43] := 0
  outa[pinIOJ42] := 0
  outa[pinIOJ41] := 0

  PST.str(string("Testing GPIO (passes silently)",13))
  
  if ina[pinIOJ54]<>0 or ina[pinIOJ53]<>0 or ina[pinIOJ52]<>0 or ina[pinIOJ51]<>0
    PST.str(string("## IO Failed at 1",13))
    
  outa[pinIOJ44]:= 1
  if ina[pinIOJ54]<>1 or ina[pinIOJ53]<>0 or ina[pinIOJ52]<>0 or ina[pinIOJ51]<>0
    PST.str(string("## IO Failed at 2",13))

  outa[pinIOJ44]:= 0
  outa[pinIOJ43]:= 1
  if ina[pinIOJ54]<>0 or ina[pinIOJ53]<>1 or ina[pinIOJ52]<>0 or ina[pinIOJ51]<>0
    PST.str(string("## IO Failed at 3",13))

  outa[pinIOJ43]:= 0
  outa[pinIOJ42]:= 1
  if ina[pinIOJ54]<>0 or ina[pinIOJ53]<>0 or ina[pinIOJ52]<>1 or ina[pinIOJ51]<>0
    PST.str(string("## IO Failed at 4",13))

  outa[pinIOJ42]:= 0
  outa[pinIOJ41]:= 1
  if ina[pinIOJ54]<>0 or ina[pinIOJ53]<>0 or ina[pinIOJ52]<>0 or ina[pinIOJ51]<>1
    PST.str(string("## IO Failed at 5",13))

  ' ======================================================================
  ' Test the NEO Pixels and terminal round-trip
  ' ======================================================================

  PST.str(string("Press a key to redraw the pixels.",13))
  PST.str(string("You should get back YourKey + 1",13))

  STRIP.draw(2, @colors, @pixelPattern1, pinPIX1, 8)
  STRIP.draw(2, @colors, @pixelPattern2, pinPIX2, 8)
  STRIP.draw(2, @colors, @pixelPattern3, pinPIX3, 8)
  STRIP.draw(2, @colors, @pixelPattern4, pinPIX4, 8) 

  repeat
  
    i := PST.charIn
    i := i + 1
    PST.char(i)
    
    ' Draw the pattern on each strand (different colors)
    STRIP.draw(2, @colors, @pixelPattern1, pinPIX1, 256)
    STRIP.draw(2, @colors, @pixelPattern2, pinPIX2, 256)
    STRIP.draw(2, @colors, @pixelPattern3, pinPIX3, 256)
    STRIP.draw(2, @colors, @pixelPattern4, pinPIX4, 256)

' Make "main" private to run this simple test
pub pixelOnlyTest

  ' Go ahead and drive the pixel data lines low.
  dira[pinPIX1] := 1
  outa[pinPIX1] := 0

  dira[pinPIX2] := 1
  outa[pinPIX2] := 0
                                                                         
  dira[pinPIX3] := 1                                                                 
  outa[pinPIX3] := 0

  dira[pinPIX4] := 1
  outa[pinPIX4] := 0

  STRIP.init
  PauseMSec(1000)    

  repeat
    STRIP.draw(2, @colors, @PIXELTEST,  pinPIX1, 256)
    STRIP.draw(2, @colors, @PIXELTEST,  pinPIX2, 256)
    STRIP.draw(2, @colors, @PIXELTEST,  pinPIX3, 256)
    STRIP.draw(2, @colors, @PIXELTEST,  pinPIX4, 256)
    PauseMSec(1000)

PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

DAT   
pixelPattern1
    byte 1,0,1,1,0,0,1,0
    
pixelPattern2
    byte 2,0,2,2,0,0,2,0
    
pixelPattern3
    byte 3,0,3,3,0,0,3,0
    
pixelPattern4
    byte 4,0,4,4,0,0,4,0   

colors
         '   GG RR BB
    long $00_00_00_00  ' 0 Off
    long $00_00_05_00  ' 1 Red
    long $00_05_00_00  ' 2 Green    
    long $00_00_00_05  ' 3 Blue
    long $00_05_05_05  ' 4 White

dat
PIXELTEST   
    byte 1,2,1,1,1,1,1,1,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4
    byte 1,2,3,4,1,2,3,4,4,4,4,4,4,4,3,4    