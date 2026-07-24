import { View, Text, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Step = {
  label: string;
  timestamp?: string;
  status: 'completed' | 'current' | 'future';
};

type Props = {
  steps: Step[];
};

export function StatusTimeline({ steps }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View className="pl-2">
      {steps.map((step, i) => {
        const isLast = i === steps.length - 1;
        const isCompleted = step.status === 'completed';
        const isCurrent = step.status === 'current';

        return (
          <View key={i} className="flex-row">
            <View className="items-center" style={{ width: 24 }}>
              {isCompleted ? (
                <View
                  className="w-5 h-5 rounded-full items-center justify-center"
                  style={{ backgroundColor: '#08142E' }}
                >
                  <MaterialIcons name="check" size={12} color="#FFFFFF" />
                </View>
              ) : isCurrent ? (
                <View
                  className="w-5 h-5 rounded-full items-center justify-center"
                  style={{ borderWidth: 2, borderColor: '#08142E', backgroundColor: 'transparent' }}
                >
                  <View className="w-2 h-2 rounded-full" style={{ backgroundColor: '#08142E' }} />
                </View>
              ) : (
                <View
                  className="w-5 h-5 rounded-full"
                  style={{
                    borderWidth: 2,
                    borderColor: isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce',
                    backgroundColor: 'transparent',
                  }}
                />
              )}
              {!isLast && (
                <View
                  className="flex-1"
                  style={{
                    width: 1.5,
                    backgroundColor: isCompleted ? '#08142E' : isDark ? 'rgba(255,255,255,0.1)' : '#E4E7EE',
                  }}
                />
              )}
            </View>
            <View className={`flex-1 ${isLast ? '' : 'pb-5'} ml-3`}>
              <Text
                className={isCurrent ? 'font-body-semibold' : 'font-body-medium'}
                style={{
                  fontSize: 15,
                  color: isCompleted || isCurrent
                    ? (isDark ? '#FFFFFF' : '#1A1A1A')
                    : (isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76'),
                }}
              >
                {step.label}
              </Text>
              {step.timestamp && (
                <Text
                  className="font-body"
                  style={{
                    fontSize: 13,
                    color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76',
                    marginTop: 2,
                  }}
                >
                  {step.timestamp}
                </Text>
              )}
            </View>
          </View>
        );
      })}
    </View>
  );
}
