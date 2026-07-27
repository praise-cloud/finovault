import Svg, { Circle, Text as SvgText, G } from 'react-native-svg';
import { useColorScheme } from 'react-native';

type Props = {
  size?: number;
  percentage?: number;
  label?: string;
  strokeWidth?: number;
  activeColor?: string;
  trackColor?: string;
  textColor?: string;
};

export function RadialGauge({
  size = 120,
  percentage = 78,
  label = 'Good',
  strokeWidth = 10,
  activeColor,
  trackColor,
  textColor,
}: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const resolvedActive = activeColor ?? (isDark ? '#D4AF37' : '#08142E');
  const resolvedTrack = trackColor ?? (isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.08)');
  const resolvedText = textColor ?? (isDark ? '#FFFFFF' : '#1A1A1A');
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const clampedPct = Math.min(100, Math.max(0, percentage));
  const strokeDashoffset = circumference * (1 - clampedPct / 100);
  const center = size / 2;
  const fontSize = size * 0.22;
  const labelSize = size * 0.1;

  return (
    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      {/* Background track */}
      <Circle
        cx={center}
        cy={center}
        r={radius}
        stroke={resolvedTrack}
        strokeWidth={strokeWidth}
        fill="none"
      />

      {/* Active arc — starts at top (-90°) */}
      <G rotation="-90" origin={`${center}, ${center}`}>
        <Circle
          cx={center}
          cy={center}
          r={radius}
          stroke={resolvedActive}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
        />
      </G>

      {/* Center percentage */}
      <SvgText
        x={center}
        y={center - fontSize * 0.15}
        textAnchor="middle"
        fontSize={fontSize}
        fontWeight="700"
        fill={resolvedText}
        fontFamily="Montserrat_700Bold"
      >
        {Math.round(clampedPct)}%
      </SvgText>

      {/* Status label */}
      <SvgText
        x={center}
        y={center + fontSize * 0.4}
        textAnchor="middle"
        fontSize={labelSize}
        fontWeight="500"
        fill={resolvedText}
        opacity={0.7}
        fontFamily="Montserrat_500Medium"
      >
        {label}
      </SvgText>
    </Svg>
  );
}
