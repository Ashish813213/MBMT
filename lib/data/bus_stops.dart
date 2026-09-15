/// Real, collected MBMT stop data for the Mira-Bhayandar zone.
///
/// Ported from `MBMC.html` (86 stops: 52 unique OSM `highway=bus_stop` nodes
/// merged with the official MBMC route network) plus three Outside-MBMC
/// termini needed so every official route has >= 2 halts
/// (Thane / Andheri / Jogeshwari).
///
/// `src` marks provenance: `osm` = exact OSM GPS, `curated` = approximate
/// real position (Bhayandar-West / Uttan gap where OSM has no coverage),
/// `osm+curated` = OSM GPS merged with the official bus list.
///
/// SYNC NOTE: this table mirrors `MBMC.html` exactly, except four
/// route-integrity enrichments required by `real_routes.dart` (official
/// routes whose halts the HTML does not list them under): `20` added to
/// Bhayandar Station (W) + Rai Morva / Morva Bhat, `19`/`27`/`30` added to
/// Mira Road Station (E), `30` added to Tiwari College / Unique Garden.
/// Re-apply these when re-porting from HTML.
class RealStop {
  final String name;
  final double lat;
  final double lng;
  final String area;
  final List<String> buses;
  final String src;

  const RealStop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.area,
    required this.buses,
    required this.src,
  });

  bool get isOutside => area == 'Outside MBMC';
}

