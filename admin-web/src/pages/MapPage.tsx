import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import { RefreshCw } from 'lucide-react';
import { getDriverPositions } from '../api/admin';
import { formatApiError } from '../api/client';
import { FitMapBounds } from '../components/FitMapBounds';
import { PageHeader } from '../components/PageHeader';
import type { DriverPosition } from '../types';
import { averageLatLng, normalizeLatLng } from '../utils/geo';
import 'leaflet/dist/leaflet.css';

const motoIcon = L.divIcon({
  className: 'map-marker-moto',
  html: '<div class="map-marker-moto__dot"></div>',
  iconSize: [28, 28],
  iconAnchor: [14, 14],
});

type MapDriver = DriverPosition & { lat: number; lng: number };

function toMapDrivers(drivers: DriverPosition[]): MapDriver[] {
  return drivers.flatMap((driver) => {
    const coords = normalizeLatLng(driver.lat, driver.lng);
    if (!coords) {
      return [];
    }
    return [{ ...driver, ...coords }];
  });
}

export function MapPage() {
  const { data = [], isLoading, isError, error, refetch, isFetching } =
    useQuery({
      queryKey: ['driver-positions'],
      queryFn: getDriverPositions,
      refetchInterval: 20_000,
    });

  const mapDrivers = useMemo(() => toMapDrivers(data), [data]);
  const center = useMemo(
    () => averageLatLng(mapDrivers.map((driver) => ({ lat: driver.lat, lng: driver.lng }))),
    [mapDrivers],
  );

  return (
    <div>
      <PageHeader
        title="Mapa en vivo"
        subtitle="Posición GPS de conductores activos"
        actions={
          <button
            type="button"
            className="btn btn--secondary"
            onClick={() => refetch()}
            disabled={isFetching}
          >
            <RefreshCw size={16} className={isFetching ? 'spin' : ''} />
            Actualizar
          </button>
        }
      />
      {isError && (
        <div className="alert alert--danger">{formatApiError(error)}</div>
      )}
      <div className="card map-card">
        {isLoading ? (
          <div className="loading-block">Cargando mapa…</div>
        ) : (
          <>
            {mapDrivers.length === 0 && (
              <div className="empty-state empty-state--map">
                <p>No hay conductores con posición GPS en este momento.</p>
              </div>
            )}
            <MapContainer
              center={center}
              zoom={13}
              className="live-map"
              scrollWheelZoom
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/">OSM</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <FitMapBounds
                points={mapDrivers.map((driver) => ({
                  lat: driver.lat,
                  lng: driver.lng,
                }))}
              />
              {mapDrivers.map((driver) => (
                <Marker
                  key={driver.id_driver}
                  position={{ lat: driver.lat, lng: driver.lng }}
                  icon={motoIcon}
                >
                  <Popup>
                    <strong>
                      {driver.name} {driver.lastname}
                    </strong>
                    <br />
                    {driver.phone}
                  </Popup>
                </Marker>
              ))}
            </MapContainer>
          </>
        )}
      </div>
    </div>
  );
}
