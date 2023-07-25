<script setup>
  import maplibregl from 'maplibre-gl';
  import { GeocodingControl } from '@maptiler/geocoding-control/maplibregl';
  import * as pmtiles from 'pmtiles';
  import { onMounted } from 'vue';
  import { useStore } from '@/stores/store';
  import 'maplibre-gl/dist/maplibre-gl.css';
  import '@maptiler/geocoding-control/style.css';

  const MAPTILER_API_KEY = 'kzHOjc7iFcT1ArfZLBt2';

  const store = useStore();

  // set up pmtiles
  // https://protomaps.com/docs/frontends/maplibre
  const pmtilesProtocol = new pmtiles.Protocol();
  maplibregl.addProtocol('pmtiles', pmtilesProtocol.tile);

  onMounted(() => {
    const map = new maplibregl.Map({
      container: 'map',
      style: `https://api.maptiler.com/maps/backdrop-dark/style.json?key=${MAPTILER_API_KEY}`,
      center: [-77.4, 40.9],
      zoom: 7,
      minZoom: 6,
      maxZoom: 17,
    });

    // add map controls
    map.addControl(new maplibregl.NavigationControl(), 'top-left');
    map.addControl(new maplibregl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
    }), 'top-left');

    // add geocoder
    // https://github.com/maptiler/maptiler-geocoding-control#example-for-maplibre-gl-js-using-module-bundler
    map.addControl(new GeocodingControl({
      apiKey: MAPTILER_API_KEY,
      maplibregl,
    }));

    // TODO add attribution for data sources (fcc, mlab, etc.)?

    map.on('load', () => {
      // https://docs.mapbox.com/mapbox-gl-js/example/geojson-layer-in-stack/
      const layers = map.getStyle().layers;
        // Find the index of the first symbol layer in the map style.
        let firstSymbolId;
        for (const layer of layers) {
        if (layer.type === 'symbol') {
          firstSymbolId = layer.id;
          break;
        }
      }

      map.addLayer(
        {
          id: 'summary-addresses',
          source: {
            type: 'vector',
            url: 'pmtiles://https://broadband-map-pa.nyc3.digitaloceanspaces.com/tiles/summary_addresses_20230725_000653.pmtiles',
          },
          'source-layer': 'summary-addresses',
          type: 'circle',
          paint: {
            'circle-color': [
              'case',
              // no bdc service reported
              ['==', ['get', 'bdc_service_reported'], 0],
              'rgb(0, 255, 204)', // turquoise

              // served
              ['==', ['get', 'bdc_wired_class'], 3],
              'rgb(146, 52, 235)', // purple
              
              // underserved
              ['==', ['get', 'bdc_wired_class'], 2],
              'rgb(242, 255, 0)', // yellow

              // unserved
              ['<', ['get', 'bdc_wired_class'], 2],
              'rgb(255, 0, 0)', // red
              
              // other (shouldn't be any of these)
              'rgb(255, 255, 255)', // white
            ],

            'circle-radius': [
              'interpolate', ['linear'], ['zoom'],
              7, 0.8,
              16, 3.75,
              17, 6,
            ],
          }
        },
        firstSymbolId,
      );
    });

    map.on('click', async (e) => {
      // https://docs.mapbox.com/mapbox-gl-js/example/queryrenderedfeatures-around-point/
      const bbox = [
        [e.point.x - 5, e.point.y - 5],
        [e.point.x + 5, e.point.y + 5],
      ];

      const selectedFeatures = map.queryRenderedFeatures(bbox, {
        layers: ['summary-addresses']
      });

      // TODO handle more than one feature?
      const [ selectedFeature ] = selectedFeatures;

      // TODO some user feedback if they didn't select anything? maybe not?
      if (!selectedFeature) {
        console.log('no feature selected');
        return;
      };

      const { hash } = selectedFeature.properties;

      await store.fetchAddress(hash);
    });
  });
</script>

<template>
  <div id="map"></div>
</template>

<style scoped>
#map {
  flex-grow: 1;
}
</style>
