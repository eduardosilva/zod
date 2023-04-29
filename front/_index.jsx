import Head from 'next/head'
import styles from '@/styles/Home.module.css'

import React, { useState, useEffect } from 'react';


export default function Home() {
  const chords = [
    { time: 0, chord: 'A:maj' }, { time: 1.8, chord: 'B:min' }, { time: 2.5, chord: 'A:maj' },
    { time: 3.6, chord: 'G:maj' }, { time: 7.1, chord: 'C#:min' }, { time: 8.1, chord: 'B:maj' },
    { time: 9.1, chord: 'A:maj' }, { time: 11, chord: 'F#:min' }, { time: 11.8, chord: 'E:maj' },
    { time: 13, chord: 'B:min' }, { time: 16.6, chord: 'A:maj' }, { time: 20.3, chord: 'D:maj' },
    { time: 23.8, chord: 'F#:min' }, { time: 27.8, chord: 'D:maj' }, { time: 31.1, chord: 'F#:min' },
    { time: 35.1, chord: 'A:maj' }, { time: 38.9, chord: 'D:maj' }, { time: 41.4, chord: 'F#:min' },
    { time: 42.5, chord: 'E:maj' }, { time: 50.8, chord: 'F#:min' }, { time: 64.3, chord: 'A:maj' },
    { time: 68.5, chord: 'D:maj' }, { time: 71.4, chord: 'F#:min' }, { time: 72.1, chord: 'E:maj' },
    { time: 79.4, chord: 'B:min' }, { time: 83.1, chord: 'D:maj' }, { time: 84.7, chord: 'A:maj' },
    { time: 90.5, chord: 'E:maj' }, { time: 94.3, chord: 'B:min' }, { time: 97.6, chord: 'D:maj' },
    { time: 101.1, chord: 'A:maj' }, { time: 101.9, chord: 'E:maj' }, { time: 103.5, chord: 'D:maj' },
    { time: 104.3, chord: 'F#:min' }, { time: 105.3, chord: 'E:maj' }, { time: 108.7, chord: 'A:maj' },
    { time: 112.7, chord: 'E:maj' }, { time: 116.2, chord: 'F#:min' }, { time: 120, chord: 'D:maj' },
    { time: 122.3, chord: 'F#:min' }, { time: 123.5, chord: 'A:maj' }, { time: 127.7, chord: 'E:maj' },
    { time: 130.9, chord: 'F#:min' }, { time: 132.4, chord: 'A:maj' }, { time: 134.8, chord: 'D:maj' },
    { time: 137.5, chord: 'A:maj' }, { time: 138.6, chord: 'E:maj' }, { time: 141.1, chord: 'F#:min' },
    { time: 142.4, chord: 'D:maj' }, { time: 144, chord: 'B:min' }, { time: 144.9, chord: 'A:maj' },
    { time: 145.8, chord: 'E:maj' }, { time: 148.5, chord: 'F#:min' }, { time: 149.6, chord: 'D:maj' },
    { time: 152.3, chord: 'F#:min' }, { time: 153.3, chord: 'E:maj' }, { time: 157, chord: 'F#:min' },
    { time: 158.8, chord: 'D:maj' }, { time: 160.3, chord: 'A:maj' }, { time: 162.4, chord: 'E:maj' },
    { time: 164.2, chord: 'F#:min' }, { time: 166.3, chord: 'D:maj' }, { time: 167.7, chord: 'A:maj' },
    { time: 172, chord: 'B:min' }, { time: 175.2, chord: 'F#:maj' }, { time: 177.4, chord: 'F:maj' },
    { time: 178.2, chord: 'A:maj' }, { time: 180.9, chord: 'D:maj' }, { time: 181.9, chord: 'F#:min' },
    { time: 182.7, chord: 'E:maj' }, { time: 186.4, chord: 'B:min' }, { time: 190.1, chord: 'F#:min' },
    { time: 192, chord: 'D:maj' }, { time: 193.6, chord: 'A:maj' }, { time: 195.7, chord: 'D:maj' },
    { time: 197.2, chord: 'A:maj' }, { time: 198.8, chord: 'E:maj' }, { time: 200.9, chord: 'A:maj' },
    { time: 205.1, chord: 'E:maj' }, { time: 208.6, chord: 'F#:min' }, { time: 212.2, chord: 'D:maj' },
    { time: 214.9, chord: 'F#:min' }, { time: 215.9, chord: 'A:maj' }, { time: 219.8, chord: 'E:maj' },
    { time: 223.3, chord: 'F#:min' }, { time: 224.6, chord: 'A:maj' }, { time: 227, chord: 'D:maj' },
    { time: 229.8, chord: 'A:maj' }, { time: 231.1, chord: 'E:maj' }, { time: 233.5, chord: 'F#:min' },
    { time: 234.6, chord: 'D:maj' }, { time: 236.3, chord: 'B:min' }, { time: 237.2, chord: 'A:maj' },
    { time: 238.1, chord: 'E:maj' }, { time: 240.8, chord: 'A:maj' }, { time: 242, chord: 'D:maj' },
    { time: 245.2, chord: 'A:maj' }, { time: 256.6, chord: 'D:maj' }, { time: 260.1, chord: 'A:maj' },
    { time: 264.1, chord: 'E:maj' }, { time: 267.2, chord: 'A:maj' }, { time: 271.3, chord: 'D:maj' },
    { time: 275, chord: 'A:maj' }, { time: 279.1, chord: 'E:maj' }, { time: 282.3, chord: 'F#:min' },
    { time: 286, chord: 'D:maj' }, { time: 289.8, chord: 'A:maj' }, { time: 293.6, chord: 'E:maj' },
    { time: 297.2, chord: 'F#:min' }, { time: 298.7, chord: 'A:maj' }, { time: 301, chord: 'D:maj' },
    { time: 304.3, chord: 'A:maj' }, { time: 308.7, chord: 'C#:min' }, { time: 311.8, chord: 'F#:min' },
    { time: 314.4, chord: 'A:maj' }, { time: 315.4, chord: 'D:maj' }, { time: 318.5, chord: 'A:maj' },
    { time: 323.3, chord: 'C#:min' }, { time: 326.5, chord: 'F#:min' }, { time: 328.7, chord: 'A:maj' },
    { time: 330.8, chord: 'D:maj' }, { time: 333.1, chord: 'F#:min' }, { time: 334.1, chord: 'E:maj' },
    { time: 336.9, chord: 'F#:min' }, { time: 337.8, chord: 'D:maj' }, { time: 340.6, chord: 'F#:min' },
    { time: 341.5, chord: 'E:maj' }, { time: 344.3, chord: 'F#:min' }, { time: 345.3, chord: 'D:maj' }]

  const [isPlaying, setIsPlaying] = useState(false);
  const [audio, setAudio] = useState(null);
  const [currentChord, setCurrentChord] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const newAudio = new Audio('/audio.mp3');
    newAudio.addEventListener('error', () => {
      setError('Error loading audio file');
    });
    setAudio(newAudio);
  }, []);

  useEffect(() => {
    if (isPlaying && audio) {
      audio.play();
    } else if (audio) {
      audio.pause();
    }
  }, [isPlaying, audio]);

  useEffect(() => {
    if (!audio) {
      return;
    }
    const checkTime = () => {
      const currentTime = audio.currentTime;
      const chord = chords.find((chord) => Math.floor(chord.time) === Math.floor(currentTime));

      setCurrentChord(chord ? chord.chord : null);
    };

    audio.addEventListener('timeupdate', checkTime);

    return () => {
      audio.removeEventListener('timeupdate', checkTime);
    };
  }, [audio]);

  const togglePlay = () => setIsPlaying(!isPlaying);

  return (
    <div>
      <button onClick={togglePlay}>{isPlaying ? 'Pause' : 'Play'}</button>
      {error && <p>{error}</p>}
      {currentChord && <p>{currentChord}</p>}
    </div>
  );
}
