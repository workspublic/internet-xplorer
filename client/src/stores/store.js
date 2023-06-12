// import { ref, computed } from 'vue';
import { defineStore } from 'pinia';

export const useStore = defineStore('store', {
  state: () => {
    return {
      selectedAddressHash: null,
      selectedAddressDetails: null,
      locationServices: null,
    };
  },
  actions: {
    async fetchAddress(hash) {
      console.log('fetch address', hash);

      const res = await fetch(
        'https://broadband-map-pa-4mxrg.ondigitalocean.app/summary_addresses?' +
        new URLSearchParams({
          hash: `eq.${hash}`,
        })
      );

      const json = await res.json();

      this.selectedAddressHash = hash;
      this.selectedAddressDetails = json[0];

      this.locationServices = null;
      this.fetchLocationServices();
    },
    async fetchLocationServices() {
      const blockId = this.selectedAddressDetails.block_id;
      const hexagonId = this.selectedAddressDetails.hexagon_id;
      
      console.log('fetch location services', blockId, hexagonId);

      const res = await fetch(
        'https://broadband-map-pa-4mxrg.ondigitalocean.app/bdc_location_services?' +
        new URLSearchParams({
          block_geoid: `eq.${blockId}`,
          h3_res8_id: `eq.${hexagonId}`,
        })
      );

      const json = await res.json();

      this.locationServices = json;
    },
  },
});
