import Svg, { Circle, Path, G } from 'react-native-svg';

type Props = {
  size?: number;
  color?: string;
  bgColor?: string;
  showWordmark?: boolean;
  flat?: boolean;
};

export function VaultMonogram({ size = 48, color = '#08142E', bgColor = '#0A1F5C', showWordmark = false, flat = false }: Props) {
  const s = size;
  const c = s / 2;

  if (flat) {
    return (
      <Svg width={s} height={s} viewBox={`0 0 ${s} ${s}`}>
        <Circle cx={c} cy={c} r={s * 0.38} fill="none" stroke={color} strokeWidth={s * 0.035} />
        {[0, 45, 90, 135, 180, 225, 270, 315].map((angle) => {
          const rad = (angle * Math.PI) / 180;
          const x1 = c + s * 0.22 * Math.cos(rad);
          const y1 = c + s * 0.22 * Math.sin(rad);
          const x2 = c + s * 0.35 * Math.cos(rad);
          const y2 = c + s * 0.35 * Math.sin(rad);
          return (
            <Path
              key={`flat-spoke-${angle}`}
              d={`M ${x1} ${y1} L ${x2} ${y2}`}
              stroke={color}
              strokeWidth={s * 0.025}
              strokeLinecap="round"
            />
          );
        })}
        <Circle cx={c} cy={c} r={s * 0.1} fill={color} />
        <G transform={`translate(${c}, ${c})`}>
          <Path
            d={`M ${-s * 0.04} ${s * 0.05} L ${0} ${-s * 0.06} L ${s * 0.04} ${s * 0.05}`}
            fill="none"
            stroke="white"
            strokeWidth={s * 0.03}
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </G>
      </Svg>
    );
  }

  const r = s * 0.42;
  const spokeR = s * 0.28;
  const hubR = s * 0.12;

  const spokes = [0, 45, 90, 135, 180, 225, 270, 315].map((angle) => {
    const rad = (angle * Math.PI) / 180;
    const x1 = c + spokeR * Math.cos(rad);
    const y1 = c + spokeR * Math.sin(rad);
    const x2 = c + r * 0.92 * Math.cos(rad);
    const y2 = c + r * 0.92 * Math.sin(rad);
    return { x1, y1, x2, y2 };
  });

  return (
    <Svg width={s} height={s} viewBox={`0 0 ${s} ${s}`}>
      <Circle cx={c} cy={c} r={r} fill={bgColor} stroke={color} strokeWidth={s * 0.04} />

      {[0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330].map((angle) => {
        const rad = (angle * Math.PI) / 180;
        const dotR = s * 0.025;
        const dotDist = r - s * 0.07;
        return (
          <Circle
            key={`rivet-${angle}`}
            cx={c + dotDist * Math.cos(rad)}
            cy={c + dotDist * Math.sin(rad)}
            r={dotR}
            fill={color}
          />
        );
      })}

      <Circle cx={c} cy={c} r={r * 0.85} fill="none" stroke={color} strokeWidth={s * 0.015} />

      {spokes.map((sp, i) => (
        <Path
          key={`spoke-${i}`}
          d={`M ${sp.x1} ${sp.y1} L ${sp.x2} ${sp.y2}`}
          stroke={color}
          strokeWidth={s * 0.025}
          strokeLinecap="round"
        />
      ))}

      <Circle cx={c} cy={c} r={hubR} fill={color} />

      <G transform={`translate(${c}, ${c})`}>
        <Path
          d={`M ${-hubR * 0.45} ${hubR * 0.55} L ${0} ${-hubR * 0.65} L ${hubR * 0.45} ${hubR * 0.55}`}
          fill="none"
          stroke={bgColor}
          strokeWidth={s * 0.035}
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <Circle cx={0} cy={hubR * 0.45} r={s * 0.02} fill={bgColor} />
      </G>

      {showWordmark && (
        <G transform={`translate(${c}, ${s * 0.85})`}>
          <Path
            d="M -30 0 L -25 -6 L -20 0 L -15 -6 L -10 0 L -5 -6 L 0 0 L 5 -6 L 10 0 L 15 -6 L 20 0 L 25 -6 L 30 0"
            stroke={color}
            strokeWidth={1.5}
            strokeLinecap="round"
            fill="none"
            opacity={0.6}
          />
        </G>
      )}
    </Svg>
  );
}
