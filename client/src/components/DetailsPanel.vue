<script>
import { mapState } from 'pinia';
import { useStore } from '@/stores/store';

export default {
  computed: {
    ...mapState(useStore, {
      addressLine1: (store) => {
        let addressLine1;

        if (store.selectedAddressDetails) {
          const { number, street, unit } = store.selectedAddressDetails;

          // TODO clean this up
          if (
            (number + street + unit).trim().length > 0 &&
            // CASE there's just a number but no street => looks weird, skip
            (number.trim().length > 0 ? street.trim().length > 0 : false)
          ) {
            addressLine1 = (
              store.selectedAddressDetails.number + ' ' +
              store.selectedAddressDetails.street
            );
          } else {
            addressLine1 = 'No address';
          }
        }

        return addressLine1;
      },
      addressLine2: (store) => {
        let addressLine2;

        if (store.selectedAddressDetails) {
          if (store.selectedAddressDetails.city.trim().length === 0) {
            return;
          }

          addressLine2 = store.selectedAddressDetails.city + ', PA'
          
          const { zip } = store.selectedAddressDetails;
          
          if (zip) {
            addressLine2 += zip;
          }
        }

        return addressLine2;
      },
      reportedServiceAllDownMax: (store) => {
        return (store.selectedAddressDetails || {}).bdc_all_down_max;
      },
      reportedServiceAllUpMax: (store) => {
        return (store.selectedAddressDetails || {}).bdc_all_up_max;
      },
      reportedServiceWiredDownMax: (store) => {
        return (store.selectedAddressDetails || {}).bdc_wired_down_max;
      },
      reportedServiceWiredUpMax: (store) => {
        return (store.selectedAddressDetails || {}).bdc_wired_up_max;
      },
      locationServicesSortedBySpeedDesc: (store) => {
        return [...(store.locationServices || [])].sort((a, b) => {
          if (
            a.bdc_wired_down_max < b.bdc_wired_down_max &&
            a.bdc_wired_up_max < b.bdc_wired_up_max
          ) {
            return -1;
          }

          if (
            a.bdc_wired_down_max > b.bdc_wired_down_max &&
            a.bdc_wired_up_max > b.bdc_wired_up_max
          ) {
            return 1;
          }

          return 0;
        });
      },
      fastestLocationService() {
        if (this.locationServicesSortedBySpeedDesc && this.locationServicesSortedBySpeedDesc.length > 0) {
          return this.locationServicesSortedBySpeedDesc[0];
        }
        
        return {};
      },
    }),
  },
  methods: {
    labelForTechCode(techCode) {
      const TECH_CODES_LABELS = {
        '0': 'Other',
        '10': 'Copper',
        '40': 'Cable',
        '50': 'Fiber',
        '60': 'Satellite',
        '61': 'Satellite',
        '70': 'Wireless',
        '71': 'Wireless',
        '72': 'Wireless',
      };

      return TECH_CODES_LABELS[techCode];
    },
  },
};
</script>

<template>
  <div class="panel">
    <h1>{{ addressLine1 }}</h1>
    <p v-if="addressLine2">{{ addressLine2 }}</p>

    <hr />

    <!-- <div class="speed-badge-row mb-4">
      <div class="speed-badge">
        <div class="speed-badge-label">
          Top Advertised Speed Down
        </div>
        <div class="speed-badge-value">{{ reportedServiceWiredDownMax }} Mbps</div>
      </div>
      
      <div class="speed-badge">
        <div class="speed-badge-label">
          Median Observed Speed Down
        </div>
        <div class="speed-badge-value">93 Mbps</div>
      </div>
    </div> -->

    <h2>Reported service</h2>

    <div v-if="reportedServiceWiredDownMax">
      <p>
        The fastest
        <strong>wireline</strong>
        service reported by providers in this census block and H3 hexagon is:
      </p>
  
      <table class="bdc-speed-table table table-dark">
        <tr>
          <th>Download</th>
          <td>{{ reportedServiceWiredDownMax }} Mbps</td>
        </tr>
        <tr>
          <th>Upload</th>
          <td>{{ reportedServiceWiredUpMax }} Mbps</td>
        </tr>
        <tr>
          <th>Provider</th>
          <td>{{ fastestLocationService.brand_name }}</td>
        </tr>
        <tr>
          <th>Technology</th>
          <td>{{ this.labelForTechCode(fastestLocationService.technology) }}</td>
        </tr>
      </table>
    </div>

    <div v-if="(!reportedServiceWiredDownMax && !reportedServiceWiredUpMax) && (reportedServiceAllDownMax && reportedServiceAllUpMax)">
      There is no reported
      <strong>wireline</strong>
      service in this H3 hexagon and census block.
    </div>

    <div v-if="!(reportedServiceAllDownMax || reportedServiceAllUpMax)">
      There is no reported service in this H3 hexagon and census block.
    </div>
  </div>
</template>

<style scoped>
.speed-badge-row {
  display: flex;
}

.speed-badge {
  border: 2px solid #fff;
  border-radius: 5px;
  padding: 5px;
}

.speed-badge:first-of-type {
  margin-right: 10px;
}

/* .speed-badge-label {
  text-transform: uppercase;
  font-size: 0.75rem;
} */

/* .speed-badge-value {
  font-size: 1.6rem;
} */

h1 {
  font-size: 2rem;
}

h2 {
  font-size: 1.6rem;
}

.bdc-speed-table {
  /* min-width: 100px; */
  font-size: 1.25rem;
}

.bdc-speed-table tr th {
  width: 130px;
}
</style>
