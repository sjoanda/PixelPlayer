/* Program name         PixelPlayer
   Version              03-00
   Author               Jennifer M Lawson
   SRN                  120455801
   Course               CO3346 Sound and Music
   Coursework Number    2
   Date Written         21-Mar-2015
   Date last Modified   04-Apr-2015
   Source               MusicSketchVersionTwoAverageColour.pde
   Phase                Development

   This program plays a riff of 3 colours, plus one extra - currently pattern is
   RGBG.  Using RGB gives pleasing three-note melodies, however four patterns
   mimics the baroque style of composition

   ------------------------------------------------------------------------------

   Change record:

   04-Apr-15  JL  :  Started Development - yet again - from scratch
   05-Apr-15  JL  :  Aiming to sort button spacings and ensure they redraw correctly,
                     as they're currently overlapping.
   06-Apr-15  JL  :  Changed program so it plays a riff of 3 colours, plus one extra
                     - currently pattern is RGBG.  Using RGB gives pleasing three-note
                     melodies, however four patterns mimics the baroque style of composition
   ------------------------------------------------------------------------------
*/

/* Please ensure you have installed themidibus library, using "Sketch", "Import Library"
   option.
*/

import themidibus.*;

/***************************/

String VersionString = "03-00";

/***************************/

// Screen Data
//the following not used as size(x,y) now does not accept variables
int WINDOW_WIDTH_IN_PIXELS = 600;
int WINDOW_HEIGHT_IN_PIXELS = 400;

PImage PlayThisImage;

PImage MainImage;
PImage AltOne;
PImage AltTwo;
PImage AltThree;
PImage AltFour;
PImage AltFive;
PImage AltSix;

int thisimage = 0;
int TotalImages = 7;

int DEFAULT_FRAMERATE = 100;

int changetime     = 1;
int MIDIStartDelay = 75;
int MIDIStopDelay  = 25;

boolean PlayingStatus = false;

/***************************/

// Image Sampling Data

int CurrentCell;
int DownCounter;

int NUMBER_OF_COLUMNS = 16;
int NUMBER_OF_ROWS = 8;
//int TEMP_NUMBER_OF_COLUMNS;
//int TEMP_NUMBER_OF_ROWS;

int NUMBER_OF_PIXEL_CELLS;

int CELL_WIDTH;
int CELL_HEIGHT;

int DOWNLOAD_REFRESH_VALUE = DEFAULT_FRAMERATE / 2;  /* 120 BPM */

int Redint   = 60;
int Greenint = 40;
int Blueint  = 80;

/***************************/

// Audio Data

MidiBus myBus; // The MidiBus

//AudioSample beep;

int ColourNumberRed;
int ColourNumberGreen;
int ColourNumberBlue;
String MusicalNoteName;

int pitch;
int channel  = 0;
int velocity = 127;

/***************************/

// Button Data

final int _NUMBER_OF_BUTTONS                    = 8;
final int _BUTTON_HEIGHT_FROM_TOP               = 300;
final int _BUTTON_X_FIRST_BUTTON_POSITION       = 50;
final int _BUTTON_SPACING                       = 60;

int ButtonWidth  = 40;
int ButtonHeight = 40;

//Button images
PImage PressingButton;
PImage DropShadow;

// Button Data arrays
int  ButtonXPosition[]    = new int [_NUMBER_OF_BUTTONS];
int  ButtonYPosition[]    = new int [_NUMBER_OF_BUTTONS];

/***************************/

// ButtonPressed Data

int ButtonNumber = 0;
int ImageNumber  = 0;


/*******************************************************************************/