const List<RealStop> kRealStops = <RealStop>[
  // --- Bhayandar East -------------------------------------------------------
  RealStop(name: '150 Feet Road', lat: 19.3032, lng: 72.8545, area: 'Bhayandar East', buses: <String>['12', '23', '28'], src: 'curated'),
  RealStop(name: 'Azad Nagar (Bhayandar Fatak)', lat: 19.298572, lng: 72.855485, area: 'Bhayandar East', buses: <String>['9', '12', '14', '23', '26', '28'], src: 'osm'),
  RealStop(name: 'Bhayandar Pada', lat: 19.315, lng: 72.862, area: 'Bhayandar East', buses: <String>['12', '14', '28'], src: 'curated'),
  RealStop(name: 'Bhayandar Station (E)', lat: 19.311042, lng: 72.853362, area: 'Bhayandar East', buses: <String>['9', '12', '14', '23', '26', '28'], src: 'osm+curated'),
  RealStop(name: 'Delta Garden', lat: 19.3075, lng: 72.862, area: 'Bhayandar East', buses: <String>['23'], src: 'curated'),
  RealStop(name: 'Ghoddev Naka', lat: 19.303853, lng: 72.858585, area: 'Bhayandar East', buses: <String>['9', '12', '14', '23', '26', '28'], src: 'osm'),
  RealStop(name: 'Golden Nest Circle', lat: 19.295017, lng: 72.859125, area: 'Bhayandar East', buses: <String>['12', '23', '26', '28'], src: 'osm'),
  RealStop(name: 'Indralok', lat: 19.299, lng: 72.8605, area: 'Bhayandar East', buses: <String>['12', '23', '26'], src: 'curated'),
  RealStop(name: 'K.D. Empire', lat: 19.301494, lng: 72.87479, area: 'Bhayandar East', buses: <String>['21'], src: 'osm+curated'),
  RealStop(name: 'Navghar Road', lat: 19.3045, lng: 72.8585, area: 'Bhayandar East', buses: <String>['12', '14', '23'], src: 'curated'),
  RealStop(name: 'Penkarpada', lat: 19.3105, lng: 72.8665, area: 'Bhayandar East', buses: <String>['23'], src: 'curated'),
  // --- Bhayandar West -------------------------------------------------------
  RealStop(name: 'Bhayandar Station (W)', lat: 19.3128, lng: 72.8502, area: 'Bhayandar West', buses: <String>['1', '2', '3', '4', '5', '10', '10AC', '20'], src: 'curated'),
  RealStop(name: 'Jesal Park', lat: 19.3058, lng: 72.8512, area: 'Bhayandar West', buses: <String>['12', '23', '26', '28'], src: 'curated'),
  RealStop(name: 'Maxus Mall', lat: 19.3078, lng: 72.847, area: 'Bhayandar West', buses: <String>['1', '2', '5', '7', '7AC'], src: 'curated'),
  RealStop(name: 'ST Bus Stand (Bhayandar W)', lat: 19.312602, lng: 72.851916, area: 'Bhayandar West', buses: <String>['1', '2', '5', '10'], src: 'osm'),
  // --- Ghodbunder -----------------------------------------------------------
  RealStop(name: 'Ghodbunder Depot', lat: 19.2635, lng: 72.9005, area: 'Ghodbunder', buses: <String>['15', '22'], src: 'curated'),
  RealStop(name: 'Ghodbunder Village (East)', lat: 19.286897, lng: 72.893412, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Ghodbunder Village (West)', lat: 19.273, lng: 72.885, area: 'Ghodbunder', buses: <String>['22'], src: 'curated'),
  RealStop(name: 'Kashi Village', lat: 19.274301, lng: 72.885841, area: 'Ghodbunder', buses: <String>['5', '14', '25', '29'], src: 'osm'),
  RealStop(name: 'Kinara Dhaba', lat: 19.302196, lng: 72.904344, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Modern Company (Ghodbunder)', lat: 19.27, lng: 72.895, area: 'Ghodbunder', buses: <String>['22'], src: 'curated'),
  RealStop(name: 'Pathar Pada', lat: 19.321312, lng: 72.895691, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Piyushpani Parshvanath Jain Temple', lat: 19.285405, lng: 72.899376, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Royal Garden Resort', lat: 19.318248, lng: 72.898516, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Sasunavghar', lat: 19.31509, lng: 72.899751, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Shashkiy Vishram Gruh Versova', lat: 19.282445, lng: 72.906719, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Varsova / Fountain Hotel', lat: 19.284947, lng: 72.90461, area: 'Ghodbunder', buses: <String>['10', '22', '29'], src: 'osm'),
  RealStop(name: 'Western Hotel / Lakshmi Baug', lat: 19.276169, lng: 72.888795, area: 'Ghodbunder', buses: <String>['5', '14', '25', '29'], src: 'osm'),
  // --- Kashimira ------------------------------------------------------------
  RealStop(name: 'Amar Palace', lat: 19.269292, lng: 72.879061, area: 'Kashimira', buses: <String>['5', '14', '25', '29'], src: 'osm'),
  RealStop(name: 'Dahisar Check Naka', lat: 19.257806, lng: 72.871859, area: 'Kashimira', buses: <String>['11', '14'], src: 'osm+curated'),
  RealStop(name: 'Dahisar Toll Naka', lat: 19.258668, lng: 72.871704, area: 'Kashimira', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Kashigaon / Kashimira Naka', lat: 19.272653, lng: 72.882832, area: 'Kashimira', buses: <String>['5', '14', '25'], src: 'osm+curated'),
  RealStop(name: 'Kashimira Junction', lat: 19.2738, lng: 72.8725, area: 'Kashimira', buses: <String>['5', '14', '25', '29', '29AC'], src: 'curated'),
  RealStop(name: 'Mira Gaon', lat: 19.269526, lng: 72.878633, area: 'Kashimira', buses: <String>['5', '14', '25', '29'], src: 'osm'),
  RealStop(name: 'Mira Gaothan', lat: 19.267647, lng: 72.877361, area: 'Kashimira', buses: <String>['5', '14', '25', '29'], src: 'osm'),
  RealStop(name: 'MIT School Kashigaon', lat: 19.267, lng: 72.876, area: 'Kashimira', buses: <String>['27'], src: 'curated'),
  RealStop(name: 'S.K. Stone', lat: 19.2775, lng: 72.8705, area: 'Kashimira', buses: <String>['14', '15', '16', '29', '29AC'], src: 'curated'),
  RealStop(name: 'Western Park', lat: 19.2665, lng: 72.8755, area: 'Kashimira', buses: <String>['18', '24'], src: 'curated'),
  // --- Mira Road ------------------------------------------------------------
  RealStop(name: 'Asmita Jyoti / Pleasant Park', lat: 19.278, lng: 72.8795, area: 'Mira Road', buses: <String>['15'], src: 'curated'),
  RealStop(name: 'Beverly Park', lat: 19.286958, lng: 72.867461, area: 'Mira Road', buses: <String>['15', '16', '29', '29AC'], src: 'osm+curated'),
  RealStop(name: 'Cinemax / Rashmi Complex Rd', lat: 19.292223, lng: 72.871922, area: 'Mira Road', buses: <String>['15', '16'], src: 'osm+curated'),
  RealStop(name: 'Ghartan Pada', lat: 19.251943, lng: 72.867519, area: 'Mira Road', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Golden Chemicals / Thakur Mall', lat: 19.262074, lng: 72.873127, area: 'Mira Road', buses: <String>['14'], src: 'osm+curated'),
  RealStop(name: 'Green Park / Pleasant Park', lat: 19.27845, lng: 72.878842, area: 'Mira Road', buses: <String>['15'], src: 'osm'),
  RealStop(name: 'Hanuman Mandir', lat: 19.299456, lng: 72.861924, area: 'Mira Road', buses: <String>['12', '23'], src: 'osm'),
  RealStop(name: 'Hatkesh', lat: 19.279977, lng: 72.877238, area: 'Mira Road', buses: <String>['22'], src: 'osm'),
  RealStop(name: 'J.P. North City', lat: 19.287, lng: 72.869, area: 'Mira Road', buses: <String>['19'], src: 'curated'),
  RealStop(name: 'Jangid Circle', lat: 19.280336, lng: 72.870776, area: 'Mira Road', buses: <String>['22'], src: 'osm'),
  RealStop(name: 'Kanakia', lat: 19.2855, lng: 72.863, area: 'Mira Road', buses: <String>['15', '16', '29', '29AC'], src: 'curated'),
  RealStop(name: 'Mira Road Station (E)', lat: 19.2952, lng: 72.8568, area: 'Mira Road', buses: <String>['15', '16', '17', '19', '21', '22', '24', '25', '26', '27', '28', '29', '29AC', '30'], src: 'osm+curated'),
  RealStop(name: 'Mira Road Station (W)', lat: 19.2952, lng: 72.851, area: 'Mira Road', buses: <String>['24', '25'], src: 'curated'),
  RealStop(name: 'MTNL Road / Shanti Vidya Nagri', lat: 19.293, lng: 72.859, area: 'Mira Road', buses: <String>['24'], src: 'curated'),
  RealStop(name: 'Ram Nagar', lat: 19.298493, lng: 72.871904, area: 'Mira Road', buses: <String>['21'], src: 'osm'),
  RealStop(name: 'Ramdev Park', lat: 19.2995, lng: 72.8645, area: 'Mira Road', buses: <String>['12'], src: 'curated'),
  RealStop(name: 'Raval Pada', lat: 19.251793, lng: 72.867952, area: 'Mira Road', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Royal College', lat: 19.298, lng: 72.8635, area: 'Mira Road', buses: <String>['26'], src: 'curated'),
  RealStop(name: 'RTO Office Rd (Chichba Devi diversion)', lat: 19.289, lng: 72.866, area: 'Mira Road', buses: <String>['15', '22'], src: 'curated'),
  RealStop(name: 'Samrat Hotel / Mahavishnu Mandir', lat: 19.265181, lng: 72.875572, area: 'Mira Road', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Seven Squares School', lat: 19.296117, lng: 72.86428, area: 'Mira Road', buses: <String>['12', '23'], src: 'osm'),
  RealStop(name: 'Shanti Nagar (Mira Road)', lat: 19.2905, lng: 72.8535, area: 'Mira Road', buses: <String>['22', '25'], src: 'curated'),
  RealStop(name: 'Shivar Garden / Bharti Park', lat: 19.288288, lng: 72.865638, area: 'Mira Road', buses: <String>['21'], src: 'osm+curated'),
  RealStop(name: 'Silver Park (West)', lat: 19.288, lng: 72.8575, area: 'Mira Road', buses: <String>['22'], src: 'curated'),
  RealStop(name: 'Silver Park (East)', lat: 19.282083, lng: 72.874093, area: 'Mira Road', buses: <String>['22'], src: 'osm'),
  RealStop(name: 'Tiwari College / Unique Garden', lat: 19.2835, lng: 72.872, area: 'Mira Road', buses: <String>['16', '30'], src: 'curated'),
  RealStop(name: 'Umrao', lat: 19.283536, lng: 72.863838, area: 'Mira Road', buses: <String>['22'], src: 'osm'),
  RealStop(name: 'Vinay Nagar / J.P. Garden', lat: 19.2885, lng: 72.8615, area: 'Mira Road', buses: <String>['17'], src: 'curated'),
  RealStop(name: 'Vinay Nagar (East)', lat: 19.279002, lng: 72.882078, area: 'Mira Road', buses: <String>['17'], src: 'osm'),
  // --- Outside MBMC (terminus links, hidden by default) ----------------------
  RealStop(name: 'Bhagwati Hospital', lat: 19.240307, lng: 72.854574, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Borivali National Park', lat: 19.230582, lng: 72.863616, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Borivali Sukurwadi ST Bus Stop', lat: 19.231669, lng: 72.860096, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'EsselWorld / Pagoda', lat: 19.232, lng: 72.805, area: 'Outside MBMC', buses: <String>['4'], src: 'curated'),
  RealStop(name: 'Ganesh Nagar', lat: 19.244507, lng: 72.864763, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Gokul Anand Hotel (Borivali E)', lat: 19.244128, lng: 72.864255, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Gorai Khadi', lat: 19.235, lng: 72.8, area: 'Outside MBMC', buses: <String>['8'], src: 'curated'),
  RealStop(name: 'IC Colony', lat: 19.248272, lng: 72.84805, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'L.I.C. Colony', lat: 19.24262, lng: 72.85202, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Manori Tar', lat: 19.205, lng: 72.792, area: 'Outside MBMC', buses: <String>['3', '6'], src: 'curated'),
  RealStop(name: 'MHB Colony', lat: 19.230436, lng: 72.838492, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Nency Colony', lat: 19.237783, lng: 72.863484, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Omkareshwar Mandir', lat: 19.231004, lng: 72.862682, area: 'Outside MBMC', buses: <String>['14'], src: 'osm'),
  RealStop(name: 'Thane Station (E) Kopri', lat: 19.186, lng: 72.975, area: 'Outside MBMC', buses: <String>['10', '10AC', '29', '29AC'], src: 'curated'),
  RealStop(name: 'Andheri Station (E)', lat: 19.113, lng: 72.869, area: 'Outside MBMC', buses: <String>['7', '7AC', '28', '28AC'], src: 'curated'),
  RealStop(name: 'Jogeshwari Station (W)', lat: 19.135, lng: 72.847, area: 'Outside MBMC', buses: <String>['18'], src: 'curated'),
  // --- Uttan / Coastal --------------------------------------------------------
  RealStop(name: 'Chowk (Chimaji Appa Garden)', lat: 19.2895, lng: 72.7985, area: 'Uttan / Coastal', buses: <String>['1', '8', '9'], src: 'curated'),
  RealStop(name: 'Chowk Dhakka Jetty', lat: 19.292, lng: 72.793, area: 'Uttan / Coastal', buses: <String>['9'], src: 'curated'),
  RealStop(name: 'Dongri', lat: 19.2805, lng: 72.808, area: 'Uttan / Coastal', buses: <String>['2', '6'], src: 'curated'),
  RealStop(name: 'Pali Beach / Uttan Beach', lat: 19.2705, lng: 72.7955, area: 'Uttan / Coastal', buses: <String>['2'], src: 'curated'),
  RealStop(name: 'Rai Morva / Morva Bhat', lat: 19.2845, lng: 72.812, area: 'Uttan / Coastal', buses: <String>['3', '6', '20'], src: 'curated'),
  RealStop(name: 'Uttan Naka', lat: 19.2775, lng: 72.8025, area: 'Uttan / Coastal', buses: <String>['2', '6'], src: 'curated'),
];

/// Names of stops inside the MBMC zone (Outside-MBMC termini excluded).
List<String> get kZoneStopNames => kRealStops
    .where((RealStop s) => !s.isOutside)
    .map((RealStop s) => s.name)
    .toList();

/// All stop names, including Outside-MBMC termini.
List<String> get kAllStopNames =>
    kRealStops.map((RealStop s) => s.name).toList();

/// Lookup helpers (case-insensitive).
RealStop? stopByName(String name) {
  final String q = name.trim().toLowerCase();
  for (final RealStop s in kRealStops) {
    if (s.name.toLowerCase() == q) return s;
  }
  return null;
}

List<RealStop> stopsForBus(String number) {
  final String q = number.trim().toLowerCase();
  return kRealStops
      .where((RealStop s) => s.buses.any((String b) => b.toLowerCase() == q))
      .toList();
}
