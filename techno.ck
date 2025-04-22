// techno.ck - Enhanced techno performance file for live coding
@import "smuck"

// Initialize global control parameters
global float bpm;
global float filterFreq;
global float filterQ;
global float reverbMix;
global int patternVariation;

// Set defaults
120.0 => bpm;
1500.0 => filterFreq;
3.5 => filterQ;
0.05 => reverbMix;
0 => patternVariation;

// Create pattern with proper ChucK syntax
ezScore pattern0("c5 c5 g5 g5 a5 a5 g5| h f5 f5 e5 e5 d5 d5 c5|h");
pattern0 @=> ezScore score;

// Alternate patterns for live switching
ezScore pattern1("c5:e:g c5:e:g g5:b:d g5:b:d a5:c6:e a5:c6:e g5:b:d g5:b:d");
ezScore pattern2("c5 e5 g5 c6 g5 e5 c5 e5 g5 b5 d6 g6 d6 b5 g5 b5");
ezScore pattern3("c5 r d5 r e5 r f5 r g5 r a5 r b5 r c6 r");
ezScore pattern4("c5|e r|e c5|e r|e g5|e r|e g5|e r|e a5|e r|e a5|e r|e g5|e r|e");

// Create comprehensive signal chain
ezScorePlayer player(score);
William instrument => Gain split => LPF filter => ADSR masterEnv => NRev reverb => Gain master => dac;

// Stereo field processing
split => Gain leftGain => dac.left;
split => PitShift rightShift => Gain rightGain => dac.right;

// Sidechain for pumping effect
Gain sidechain => dac;
master => sidechain;

// Setup initial parameter values
0.4 => rightShift.shift;
0.5 => leftGain.gain;
0.5 => rightGain.gain;
0.0 => master.gain; // Start silent
reverbMix => reverb.mix;

// Setup player
player.setInstrument(0, instrument);
bpm/60.0 => player.rate;
true => player.loop;

// Master envelope with quick attack
masterEnv.set(5::ms, 10::ms, 1.0, 10::ms);
masterEnv.keyOn();

// Configure instrument envelopes for short techno sounds
for (0 => int i; i < instrument.n_voices; i++) {
    instrument.envs[i].set(5::ms, 80::ms, 0.4, 150::ms);
}

// Initial filter settings
filterFreq => filter.freq;
filterQ => filter.Q;

spork ~ enhancedDrums();
spork ~ subBass();
spork ~ visualizer();
spork ~ automateFilter();
spork ~ handleKeyboard();

// Fade in at start
spork ~ fadeIn(3.0);

// Start playback
player.play();

// Print startup message
<<< "TECHNO PERFORMANCE STARTED - Press numbers 1-5 to change patterns" >>>;
<<< "Press 'q' for sine, 'w' for triangle, 'e' for square, 'r' for saw oscillators" >>>;
<<< "Press '[' and ']' to adjust filter, '-' and '=' to adjust tempo" >>>;

// Keep program running
while(true) {
    1::second => now;
}

// Function for visualization in terminal
fun void visualizer() {
    while(true) {
        // Clear terminal (sort of)
        <<< "\n\n\n\n\n\n\n\n\n\n" >>>;
        <<< "=== TECHNO PERFORMANCE ===" >>>;
        <<< "BPM:", bpm, "| Filter:", filter.freq(), "Q:", filter.Q() >>>;
        <<< "Pattern:", patternVariation, "| Oscillator:", instrument.oscTypes[0] >>>;
        <<< "Reverb Mix:", reverb.mix(), "| Master Volume:", master.gain() >>>;
        
        // Simple beat counter visualization
        // Calculate beat duration correctly
        60.0::second / bpm => dur beat;
        // Calculate current beat position
        (now / beat) % 16 => float beatPosFloat;
        Std.ftoi(beatPosFloat) => int beatPos;
        
        string progress;
        for (0 => int i; i < 16; i++) {
            if (i == beatPos) {
                "|X|" +=> progress;
            } else {
                "|-|" +=> progress;
            }
        }
        <<< progress >>>;
        
        100::ms => now;
    }
}