void setup()
{
   println("PixelPlayer " + VersionString);
   
   /***************************/
   /* Setup screen basics */
   size(600,400);
   background(#ffffff);
   
   try
      {
      /* Load in the main image */
      /* NOTE : The image should be suitably rescaled, and saved as .png or .jpg format.
      Files saved as .JPG do not work - possibly because the files tried were too big. */
      MainImage = loadImage("Moonlightoverdarkwaters.png");
      }
   catch (NullPointerException e)
      {
      e.printStackTrace();
      println("? Can't load image... ");
      }
   
   /***************************/
   /* Setup A Selection of Images */
   
   PlayThisImage = MainImage;
   AltOne    = loadImage("AltOne.png");
   AltTwo    = loadImage("AltTwo.png");
   AltThree  = loadImage("AltThree.png");
   AltFour   = loadImage("AltFour.png"); // This image is used to check that a scale is played
                                         // when using a gradient
   AltFive   = loadImage("AltFive.png"); //image from https://www.flickr.com/photos/64092228@N00/2505946893/
                                         // Included to show effect of disjoint colours on the sounds produced 
   AltSix    = loadImage("AltSix.png"); // Image is a John Martin 1852 painting, Sodom and Gomorrah, and is
                                        // included to test how closely the mood is mirrored by the colour
                                        // sounds produced
    
   /* Load the image into our window and size it to fit window */   
   image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
   
   /***************************/
   /* Setup Playback / Sound */
     
   /* Use the frameRate as a basic time base for playback. Crude but effective and
      easier than using a GTimer.  Set up our basic time keeping mechanism... */
   DownCounter = DOWNLOAD_REFRESH_VALUE;
   frameRate(DEFAULT_FRAMERATE);

//   minim = new Minim(this);
//   beep = minim.loadSample("beep.mp3", 512);
   
   /* Setup midi using themidibus library.  Method based on Basic sketch in library of
      examples provided with themidibus.*/
      
   MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
   
    //               Parent In Out
    //                  |    |  |
   myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

   
   /***************************/
   /* Setup cells */
   
   int NUMBER_OF_PIXEL_CELLS = NUMBER_OF_COLUMNS * NUMBER_OF_ROWS;

   int CELL_WIDTH  = WINDOW_WIDTH_IN_PIXELS / NUMBER_OF_COLUMNS;
   int CELL_HEIGHT = WINDOW_HEIGHT_IN_PIXELS / NUMBER_OF_ROWS;
   
   CurrentCell = 0; 
   //TEMP_NUMBER_OF_COLUMNS  = NUMBER_OF_COLUMNS;
   //TEMP_NUMBER_OF_ROWS     = NUMBER_OF_ROWS;
   
   /***************************/
   /* Create the buttons */
   PressingButton          = loadImage("button.png");
   DropShadow              = loadImage("Dropshadow.png");
  
   
   myBus.sendMessage(0xC0, 0, 98, 0);
   
}

/*******************************************************************************/

/* this is the main control loop for the program. Here, we do cleveer stuff, and make chocolate fluffies and nice things.

*/

void draw()
{
  /* This is our pox rotten timing scheme. A better way of doing this would be to 
     use  GTimer.
  */ 

      --DownCounter;
     if (DownCounter == 0)
      {
      image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
      DownCounter = DOWNLOAD_REFRESH_VALUE;
//      beep.trigger();
      MakeMeMyButtons();
      DrawCurrentCell(CurrentCell);

        CurrentCell++;
        if (CurrentCell == NUMBER_OF_PIXEL_CELLS) 
           CurrentCell = 0;  
        }
}

/*******************************************************************************/

// cellx = top left x coord
// celly = top left y coord

void DrawCurrentCell(int CellNumber)
{
   int CurrentRow    = CellNumber / NUMBER_OF_COLUMNS;
   int CurrentColumn = CellNumber % NUMBER_OF_COLUMNS;
   
   CalculateCells();

   int Cellx = CurrentColumn * CELL_WIDTH;
   int Celly = CurrentRow * CELL_HEIGHT;
   
   /***************************/
   //draw a box around the cell
   stroke(255);
   line(Cellx, Celly, (Cellx + CELL_WIDTH), Celly);   
   line(Cellx + CELL_WIDTH, Celly, (Cellx + CELL_WIDTH), (Celly + CELL_HEIGHT));   
   line((Cellx + CELL_WIDTH), (Celly + CELL_HEIGHT), Cellx, Celly + CELL_HEIGHT);   
   line(Cellx, Celly + CELL_HEIGHT, Cellx, Celly); 
   
   /***************************/
   // get average colour of the cell, and temporarily fill that cell with that colour.
   
   color CellColour = GetColourOfCell(CellNumber);  

   fill(CellColour);
   rect(Cellx, Celly, CELL_WIDTH, CELL_HEIGHT);

}

/*******************************************************************************/

void CalculateCells()
{
  NUMBER_OF_PIXEL_CELLS = NUMBER_OF_COLUMNS * NUMBER_OF_ROWS;
  
  CELL_WIDTH  = WINDOW_WIDTH_IN_PIXELS / NUMBER_OF_COLUMNS;
  CELL_HEIGHT = WINDOW_HEIGHT_IN_PIXELS / NUMBER_OF_ROWS;
}

/*******************************************************************************/

color GetColourOfCell(int CellNumber) 
{
   int CurrentRow    = CellNumber / NUMBER_OF_COLUMNS;
   int CurrentColumn = CellNumber % NUMBER_OF_COLUMNS;
   
   int X_Position = CurrentColumn * CELL_WIDTH;
   int Y_Position = CurrentRow * CELL_HEIGHT;

   PImage CellImage = PlayThisImage.get(X_Position, Y_Position, CELL_WIDTH, CELL_HEIGHT);
   
   color AverageColour = getAverageColor(CellImage);
   //println("Average Colour is " + hex(AverageColour, 6));
   ColourNumberRed = Redint;
   ColourNumberGreen = Greenint;
   ColourNumberBlue = Blueint;
   MidiLookup(ColourNumberRed);
   MidiLookup(ColourNumberGreen);
   MidiLookup(ColourNumberBlue);
   MidiLookup(ColourNumberGreen);


   return AverageColour;
}

/*******************************************************************************/

color getAverageColor(PImage img) 
{
   img.loadPixels();
   int r = 0, g = 0, b = 0;
   for (int i=0; i<img.pixels.length; i++) 
      {
      color c = img.pixels[i];
      r += c>>16&0xFF;
      g += c>>8&0xFF;
      b += c&0xFF;
      }
   
   r /= img.pixels.length;
   g /= img.pixels.length;
   b /= img.pixels.length;
   
   Redint   = r;
   Greenint = g;
   Blueint  = b;
   
   //println("Red = " + Redint + " , Green = " + Greenint + " , Blue = " + Blueint);
  
   return color(r, g, b);
}

/**********************************************************************************/

void MakeMeMyButtons()
{
   int ButtonNumber = 0;
   while (ButtonNumber < _NUMBER_OF_BUTTONS)
      {
      MakeButton(ButtonNumber, PressingButton, (_BUTTON_X_FIRST_BUTTON_POSITION + (_BUTTON_SPACING * (ButtonNumber + 1))), _BUTTON_HEIGHT_FROM_TOP);   
      ++ButtonNumber;
      }
}

/**********************************************************************************/

// Make a button using the ButtonPosition arrays of data.

void  MakeButton(int ImageNumber, PImage Button, int ButtonXPositionValue, int ButtonYPositionValue)
{
   ButtonXPosition[ImageNumber] = ButtonXPositionValue;
   ButtonYPosition[ImageNumber] = ButtonYPositionValue;

   image(PressingButton, ButtonXPositionValue, ButtonYPositionValue, ButtonWidth, ButtonHeight);
}

/**********************************************************************************/

/* ButtonPressed(0 is called to tell us if the mouse has been clicked within the 
   confines of the button space
*/

boolean ButtonPressed(int ThisButtonNumber)
{
   boolean X_Hit = false;
   boolean Y_Hit = false;
   boolean ReturnStatus = false;

   if ((mouseX > ButtonXPosition[ThisButtonNumber]) && (mouseX < (ButtonXPosition[ThisButtonNumber] + ButtonWidth)))
      X_Hit = true;
      
   if ((mouseY > ButtonYPosition[ThisButtonNumber]) && (mouseY < (ButtonYPosition[ThisButtonNumber] + ButtonHeight)))
      Y_Hit = true;
      
   if (X_Hit && Y_Hit)
      ReturnStatus = true;


   return ReturnStatus;   
}

/**********************************************************************************/

/* mousePressed() is the handler for the system mousePressed() event. 

   Here, we look to see if any of the buttons have been pressed, returning
   true if they have, otherwise false.
*/

void mousePressed()
{
boolean ButtonStatus = false;
boolean ButtonPressed;

   for (int ButtonNumber = 0; ButtonNumber < _NUMBER_OF_BUTTONS; ButtonNumber++)
     {
     ButtonStatus = ButtonPressed(ButtonNumber);
     if (ButtonStatus == true)
        {
        switch(ButtonNumber)
          {
          case 0:
            /* Go to the previous image */
            ImageSelect(--thisimage);
            println("Button number " + ButtonNumber + " is hit");
            break;
          case 1:
            /* Go to next image */
            ImageSelect(++thisimage);
               println("Button number " + ButtonNumber + " is hit");
            break;
          case 2:
             /* Play or pause pixels playback */
                if (PlayingStatus == false)
                {
                  PlayingStatus = true;
                }
                else if (PlayingStatus == true)
                {
                  PlayingStatus = false;
                }
                println("Button number " + ButtonNumber + " is hit");
            break;
          case 3:
             /* Double cell size*/
                CurrentCell = 0;
                NUMBER_OF_COLUMNS = NUMBER_OF_COLUMNS / 2;
                NUMBER_OF_ROWS    = NUMBER_OF_ROWS / 2;
                CalculateCells();
                println("Button number " + ButtonNumber + " is hit");
            break;
          case 4:
             /* Half cell size */
                CurrentCell = 0;
                NUMBER_OF_COLUMNS = 2 * NUMBER_OF_COLUMNS;
                NUMBER_OF_ROWS    = 2 * NUMBER_OF_ROWS;
                CalculateCells();
                println("Button number " + ButtonNumber + " is hit");
            break;
          case 5:
             /* Change Tempo Down */          
                ++changetime;
                MIDIStartDelay = 75 * changetime;
                MIDIStopDelay  = 25 * changetime;
                println("Button number " + ButtonNumber + " is hit");
            break;
          case 6:
             /*  Change Tempo Up */
                --changetime;
                MIDIStartDelay = 75 * changetime;
                MIDIStopDelay  = 25 * changetime;
                println("Button number " + ButtonNumber + " is hit");
            break;
          case 7:
             /* Blue from RGB gives note */
                //ColourNumber = Blueint;
                println("Button number " + ButtonNumber + " is hit");
            break;
           /*case 8:
             /* Go to last image.. */
             /*   println("Button number " + ButtonNumber + " is hit");
            break;
          case 9:
             /* Go to last image.. */
             /*   println("Button number " + ButtonNumber + " is hit");
            break;*/
            
          }
        break;
        }
     }
}
/*******************************************************************************/

void ImageSelect(int thisimage)
{
   switch(thisimage)
      {
      case 0:
         /* Go to the MainImage */
         PlayThisImage = MainImage;
         CurrentCell = 0;
         //image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
         println("Image is MainImage");
         break;

   case 1:
      /* Go to the first alternative image */
      PlayThisImage = AltOne;
      CurrentCell = 0;
      //image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
      println("Image is AltOne");
   break;
   
   case 2:
      /* Go to the second alternative image */
      PlayThisImage = AltTwo;
      CurrentCell = 0;
      //image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
      println("Image is AltTwo");
   break;
   
   case 3:
      /* Go to the third alternative image */
      PlayThisImage = AltThree;
      CurrentCell = 0;
      //image(PlayThisImage, 0, 0, WINDOW_WIDTH_IN_PIXELS, WINDOW_HEIGHT_IN_PIXELS);
      println("Image is AltThree");
   break;
   
   case 4:
      /* Go to the fourth alternative image */
      PlayThisImage = AltFour;
      println("Image is AltFour");
   break;
   
   case 5:
      /* Go to the fifth alternative image */
      PlayThisImage = AltFive;
      println("Image is AltFive");
   break;   

   case 6:
      /* Go to the sixth alternative image */
      PlayThisImage = AltSix;
      println("Image is AltSix");
   break; 
   }
}

/**********************************************************************************/

/* MidiLookup() is called to convert the value passed as a parameter into a MIDI note
   number (0..127).

   We do some basic mugtrapping to make sure that we don't send a load of rubbisgh to
   the MIDI synthesiser because that will really piss David off, especially if he has to 
   reboot/reflash his precious JD800.
*/

void MidiLookup(int ColourNumber)
{
   println("Colour Number is " + ColourNumber);
   // Take modulus of Colour Number to find octave
   int Note   = ColourNumber / 12;
   int Octave = ColourNumber % 12;
   //println("Octave is : " + Octave);
   //println("Note is : " + Note);
   
   /* Adjust the note to be within a pleasing note range to the ear, using the inbuilt
      MIDI library.
   */
   if ((ColourNumber > 24) && (ColourNumber < 72))
      pitch = ColourNumber;
   else if (ColourNumber < 24)
      {
      ColourNumber = ColourNumber + 24;
      pitch = ColourNumber;
      }
   else if (ColourNumber > 72)
      {
      ColourNumber = ColourNumber / 2;
      pitch = ColourNumber;
      }
 
   println("Colour Number is " + ColourNumber);
  
   //int channel = 0;
   // velocity gives dynamic range
   int velocity = 127;
 
 //  int number = 0;
 //  int value = 90;
   
   //myBus.sendControllerChange(channel, number, value); // Send a controllerChange
   //delay(2000);
  
/***************************/
/* Print note name to console to check note lookup is working as expected
   This method was discontinued in favour of a wider span of possible notes, however
   is left in the program as a useful method of debugging/reference, should it be required.
/*   switch(Note)
   {
     case 0:
        MusicalNoteName = ("Note is C"); 
        pitch = 60;
     break;
     case 1:
        MusicalNoteName = ("Note is C Sharp"); 
        pitch = 61;
     break;
     case 2:
        MusicalNoteName = ("Note is D"); 
        pitch = 62;
     break;
     case 3:
        MusicalNoteName = ("Note is E flat"); 
        pitch = 63;
     break;
     case 4:
        MusicalNoteName = ("Note is E"); 
        pitch = 64;     
     break;
     case 5:
        MusicalNoteName = ("Note is F"); 
        pitch = 65;
     break;
     case 6:
        MusicalNoteName = ("Note is F Sharp"); 
        pitch = 66;
     break;
     case 7:
        MusicalNoteName = ("Note is G"); 
     break;
     case 8:
        MusicalNoteName = ("Note is G Sharp"); 
        pitch = 67;
     break;
     case 9:
        MusicalNoteName = ("Note is A"); 
        pitch = 68;
     break;
     case 10:
        MusicalNoteName = ("Note is B flat"); 
        pitch = 69;
     break;
     case 11:
        MusicalNoteName = ("Note is B"); 
        pitch = 70;
     break;
     case 12:
        MusicalNoteName = ("Note is high C");
        pitch = 71;
     break;
   }*/
   
/***************************/
 /* These are the control MIDI on/off signals.  The pitch timing and delay
    is set so that repeated notes will "clip" slightly, thus producing a rhythmic
    effect which breaks the monotony. 
*/ 
   
   myBus.sendNoteOn(channel, pitch + 12, velocity); // Send a Midi noteOn   
   delay(MIDIStartDelay);
   myBus.sendNoteOff(channel, pitch + 12, velocity); // Send a Midi nodeOff
   delay(MIDIStopDelay);
   
   //println(MusicalNoteName);
}

/**********************************************************************************/
//END OF FILE
/**********************************************************************************/