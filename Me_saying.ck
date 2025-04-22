SndBuf mySound => dac;

me.dir() + "/Me_saying.wav" => mySound.read;

0 => mySound.pos;

mySound.length() => now;