// Enhanced drum function with better patterns
fun void enhancedDrums() {
    // Kick drum
    SinOsc kickOsc => ADSR kickEnv => Gain kickGain => dac;
    SinOsc kickClick => ADSR kickClickEnv => kickGain;
    
    // Hihat sounds
    Noise hihatNoise => HPF hihatFilter => ADSR hihatEnv => Pan2 hihatPan => dac;
    Noise openHatNoise => HPF openHatFilter => ADSR openHatEnv => Pan2 openHatPan => dac;
    
    // Percussion sounds
    Noise snapNoise => BPF snapFilter => ADSR snapEnv => NRev snapRev => dac;
    
    // Toms for fills
    SinOsc tomOsc => ADSR tomEnv => NRev tomRev => dac;
    
    // Configure envelopes
    kickEnv.set(1::ms, 180::ms, 0.0, 20::ms);
    kickClickEnv.set(0.5::ms, 10::ms, 0.0, 20::ms);
    hihatEnv.set(1::ms, 60::ms, 0.0, 10::ms);
    openHatEnv.set(1::ms, 200::ms, 0.1, 100::ms);
    snapEnv.set(1::ms, 80::ms, 0.0, 40::ms);
    tomEnv.set(5::ms, 150::ms, 0.0, 200::ms);
    
    // Set initial gains and frequencies
    0.9 => kickOsc.gain;
    0.7 => kickClick.gain;
    1.0 => kickGain.gain;
    2000.0 => kickClick.freq;
    8000.0 => hihatFilter.freq;
    6000.0 => openHatFilter.freq;
    0.4 => hihatNoise.gain;
    0.3 => openHatNoise.gain;
    2500.0 => snapFilter.freq;
    1.5 => snapFilter.Q;
    0.5 => snapNoise.gain;
    0.15 => snapRev.mix;
    0.7 => tomOsc.gain;
    0.1 => tomRev.mix;
    
    // Base patterns
    
    [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0] @=> int kickBase[];
    [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1] @=> int hihatBase[];
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] @=> int openHatBase[];
    [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0] @=> int snapBase[];
    
    
    int kickPattern[16];
    int hihatPattern[16];
    int openHatPattern[16];
    int snapPattern[16];
    int tomPattern[16];
    
    arraycopy(kickBase, 0, kickPattern, 0, kickBase.size());
    arraycopy(hihatBase, 0, hihatPattern, 0, hihatBase.size());
    arraycopy(openHatBase, 0, openHatPattern, 0, openHatBase.size());
    arraycopy(snapBase, 0, snapPattern, 0, snapBase.size());
    
    // Pattern positions and counters
    0 => int patternPos;
    0 => int measureCount;
    
    // Calculate beat duration correctly
    60.0::second / bpm / 4.0 => dur beatDuration;
    
    // Main drum loop
    while (true) {
        // Calculate current position in pattern
        patternPos % kickPattern.size() => int currentPos;
        
        // Update pattern periodically
        if (patternPos % (kickPattern.size() * 2) == 0 && patternPos > 0) {
            measureCount++;
            createPatternVariation(kickPattern, hihatPattern, openHatPattern, snapPattern, tomPattern, measureCount);
        }
        
        // Adjust beat duration based on global BPM
        60.0::second / bpm / 4.0 => beatDuration;
        
        // Play kick drum
        if (kickPattern[currentPos]) {
            60.0 => kickOsc.freq;
            kickEnv.keyOn();
            kickClickEnv.keyOn();
            spork ~ enhancedKickPitch(kickOsc);
            
            // Apply sidechain effect when kick hits
            spork ~ sidechainPump();
        }
        
        // Play hihat
        if (hihatPattern[currentPos]) {
            hihatEnv.keyOn();
            Math.random2f(-0.5, 0.7) => hihatPan.pan;
        }
        
        // Play open hihat
        if (openHatPattern[currentPos]) {
            openHatEnv.keyOn();
            Math.random2f(-0.5, 0.5) => openHatPan.pan;
        }
        
        // Play snap/clap sound
        if (snapPattern[currentPos]) {
            snapEnv.keyOn();
            Math.random2f(0.8, 1.0) => float snapVel;
            snapVel => snapNoise.gain;
        }
        
        // Play tom sound
        if (tomPattern[currentPos]) {
            (currentPos % 3) * 50 + 100 => float tomFreq;
            tomFreq => tomOsc.freq;
            tomEnv.keyOn();
        }
        
        // Reset envelopes after a short delay
        5::ms => now;
        kickEnv.keyOff();
        kickClickEnv.keyOff();
        hihatEnv.keyOff();
        openHatEnv.keyOff();
        snapEnv.keyOff();
        tomEnv.keyOff();
        
        // Wait for remainder of beat duration
        beatDuration - 5::ms => now;
        patternPos++;
    }
}

