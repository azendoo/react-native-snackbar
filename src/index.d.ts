// TypeScript typings.

/**
 * An optional, actionable button on the Snackbar.
 */
export interface SnackbarAction {
  /**
   * Button text.
   */
  text: string;

  /**
   * Button text color.
   * Accepts various forms of colors such as hex, literals, rgba, etc.
   */
  textColor?: string | number;

  /**
   * Function called when the user taps the button.
   */
  onPress?(): void;
}

/**
 * Snackbar configuration options.
 */
export interface SnackBarOptions {
  /**
   * Snackbar text.
   */
  text: string;

  /**
   * Number of text lines to display on the snackbar.
   * Default 2 lines are shown.
   */
  numberOfLines?: number;

  /**
   * Length of time the Snackbar stays on screen.
   * Must be one of Snackbar.LENGTH_SHORT, Snackbar.LENGTH_LONG, or Snackbar.LENGTH_INDEFINITE.
   */
  duration?: number;

  /**
   * Margin from bottom, defaults to 0.
   */
  marginBottom?: number;

  /**
   * Snackbar text color.
   * Accepts various forms of colors such as hex, literals, rgba, etc.
   */
  textColor?: string | number;

  /**
   * Background color of the snackbar.
   * Accepts color strings such as hex, literals, rgba
   */
  backgroundColor?: string;

  /**
   * [Android] The basename of a .ttf font from assets/fonts/.
   */
  fontFamily?: string;

  /**
   * Action button configuration options.
   */
  action?: SnackbarAction;
}

/**
 * Static Snackbar attributes.
 */
export interface SnackbarStatic {
  /**
   * Snackbar duration of about one second (varies per device).
   */
  LENGTH_SHORT: number;

  /**
   * Snackbar duration of about three seconds (varies per device).
   */
  LENGTH_LONG: number;

  /**
   * Snackbar duration that lasts forever (until dismissed, replaced, or action button is tapped).
   */
  LENGTH_INDEFINITE: number;

  /**
   * Shows a native Snackbar component.
   */
  show(options: SnackBarOptions): void;

  /**
   * Dismisses any and all active Snackbars.
   */
  dismiss(): void;
}

declare const Snackbar: SnackbarStatic;
export default Snackbar;
