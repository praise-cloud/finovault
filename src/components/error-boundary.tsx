import { Component, PropsWithChildren } from 'react';
import { View, Text, Pressable } from 'react-native';

interface State {
  error: Error | null;
}

export class ErrorBoundary extends Component<PropsWithChildren> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error) {
    return { error };
  }

  componentDidCatch(error: Error) {
    this.setState({ error });
  }

  render() {
    if (this.state.error) {
      return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#F0F0F0', padding: 24 }}>
          <Text style={{ fontSize: 18, fontWeight: '700', color: '#111111', marginBottom: 8 }}>Something went wrong</Text>
          <Text style={{ fontSize: 13, color: '#5E6470', textAlign: 'center', marginBottom: 20, fontFamily: 'monospace' }}>
            {this.state.error.message}
          </Text>
          <Pressable
            onPress={() => this.setState({ error: null })}
            style={{ backgroundColor: '#0D358C', paddingHorizontal: 24, paddingVertical: 12, borderRadius: 12 }}
          >
            <Text style={{ color: '#FFFFFF', fontWeight: '600' }}>Try Again</Text>
          </Pressable>
        </View>
      );
    }
    return this.props.children;
  }
}
