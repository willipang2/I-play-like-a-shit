// var.ck 
@import "smuck"

ezScore theme("c4 c4 g4 g4 a4 a4 g4 | f4 f4 e4 e4 d4 d4 c4");

// Create variations inspired by Mozart's K.265
ezScore var1("c4 r c5 r c4 r c5 r | g4 r g5 r a4 r a5 r | g4 r g5 r f4 r f5 r | e4 r e5 r d4 r d5 r | c4 r c5 r");
ezScore var2("c4 c4 c4 c4 g4 g4 g4 g4 | a4 a4 a4 a4 g4 g4 g4 g4 | f4 f4 f4 f4 e4 e4 e4 e4 | d4 d4 d4 d4 c4 c4 c4 c4");
ezScore var3("c4:e4:g4:c5 c4:e4:g4:c5 g3:b3:d4:g4 g3:b3:d4:g4 | a3:c4:e4:a4 a3:c4:e4:a4 g3:b3:d4:g4 g3:b3:d4:g4 | f3:a3:c4:f4 f3:a3:c4:f4 e3:g3:b3:e4 e3:g3:b3:e4 | d3:f3:a3:d4 d3:f3:a3:d4 c3:e3:g3:c4 c3:e3:g3:c4");
ezScore var4("c6 g5 e5 c5 c6 g5 e5 c5 | g5 d5 b4 g4 g5 d5 b4 g4 | a5 e5 c5 a4 a5 e5 c5 a4 | g5 d5 b4 g4 g5 d5 b4 g4");
ezScore var5("c4:e:g c4:e:g g4:b:d g4:b:d | a4:c5:e a4:c5:e g4:b:d g4:b:d | f4:a:c f4:a:c e4:g:b e4:g:b | d4:f:a d4:f:a c4:e:g c4:e:g");
ezScore var6("c4 d4 e4 f4 g4 a4 b4 c5 | c5 b4 a4 g4 f4 e4 d4 c4 | c4 d4 e4 f 4 g4 a4 b4 c5 | c5 b4 a4 g4 f4 e4 d4 c4");
ezScore var7("c4:e:g e4:g:c5 g4:c5:e5 c5:e5:g5 | a4:c5:e5 g4:c5:e5 a4:c5:f5 g4:b4:d5 | f4:a4:c5 e4:g4:c5 d4:f4:a4 c4:e4:g4");
ezScore var8("c4 c4 c4#:eb:g g4:c5:eb5 g4 | ab4 ab4 g4:c5:eb5 g4 | f4:ab4:c5 f4 eb4:g4:c5 eb4 | d4:f4:ab4 d4 c4:eb4:g4 c4"); 
ezScore var9("c4 e4 g4 c5 g4 e4 c4 e4 | g4 b4 d5 g5 d5 b4 g4 b4 | a4 c5 e5 a5 e5 c5 a4 c5 | g4 b4 d5 g5 d5 b4 g4 b4");
ezScore var10("c4 r e4 r g4 r c5 r | g3 r b3 r d4 r g4 r | a3 r c4 r e4 r a4 r | g3 r b3 r d4 r g4 r");
ezScore var11("c4|q. c5|q. c4|q. c5|q. | g4|q. g5|q. a4|q. a5|q. | g4|q. g5|q. f4|q. f5|q. | e4|q. e5|q. d4|q. d5|q. | c4|q. c5|q.");
ezScore var12("c4 c5 c6 c5 g4 g5 g6 g5 | a4 a5 a6 a5 g4 g5 g6 g5 | f4 f5 f6 f5 e4 e5 e6 e5 | d4 d5 d6 d5 c4 c5 c6 c5");

ezScore scores[13];
theme @=> scores[0];
var1 @=> scores[1];
var2 @=> scores[2];
var3 @=> scores[3];
var4 @=> scores[4];
var5 @=> scores[5];
var6 @=> scores[6];
var7 @=> scores[7];
var8 @=> scores[8];
var9 @=> scores[9];
var10 @=> scores[10];
var11 @=> scores[11];
var12 @=> scores[12];

global float variationTempo;
global int currentVar;
global float reverbAmount;
global string oscType;

