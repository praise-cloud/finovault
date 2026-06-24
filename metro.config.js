const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

config.resolver.blockList = [
  /design_ui\/.*/,
  /stitch_finovault_ai_onboarding_flow\/.*/,
];

module.exports = withNativeWind(config, { input: './src/global.css' });
