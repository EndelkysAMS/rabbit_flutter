export function normalizeLatLng(
  lat: number | null | undefined,
  lng: number | null | undefined,
): { lat: number; lng: number } | null {
  if (lat == null || lng == null || Number.isNaN(lat) || Number.isNaN(lng)) {
    return null;
  }

  let a = lat;
  let b = lng;

  if (Math.abs(a) > 90 && Math.abs(b) <= 90) {
    [a, b] = [b, a];
  } else if (Math.abs(b) > 90 && Math.abs(a) <= 90) {
    // already lat, lng
  } else if (Math.abs(a) > 45 && Math.abs(b) <= 45) {
    [a, b] = [b, a];
  } else if (Math.abs(b) > 45 && Math.abs(a) <= 45) {
    // already lat, lng
  }

  if (Math.abs(a) > 90 || Math.abs(b) > 180) {
    return null;
  }

  return { lat: a, lng: b };
}

export function averageLatLng(
  points: Array<{ lat: number; lng: number }>,
): { lat: number; lng: number } {
  if (points.length === 0) {
    return { lat: 9.3806, lng: -70.7349 };
  }

  const sum = points.reduce(
    (acc, point) => ({ lat: acc.lat + point.lat, lng: acc.lng + point.lng }),
    { lat: 0, lng: 0 },
  );

  return {
    lat: sum.lat / points.length,
    lng: sum.lng / points.length,
  };
}
