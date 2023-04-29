import argparse
import os
import warnings

import librosa
import librosa.display

import scipy.stats

import numpy as np

import matplotlib.pyplot as plt

import madmom
import madmom.features

from madmom.audio.chroma import DeepChromaProcessor



# Parse command line arguments
parser = argparse.ArgumentParser(description='Extract tempo and save plot for a music file')
parser.add_argument('-f', '--filename', required=True, help='Input file name')
args = parser.parse_args()

if not os.path.isfile(args.filename):
    print(f"Error: '{args.filename}' is not a valid file.")
    exit(1)

try:
    # load audio file
    signal, sample_rate = madmom.io.audio.load_audio_file(args.filename)
except Exception as e:
    print(f"Error loading audio file '{args.filename}': {e}")
    exit(1)


# extract chroma features
dcp = DeepChromaProcessor()
chroma = dcp(args.filename)

# extract chord sequence
processor = madmom.features.chords.DeepChromaChordRecognitionProcessor()
chords = processor(chroma)

# print the chord sequence
print(f'Chords: {chords}')

# Load audio file
y, sr = librosa.load(args.filename)

# Perform harmonic-percussive source separation
y_harmonic, y_percussive = librosa.effects.hpss(y)

# Compute tempo
hop_length = 512 # samples per frame
onset_env = librosa.onset.onset_strength(y=y, sr=sr,
                                         aggregate=np.median)

frames = range(len(onset_env))
t = librosa.frames_to_time(frames, sr=sr, hop_length=hop_length)

#plt.plot(t, onset_env)
#plt.xlim(0, t.max())
#plt.ylim(0)
#plt.xlabel('Time (sec)')
#plt.title('Novelty Function')

user_estimated_tempo = 60
prior = scipy.stats.uniform(user_estimated_tempo, user_estimated_tempo / t.max())  # uniform over 30-300 BPM

tempo_range = librosa.beat.tempo(y=y_percussive, sr=sr, hop_length=hop_length,aggregate=None,prior=prior)
tempo, beats = librosa.beat.beat_track(y=y_percussive, sr=sr, hop_length=hop_length, start_bpm=tempo_range[0])

plt.figure(figsize=(10, 10))

plt.subplot(2, 1, 1)
librosa.display.waveshow(y, alpha=0.5)
plt.title('Waveform')

# Print the tempo and beat times
print(f'Estimated Tempo: {tempo:.2f} BPM')

# Save plot to file in the same directory as the input file
filename = os.path.basename(args.filename)
dirname = os.path.dirname(args.filename)
basename, extension = os.path.splitext(filename)
plot_filename = os.path.join(dirname, f'{basename}_tempo_plot.png')
plt.savefig(plot_filename)

# Save the tempo and beat times information to a file
output_file = os.path.join(dirname, f'{basename}_metadata.txt')
with open(output_file, 'w') as f:
    print(f'Estimated Tempo: {tempo:.2f} BPM')
    f.write(f'Chords: {chords}\n')

print(f'Metadata song information saved to {output_file}')

# Exit
exit(0)