// 2 is ~120 Theme
2.0 => variationTempo; 

2 => currentVar;
0.1 => reverbAmount;
"sin" => oscType;

ezScorePlayer player(scores[currentVar]);
William instrument => LPF filter => NRev reverb => Gain master => dac;

master => Gain split => dac;
split => Gain leftGain => dac.left;
split => PitShift rightShift => Gain rightGain => dac.right;

0 => rightShift.shift;
0.5 => leftGain.gain;
0.5 => rightGain.gain;

player.setInstrument(0, instrument);
1 => player.rate;
true => player.loop;
instrument.changeOscType("sin");
reverbAmount => reverb.mix;
0.5 => master.gain;
2000.0 => filter.freq;
1.0 => filter.Q;

for (0 => int i; i < instrument.n_voices; i++) {
    instrument.envs[i].set(10::ms, 200::ms, 0.7, 500::ms);
}

2 => int currentVariation;
0 => int sequencerShredID;
0 => int visualizerShredID;
0 => int autoChangeShredID; // Added to track auto-change process

fun void applyVariationSettings(int variation) {
    if (variation == 0) { // Theme
        1.0 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(10::ms, 200::ms, 0.7, 500::ms);
        }
    }
    else if (variation == 1) { // Variation 1 - Alternating octaves
        1.1 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 150::ms, 0.6, 300::ms);
        }
    }
    else if (variation == 2) { // Variation 2 - 16th notes
        1.2 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 100::ms, 0.5, 200::ms);
        }
    }
    else if (variation == 3) { // Variation 3 - Broken Chords
        0.9 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(10::ms, 300::ms, 0.8, 600::ms);
        }
    }
    else if (variation == 4) { // Variation 4 - Descending Scale
        1.3 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 80::ms, 0.5, 150::ms);
        }
    }
    else if (variation == 5) { // Variation 5 - Block Chords
        0.9 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(15::ms, 250::ms, 0.7, 500::ms);
        }
    }
    else if (variation == 6) { // Variation 6 - Scale Runs
        1.2 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 120::ms, 0.6, 200::ms);
        }
    }
    else if (variation == 7) { // Variation 7 - Arpeggios
        1.0 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(10::ms, 200::ms, 0.7, 400::ms);
        }
    }
    else if (variation == 8) { // Variation 8 - Minor Mode
        0.8 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(15::ms, 300::ms, 0.6, 600::ms);
        }
    }
    else if (variation == 9) { // Variation 9 - Virtuosic Arpeggios
        1.3 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 100::ms, 0.5, 200::ms);
        }
    }
    else if (variation == 10) { // Variation 10 - Alberti Bass
        1.0 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(10::ms, 180::ms, 0.6, 350::ms);
        }
    }
    else if (variation == 11) { // Variation 11 - Adagio
        0.7 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(20::ms, 400::ms, 0.8, 800::ms);
        }
    }
    else if (variation == 12) { // Variation 12 - Allegro
        1.5 * variationTempo => player.rate;
        for (0 => int i; i < instrument.n_voices; i++) {
            instrument.envs[i].set(5::ms, 80::ms, 0.5, 150::ms);
        }
    }
    
    variation => currentVar;
    scores[variation] @=> player.score; 
}

fun void autoChangeVariation(float changeInterval, int randomize) {
    while (true) {
        if (randomize) {
            // Random variation selection
            Math.random2(0, 12) => int nextVariation;
            while (nextVariation == currentVariation) {
                Math.random2(0, 12) => nextVariation;
            }
            
            nextVariation => currentVariation;
            applyVariationSettings(currentVariation);
            <<< "Auto-changing to Variation", currentVariation, "(Random)" >>>;
        } else {
            (currentVariation + 1) % 13 => currentVariation;
            applyVariationSettings(currentVariation);
            <<< "Auto-changing to Variation", currentVariation, "(Sequential)" >>>;
        }
        
        changeInterval::second => now;
    }
}

