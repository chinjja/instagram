importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyCgl15S12vqf2MiWtmpZPBds5BX_nBJ3P4',
  appId: '1:479650638727:web:ee9a57c60970a302c24122',
  messagingSenderId: '479650638727',
  projectId: 'instagram-21e39',
  authDomain: 'instagram-21e39.firebaseapp.com',
  storageBucket: 'instagram-21e39.appspot.com',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});