// Pattern variation generator - more dynamic changes
fun void createPatternVariation(int kick[], int hihat[], int openHat[], int snap[], int tom[], int measureCount) {
    // Reset tom pattern
    for (0 => int i; i < tom.size(); i++) {
        0 => tom[i];
    }
    
    // Apply different variations based on pattern type and measure count
    if (patternVariation == 0) {
        // Standard techno pattern with periodic fills
        if (measureCount % 4 == 0) {
            // Create a drum fill
            0 => tom[12];
            1 => tom[13];
            1 => tom[14];
            1 => tom[15];
            
            // Increase kick density at the end
            1 => kick[12];
            1 => kick[14];
        } 
        else if (measureCount % 4 == 1) {
            // Break pattern - simplify
            for (0 => int i; i < kick.size(); i++) {
                if (i % 4 == 0) 1 => kick[i];
                else 0 => kick[i];
                
                if (i % 2 == 1) 1 => hihat[i];
                else 0 => hihat[i];
                
                0 => openHat[i];
            }
        }
        else if (measureCount % 4 == 2) {
            // Double time feel
            for (0 => int i; i < kick.size(); i++) {
                if (i % 2 == 0) 1 => kick[i];
                else 0 => kick[i];
            }
        }
        else {
            // Return to normal pattern with slight variation
            for (0 => int i; i < kick.size(); i++) {
                if (i % 8 == 0 || i % 8 == 4) 1 => kick[i];
                else if (i % 8 == 3 && Math.random2(0, 10) > 7) 1 => kick[i];
                else 0 => kick[i];
                
                if (i % 4 == 2 || i % 8 == 7) 1 => snap[i];
                else 0 => snap[i];
                
                if (i % 2 == 1) 1 => hihat[i];
                else 0 => hihat[i];
                
                if (i == 15) 1 => openHat[i];
                else 0 => openHat[i];
            }
        }
    } 
    else if (patternVariation == 1) {
        // Minimal techno - sparse kicks, lots of hats
        for (0 => int i; i < kick.size(); i++) {
            if (i % 8 == 0) 1 => kick[i];
            else 0 => kick[i];
            
            if (i % 2 == 0 || i % 3 == 0) 1 => hihat[i];
            else 0 => hihat[i];
            
            if (i % 7 == 0) 1 => snap[i];
            else 0 => snap[i];
            
            if (i % 15 == 0) 1 => openHat[i];
            else 0 => openHat[i];
        }
    }
    else if (patternVariation == 2) {
        // Acid techno - off-beat kicks
        for (0 => int i; i < kick.size(); i++) {
            if (i % 4 == 2 || i % 8 == 1) 1 => kick[i];
            else 0 => kick[i];
            
            if (i % 2 == 0) 1 => hihat[i];
            else 0 => hihat[i];
            
            if (i % 8 == 3 || i % 8 == 7) 1 => snap[i];
            else 0 => snap[i];
            
            if (i % 16 == 15) 1 => openHat[i];
            else 0 => openHat[i];
        }
    }
    else if (patternVariation == 3) {
        // Hard techno - dense kicks
        for (0 => int i; i < kick.size(); i++) {
            if (i % 4 == 0 || i % 8 == 2 || i % 8 == 6) 1 => kick[i];
            else 0 => kick[i];
            
            if (i % 2 == 1) 1 => hihat[i];
            else 0 => hihat[i];
            
            if (i % 4 == 0) 1 => snap[i];
            else 0 => snap[i];
            
            if (i % 8 == 7) 1 => openHat[i];
            else 0 => openHat[i];
        }
    }
    else if (patternVariation == 4) {
        // Broken techno - syncopated pattern
        for (0 => int i; i < kick.size(); i++) {
            if (i % 12 == 0 || i % 12 == 7 || i % 12 == 10) 1 => kick[i];
            else 0 => kick[i];
            
            if (i % 3 == 1) 1 => hihat[i];
            else 0 => hihat[i];
            
            if (i % 5 == 2) 1 => snap[i];
            else 0 => snap[i];
            
            if (i % 7 == 0) 1 => openHat[i];
            else 0 => openHat[i];
        }
    }
}

