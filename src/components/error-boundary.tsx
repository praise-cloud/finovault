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
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#f7fafd', padding: 24 }}>
          <Text style={{ fontSize: 18, fontWeight: '700', color: '#1e293b', marginBottom: 8 }}>Something went wrong</Text>
          <Text style={{ fontSize: 13, color: '#64748b', textAlign: 'center', marginBottom: 20, fontFamily: 'monospace' }}>
            {this.state.error.message}
          </Text>
          <Pressable
            onPress={() => this.setState({ error: null })}
            style={{ backgroundColor: '#08142E', paddingHorizontal: 24, paddingVertical: 12, borderRadius: 9999 }}
          >
            <Text style={{ color: '#1A1A1A', fontWeight: '600' }}>Try Again</Text>
          </Pressable>
        </View>
      );
    }
    return this.props.children;
  }
}
