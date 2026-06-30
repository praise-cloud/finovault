import { Audio } from 'expo-av';

export type SoundName = 'welcome' | 'open' | 'lock';

type SoundMap = {
  [K in SoundName]: string;
};

const SOUND_FILES: SoundMap = {
  welcome: require('@/assets/audio/safe-opening-welcome-page.mpeg'),
  open: require('@/assets/audio/opening_safe_sound.mpeg'),
  lock: require('@/assets/audio/lock_safe_sound.mpeg'),
};

const loadedSounds = new Map<SoundName, Audio.Sound>();

export async function preloadSounds() {
  await Audio.setAudioModeAsync({ playsInSilentModeIOS: true });
  const entries = Object.entries(SOUND_FILES) as [SoundName, string][];
  const results = await Promise.allSettled(
    entries.map(async ([name, source]) => {
      const { sound } = await Audio.Sound.createAsync(source, { volume: 0.5 });
      loadedSounds.set(name, sound);
    }),
  );
  for (const result of results) {
    if (result.status === 'rejected') {
      console.warn('Failed to preload sound:', result.reason);
    }
  }
}

export async function playSound(name: SoundName) {
  const sound = loadedSounds.get(name);
  if (!sound) return;
  try {
    await sound.setPositionAsync(0);
    await sound.playAsync();
  } catch (e) {
    console.warn('Failed to play sound:', e);
  }
}

export async function unloadSounds() {
  for (const [, sound] of loadedSounds) {
    await sound.unloadAsync();
  }
  loadedSounds.clear();
}
