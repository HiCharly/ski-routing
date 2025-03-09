# Introduction
The aim of this project is to explore routing with a real need: improving the skier's experience at [Font Romeu Pyrenees 2000](https://www.altiservice.com/font-romeu-pyrenees-2000).

Will I be able to draw a map with all ski pistes and ski lifts?

Will I be able to recommend a route from point A to point B?

Will I be able to take into account the difficulty of the slopes and the level of skiers?

## Data Sources
This project is based on data from OpenStreetMap and uses the following GitHub projects:
- [osrm/osrm-backend](https://github.com/Project-OSRM/osrm-backend)
- [osrm/osrm-frontend](https://github.com/Project-OSRM/osrm-frontend)

The osrm-backend "ski" profile has been adapted from [FreemapSlovakia/freemap-routing](https://github.com/FreemapSlovakia/freemap-routing/blob/master/master-ski.lua)

## Build and start the project
```bash
docker-compose up -d --build
```
- Backend listen on port 5000
- Frontend listen on port 9966 : http://127.0.0.1:9966