// Enhanced kick drum with better pitch envelope
fun void enhancedKickPitch(SinOsc osc) {
    800.0 => float startFreq;
    40.0 => float endFreq;  
    
    for (startFreq => float f; f > endFreq; f * 0.83 => f) {
        f => osc.freq;
        0.4::ms => now;
    }
}

// Sidechain pumping effect for that classic techno feel
fun void sidechainPump() {
    master.gain() => float originalGain;
    for (originalGain => float g; g > originalGain * 0.3; g - 0.1 => g) {
        g => master.gain;
        5::ms => now;
    }
    
    30::ms => now;
    
    for (master.gain() => float g; g < originalGain; g + 0.04 => g) {
        g => master.gain;
        10::ms => now;
    }
    
    originalGain => master.gain;
}

// Sub bass for deeper sound
fun void subBass() {
    SinOsc sub => LPF subFilter => ADSR subEnv => Gain subGain => dac;
    40.0 => sub.freq;
    80.0 => subFilter.freq;
    0.8 => sub.gain;
    
    subEnv.set(20::ms, 50::ms, 0.7, 200::ms);
    
    while(true) {
        // Calculate beat duration correctly
        60.0::second / bpm / 4.0 => dur beatDuration;
        
        for (0 => int i; i < 16; i++) {
            if (i % 4 == 0) {
                subEnv.keyOn();
                30.0 + Math.random2f(-5.0, 5.0) => sub.freq;
            }
            
            beatDuration => now;
            subEnv.keyOff();
        }
    }
}

// Array copy utility function
fun void arraycopy(int src[], int srcPos, int dest[], int destPos, int length) {
    for(0 => int i; i < length; i++) {
        src[srcPos + i] => dest[destPos + i];
    }
}

// Auto filter sweep function
fun void automateFilter() {
    SinOsc filterLFO => blackhole;
    0.05 => filterLFO.freq;
    
    while(true) {
        filterFreq + (filterLFO.last() * 500.0) => filter.freq;
        20::ms => now;
    }
}

