export type SoundName = 'welcome' | 'open' | 'lock';

const SOUND_FILES: Record<SoundName, number> = {
  welcome: require('@/assets/audio/safe-opening-welcome-page.mpeg'),
  open: require('@/assets/audio/opening_safe_sound.mpeg'),
  lock: require('@/assets/audio/lock_safe_sound.mpeg'),
};

let AudioModule: any = null;
const loadedSounds = new Map<SoundName, any>();

async function getAudio() {
  if (!AudioModule) {
    try {
      // @ts-ignore - expo-av may not be installed
      AudioModule = await import('expo-av');
    } catch {
      console.warn('expo-av not available, sounds disabled');
      return null;
    }
  }
  return AudioModule.Audio;
}

export async function preloadSounds() {
  const Audio = await getAudio();
  if (!Audio) return;

  try {
    await Audio.setAudioModeAsync({ playsInSilentModeIOS: true });
  } catch {
    // ignore
  }

  const entries = Object.entries(SOUND_FILES) as [SoundName, number][];
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
