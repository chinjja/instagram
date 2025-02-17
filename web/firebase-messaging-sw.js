// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js");

firebase.initializeApp({

    apiKey: 'AIzaSyCgl15S12vqf2MiWtmpZPBds5BX_nBJ3P4',
    appId: '1:479650638727:web:ee9a57c60970a302c24122',
    messagingSenderId: '479650638727',
    projectId: 'instagram-21e39',
    authDomain: 'instagram-21e39.firebaseapp.com',
    storageBucket: 'instagram-21e39.appspot.com',
//   databaseURL: "...",
});

const messaging = firebase.messaging();