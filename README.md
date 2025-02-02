# Homage to TST D0

This is a demo for the Atari ST family, developed by Djaybee and
Pandafox from the MegaBuSTers, in collaboration with AD from MPS.

This is a fake cracktro, i.e. it is meant to look like the
type of intro that crackers would typically add to games after
removing the copy protections. It wasn't originally developed
to be used as a true cracktro, given that there are no new games
to crack yet, but, by virtue of being Open Source, it can be used
as such if someone wants to.

This is meant to be an homage to TST D0, a cracker from the era
of the Atari ST, who passed away in an accident. Some cracktro
work had been an opportunity for collaboration between VMax and
the MegaBuSTers, which is captured in
[this YouTube video](https://youtu.be/gM9xbzor0TI?si=HSIA2ELya2SluoCb).

The demo is believed to run on a wide variety of ST hardware,
from a plain 520 ST all the way to the TT or Falcon. However,
it ignores any hardware beyond that of a plain ST, such that
it neither uses those capabilities nor disables them, which
could cause compatibility issues. It needs to be launched from
ST Low or ST medium resolution, and launching from other
resolutions will have undesired effects.

It's been developed with rmac 2.2.25 and tested under Hatari
v2.6.0-devel with EmuTOS 1.3.

# Timeline and design thoughts

Jan 13 2025: announcement for a fake cracktro showcase in mid-March.
Jan 14 2025: Pandafox and Djaybee agree to work on such a fake cracktro
and announce the MegaBuSTers' participation.
Jan 20-21 2025: Pandafox suggests a remake of the VMax cracktro,
possibly with enhancements as possible, ideally starting with
something faithful to the original and progressively evolving into
the enhanced version. Hints at the possibility of some distortion
on the 3D cubes.
Jan 21 2025: Pandafox proposes a redrawn logo.
Jan 22 2025: Djaybee explores the possibilities behind the 3D cubes.
Precomputing a long animation might take a lot of RAM (450kiB for 8
seconds of 96*96*1bpp), while rendering it in real-time would limit
the complexity and/or require optimizations that there might not be
enough time to develop. A hybrid solution could be possible, precomputing
some of the frames and rendering the other frames on-demand (but
in sub-real-time).
Jan 22 2025: Djaybee sets up the baseline git project.
Jan 23 2025: Technically, mode 0 pixels are skinny 59:64 in PAL,
which gives a hint about how large the 3D cubes need to be to have
the proper aspect ratio on a real ST with a real TV.
Jan 25 2025: Explorations in precomputing the 3D -> 2D coordinate
transforms. Those computations are easy to do in C with floating-point
numbers. In a naive implementation, each line can be made to take
4 bytes (xy coordinates 0-255). A plain cube without any decoration
takes at most 9 lines (3 faces visible), i.e. 36 bytes. An MB logo
can be drawn with 10 lines, visible on about half of the frames.
That adds up to 50-60 bytes per frame, 500 frames for a 10-second
animation, less than 30kB overall.
A line can be defined by a start point (offset + bit number), a
direction, a Bresenham increment, and a number of pixels. For a
maximum size of 128x128, the offset fits in 10 bits (1024 words),
the bit number takes 4 bits, there are 4 possible directions (2 bits).
8 bits fit the Bresenham increment, and 7 bits is enough for the pixel
count, with one bit to spare to mark the end of the frame.
That all fits in 4 bytes.
Jan 26 2025: The line data mentioned yesterday is enough to draw
lines aligned on exact pixels, but not for partial pixels, which
would potentially result in smoother animation (i.e. sub-pixel
precision for the line positioning). The initial partial pixel
count for Bresenham might therefore need to be stored as well,
which would be a 5th byte per line.
Feb 02 2025: Moving toward a proper cube
```
              4
    4+---------------+5
    /|              /|
  8/ |            9/ |
  /  |    0       /  |
0+---------------+1  |
 |   |5          |   |6
 |   |           |   |
 |   |           |   |
1|   |        7  |2  |
 |  6+-----------|---+7
 |  /            |  /
 | /10           | /11
 |/       3      |/
2+---------------+3
```


# What's in the package

The distribution package contains this `README.md` file, the main
`LICENSE` file for the final, an alternative `LICENSE_ASSETS`
if you extract non-code assets from the demo or its source tree,
and an `AGPL_DETAILS.md` file to explain the original author's
intentions for compliance with the AGPL license.

The demo itself is provided under 5 forms in the package:
* A naked `TSTD0HMG.PRG` file meant to be executed e.g. from with
an emulator with GEMDOS hard drive emulation.
* A `tstd0mhg.st` uncompressed floppy image.
* A `tstd0hmg.msa` compressed floppy image.
* A copy of the source tree `src.zip` that was used to compile
the demo.
* The full source history as a git bundle `tstd0hmg.bundle` which
can be cloned with `git clone tstd0hmg.bundle`.

# Building

The build process expects to have
rmac, cc, upx, hmsa, git and zip in the path.
Rmac can be found on [the official rmac web site](https://rmac.is-slick.com/).
UPX is [the Ultimate Packer for eXecutables](https://upx.github.io/).
Hmsa is part of [the Hatari emulator](http://hatari.tuxfamily.org/).

A regular build can be done in a single script `build.sh` which is
useful during most incremental development. However, using the music
from the editable file requires some manual steps:

## Converting the music

The music in its original form is delivered as an SNDH file, which
combines player code and music data. While the music data was created
specifically for this demo, the player code has licensing restrictions
that make it unsuitable for integration into Open Source binaries, and
especially copyleft ones.

To avoid those restrictions, the music data is extracted as a raw
dump of the YM2149F registers, which is a pure derivative of the
music data and contains no trace of the player itself. That dump
is generated from within an emulated ST.

The end-to-end process involved running `audioconvert.sh` to build
the dumping program `ACONVERT.PRG`, which needs to be run from within
an Atari emulator (or on real hardware for the more adventurous),
where it generates the file `AREGDUMP.BIN` that can be copied back
into the source tree. `AREGDUMP.BIN` is provided in the source
tree already such that it's possible to modify the demo without
having to build and execute `ACONVERT.PRG`

# (Un)important things

## Licensing

The demo in this repository is licensed under the terms of the
[AGPL, version 3](https://www.gnu.org/licenses/agpl-3.0.en.html)
or later, with the following additional restriction: if you make
the program available for third parties to use on hardware you own
(or co-own, lease, rent, or otherwise control,) such as public
gaming cabinets (whether or not in a gaming arcade, whether or not
coin-operated or otherwise for a fee,) the conditions of section 13
will apply even if no network is involved.

As a special exception, the source assets for the demo (images, text,
music, movie files) as well as output from the demo (screenshots,
audio or video recordings) are also optionally licensed under the
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
License. That exception explicitly does not apply to source code or
object/executable code, only to assets/media files when separated
from the source code or object/executable file.

Licensees of the a whole demo or of the whole repository may apply
the same exception to their modified version, or may decide to
remove that exception entirely.

## Privacy

This code doesn't have any privacy implications, and has been
written without any thought about the privacy implications
that might arise from any changes made to it.

_Let's be honest, if using a demo on such an old computer,
even emulated, causes significant privacy concerns or in
fact any privacy concerns, the world is coming to an end._

### Specific privacy aspects for GDPR (EU 2016/679)

None of the code in this project processes any personal data
in any way. It does not collect, record, organize, structure,
store, adapt, alter, retrieve, consult, use, disclose, transmit,
disseminate, align, combine, restrict, erase, or destroy any
personal data.

None of the code in this project identifies natural persons
in any way, directly or indirectly. It does not reference
any name, identification number, location data, online
identifier, or any factors related to the physical, psychological,
genetic, mental, economic, cultural or social identity of
any person.

None of the code in this project evaluates any aspect of
any natural person. It neither analyzes nor predicts performance
at work, economic situation, health, personal preferences,
interests, reliability, behavior, location, and movements.

_Don't use this code where GDPR might come into scope.
Seriously. Don't. Just don't.

## Security

Generally speaking, the code in this project is inappropriate
for any application where security is a concern of any kind.

_Don't even think of using any code from this project for
anything remotely security-sensitive. That would be awfully
stupid._

_In the context of the Atari ST, there are no significant
security features in place when using the original ROMs.
Worse, to the extent that primitive security features might
exist at all (protection of the top 32kB and bottom 2kB of
the address space), the code disables them as much as possible,
e.g. running in supervisor mode in order to gain direct
access to hardware registers._

_Finally, the code is developed in assembly language, which
lacks the modern language features that help security._

### Specific security aspects for CRA (EU 2022/454)

None of the code in this project involves any direct or indirect
logical or physical data connection to a device or network.

Also, all of the code in this project is provided under a free
and open source license, in a non-commercial manner. It is
developed, maintained, and distributed openly. As of January
2025, no price has been charged for any of the code in this
project, nor have any donations been accepted in connection
with this project. The author has no intention of charging a
price for this code. They also do not intend to accept donations,
but acknowledge that, in extreme situations, donations of
hardware or of access to hardware might facilitate development,
without any intent to make a profit.

_This code is intended to be used in isolated environments.
If you build a connected product from this code, the security
implications are on you. You've been warned._

### Specific security aspects for NIS2 (EU 2022/2555)

The intended use for this code is not a critical application.
This project has been developed without any attention to the
practices mandated by NIS2 for critical applications.
It is not appropriate as-is for any critical application, and,
by its very nature, no amount of paying and auditing will
ever make it reach a point where it is appropriate.
The author will immediately dismiss any request to reach the
standards set by NIS2.

_Don't even think about it. Seriously. I'm not kidding. If you
are even considering using this code or any similar code for any
critical project, you should expect to get fired.
I cannot understate how grossly inappropriate this code is for
anything that might actually matter._
