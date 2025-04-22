// Live_Performance.ck 
@import "smuck"

global float masterVolume;
global float tempo;
global int currentPattern;
global string currentOscType;
global float filterFreq;
global float filterQ;
global float reverbMix;

0.8 => masterVolume;
120.0 => tempo;
2 => currentPattern;
"tri" => currentOscType;
2000.0 => filterFreq;
1.0 => filterQ;
0.1 => reverbMix;

ezScore patterns[8];

ezScore pattern0("c4 c4 g4 g4 a4 a4 g4 | f4 f4 e4 e4 d4 d4 c4");
ezScore pattern1("c4:e:g c4:e:g g4:b:d g4:b:d a4:c5:e a4:c5:e g4:b:d g4:b:d");
ezScore pattern2("c4 e4 g4 c5 g4 e4 c4 e4 g4 b4 d5 g5 d5 b4 g4 b4");
ezScore pattern3("c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4");
ezScore pattern4("c4 c5 g4 g5 a4 a5 g4 g5 f4 f5 e4 e5 d4 d5 c4 c5");
ezScore pattern5("c4|q d4|e e4|e f4|q g4|e a4|e b4|q c5|q");
ezScore pattern6("c4|q. d4|e e4|q. f4|e g4|q. a4|e b4|q c5|q");
ezScore pattern7("c4|e r|e d4|e r|e e4|e r|e f4|e r|e g4|e r|e a4|e r|e b4|e r|e c5|e r|e");

pattern0 @=> patterns[0];
pattern1 @=> patterns[1];
pattern2 @=> patterns[2];
pattern3 @=> patterns[3];
pattern4 @=> patterns[4];
pattern5 @=> patterns[5];
pattern6 @=> patterns[6];
pattern7 @=> patterns[7];

William instrument => Gain split => LPF filter => NRev reverb => Gain master => dac;

// Create stereo field
split => Gain leftGain => dac.left;
split => PitShift rightShift => Gain rightGain => dac.right;

// Initialize panning values
0.6 => float stereoWidth;
0.3 => rightShift.shift;
0.4 * (1.0 - stereoWidth) => leftGain.gain;
0.4 * (1.0 - stereoWidth) => rightGain.gain;

// Setup initial effects
2000.0 => filter.freq;
1.0 => filter.Q;
0.1 => reverb.mix;
0.5 => master.gain;

// Create player with first pattern
ezScorePlayer player(patterns[0]);
player.setInstrument(0, instrument);
tempo/60.0 => player.rate;

changePattern(2);

true => player.loop;

for (0 => int i; i < instrument.n_voices; i++) {
    instrument.envs[i].set(80::ms, 100::ms, 0.7, 200::ms);
}

SinOsc filterLFO => blackhole;
0.2 => filterLFO.freq;
0.0 => float lfoDepth;

spork ~ runFilterLFO();   

player.play();
<<< "Live coding session started!" >>>;

while(true) {
    1::second => now;
}


fun void runFilterLFO() {
    while(true) {
        filterFreq + (filterLFO.last() * lfoDepth * filterFreq) => filter.freq;
        10::ms => now;
    }
}

fun void changePattern(int patternIndex) {
    ezScorePlayer oldPlayer;
    player @=> oldPlayer;
    patternIndex => currentPattern;
    
    new ezScorePlayer(patterns[patternIndex]) @=> player;
    player.setInstrument(0, instrument);
    tempo/60.0 => player.rate;
    false => player.loop;
    
    player.play();
    
    spork ~ crossfade(oldPlayer, player, 0.5);
    
    <<< "Changed to pattern", patternIndex >>>;
}

fun void crossfade(ezScorePlayer playerA, ezScorePlayer playerB, float fadeTime) {
    instrument.g.gain() => float originalGain;
    
    Gain fadeGainA => blackhole;
    Gain fadeGainB => blackhole;
    originalGain => fadeGainA.gain;
    0.0 => fadeGainB.gain;
    
    for (0.0 => float i; i <= 1.0; i + 0.05 => i) {
        (1.0 - i) * originalGain => fadeGainA.gain;
        i * originalGain => fadeGainB.gain;
        fadeGainA.gain() => instrument.g.gain;
        (fadeTime * 0.05)::second => now;
    }
    
    originalGain => instrument.g.gain;
    
    playerA.stop();
}

fun void setStereoWidth(float width) {
    Math.min(1.0, Math.max(0.0, width)) => stereoWidth;
    0.5 * (1.0 - stereoWidth) => leftGain.gain;
    0.5 * (1.0 - stereoWidth) => rightGain.gain;
}

fun void startAutoPan(float rate, float depth) {
    SinOsc panLFO => blackhole;
    rate => panLFO.freq;
    
    while(true) {
        0.5 + panLFO.last() * depth => float panPosition;
        (1.0 - panPosition) => leftGain.gain;
        panPosition => rightGain.gain;
        10::ms => now;
    }
}
