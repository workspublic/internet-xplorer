# Internet Xplorer

_work in progress_

An interactive map of broadband service in Pennsylvania built from open data

## Where did this data come from?

From free and open sources!

- Addresses points are from [OpenAddresses](https://openaddresses.io/)
  - Sourced from county governments
  - Mostly E911 addresses and/or tax parcels
  - Data is openly-licensed and free to [download]([download](https://batch.openaddresses.io/data))
- Broadband availability data is from the FCC [Broadband Data Collection](https://bdc.fcc.gov/) program
  - This is the broadband service ISPs report to the FCC
  - The FCC makes this data [public](https://broadbandmap.fcc.gov/data-download/nationwide-data?version=jun2022), aggregated to census blocks and [H3]([url](https://h3geo.org/)) resolution-8 hexagons
  - We intersect the census block and hexagon reporting areas and overlay them over OpenAddresses points to derive hyperlocal _reported_ availability