// Handle keyboard input
fun void handleKeyboard() {
    // Set up keyboard input
    Hid keyboard;
    HidMsg msg;
    
    // Try to open keyboard
    if (!keyboard.openKeyboard(0)) {
        <<< "Failed to open keyboard! Keyboard control disabled." >>>;
        return;
    }
    
    // Listen for key presses
    while(true) {
        keyboard => now;
        
        while(keyboard.recv(msg)) {
            // Only process key-down events
            if (msg.isButtonDown()) {
                if (msg.ascii >= 49 && msg.ascii <= 53) {  // Keys 1-5
                    msg.ascii - 49 => int newPattern;
                    
                    if (newPattern == 0) {
                        pattern0 @=> score;
                        player.setScore(score);
                    } else if (newPattern == 1) {
                        pattern1 @=> score;
                        player.setScore(score);
                    } else if (newPattern == 2) {
                        pattern2 @=> score;
                        player.setScore(score);
                    } else if (newPattern == 3) {
                        pattern3 @=> score;
                        player.setScore(score);
                    } else if (newPattern == 4) {
                        pattern4 @=> score;
                        player.setScore(score);
                    }
                    
                    newPattern => patternVariation;
                    <<< "Switched to pattern", patternVariation >>>;
                }
                else if (msg.ascii == 113) {  // 'q' key for sine oscillator
                    instrument.changeOscType("sin");
                    <<< "Changed to sine oscillator" >>>;
                }
                else if (msg.ascii == 119) {  // 'w' key for triangle oscillator
                    instrument.changeOscType("tri");
                    <<< "Changed to triangle oscillator" >>>;
                }
                else if (msg.ascii == 101) {  // 'e' key for square oscillator
                    instrument.changeOscType("sqr");
                    <<< "Changed to square oscillator" >>>;
                }
                else if (msg.ascii == 114) {  // 'r' key for sawtooth oscillator
                    instrument.changeOscType("saw");
                    <<< "Changed to sawtooth oscillator" >>>;
                }
                else if (msg.ascii == 91) {  // '[' key to decrease filter frequency
                    filter.freq() * 0.9 => filterFreq => filter.freq;
                }
                else if (msg.ascii == 93) {  // ']' key to increase filter frequency
                    filter.freq() * 1.1 => filterFreq => filter.freq;
                }
                else if (msg.ascii == 59) {  // ';' key to decrease filter Q
                    Math.max(0.5, filter.Q() * 0.9) => filterQ => filter.Q;
                }
                else if (msg.ascii == 39) {  // ''' key to increase filter Q
                    filter.Q() * 1.1 => filterQ => filter.Q;
                }
                else if (msg.ascii == 45) {  // '-' key to decrease tempo
                    bpm * 0.95 => bpm;
                    bpm/60.0 => player.rate;
                }
                else if (msg.ascii == 61) {  // '=' key to increase tempo
                    bpm * 1.05 => bpm;
                    bpm/60.0 => player.rate;
                }
                else if (msg.ascii == 48) {  // '0' key to decrease reverb
                    Math.max(0.0, reverb.mix() - 0.05) => reverbMix => reverb.mix;
                }
                else if (msg.ascii == 57) {  // '9' key to increase reverb
                    Math.min(0.95, reverb.mix() + 0.05) => reverbMix => reverb.mix;
                }
                else if (msg.ascii == 32) {  // Space bar to toggle drums
                    // This would need more implementation
                    <<< "Space pressed - toggle drums feature not implemented" >>>;
                }
                else if (msg.ascii == 13) {  // Enter to fade in/out
                if (master.gain() > 0.2) {
                    spork ~ fadeOut(2.0);
                } else {
                    spork ~ fadeIn(2.0);
                }
            }
        }
    }
}
}

// Fade in function
fun void fadeIn(float durationInSeconds) {
    (durationInSeconds::second) / 50.0 => dur stepDuration;
    for (0.0 => float g; g < 0.6; g + 0.012 => g) {
        g => master.gain;
        stepDuration => now;
    }
    0.6 => master.gain;
    <<< "Faded in" >>>;
}

// Fade out function
fun void fadeOut(float durationInSeconds) {
    master.gain() => float startGain;
    (durationInSeconds::second) / 50.0 => dur stepDuration;
    for (startGain => float g; g > 0.0; g - 0.012 => g) {
        g => master.gain;
        stepDuration => now;
    }
    0.0 => master.gain;
    <<< "Faded out" >>>;
}