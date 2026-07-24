import { useFonts } from 'expo-font';

export function useFinovaultFonts() {
  const [loaded] = useFonts({
    Cinzel_600SemiBold: require('../../assets/fonts/Cinzel_600SemiBold.ttf'),
    Cinzel_700Bold: require('../../assets/fonts/Cinzel_700Bold.ttf'),
    Montserrat_400Regular: require('../../assets/fonts/Montserrat_400Regular.ttf'),
    Montserrat_500Medium: require('../../assets/fonts/Montserrat_500Medium.ttf'),
    Montserrat_600SemiBold: require('../../assets/fonts/Montserrat_600SemiBold.ttf'),
    Montserrat_700Bold: require('../../assets/fonts/Montserrat_700Bold.ttf'),
    Montserrat_800ExtraBold: require('../../assets/fonts/Montserrat_800ExtraBold.ttf'),
  });
  return loaded;
}
