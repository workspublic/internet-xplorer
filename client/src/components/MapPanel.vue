<script setup>
  import mapboxgl from 'mapbox-gl';
  import MapboxGeocoder from '@mapbox/mapbox-gl-geocoder';
  import { onMounted } from 'vue';
  import { useStore } from '@/stores/store';
  import '@mapbox/mapbox-gl-geocoder/dist/mapbox-gl-geocoder.css';

  const store = useStore();

  onMounted(() => {
    mapboxgl.accessToken = 'pk.eyJ1Ijoid29ya3NwdWJsaWMiLCJhIjoiY2xkcXBxanZmMTUyNzNvdXVsbGNpcThlZCJ9.9bLxlYgqGCLQr2G5zYCFYw';

    const map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/dark-v11',
      center: [-77.4, 40.9],
      zoom: 7,
      minZoom: 6,
      maxZoom: 17,
    });


    // add map controls/attribution
    // map.addControl(new mapboxgl.AttributionControl({
    //   customAttribution: 'Addresses from OpenAddresses; broadband availability from FCC'
    // }));
    map.addControl(new mapboxgl.NavigationControl(), 'top-left');
    map.addControl(new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
    }), 'top-left');

    // add geocoder
    map.addControl(new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl
    }));

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
            // local tiles with dirt
            // tiles: [`http://localhost:3000/v1/mvt/pa_addresses_service_summary/{z}/{x}/{y}?columns=${SYMBOLOGY_ATTRIBUTE},hash`],
            // local tiles with python http server
            // tiles: [`http://localhost:3000/{z}/{x}/{y}.pbf`],
            tiles: ['https://broadband-map-pa.nyc3.digitaloceanspaces.com/tiles/summary-addresses-tiles_20230508_184409/{z}/{x}/{y}.pbf'],
          },
          'source-layer': 'summary-addresses',
          type: 'circle',
          paint: {
            'circle-color': [
              'case',
              // if bdc all-tech speeds are null
              [
                'any',
                ['!', ['has', 'bad']],
                ['!', ['has', 'bau']],
              ],
              'rgb(0, 255, 204)', // turquoise

              // if bdc wired speeds are null, treat as unserved
              // note: this goes up here and is separate from the "unserved" 
              // logic because otherwise there are errors checking null fields
              // below
              [
                'any',
                ['!', ['has', 'bwd']],
                ['!', ['has', 'bwu']],
              ],
              'rgb(255, 1, 52)', // red
              
              // served
              [
                'all',
                ['>=', ['get', 'bwd'], 100],
                ['>=', ['get', 'bwu'], 20],
              ],
              'rgb(146, 52, 235)', // purple
              
              // underserved
              [
                'all',
                ['>=', ['get', 'bwd'], 25],
                ['>=', ['get', 'bwu'], 3],
                [
                  'any',
                  ['<', ['get', 'bwd'], 100],
                  ['<', ['get', 'bwu'], 20],
                ],
              ],
              'rgb(242, 255, 0)', // yellow
              
              // unserved
              [
                'any',
                ['<', ['get', 'bwd'], 25],
                ['<', ['get', 'bwu'], 3],
              ],
              'rgb(255, 0, 0)', // red
              
              // other
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

      const hash = selectedFeature.properties.h;

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
