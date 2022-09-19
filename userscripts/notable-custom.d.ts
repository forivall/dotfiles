export {};

declare global {
  interface Window {
    __themeListenerUnsubscribe?: () => void;
    __themeStyleMutationObserver?: MutationObserver;
  }
}
