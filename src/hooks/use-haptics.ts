import { Platform } from 'react-native';
import { requireOptionalNativeModule } from 'expo';

const isNative = Platform.OS === 'ios' || Platform.OS === 'android';

const ExpoHaptics: Record<string, (...args: any[]) => Promise<void>> | null =
  isNative ? requireOptionalNativeModule('ExpoHaptics') : null;

type ImpactStyle = 'light' | 'medium' | 'heavy' | 'soft' | 'rigid';
type NotificationType = 'success' | 'warning' | 'error';

async function call(method: string, ...args: any[]) {
  if (!ExpoHaptics?.[method]) return;
  try {
    await ExpoHaptics[method](...args);
  } catch {}
}

export function lightImpact() {
  call('impactAsync', 'light' satisfies ImpactStyle);
}

export function mediumImpact() {
  call('impactAsync', 'medium' satisfies ImpactStyle);
}

export function heavyImpact() {
  call('impactAsync', 'heavy' satisfies ImpactStyle);
}

export function softImpact() {
  call('impactAsync', 'soft' satisfies ImpactStyle);
}

export function rigidImpact() {
  call('impactAsync', 'rigid' satisfies ImpactStyle);
}

export function successNotification() {
  call('notificationAsync', 'success' satisfies NotificationType);
}

export function errorNotification() {
  call('notificationAsync', 'error' satisfies NotificationType);
}

export function warningNotification() {
  call('notificationAsync', 'warning' satisfies NotificationType);
}

export function selection() {
  call('selectionAsync');
}