// Toggle auto-change function - ADDED
fun void toggleAutoChange(float interval, int randomMode) {
    if (autoChangeShredID != 0) {
        // Stop existing auto-change
        Machine.remove(autoChangeShredID);
        0 => autoChangeShredID;
        <<< "Auto-change stopped" >>>;
    } else {
        // Start new auto-change
        spork ~ autoChangeVariation(interval, randomMode) @=> Shred tempShred;
        tempShred.id() => autoChangeShredID;
        <<< "Auto-change started:", randomMode ? "random mode" : "sequential mode", 
        "with interval", interval, "seconds" >>>;
    }
}

fun void startVisualizer() {
    if (visualizerShredID != 0) {
        return; 
    }
    spork ~ visualizer() @=> Shred tempShred;
    tempShred.id() => visualizerShredID;
}

fun void visualizer() {
    while(true) {
        <<< "Tempo:", player.rate() * 60.0, "BPM" >>>;
        <<< "Oscillator Type:", instrument.oscTypes[0] >>>;
        <<< "Reverb Mix:", reverb.mix() >>>;
        <<< "Filter Freq:", filter.freq() >>>;
        100::ms => now;
    }
}

// Keyboard control
fun void listenForCommands() {
    Hid keyboard;
    HidMsg msg;
    
    if (!keyboard.openKeyboard(0)) {
        <<< "Failed to open keyboard. Keyboard control disabled." >>>;
        return;
    }
    
    // Listen for key presses
    while(true) {
        keyboard => now;
        
        while(keyboard.recv(msg)) {
            if (msg.isButtonDown()) {
                if (msg.ascii == 91) {  // '[' key to decrease filter
                    filter.freq() * 0.8 => filter.freq;
                    <<< "Filter frequency:", filter.freq() >>>;
                }
                else if (msg.ascii == 93) {  // ']' key to increase filter
                    filter.freq() * 1.2 => filter.freq;
                    <<< "Filter frequency:", filter.freq() >>>;
                }
                else if (msg.ascii == 45) {  // '-' key to decrease tempo
                    variationTempo * 0.95 => variationTempo;
                    applyVariationSettings(currentVariation);
                    <<< "Tempo:", variationTempo * 60.0 >>>;
                }
                else if (msg.ascii == 61) {  // '=' key to increase tempo
                    variationTempo * 1.05 => variationTempo;
                    applyVariationSettings(currentVariation);
                    <<< "Tempo:", variationTempo * 60.0 >>>;
                }
                else if (msg.ascii == 48) {  // '0' key to decrease reverb
                    Math.max(0.0, reverb.mix() - 0.05) => reverbAmount => reverb.mix;
                    <<< "Reverb mix:", reverb.mix() >>>;
                }
                else if (msg.ascii == 57) {  // '9' key to increase reverb
                    Math.min(0.95, reverb.mix() + 0.05) => reverbAmount => reverb.mix;
                    <<< "Reverb mix:", reverb.mix() >>>;
                }
                else if (msg.ascii == 97) {  // 'a' key to toggle auto-change - ADDED
                    toggleAutoChange(8.0, 0);  // sequential mode, 8-second interval
                }
                else if (msg.ascii == 114) {  // 'r' key to toggle random auto-change - ADDED
                    toggleAutoChange(8.0, 1);  // random mode, 8-second interval
                }
                else if (msg.ascii >= 49 && msg.ascii <= 57) {  // number keys 1-9 - ADDED
                    msg.ascii - 49 => int variation;
                    variation => currentVariation;
                    applyVariationSettings(variation);
                }
           
            }
        }
    }
}

fun void startAutoPan(float cycleTime, float depth) {
    SinOsc panLFO => blackhole;
    0.1 => panLFO.freq;
    
    while(true) {
        0.5 + panLFO.last() * depth => float panPosition;
        (1.0 - panPosition) => leftGain.gain;
        panPosition => rightGain.gain;
        10::ms => now;
    }
}

applyVariationSettings(currentVariation);
player.play();
<<< "Playing Theme" >>>;

// Spork background processes
spork ~ listenForCommands();
spork ~ startVisualizer();
spork ~ startAutoPan(5.0, 0.1); 

// Uncomment to start auto-variation changing when the program begins
 spork ~ autoChangeVariation(8.0, 0) @=> Shred tempShred; // Sequential mode, 8 second intervals
 tempShred.id() => autoChangeShredID;

while(true) {
    1::second => now;
}
