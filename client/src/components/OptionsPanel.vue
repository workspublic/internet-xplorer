<template>
  <div class="panel">
    <section class="mb-4">
      <p>
        Every dot on this map is a
        <a href="https://openaddresses.io" target="_blank">location</a>
        used by local government, such
        as an E911 address or tax parcel.
      </p>
      <p>
        We've colored them based on the level of 
        <strong>wireline</strong>
        service
        <a href="https://www.fcc.gov/BroadbandData" target="_blank">reported</a>
        by ISPs in the same census block and
        <a href="https://h3geo.org/" target="_blank">H3</a>
        resolution-8 hexagon.
      </p>
      <p>Click on a dot to see details.</p>
    </section>

    <div class="alert alert-dark">
      🚧 We're awaiting data from some counties. Please check back soon.
    </div>

    <!-- TODO options - work in progress for now -->
    <!-- <section class="mb-5">
      <h1 class="mb-3">
        <span class="badge rounded-pill step-number">1</span>
        Geography
      </h1>
        
      <div class="option mt-2">
        <div class="option__header option--selected">Address points</div>
      </div>

      <div class="option mt-2">
        <div class="option__header option">H3 hexagons</div>
      </div>
    </section>

    <section class="mb-5">
      <h1 class="mb-3">
        <span class="badge rounded-pill step-number">2</span>
        Variable
      </h1>
        
      <div class="option">
        <div class="option__header option--selected">Service reported by providers</div>
      </div>

      <div class="option mt-2">
        <div class="option__header">Speed test results</div>
      </div>

      <div class="option mt-2">
        <div class="option__header">Reported vs. observed speeds</div>
      </div>
    </section> -->

    <section class="mb-4">
      <h1 class="mb-3">
        What do the colors mean?
      </h1>
      
      <table class="map-legend">
        <tr>
          <td>
            <span class="map-legend-circle map-legend-circle--served"></span>
          </td>
          <td>Served (100 x 20 Mbps or greater)</td>
        </tr>
        <tr>
          <td>
            <span class="map-legend-circle map-legend-circle--underserved"></span>
          </td>
          <td>Underserved (25 x 3 Mbps to 100 x 20)</td>
        </tr>
        <tr>
          <td>
            <span class="map-legend-circle map-legend-circle--unserved"></span>
          </td>
          <td>Unserved (Less than 25 x 3 Mbps)</td>
        </tr>
        <tr>
          <td>
            <span class="map-legend-circle map-legend-circle--missing"></span>
          </td>
          <td>No reported service</td>
        </tr>
      </table>
    </section>

    <hr />

    <small class="text-body-secondary">
      A project of
      <a href="https://thexlab.org/" target="_blank">The X-Lab</a>
      and
      <a href="https://workspublic.co" target="_blank">Works Public</a>. Built with
      <a href="https://github.com/workspublic/internet-xplorer" target="_blank">open source</a>
      code and 
      <a href="https://github.com/workspublic/internet-xplorer#where-did-this-data-come-from" target="_blank">open data</a>.
      Free for non-commercial use.
    </small>
  </div>
</template>

<style scoped>
h1 {
  font-size: 1.25rem;
}

/* options styles - still wip */
/* .step-number {
  background-color: rgb(13, 110, 253);
  margin-right: 0.5rem;
}

.option {
  width: 100%;
}

.option__header {
  border: 2px solid #333;
  border-radius: 5px;
  padding: 0.75rem;
}

.option__body {
  border: 2px solid #ebebeb;
  border-top-width: 0;
  padding: 0.75rem;
}

.option--selected {
  border-color: #0c7bdc !important;
}

.option--disabled {
  background-color: #eee;
}

.options-label {
  text-transform: uppercase;
  letter-spacing: 0.04rem;
  font-size: 0.8rem;
  color: #555;
} */

.map-legend-circle {
  height: 1rem;
  width: 1rem;
  border-radius: 50%;
  display: inline-block;
}

.map-legend td:first-of-type {
  padding-right: 0.5rem;
}

.map-legend td {
  padding-bottom: 0.4rem;
}

.map-legend-circle--served {
  background-color: rgb(146, 52, 235);
}
.map-legend-circle--underserved {
  background-color: rgb(242, 255, 0);
}
.map-legend-circle--unserved {
  background-color: rgb(255, 1, 52);
}

.map-legend-circle--missing {
  background-color: rgb(0, 255, 204);
}
</style>
