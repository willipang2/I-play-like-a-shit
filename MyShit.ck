MidiIn min;
MidiMsg msg;

SinOsc oscillators[6];
ADSR envelopes[6];
Gain channelGains[6];

for (0 => int i; i < 6; i++) {
    oscillators[i] => envelopes[i] => channelGains[i] => dac;
    envelopes[i].set(10::ms, 50::ms, 0.7, 100::ms);
    1 => channelGains[i].gain; 
}

if (!min.open("IAC Driver Bus 1")) {
    <<< "Error: Could not open MIDI device 'IAC Driver Bus 1'" >>>;
    me.exit();
}

int activeNotes[6][128]; 
float baseFreqs[6];   

fun float midiToFreq(int note) {
    return 440.0 * Math.pow(2.0, (note - 69.0) / 12.0);
}

while (true) {
    min => now;
    
    while (min.recv(msg)) {
        (msg.data1 & 0x0F) => int channel;
        
        if (channel >= 0 && channel < 6) {
            if ((msg.data1 & 0xF0) == 0x90 && msg.data3 > 0) {
                msg.data2 => int note;
                msg.data3 => int velocity;
                
                1 => activeNotes[channel][note];
                
                midiToFreq(note) => baseFreqs[channel] => oscillators[channel].freq;
                
                velocity/127.0 => float velocityNorm;
                velocityNorm => envelopes[channel].target;
                envelopes[channel].keyOn();
                
                <<< "Channel", channel+1, "Note On:", note, "Velocity:", velocity >>>;
            }
            else if (((msg.data1 & 0xF0) == 0x80) || ((msg.data1 & 0xF0) == 0x90 && msg.data3 == 0)) {
                msg.data2 => int note;
                0 => activeNotes[channel][note];
             
                int anyActive;
                for (0 => int i; i < 128; i++) {
                    if (activeNotes[channel][i] == 1) {
                        1 => anyActive;
                        break;
                    }
                }
                
                if (!anyActive) {
                    envelopes[channel].keyOff();
                    <<< "Channel", channel+1, "All notes off" >>>;
                }
                
                <<< "Channel", channel+1, "Note Off:", note >>>;
            }
            else if ((msg.data1 & 0xF0) == 0xB0) {
                msg.data2 => int controller;
                msg.data3 => int value;
                
                if (controller == 7) {
                    value/127.0 => channelGains[channel].gain;
                    <<< "Channel", channel+1, "Volume:", value >>>;
                }
                else if (controller == 1) {
                    <<< "Channel", channel+1, "Controller:", controller, "Value:", value >>>;
                }
            }
        }
    }
}
