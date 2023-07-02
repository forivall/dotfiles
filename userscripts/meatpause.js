javascript: {
  var sml = document.querySelector('sc-message-list');
  document.onblur = () => {
    sml.shadowRoot
      .querySelectorAll('sc-message')
      .forEach((sm) =>
        sm.shadowRoot.querySelectorAll('video').forEach((v) => v.pause()),
      );
    /** @type {HTMLVideoElement} */
    var preview = document.getElementById('preview');
    (preview.srcObject || preview.mozSrcObject)
      .getTracks()
      .forEach((track) => track.stop());
  };
  document.onfocus = () =>
    sml.shadowRoot
      .querySelectorAll('sc-message')
      .forEach((sm) =>
        sm.shadowRoot.querySelectorAll('video').forEach((v) => v.play()),
      );
}
