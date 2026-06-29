const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');
const path = require('path');

const config = getDefaultConfig(__dirname);

config.resolver.blockList = [
  /design_ui\/.*/,
  /stitch_finovault_ai_onboarding_flow\/.*/,
];

const srcDir = path.join(__dirname, 'src');
const assetsDir = path.join(__dirname, 'assets');

config.watchFolders = [srcDir, assetsDir];

config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (moduleName.startsWith('@/assets/')) {
    const assetPath = moduleName.replace('@/assets/', '');
    return context.resolveRequest(context, path.join(assetsDir, assetPath), platform);
  }
  if (moduleName.startsWith('@/')) {
    const srcPath = moduleName.replace('@/', '');
    return context.resolveRequest(context, path.join(srcDir, srcPath), platform);
  }
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = withNativeWind(config, { input: './src/global.css' });
