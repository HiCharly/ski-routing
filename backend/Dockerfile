FROM osrm/osrm-backend

# Copy local files into the container
COPY . /data

RUN echo "Preprocess the data"
RUN osrm-extract -p /data/profiles/ski.lua /data/map/map.osm
RUN osrm-partition /data/map/map.osm
RUN osrm-customize /data/map/map.osm

# Start OSRM backend
CMD ["osrm-routed", "--algorithm", "mld", "/data/map/map.osm"]
EXPOSE 5000