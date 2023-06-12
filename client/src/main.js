import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'mapbox-gl/dist/mapbox-gl.css';
import './assets/main.css';

const app = createApp(App);

app.use(createPinia());

app.mount('#app');
