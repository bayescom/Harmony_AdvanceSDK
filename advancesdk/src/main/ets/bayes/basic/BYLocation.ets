import { geoLocationManager } from '@kit.LocationKit';

export class BYLocation implements geoLocationManager.Location {
  constructor(latitude: number, longitude: number) {
    this.latitude = latitude
    this.longitude = longitude
  }

  latitude: number = 0;
  longitude: number = 0;
  altitude: number = 0;
  accuracy: number = 0;
  speed: number = 0;
  timeStamp: number = 0;
  direction: number = 0;
  timeSinceBoot: number = 0;
  additions?: string[] | undefined;
  additionsMap?: Map<string, string> | undefined;
  additionSize?: number | undefined;
  altitudeAccuracy: number = 0;
  speedAccuracy: number = 0;
  directionAccuracy: number = 0;
  uncertaintyOfTimeSinceBoot: number = 0;
  sourceType: geoLocationManager.LocationSourceType = geoLocationManager.LocationSourceType.GNSS;
}