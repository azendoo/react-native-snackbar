import React, { Component } from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import Snackbar from 'react-native-snackbar';

import styles from '../styles';

// eslint-disable-next-line react/prefer-stateless-function
class Example extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Snackbar Examples</Text>

        <TouchableOpacity
          onPress={() => Snackbar.show({ text: 'Hello, World!' })}
        >
          <Text style={styles.button}>Simple Snackbar</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'Hello, World! How are you doing today? Enjoying the sun?! This should wrap to two lines.',
            duration: Snackbar.LENGTH_LONG,
          })}
        >
          <Text style={styles.button}>Simple Snackbar - two lines</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            duration: Snackbar.LENGTH_LONG,
            numberOfLines: 5,
          })}
        >
          <Text style={styles.button}>Simple Snackbar - extra lines</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'Please agree to this.',
            duration: Snackbar.LENGTH_INDEFINITE,
            action: {
              text: 'AGREE',
              textColor: 'green',
              onPress: () => Snackbar.show({ text: 'Thank you!' }),
            },
          })}
        >
          <Text style={styles.button}>Snackbar with action</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'Please agree to this.',
            duration: Snackbar.LENGTH_INDEFINITE,
            textColor: 'blue',
            backgroundColor: 'silver',
            fontFamily: 'Lobster-Regular',
            action: {
              text: 'AGREE',
              textColor: 'blue',
              onPress: () => Snackbar.show({ text: 'Thank you!' }),
            },
          })}
        >
          <Text style={styles.button}>Snackbar with style</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'يرجى الموافقة على هذا.',
            rtl: true,
            duration: Snackbar.LENGTH_INDEFINITE,
            action: {
              text: 'يوافق على',
              textColor: 'green',
              onPress: () => Snackbar.show({ text: 'شكرا لكم!', rtl: true }),
            },
          })}
        >
          <Text style={styles.button}>Snackbar with RTL text</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            text: 'Use a bottom margin to avoid covering navigational elements such as a tab bar.',
            marginBottom: 500,
          })}
        >
          <Text style={styles.button}>Snackbar with bottom margin</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => Snackbar.dismiss()}>
          <Text style={styles.button}>Dismiss active Snackbar</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

export default Example;
